#' Create New DB Source
#'
#' Creates a template for a new data source from a DB connection and sets .Renviron variables.
#'
#' @param dbName name of the database, e.g. "14CSea", "CIMA", "IntChron", "LiVES"
#' @param dbUser user name (only if dBType == "mySql database")
#' @param dbPassword password (only if dBType == "mySql database")
#' @param dbHost host (only if dBType == "mySql database")
#' @param dbPort port (only if dBType == "mySql database")
#' @param tableName name of the table containing the data
#' @param descriptionCreator (character) command that creates the description, e.g. pasting data
#'  columns "var1" and "var2": "paste(isoData$var1, isoData$var2)"
#' @param templateFolder (character) place to store the scripts, usually in the R folder (except
#' for tests).
createNewDBSource <- function(dbName,
                              tableName,
                              dbUser = NULL,
                              dbPassword = NULL,
                              dbHost = NULL,
                              dbPort = NULL,
                              descriptionCreator = NULL,
                              templateFolder = "R") {

  dbScript <- pasteScriptBegin(dbName = dbName)

  dbScript <- c(dbScript,
                addDataLoadForDB(dbName = dbName))

  dbScript <- c(
    dbScript,
    addDescription(descriptionCreator = descriptionCreator),
    pasteScriptEnd()
  )

  if (is.null(tableName))
    stop("tableName not found. Please provide 'tableName'.")

  dbScript <- dbScript %>%
    addDBSettings(dbName = dbName,
                  tableName = tableName)

  writeLines(dbScript, con = file.path(templateFolder, paste0("02-", dbName, ".R")))
}


#' add lines for data load from database
#'
#' @param dbName name of the database
addDataLoadForDB <- function(dbName) {
  c("# load data",
    paste0("  isoData <- get", dbName, "()"),
    "")
}


#' Paste DB settings
#'
#' @param script (character) vector of lines of the script
#' @param dbName name of the database
#' @param tableName name of the table containing the data
addDBSettings <- function(script, dbName, tableName) {
  c(
    script,
    "",
    "# Template for the credentials of the database",
    paste0("creds", dbName, " <- function(){"),
    "    Credentials(",
    "        drv = RMySQL::MySQL,",
    paste0("        user = Sys.getenv(\"", toupper(dbName), "_USER\"),"),
    paste0("        password = Sys.getenv(\"", toupper(dbName), "_PASSWORD\"),"),
    paste0("        dbname = Sys.getenv(\"", toupper(dbName), "_NAME\"),"),
    paste0("        host = Sys.getenv(\"", toupper(dbName), "_HOST\"),"),
    paste0(
      "        port = as.numeric(Sys.getenv(\"",
      toupper(dbName),
      "_PORT\")),"
    ),
    "    )",
    "}",
    "",
    paste0("get", dbName, " <- function(){"),
    "  query <- paste(",
    paste0("      \"select * from ", tableName, ";\""),
    "  )",
    "",
    paste0("  dbtools::sendQuery(creds", dbName, "(), query)"),
    "}"
  )
}
