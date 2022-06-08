#' Generate DB Connection Template
#'
#' Generates a template for a new DB connection and sets .Renviron variables
#'
#' @param dbName name of the database, e.g. "14CSea", "CIMA", "IntChron", "LiVES"
#' @param dbType type of the database, e.g. "file", "database"
#' @param dbUser user name (only if dBType == "mySql database")
#' @param dbPassword password (only if dBType == "mySql database")
#' @param dbHost host (only if dBType == "mySql database")
#' @param dbPort port (only if dBType == "mySql database")
#' @param tableName name of the table containing the data
#' @param descriptionCreator (character) command that creates the description, e.g. pasting data
#'  columns "var1" and "var2": "paste(isoData$var1, isoData$var2)"
#' @inheritParams addDataLoadForFiles
generateTemplateDataSource <- function(dbName,
                                       dbType,
                                       locationType = NULL,
                                       fileName = NULL,
                                       remotePath = NULL,
                                       sheetName = NULL,
                                       tableName = NULL,
                                       dbUser = NULL,
                                       dbPassword = NULL,
                                       dbHost = NULL,
                                       dbPort = NULL,
                                       descriptionCreator = NULL) {
  dbScript <- c(
    "# Template to set up a new data source",
    "# add dbname also to R/00-databases.R!",
    paste0("extract.", dbName, " <- function(x){")
  )

  if (!(dbType %in% c("file", "database")))
    stop("dbType not found. Only use 'file' or 'database'.")

  if (dbType == "file") {
    dbScript <- c(
      dbScript,
      addDataLoadForFiles(
        locationType = locationType,
        fileName = fileName,
        remotePath = remotePath,
        sheetName = sheetName
      )
    )
  }

  if (dbType == "database") {
    dbScript <- c(dbScript,
                  addDataLoadForDB(dbName = dbName))
  }

  dbScript <- c(dbScript,
                addDescription(descriptionCreator = descriptionCreator),
                "",
                "# pass isoData to next steps (no need to change anything here)",
                "  x$dat <- isoData",
                "",
                "  x",
                "}",
                "")

  if (dbType == "database") {
    if (is.null(tableName))
      stop("tableName not found. Please provide 'tableName' for dbType = 'database'.")
    dbScript <- dbScript %>%
      addDBSettings(dbName = dbName,
                    tableName = tableName)
  }

  dbScript
}

# writeLines(addFileImport("data.csv"), "tmpFile.txt")

#' Add description And Pass Data
#'
#' @inheritParams generateTemplateDataSource
addDescription <- function(descriptionCreator = NULL) {
  if (is.null(descriptionCreator)) return(NULL)

  c(
    "  # create Description",
    paste0("  isoData$description <- ", descriptionCreator)
  )
}
