#' Generate DB Connection Template
#'
#' Generates a template for a new DB connection and sets .Renviron variables
#'
#' @param dbName name of the database, e.g. "14CSea", "CIMA", "IntChron", "LiVES"
#' @param dbType type of the database, e.g. "file", "database"
#' @param dBUser user name (only if dBType == "mySql database")
#' @param dbPassword password (only if dBType == "mySql database")
#' @param dbHost host (only if dBType == "mySql database")
#' @param dbPort port (only if dBType == "mySql database")
generateTemplateDataSource <- function(dbName,
                                         dbType,
                                         locationType,
                                         fileName = NULL,
                                         remotePath = NULL,
                                         sheetName = NULL,
                                         tableName = NULL,
                                         dbUser = NULL,
                                         dbPassword = NULL,
                                         dbHost = NULL,
                                         dbPort = NULL){

  dbScript <- "# Template to set up a new data source"

  if (!(dbType %in% c("file", "database")))
    stop("dbType not found. Only use \"file\" or \"database\".")

  if (dbType == "file") {
  dbScript <- dbScript %>%
    addExtractForFiles(dbName = dbName,
                       locationType = locationType,
                       fileName = fileName,
                       remotePath = remotePath,
                       sheetName = sheetName)
  }

  if (dbType == "database") {
    dbScript <- dbScript %>%
      addExtractForDatabases(dbName = dbName) %>%
      addDBSettings(dbName = dbName,
                    tableName = tableName)
  }

  dbScript
}

# writeLines(addFileImport("data.csv"), "tmpFile.txt")

#' Add extract for files
#'
#' @param script (character) vector of lines of the script
#' @param dbName name of the database, e.g. "14CSea", "CIMA", "IntChron", "LiVES"
#' @inheritParams addDataLoadForFiles
addExtractForFiles <- function(script, dbName,
                               locationType, fileName, remotePath = NULL,
                               sheetName = NULL){

  c(script,
    "",
    "# add dbname also to R/00-databases.R!",
    paste0("extract.", dbName, " <- function(x){"),
    "",
    addDataLoadForFiles(fileName, locationType, remotePath, sheetName),
    addDescriptionAndPassData(),
    "x",
    "}"
  )
}

#' Add extract for databases
#'
#' @param script (character) vector of lines of the script
#' @param dbName name of the database, e.g. "14CSea", "CIMA", "IntChron", "LiVES"
addExtractForDatabases <- function(script, dbName){

  c(script,
    "",
    "# add dbname also to R/00-databases.R!",
    paste0("extract.", dbName, " <- function(x){"),
    "",
    addDataLoadForDB(dbName = dbName),
    addDescriptionAndPassData(),
    "x",
    "}"
  )
}

addDescriptionAndPassData <- function(){
  c(
    "# create a new column with a description",
    paste0("isoData$description <- paste(\"Description\", isoData$var1, isoData$var2)"),
    "",
    "# pass isoData to next steps (no need to change anything here)",
    "x$dat <- isoData",
    "",
  )
}
