#' Create New DB Source
#'
#' Creates a script for a new data source from a database connection and sets .Renviron variables.
#' Only "mySql" databases are supported.
#'
#' @param dbName (character) name of the new database source, e.g. "xyDBname"
#' @param tableName name of the table containing the data
#' @param datingType (character) dating type for the database, e.g. "radiocarbon" or "expert"
#' @param coordType (character) coord type for the database, e.g. "decimal degrees"
#' @param scriptFolder (character) place to store the scripts.
#' @param rootFolder (character) root folder of the package, usually containing .Renviron,
#' DESCRIPTION, ...
#' @export
createNewDBSource <- function(dbName,
                              tableName,
                              datingType,
                              coordType,
                              scriptFolder = "R",
                              rootFolder = ".") {
  # check for duplicated db names
  if (formatDBName(dbName) %in% formatDBName(dbnames()))
    stop(
      paste0(
        "dbName = ",
        dbName,
        " already exists in (",
        paste0(dbnames(), collapse = ", "),
        "). Please provide case-insensitive unique names without special characters."
      )
    )

  dbName <- formatDBName(dbName)

  dbScript <- pasteScriptBegin(dbName = dbName)

  dbScript <- c(dbScript,
                addDataLoadForDB(dbName = dbName))

  dbScript <- c(dbScript,
                addDescription(),
                pasteScriptEnd())

  dbScript <- c(dbScript,
                addDBSettings(dbName = dbName,
                              tableName = tableName))

  logging("Creating new file: %s", file.path(scriptFolder, paste0("02-", dbName, ".R")))
  writeLines(dbScript, con = file.path(scriptFolder, paste0("02-", dbName, ".R")))

  setupRenviron(dbName = dbName, scriptFolder = file.path(rootFolder))

  updateDatabaseList(
    dbName = dbName,
    datingType = datingType,
    coordType = coordType,
    scriptFolder = file.path(scriptFolder)
  )
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
#' @inheritParams createNewDBSource
addDBSettings <- function(dbName, tableName) {
  c(
    "",
    "# Template for the credentials of the database",
    paste0("creds", dbName, " <- function(){"),
    "    Credentials(",
    "        drv = RMySQL::MySQL,",
    paste0("        user = Sys.getenv(\"", dbName, "_USER\"),"),
    paste0("        password = Sys.getenv(\"", dbName, "_PASSWORD\"),"),
    paste0("        dbname = Sys.getenv(\"", dbName, "_NAME\"),"),
    paste0("        host = Sys.getenv(\"", dbName, "_HOST\"),"),
    paste0("        port = as.numeric(Sys.getenv(\"",
           dbName,
           "_PORT\")),"),
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

#' Format DB Name
#'
#' @param dbName (character) user-provided name of the new data source
#' @return (character) name formated to upper letters and underscore for special characters
formatDBName <- function(dbName) {
  # upper letters
  res <- toupper(dbName)
  # replace special characters with underscore
  res <- gsub("[^[:alnum:]]", "_", res)
  # replace "__" with "_"
  gsub("_+", "_", res)
}

#' Setup Renviron
#'
#' Creates or updates the .Renviron file with placeholders for a new database connection.
#'
#' @inheritParams createNewDBSource
setupRenviron <- function(dbName, scriptFolder = "") {
  renvironBegin <- c(
    "# Never upload any credentials to GitHub. The variable definitions are only placeholders",
    "# for Jenkins. Do not fill in credentials!",
    "# Uploading this script helps to maintain an overview for setting up all db connections."
  )

  renvironDef <- c(
    "",
    paste0(dbName, "_USER=\"\""),
    paste0(dbName, "_PASSWORD=\"\""),
    paste0(dbName, "_NAME=\"\""),
    paste0(dbName, "_HOST=\"\""),
    paste0(dbName, "_PORT=\"\"")
  )

  filePath <- file.path(scriptFolder, ".Renviron")

  if (!file.exists(filePath)) {
    logging("Creating new file: %s", filePath)
    writeLines(c(renvironBegin, renvironDef),
               con = filePath)
  } else {
    logging("Updating existing file: %s", filePath)
    write(renvironDef,
          file = filePath,
          append = TRUE)
  }
}


#' Update Database List
#'
#' Updates the list of all data sources.
#'
#' @inheritParams createNewDBSource
updateDatabaseList <-
  function(dbName,
           datingType,
           coordType,
           scriptFolder = "R") {
    newSource <- c(
      "        ),",
      "        singleSource (",
      paste0("          name = \"", dbName, "\","),
      paste0("          datingType = \"", datingType, "\","),
      paste0("          coordType = \"", coordType, "\"")
    )

    databaseFile <-
      readLines(con = file.path(scriptFolder, "00-databases.R")) %>%
      cleanUpScript()

    dbBegin <- grep("databases <- ", databaseFile)
    dbnamesBegin <- grep("dbnames <- ", databaseFile)

    dbDef <- databaseFile[dbBegin:(dbnamesBegin - 1)]
    otherDefs <- databaseFile[dbnamesBegin:length(databaseFile)]

    lastRow <- length(dbDef)

    dbDef <-
      c(dbDef[1:(lastRow - 3)], newSource, dbDef[(lastRow - 2):lastRow])

    logging("Updating existing file: %s",
            file.path(scriptFolder, "00-databases.R"))
    writeLines(c(dbDef, "", otherDefs),
               con = file.path(scriptFolder, "00-databases.R"))
  }
