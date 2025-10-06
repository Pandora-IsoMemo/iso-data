retry_get_text <- function(url, ..., tries = 5, base_sleep = 0.5) {
  last <- NULL
  for (i in seq_len(tries)) {
    res <- try(GET(url = url, ...), silent = TRUE)
    if (!inherits(res, "try-error") && !http_error(res)) {
      # Always parse as text; don't trust Content-Type equality
      return(content(res, as = "text", encoding = "UTF-8"))
    }
    last <- res
    Sys.sleep(base_sleep * 2^(i - 1))
  }
  if (inherits(last, "response")) {
    stop(sprintf("GET %s failed: HTTP %s", url, status_code(last)))
  } else {
    stop(sprintf("GET %s failed: %s", url, as.character(last)))
  }
}

# -------- 2) BibTeX via DOI content negotiation (preferred) ----------
bibtex_via_doi_org <- function(doi) {
  d <- strip_doi(doi)
  url <- sprintf("https://doi.org/%s", URLencode(d, reserved = TRUE))
  retry_get_text(url, add_headers(Accept = "application/x-bibtex"))
}

# -------- 3) Fallback: Crossref transform endpoint ----------
bibtex_via_crossref_transform <- function(doi) {
  d <- strip_doi(doi)
  # Either Accept header or content-type suffix works; do both for safety
  url <- sprintf("https://api.crossref.org/works/%s/transform/application/x-bibtex",
                 URLencode(d, reserved = TRUE))
  retry_get_text(url, add_headers(Accept = "application/x-bibtex"))
}

# -------- 4) Fallback: REST JSON -> minimal BibTeX ----------
bibtex_from_rest_json <- function(doi) {
  d <- strip_doi(doi)
  url <- sprintf("https://api.crossref.org/works/%s", URLencode(d, reserved = TRUE))
  body <- retry_get_text(url)
  w <- fromJSON(body, simplifyVector = TRUE)$message
  if (is.null(w)) stop("No Crossref message payload")

  # Build a simple BibTeX (you can enrich as needed)
  yr <- tryCatch(w$issued$`date-parts`[[1]][1], error = function(e) NA)
  authors <- tryCatch({
    if (length(w$author)) {
      paste(vapply(w$author, function(a) paste(a$family, a$given), ""), collapse = " and ")
    } else ""
  }, error = function(e) "")
  key <- gsub("[^A-Za-z0-9]+", "_", paste0(w$author[[1]]$family, "_", yr))

  paste0("@article{", key, ",\n",
         "  title={", w$title[[1]], "},\n",
         "  author={", authors, "},\n",
         "  journal={", if (length(w$`container-title`)) w$`container-title`[[1]] else "", "},\n",
         "  year={", yr, "},\n",
         "  doi={", w$DOI, "}\n",
         "}")
}

# -------- Unified BibTeX getter ----------
get_bibtex_direct <- function(doi) {
  tryCatch(
    bibtex_via_doi_org(doi),
    error = function(e1) {
      tryCatch(
        bibtex_via_crossref_transform(doi),
        error = function(e2) bibtex_from_rest_json(doi)
      )
    }
  )
}


safe_call <- function(fun, ..., tries = 5, base_sleep = 0.5) {
  last_error <- NULL
  for (i in seq_len(tries)) {
    out <- tryCatch(
      fun(...),
      error = function(e) {
        last_error <<- e
        NULL
      }
    )
    if (!is.null(out)) return(out)
    Sys.sleep(base_sleep * 2^(i - 1))
  }
  stop(sprintf("Call failed after %i retries: %s", tries, conditionMessage(last_error)))
}

# Utility: normalize "https://doi.org/..." -> bare DOI
strip_doi <- function(x) sub("^https?://(dx\\.)?doi\\.org/", "", x, ignore.case = TRUE)

# Helper to add a bibtex citation column for a given DOI column
add_bibtex_column <- function(
  df,
  doi_column,
  citation_column = "citation"
) {
  unique_doi_url <- unique(df[[doi_column]])
  unique_doi_url <- unique_doi_url[!is.na(unique_doi_url) & nzchar(unique_doi_url)]
  splitted <- strip_doi(unique_doi_url)

  df[[citation_column]] <- NA_character_
  last_error <- NULL
  log_str <- sprintf(
    "Adding BibTeX citations for %s. Found %i unique DOI%s ",
    doi_column,
    length(unique_doi_url),
    ifelse(length(unique_doi_url) != 1, "s", "")
  )

  # loop over unique DOIs and fetch citation
  for (i in seq_along(unique_doi_url)) {
    doi_full <- unique_doi_url[i]
    doi <- splitted[i]
    citation <- tryCatch(
      safe_call(get_bibtex_direct, doi = doi),
      error = function(e) {
        msg <- conditionMessage(e)
        last_error <<- paste("Last Bibtex error: Failed for DOI:", doi, "with message:", msg)
        NULL
      }
    )

    if (!is.null(citation)) {
      index <- !is.na(df[[doi_column]]) & df[[doi_column]] == doi_full
      if (any(index)) {
        df[index, citation_column] <- rep(citation, sum(index))
        log_str <- paste0(log_str, ".")
      } else {
        log_str <- paste0(log_str, "e")
      }
    } else {
      log_str <- paste0(log_str, "n")
    }

    # gentle throttle to avoid bursts from container IP
    Sys.sleep(0.15)
  }

  logging(log_str)
  if (!is.null(last_error)) logging(last_error)
  return(df)
}

# Add bibtex columns for all reference types (database, compilation, originalData)
add_bibtex <- function(df) {
  df <- add_bibtex_column(df, "databaseDOI", "databaseBibtex")
  df <- add_bibtex_column(df, "compilationDOI", "compilationBibtex")
  df <- add_bibtex_column(df, "originalDataDOI", "originalDataBibtex")
  df
}
