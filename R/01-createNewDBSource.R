#' Create New DB Source
#'
#' Creates a script for a new data source from a database connection and sets .Renviron variables.
#' Only "mySql" databases are supported.
#'
#' @param dbName (character) name of the database, e.g. "xyDBname"
#' @param tableName name of the table containing the data
#' @param descriptionCreator (character) command that creates the description, e.g. pasting data
#'  columns "var1" and "var2": "paste(isoData$var1, isoData$var2)"
#' @param scriptFolder (character) place to store the scripts.
createNewDBSource <- function(dbName,
                              tableName,
                              descriptionCreator = NULL,
                              scriptFolder = "R") {
  dbScript <- pasteScriptBegin(dbName = dbName)

  dbScript <- c(dbScript,
                addDataLoadForDB(dbName = dbName))

  dbScript <- c(
    dbScript,
    addDescription(descriptionCreator = descriptionCreator),
    pasteScriptEnd()
  )

  dbScript <- dbScript %>%
    addDBSettings(dbName = dbName,
                  tableName = tableName)

  writeLines(dbScript, con = file.path(scriptFolder, paste0("02-", dbName, ".R")))

  setupRenviron(dbName = dbName, scriptFolder = file.path(scriptFolder))
}


#' Add Data Load For database source
#'
#' add lines to the script for data load from database
#'
#' @inheritParams createNewDBSource
addDataLoadForDB <- function(dbName) {
  c("# load data",
    paste0("  isoData <- get", dbName, "()"),
    "")
}


#' Paste DB settings
#'
#' @param script (character) vector of lines of the script
#' @inheritParams createNewDBSource
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


#' Setup Renviron
#'
#' Creates or updates the .Renviron file with placeholders for a new database connection.
#'
#' @inheritParams createNewDBSource
setupRenviron <- function(dbName, scriptFolder = "") {

  renvironBegin <- c(
    "# Never upload any credentials to GitHub. The variable definitions are only placeholders for Jenkins.",
    "# Uploading this script helps to maintain an overview for setting up all db connections.")

  renvironDef <- c(
    "",
    paste0(toupper(dbName), "_USER=\"\""),
    paste0(toupper(dbName), "_PASSWORD=\"\""),
    paste0(toupper(dbName), "_NAME=\"\""),
    paste0(toupper(dbName), "_HOST=\"\""),
    paste0(toupper(dbName), "_PORT=\"\"")
  )

  if(!file.exists(file.path(scriptFolder, ".Renviron"))) {
    writeLines(c(renvironBegin, renvironDef), con = file.path(scriptFolder, ".Renviron"))
  } else {
    write(renvironDef, file = file.path(scriptFolder, ".Renviron"), append = TRUE)
    }
}
