
# Helper to add a bibtex citation column for a given DOI column
add_bibtex_column <- function(
  df,
  doi_column,
  citation_column = "citation",
  citationformat = "bibtex",
  citationstyle = "apa"
) {
  logging("Adding BibTeX citations for %s", doi_column)
  unique_doi_url <- unique(df[[doi_column]])

  # split "http://dx.doi.org/" or "https://doi.org/" prefix if present from DOI
  prefix <- sub("^(?i)(https?://(?:dx\\.)?doi\\.org/).*", "\\1", unique_doi_url, perl = TRUE)
  dois   <- sub("^(?i)https?://(?:dx\\.)?doi\\.org/", "", unique_doi_url, perl = TRUE)

  df[[citation_column]] <- NA_character_
  lapply(seq_along(unique_doi_url), function(i) {
    doi <- dois[i]
    if (is.na(doi) || doi == "") {
      return(NULL)
    }
    citation <- tryCatch({
      rcrossref::cr_cn(doi = doi, format = citationformat, style = citationstyle)
    }, error = function(e) {
      warning(paste("Failed to retrieve citation for DOI:", doi))
      return(NULL)
    })

    if (!is.null(citation)) {
      index <- !is.na(df[[doi_column]]) & df[[doi_column]] == paste0(prefix[i], doi)
      df[index, citation_column] <<- citation
    }
  })

  return(df)
}

# Add bibtex columns for all reference types (database, compilation, originalData)
add_bibtex <- function(df) {
  df <- add_bibtex_column(df, "databaseDOI", "databaseBibtex")
  df <- add_bibtex_column(df, "compilationDOI", "compilationBibtex")
  df <- add_bibtex_column(df, "originalDataDOI", "originalDataBibtex")
  df
}
