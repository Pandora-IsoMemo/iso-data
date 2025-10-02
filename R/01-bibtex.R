split_doi <- function(doi_url) {
  prefix <- sub("^(?i)(https?://(?:dx\\.)?doi\\.org/).*", "\\1", doi_url, perl = TRUE)
  doi    <- sub("^(?i)https?://(?:dx\\.)?doi\\.org/", "", doi_url, perl = TRUE)

  # if a prefix equals the doi it means no prefix was found
  prefix[which(prefix == doi)] <- ""

  list(prefix = prefix, doi = doi)
}

safe_call <- function(fun, ..., tries = 5, base_sleep = 0.5) {
  last_error <- NULL
  for (i in seq_len(tries)) {
    out <- try(fun(...), silent = TRUE)
    if (!inherits(out, "try-error")) return(out)
    last_error <- out
    Sys.sleep(base_sleep * 2^(i - 1))
  }
  stop(sprintf("Call failed after retries: %s", conditionMessage(last_error)))
}

# Helper to add a bibtex citation column for a given DOI column
add_bibtex_column <- function(
  df,
  doi_column,
  citation_column = "citation",
  citationformat = "bibtex",
  citationstyle = "apa"
) {
  unique_doi_url <- unique(df[[doi_column]])
  unique_doi_url <- unique_doi_url[!is.na(unique_doi_url) & unique_doi_url != ""]

  log_str <- sprintf(
    "Adding BibTeX citations for %s. Found %i unique DOI%s ",
    doi_column,
    length(unique_doi_url),
    ifelse(length(unique_doi_url) != 1, "s", "")
  )
  last_error <- NULL

  # split "http://dx.doi.org/" or "https://doi.org/" prefix if present from DOI
  splitted_doi <- split_doi(unique_doi_url)

  df[[citation_column]] <- NA_character_
  for (i in seq_along(unique_doi_url)) {
    doi <- splitted_doi$doi[i]
    citation <- tryCatch({
      safe_call(rcrossref::cr_cn, doi = doi, format = citationformat, style = citationstyle)
    }, error = function(e) {
      msg <- conditionMessage(e)
      last_error <<- paste("Last Bibtex error: Failed for DOI:", doi, "with message:", msg)
      NULL
    })

    if (!is.null(citation)) {
      index <- !is.na(df[[doi_column]]) & df[[doi_column]] == paste0(splitted_doi$prefix[i], doi)
      if (any(index)) {
        df[index, citation_column] <- rep(citation, sum(index))
        log_str <- paste0(log_str, ".")
      } else {
        log_str <- paste0(log_str, "e")
      }
    } else {
      log_str <- paste0(log_str, "n")
    }
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
