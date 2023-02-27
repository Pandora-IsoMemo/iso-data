#' Create New DB Source
#'
#' Creates a script for a new data source from a database connection and sets .Renviron variables.
#' Only "mySql" databases are supported.
#'
#' @inheritParams updateDatabaseList
#' @param dbName (character) database name
#' @param dbUser (character) database user
#' @param dbPassword (character) database password
#' @param dbHost (character) database host
#' @param dbPort (character) database port
#' @param tableName name of the table containing the data
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

  dataSourceName <- setDataSourceName(dataSourceName)

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

#' Set Data Source Name
#'
#' @inheritParams updateDatabaseList
setDataSourceName <- function(dataSourceName) {
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

  formatDBName(dataSourceName)
}

#' Format DB Name
#'
#' @inheritParams updateDatabaseList
#' @return (character) name formated to upper letters and underscore for special characters
formatDBName <- function(dataSourceName) {
  # upper letters
  res <- toupper(dataSourceName)
  # replace special characters with underscore
  res <- gsub("[^[:alnum:]]", "_", res)
  # replace "__" with "_"
  res <- gsub("_+", "_", res)
  # remove leading or ending "_"
  res <- gsub("^_|_$", "", res)

  if (!identical(res, dataSourceName)) {
    warning(paste0("The dataSourceName was changed from: '", dataSourceName, "' to: '", res,
                   "'.\n Please update the mapping respectivaly."))
  }

  res
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
