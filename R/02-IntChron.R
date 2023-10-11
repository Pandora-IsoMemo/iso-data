extract.IntChron <- function(x){
  isoData <- getIntChron()

  isoData$description <- paste(isoData$sample, ",", isoData$material, ",", isoData$species)

  x$dat <- isoData

  x
}

getIntChron <- function(){
  # updateIntChron
  # Scrapes the IntChron data from the given URL.

  URL <- "https://intchron.org/doi"

  message("IntChron data update in progress.. this may take a couple of minutes.")

  # 01: Get the URLs of the data sets ------------------------------------------------------

  doi <- URL %>% GET(., timeout(30)) %>% xml2::read_html()

  type <- doi %>%
    rvest::html_nodes("a.more") %>%
    rvest::html_text()

  url <- doi %>%
    rvest::html_nodes("a.more") %>%
    rvest::html_attr("href")

  data <- dplyr::tibble(url, type) %>%
    dplyr::filter(type == "data")

  rm(doi, type, url)

  # 02: Extract HTML Tables from URLs ------------------------------------------------------

  readIt <- function(x, verbose = TRUE){
    if (verbose) cat("Reading ", x, "\n")
    x %>% trimws() %>% GET(., timeout(30)) %>% xml2::read_html(x)
  }

  if (isTest()) data <- data[sample(1:nrow(data), 5), ]

  intchron <- data$url %>%
    purrr::map(., readIt, verbose = TRUE) %>%
    purrr::map(., rvest::html_table, header = TRUE, fill = TRUE) %>%
    purrr::map(., c(1)) %>%
    purrr::keep(function(x) is.data.frame(x))

  rm(data)

  # 03: Cleaning --------------------------------------------------------------------------
  intchron <-  intchron %>%
    purrr::map(., function(x) x[, names(x) != ""]) %>%
    purrr::map(., function(x)  x %>%
                                 dplyr::mutate_all(., dplyr::funs(as.character))) %>%
    unique

  # 04: Merge -----------------------------------------------------------------------------

  intchron <- intchron %>%
    dplyr::bind_rows(.)

  # 05: Load Data / Export ---------------------------------------------------------------

  intchron
}
