# helper functions for file templates

#' add lines for data load from file
#'
#' @inheritParams addFilePath
#' @inheritParams addFileImport
addDataLoadForFiles <- function(fileName, locationType, remotePath, sheetName){
  c(
    "# set path to file",
    addFilePath(locationType = locationType, fileName = fileName, remotePath = remotePath),
    "",
    "# specify import options",
    addFileImport(fileName = fileName, sheetName = sheetName),
    ""
  )
}

#' Add File Path
#'
#' @param locationType type of location, any of "local" or "remote".
#' OPTION 1: "local" (add the file to inst/extdata/).
#' OPTION 2: "remote" (load data from remote path).
#' @param filename name of file, e.g. "data.csv", "14SEA_Full_Dataset_2017-01-29.xlsx"
#' @param remotePath path to remote file, if locationType == "remote",
#' e.g. "http://www.14sea.org/img/"
addFilePath <- function(locationType, fileName, remotePath = NULL){
  if (!(locationType %in% c("local", "remote")))
    stop("locationType not found. Only use \"local\" or \"remote\".")

  if (locationType == "local") {
    filePath <- paste0("dataFile <- system.file(\"extdata\", \"",
                       fileName, "\" , package = \"MpiIsoData\")")
  }

  if (locationType == "remote") {
    if (is.null(remotePath))
      stop("Provide a \"remotePath\" for \"remote\" locations.")
    filePath <- paste0("dataFile <- ", remotePath, fileName)
  }

  filePath
}

#' Paste file import
#'
#' @param filename name of file, e.g. "data.csv", "14SEA_Full_Dataset_2017-01-29.xlsx"
#' @param sheetName name of the table sheet for xlsx files, e.g. "14C Dates"
addFileImport <- function(fileName, sheetName = NULL){
  fileType <- tools::file_ext(fileName)

  if (!(fileType %in% c("csv", "xlsx")))
    stop("File type not supported. Only use \".csv\" or \".xlsx\" files.")

  if (fileType == "csv") {
    fileImport <- c(
      "isoData <- read.csv(",
      "   file = dataFile, ",
      "   stringsAsFactors = FALSE, ",
      "   check.names = FALSE, ",
      "   na.strings = c(\"\", \"NA\"), ",
      "   strip.white = TRUE",
      ")"
    )
  }

  if (fileType == "xlsx") {
    if (is.null(sheetName)) stop("Provide a \"sheetName\" when using .xlsx files.")

    fileImport <- c(
      "isoData <- read.xlsx(",
      "   xlsxFile = dataFile, ",
      paste("   sheet = \"", sheetName, "\""),
      ")"
    )
  }

  fileImport
}
