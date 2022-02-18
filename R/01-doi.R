addDOIs <- function(df) {
    df <- fillDOI(df, "databaseReference", "databaseDOI", "databaseDOIAuto")
    df <- fillDOI(df, "compilationReference", "compilationDOI", "compilationDOIAuto")
    df <- fillDOI(df, "originalDataReference", "originalDataDOI", "originalDataDOIAuto")

    df
}

lookupReference <- function(txt) {
    logging("Looking up %s", txt)
    url <- "https://api.crossref.org/works"
    res <- httr::GET(url, query = list(query.bibliographic = txt, rows = 1))
    data <- httr::content(res)

    doi <- try(data$message$items[[1]]$URL)
    if (inherits(doi, "try-error")) {
        doi <- NA
        logging("No DOI found")
    } else {
        logging("Found DOI %s", doi)
    }

    doi
}

lookupRefs <- function(txt) {
    refs <- unique(txt)
    dois <- unlist(lapply(refs, lookupReference))

    orig <- data.frame(ref = txt)
    df <- data.frame(ref = refs, doi = dois)

    merge(orig, df)
}

getCurrentDOIMapping <- function() {
    vars <- c("databaseReference", "databaseDOI",
            "compilationReference", "compilationDOI",
            "originalDataReference", "originalDataDOI")

    # no db access during test
    if (isTest()) df <- data.frame()
    else {
        df <- try({
            sendQueryMPI(dbtools::Query("select concat(source, '-', id) as id, variable, value from extraCharacter where variable in {{ dbtools::sqlInChars(vars)}};", vars = vars))
        })
        if (inherits(df, "try-error")) {
            df <- data.frame()
        }
    }

    if (nrow(df) == 0) return(
        data.frame(
            id = character(0),
            databaseReference = character(0),
            databaseDOI = character(0),
            compilationReference = character(0),
            compilationDOI = character(0),
            originalDataReference = character(0),
            originalDataDOI = character(0)
        )
    )

    tidyr::spread(df, key = "variable", value = "value")
}

fillDOI <- function(df, refField, doiField, autoField) {
    logging("Filling DOI for %s", refField)
    filled <- df[!isEmpty(df[[doiField]]), ]

    empty <- isEmpty(df[[doiField]]) & !isEmpty(df[[refField]])

    # fill in from already present refs + doi
    found <- match(df[empty, ][[refField]], filled[[refField]])

    for (i in seq_along(found)) {
        if (!is.na(found[i])) {
            df[empty, ][i, doiField] <- filled[found[i], doiField]
            df[empty, ][i, autoField] <- TRUE
        }
    }

    # still empty
    empty <- isEmpty(df[[doiField]]) & !isEmpty(df[[refField]])

    # fill in from refs + doi in DB
    dbMapping <- getCurrentDOIMapping()
    found <- match(df[empty, ][[refField]], dbMapping[[refField]])

    for (i in seq_along(found)) {
        if (!is.na(found[i])) {
            df[empty, ][i, doiField] <- dbMapping[found[i], doiField]
            df[empty, ][i, autoField] <- TRUE
        }
    }

    # still empty
    empty <- isEmpty(df[[doiField]]) & !isEmpty(df[[refField]])

    if (sum(empty) > 0) {
        doi <- lookupRefs(df[[refField]][empty])

        df[[doiField]][empty] <- doi$doi[match(df[empty, ][[refField]], doi$ref)]
        df[[autoField]][empty] <- TRUE
    }

    df
}
