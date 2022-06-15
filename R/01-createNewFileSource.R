#' Create New File Source
#'
#' Creates a script for a new data source from a local or remote file. Only "csv" or "xlsx" files
#' are supported.
#'
#' @param dbName (character) name of the new database source, e.g. "14CSea", "CIMA", "IntChron",
#' "LiVES"
#' @param datingType (character) dating type for the database, e.g. "radiocarbon" or "expert"
#' @param coordType (character) coord type for the database, e.g. "decimal degrees"
#' @param fileName name of file, e.g. "data.csv", "14SEA_Full_Dataset_2017-01-29.xlsx"
#' @param locationType type of location, any of "local" or "remote".
#' OPTION 1: "local" (add the file to inst/extdata/).
#' OPTION 2: "remote" (load data from remote path).
#' @param remotePath path to remote file, if locationType == "remote",
#' e.g. "http://www.14sea.org/img/"
#' @param sheetName name of the table sheet for xlsx files, e.g. "14C Dates"
#' @param descriptionCreator (character) command that creates the description, e.g. pasting data
#'  columns "var1" and "var2": "paste(isoData$var1, isoData$var2)"
#' @param scriptFolder (character) place to store the scripts, usually in the R folder (except
#' for tests).
#' @export
createNewFileSource <- function(dbName,
                                fileName,
                                datingType,
                                coordType,
                                locationType,
                                remotePath = NULL,
                                sheetName = NULL,
                                descriptionCreator = NULL,
                                scriptFolder = "R") {

  # check for duplicated db names
  if (formatDBName(dbName) %in% formatDBName(dbnames()))
    stop(paste0("dbName = ", dbName, " already exists in (",
               paste0(dbnames(), collapse = ", "),
               "). Please provide case-insensitive unique names."))

  dbName <- formatDBName(dbName)

  dbScript <- pasteScriptBegin(dbName = dbName)

  dbScript <- c(
    dbScript,
    addDataLoadForFiles(
      locationType = locationType,
      fileName = fileName,
      remotePath = remotePath,
      sheetName = sheetName
    )
  )

  dbScript <- c(
    dbScript,
    addDescription(descriptionCreator = descriptionCreator),
    pasteScriptEnd()
  )

  writeLines(dbScript, con = file.path(scriptFolder, paste0("02-", dbName, ".R")))

  updateDatabaseList(dbName = dbName,
                     datingType = datingType,
                     coordType = coordType,
                     scriptFolder = file.path(scriptFolder))
}


#' Paste Script Begin
#'
#' Opening lines of the script.
#' @inheritParams createNewFileSource
pasteScriptBegin <- function(dbName) {
  c(
    "# Template to set up a new data source",
    paste0("extract.", dbName, " <- function(x){")
  )
}


#' Paste Script End
#'
#' Closing lines of the script.
pasteScriptEnd <- function() {
  c(
    "",
    "# pass isoData to next steps (no need to change anything here)",
    "  x$dat <- isoData",
    "",
    "  x",
    "}",
    ""
  )
}


#' Add Data Load For Files
#'
#' add lines to the script for data load from file
#'
#' @inheritParams createNewFileSource
addDataLoadForFiles <-
  function(fileName,
           locationType,
           remotePath = NULL,
           sheetName = NULL) {
    c(
      "# set path to file",
      addFilePath(
        locationType = locationType,
        fileName = fileName,
        remotePath = remotePath
      ),
      "# specify import options",
      addFileImport(fileName = fileName, sheetName = sheetName),
      ""
    )
  }

#' Add File Path
#'
#' @inheritParams createNewFileSource
addFilePath <- function(fileName, locationType, remotePath = NULL) {
  if (!(locationType %in% c("local", "remote")))
    stop("locationType not found. Only use \"local\" or \"remote\".")

  filePath <- "  dataFile <- "
  if (locationType == "local") {
    filePath <- paste0(
      filePath,
      "system.file(\"extdata\", \"",
      fileName,
      "\" , package = \"MpiIsoData\")"
    )
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
#' @inheritParams createNewFileSource
addFileImport <- function(fileName, sheetName = NULL) {
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


#' Add description And Pass Data
#'
#' @param descriptionCreator (character) command that creates the description, e.g. pasting data
#'  columns "var1" and "var2": "paste(isoData$var1, isoData$var2)"
addDescription <- function(descriptionCreator = NULL) {
  if (is.null(descriptionCreator))
    return(NULL)

  c("  # create Description",
    paste0("  isoData$description <- ", descriptionCreator))
}
