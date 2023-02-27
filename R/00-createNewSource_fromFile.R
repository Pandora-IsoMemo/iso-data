#' Create New File Source
#'
#' Creates a script for a new data source from a local or remote file. Only "csv" or "xlsx" files
#' are supported.
#'
#' @inheritParams updateDatabaseList
#' @param locationType type of location, any of "local" or "remote".
#' OPTION 1: "local" (the file must be available under inst/extdata/).
#' OPTION 2: "remote" (load data from remote path).
#' @param fileName name of file, e.g. "data.csv", "14SEA_Full_Dataset_2017-01-29.xlsx"
#' @param remotePath path to remote file, if locationType == "remote",
#' e.g. "http://www.14sea.org/img/"
#' @param sheetNumber (integer) number of the table sheet for xlsx files, e.g. "14C Dates"
#' @param sep (character) field separator character
#' @param dec (character) the character used in the file for decimal points
#' @param isTest (logical) TRUE if automatic testing
#' @export
createNewFileSource <- function(dataSourceName,
                                datingType,
                                coordType,
                                mappingName,
                                locationType,
                                fileName,
                                remotePath = NULL,
                                sheetNumber = 1,
                                sep = ";",
                                dec = ",",
                                scriptFolder = "R",
                                isTest = FALSE) {
  # 1. check for duplicated data source names
  checkDataSourceName(dataSourceName, isTest = isTest)

  # 2. create script for file source ----
  scriptTemplate <-
    file.path(getTemplateDir(), "template-file-source.R") %>%
    readLines()

  filePath <- addFilePath(fileName = fileName,
                          locationType = locationType,
                          remotePath = remotePath)
  fileImport <- addFileImport(
    fileType = tools::file_ext(fileName),
    sheetNumber = sheetNumber,
    sep = sep,
    dec = dec
  )

  dbScript <- tmpl(
    paste0(scriptTemplate, collapse = "\n"),
    dataSourceName = dataSourceName %>%
      formatDataSourceName(),
    filePath = filePath,
    fileImport = fileImport
  ) %>%
    as.character()

  scriptName <-
    paste0("02-",
           mappingName,
           "_",
           dataSourceName %>% formatDataSourceName(),
           ".R")
  logging("Creating new file: %s", file.path(scriptFolder, scriptName))
  writeLines(dbScript, con = file.path(scriptFolder, scriptName))

  # 3. update list of databases ----
  updateDatabaseList(
    dataSourceName = dataSourceName,
    datingType = datingType,
    coordType = coordType,
    mappingName = mappingName,
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

    path <- tmpl("file.path('{{ path }}', '{{ fileName }}')",
                 path = remotePath,
                 fileName = fileName) %>%
      as.character()
  } else {
    # locationType == "local"
    path <- tmpl(
      "file.path(system.file('extdata', package = 'MpiIsoData'), '{{ fileName }}')",
      fileName = fileName
    ) %>%
      as.character()
  }

  path
}


#' Paste file import
#'
#' @param fileType (character) type of file, "csv" or "xlsx" only
#' @inheritParams createNewFileSource
addFileImport <-
  function(fileType,
           sheetNumber = 1,
           sep = ";",
           dec = ",") {
    if (!(fileType %in% c("csv", "xlsx")))
      stop("File type not supported. Only use \".csv\" or \".xlsx\" files.")

    if (fileType == "csv") {
      fileImport <-
        paste0(
          "read.csv2(file = dataFile, stringsAsFactors = FALSE, check.names = FALSE, ",
          "na.strings = c('', 'NA'), strip.white = TRUE)"
        )

      fileImport <-
        tmpl(
          paste0(
            "read.csv2(file = dataFile, sep = '{{ sep }}', dec = '{{ dec }}', stringsAsFactors = FALSE, ",
            "check.names = FALSE, na.strings = c('', 'NA'), strip.white = TRUE)"
          ),
          sep = sep,
          dec = dec
        ) %>%
        as.character()
    } else {
      # -> if (fileType == "xlsx")
      fileImport <-
        tmpl("read.xlsx(xlsxFile = dataFile, sheet = {{ sheetNumber }})",
             sheetNumber = sheetNumber) %>%
        as.character()
    }

    fileImport
  }
