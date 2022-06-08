# helper functions for database templates

#' add lines for data load from database
#'
#' @param dbName name of the database
addDataLoadForDB <- function(dbName){
  c(
    "# load data",
    paste0("  isoData <- get", dbName, "()"),
    ""
  )
}


#' Paste DB settings
#'
#' @param script (character) vector of lines of the script
#' @param dbName name of the database
#' @param tableName name of the table containing the data
addDBSettings <- function(script, dbName, tableName){
  c(script,
    "",
    "# Template for the credentials of the database",
    paste0("creds", dbName," <- function(){"),
    "    Credentials(",
    "        drv = RMySQL::MySQL,",
    paste0("        user = Sys.getenv(\"", toupper(dbName), "_USER\"),"),
    paste0("        password = Sys.getenv(\"", toupper(dbName), "_PASSWORD\"),"),
    paste0("        dbname = Sys.getenv(\"", toupper(dbName), "_NAME\"),"),
    paste0("        host = Sys.getenv(\"", toupper(dbName), "_HOST\"),"),
    paste0("        port = as.numeric(Sys.getenv(\"", toupper(dbName), "_PORT\")),"),
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
