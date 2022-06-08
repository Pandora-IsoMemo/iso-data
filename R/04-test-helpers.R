#' Clean Up Script
#'
#' @param script (character) script to extract data
cleanUpScript <- function(script) {
  script <- script[!grepl("^#|^..#", script)]    # remove all comments from script
  script <- script[script != ""]                 # remove empty lines from script
}

#' Get Folder For Tested Templates
#'
getFolderForTestedTemplates <- function() {
  testthat::test_path()
}
