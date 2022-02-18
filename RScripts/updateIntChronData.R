#' updateIntChron
#' Scrapes the IntChron data from the given URL.

library(magrittr)

require(rvest)
require(dplyr)
require(purrr)

URL <- "http://intchron.org/doi"
filePath <- "inst/extdata/IntChron.csv"

message("IntChron data update in progress.. this may take a couple of minutes.")

# 01: Get the URLs of the data sets ------------------------------------------------------

doi <- xml2::read_html(URL)

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

intchron <- data$url %>%
  purrr::map(., xml2::read_html) %>%
  purrr::map(., rvest::html_table, header = TRUE, fill = TRUE) %>%
  purrr::map(., c(1))

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

data.table::fwrite(intchron,
                   file = filePath,
                   na = "NA",
                   sep = ";")

