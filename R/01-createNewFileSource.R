#' Create New File Source
#'
#' Creates a script for a new data source from a local or remote file. Only "csv" or "xlsx" files
#' are supported.
#'
#' @param dataSourceName (character) name of the new database source, e.g. "14CSea", "CIMA", "IntChron",
#' "LiVES"
#' @param datingType (character) dating type for the database, e.g. "radiocarbon" or "expert"
#' @param coordType (character) coord type for the database, e.g. "decimal degrees"
#' @param locationType type of location, any of "local" or "remote".
#' OPTION 1: "local" (add the file to inst/extdata/).
#' OPTION 2: "remote" (load data from remote path).
#' @param fileName name of file, e.g. "data.csv", "14SEA_Full_Dataset_2017-01-29.xlsx"
#' @param remotePath path to remote file, if locationType == "remote",
#' e.g. "http://www.14sea.org/img/"
#' @param sheetNumber number of the table sheet for xlsx files, e.g. "14C Dates"
#' @param scriptFolder (character) place to store the scripts, usually in the R folder (except
#' for tests).
#' @export
createNewFileSource <- function(dataSourceName,
                                datingType,
                                coordType,
                                locationType,
                                fileName,
                                remotePath = NULL,
                                sheetNumber = 1,
                                scriptFolder = "R") {
  # check for duplicated db names
  if (formatDBName(dataSourceName) %in% formatDBName(dbnames()))
    stop(
      paste0(
        "dataSourceName = ",
        dataSourceName,
        " already exists in (",
        paste0(dbnames(), collapse = ", "),
        "). Please provide case-insensitive unique names without special characters."
      )
    )

  dataSourceName <- formatDBName(dataSourceName)

  filePath <- addFilePath(fileName = fileName,
                          locationType = locationType,
                          remotePath = remotePath)

  fileImport <- addFileImport(fileType = tools::file_ext(fileName),
                              sheetNumber = sheetNumber)

  scriptTemplate <-
    file.path(getTemplateDir(), "template-file-source.R") %>%
    readLines()

  dbScript <- tmpl(
    paste0(scriptTemplate, collapse = "\n"),
    dataSourceName = dataSourceName,
    filePath = filePath,
    fileImport = fileImport
  ) %>%
    as.character()
logging("Creating new file: %s", file.path(scriptFolder, paste0("02-", dataSourceName, ".R")))
  writeLines(dbScript, con = file.path(scriptFolder, paste0("02-", dataSourceName, ".R")))

  updateDatabaseList(
    dataSourceName = dataSourceName,
    datingType = datingType,
    coordType = coordType,
    scriptFolder = file.path(scriptFolder)
  )
}

#' Get Template directory
#'
getTemplateDir <- function() {
  file.path(system.file(package = "MpiIsoData"), "templates")
}

#' Add File Path
#'
#' @inheritParams createNewFileSource
addFilePath <- function(fileName, locationType, remotePath = NULL) {
  if (!(locationType %in% c("local", "remote")))
    stop("locationType not found. Only use \"local\" or \"remote\".")

  if (locationType == "remote") {
    if (is.null(remotePath))
      stop("Provide a \"remotePath\" for \"remote\" locations.")

    path <- remotePath
  } else {
    # locationType == "local"
    path <- "system.file(\"extdata\", package = \"MpiIsoData\")"
  }

  tmpl(
    "file.path({{ path }}, \"{{ fileName }}\")",
    path = path,
    fileName = fileName
  ) %>%
    as.character()
}


#' Paste file import
#'
#' @inheritParams createNewFileSource
#' @param fileType (character) type of file, "csv" or "xlsx" only
addFileImport <- function(fileType, sheetNumber = 1) {
  if (!(fileType %in% c("csv", "xlsx")))
    stop("File type not supported. Only use \".csv\" or \".xlsx\" files.")

  if (fileType == "csv") {
    fileImport <-
      paste0(
        "read.csv(file = dataFile, stringsAsFactors = FALSE, check.names = FALSE, ",
        "na.strings = c(\"\", \"NA\"), strip.white = TRUE)"
      )
  } else {
    # fileType == "xlsx"
    fileImport <-
      tmpl("read.xlsx(xlsxFile = dataFile, sheet = {{ sheetNumber }})",
           sheetNumber = sheetNumber) %>%
      as.character()
  }

  fileImport
}
