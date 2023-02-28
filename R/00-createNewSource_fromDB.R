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
#' @param isTest (logical) TRUE if automatic testing
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
                              rootFolder = ".",
                              isTest = FALSE) {
  # 1. check for duplicated data source names
  checkDataSourceName(dataSourceName, isTest = isTest)

  # 2. create script for database source ----
  scriptTemplate <-
    file.path(getTemplateDir(), "template-extractFromDB.R") %>%
    readLines()

  dbScript <-
    tmpl(
      paste0(scriptTemplate, collapse = "\n"),
      dataSourceName = dataSourceName %>%
        formatDataSourceName(),
      dataSourceNameCreds = dataSourceName %>%
        formatDataSourceName(toUpper = TRUE),
      tableName = tableName
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

  # 4. setup / update Renviron file ----
  setupRenviron(
    dataSourceName = dataSourceName %>% formatDataSourceName(toUpper = TRUE),
    dbName = dbName,
    dbUser = dbUser,
    dbPassword = dbPassword,
    dbHost = dbHost,
    dbPort = dbPort,
    scriptFolder = file.path(rootFolder)
  )
}

#' Check Data Source Name
#'
#' @inheritParams updateDatabaseList
#' @param isTest (logical) TRUE if testing
checkDataSourceName <- function(dataSourceName, isTest = FALSE) {
  if (!isTest) {
    # load most recent database list
    devtools::load_all(".")
  }

  if (formatDataSourceName(dataSourceName, toUpper = TRUE) %in% formatDataSourceName(dbnames(), toUpper = TRUE))
    stop(
      paste0(
        "dataSourceName = ",
        dataSourceName,
        " already exists in (",
        paste0(dbnames(), collapse = ", "),
        "). Please provide case-insensitive unique names without special characters."
      )
    )
}

#' Format DB Name
#'
#' @inheritParams updateDatabaseList
#' @param toUpper (logical) TRUE transform letters to upper letters, default FALSE
#' @return (character) name formated to upper letters and underscore for special characters
formatDataSourceName <- function(dataSourceName, toUpper = FALSE) {
  res <- dataSourceName

  if (toUpper) {
    # upper letters
    res <- res %>% toupper()
  }
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
