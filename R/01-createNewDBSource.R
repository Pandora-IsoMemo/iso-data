#' Create New DB Source
#'
#' Creates a script for a new data source from a database connection and sets .Renviron variables.
#' Only "mySql" databases are supported.
#'
#' @param dataSourceName (character) name of the new database source, e.g. "xyDBname". The name
#' of the source must be contained as a column name in the mapping file.
#' @param datingType (character) dating type for the database, e.g. "radiocarbon" or "expert"
#' @param coordType (character) coordinate type of latitude and longitude columns; one of
#'  "decimal degrees" (e.g. 40.446 or 79.982),
#'  "degrees decimal minutes" ("40° 26.767' N" or "79° 58.933' W"),
#'  "degrees minutes seconds" ("40° 26' 46'' N" or "79° 58' 56'' W")
#' @param mappingName (character) name of the mapping, e.g. "Field_Mapping". The mapping,
#' a .csv file, must be available under "inst/mapping/".
#' @param dbName (character) database name
#' @param dbUser (character) database user
#' @param dbPassword (character) database password
#' @param dbHost (character) database host
#' @param dbPort (character) database port
#' @param tableName name of the table containing the data
#' @param scriptFolder (character) place to store the scripts.
#' @param rootFolder (character) root folder of the package, usually containing .Renviron,
#' DESCRIPTION, ...
#' @export
createNewDBSource <- function(dataSourceName,
                              datingType,
                              coordType,
                              mappingName,
                              dbName,
                              dbUser,
                              dbPassword,
                              dbHost,
                              dbPort,
                              tableName,
                              scriptFolder = "R",
                              rootFolder = ".") {
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

  scriptTemplate <-
    file.path(getTemplateDir(), "template-db-source.R") %>%
    readLines()

  dbScript <-
    tmpl(
      paste0(scriptTemplate, collapse = "\n"),
      dataSourceName = dataSourceName,
      mappingName = mappingName,
      tableName = tableName
    ) %>%
    as.character()

  logging("Creating new file: %s",
          file.path(scriptFolder, paste0("02-", mappingName, "_", dataSourceName, ".R")))
  writeLines(dbScript,
             con = file.path(scriptFolder, paste0("02-", mappingName, "_", dataSourceName, ".R")))

  setupRenviron(
    dataSourceName = dataSourceName,
    dbName = dbName,
    dbUser = dbUser,
    dbPassword = dbPassword,
    dbHost = dbHost,
    dbPort = dbPort,
    scriptFolder = file.path(rootFolder)
  )

  updateDatabaseList(
    dataSourceName = dataSourceName,
    datingType = datingType,
    coordType = coordType,
    mappingName = mappingName,
    scriptFolder = file.path(scriptFolder)
  )
}


#' Format DB Name
#'
#' @param dataSourceName (character) user-provided name of the new data source
#' @return (character) name formated to upper letters and underscore for special characters
formatDBName <- function(dataSourceName) {
  # upper letters
  res <- toupper(dataSourceName)
  # replace special characters with underscore
  res <- gsub("[^[:alnum:]]", "_", res)
  # replace "__" with "_"
  res <- gsub("_+", "_", res)
  # remove leading or ending "_"
  gsub("^_|_$", "", res)
}


#' Setup Renviron
#'
#' Creates or updates the .Renviron file with placeholders for a new database connection.
#'
#' @inheritParams createNewDBSource
setupRenviron <-
  function(dataSourceName,
           dbName,
           dbUser,
           dbPassword,
           dbHost,
           dbPort,
           scriptFolder = "") {
    filePath <- file.path(scriptFolder, ".Renviron")

    scriptTemplate <-
      file.path(getTemplateDir(), "template-Renviron.R") %>%
      readLines()

    if (!file.exists(filePath)) {
      # create new Renviron
      rEnvironNew <-
        tmpl(
          paste0(scriptTemplate, collapse = "\n"),
          dataSourceName = dataSourceName,
          dbName = dbName,
          dbUser = dbUser,
          dbPassword = dbPassword,
          dbHost = dbHost,
          dbPort = dbPort
        ) %>%
        as.character()

      logging("Creating new file: %s", filePath)
      writeLines(rEnvironNew, con = filePath)
    } else {
      # update existing Renviron
      # remove first lines from the template which contain comments
      scriptTemplate <- scriptTemplate[-(1:10)]

      rEnvironUpdate <-
        tmpl(
          paste0(scriptTemplate, collapse = "\n"),
          dataSourceName = dataSourceName,
          dbName = dbName,
          dbUser = dbUser,
          dbPassword = dbPassword,
          dbHost = dbHost,
          dbPort = dbPort
        ) %>%
        as.character()

      logging("Updating existing file: %s", filePath)
      write(rEnvironUpdate, file = filePath, append = TRUE)
    }
  }
