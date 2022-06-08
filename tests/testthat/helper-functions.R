# This script is run automatically when testthat::test_dir("tests") is called.

#' Clean Up Script
#'
#' @param (character) script to extract data
cleanUpScript <- function(script) {
  script <- script[!grepl("^#|^..#", script)]    # remove all comments from script
  script <- script[script != ""]                 # remove empty lines from script
}
