# helper functions for file templates

#' add lines for data load from file
#'
#' @param fileName name of file, e.g. "data.csv", "14SEA_Full_Dataset_2017-01-29.xlsx"
#' @param locationType type of location, any of "local" or "remote".
#' OPTION 1: "local" (add the file to inst/extdata/).
#' OPTION 2: "remote" (load data from remote path).
#' @param remotePath path to remote file, if locationType == "remote",
#' e.g. "http://www.14sea.org/img/"
#' @param sheetName name of the table sheet for xlsx files, e.g. "14C Dates"
addDataLoadForFiles <- function(fileName, locationType, remotePath = NULL, sheetName = NULL){
  c(
    "# set path to file",
    addFilePath(locationType = locationType, fileName = fileName, remotePath = remotePath),
    "# specify import options",
    addFileImport(fileName = fileName, sheetName = sheetName),
    ""
  )
}

#' Add File Path
#'
#' @inheritParams addDataLoadForFiles
addFilePath <- function(fileName, locationType, remotePath = NULL){
  if (!(locationType %in% c("local", "remote")))
    stop("locationType not found. Only use \"local\" or \"remote\".")

  filePath <- "  dataFile <- "
  if (locationType == "local") {
    filePath <- paste0(filePath,
                       "system.file(\"extdata\", \"", fileName, "\" , package = \"MpiIsoData\")")
  }

  if (locationType == "remote") {
    if (is.null(remotePath))
      stop("Provide a \"remotePath\" for \"remote\" locations.")
    filePath <- paste0(filePath, "\"", remotePath, fileName, "\"")
  }

  filePath
}

#' Paste file import
#'
#' @inheritParams addDataLoadForFiles
addFileImport <- function(fileName, sheetName = NULL){
  fileType <- tools::file_ext(fileName)

  if (!(fileType %in% c("csv", "xlsx")))
    stop("File type not supported. Only use \".csv\" or \".xlsx\" files.")

  if (fileType == "csv") {
    fileImport <- c(
      "  isoData <- read.csv(file = dataFile, stringsAsFactors = FALSE, ",
      "                      check.names = FALSE, na.strings = c(\"\", \"NA\"), ",
      "                      strip.white = TRUE)"
    )
  }

  if (fileType == "xlsx") {
    if (!is.null(sheetName)) {
      fileImport <-
        paste0("  isoData <- read.xlsx(xlsxFile = dataFile, sheet = \"",
               sheetName,
               "\")")
    } else {
      fileImport <- "  isoData <- read.xlsx(xlsxFile = dataFile)"
    }
  }

  fileImport
}
