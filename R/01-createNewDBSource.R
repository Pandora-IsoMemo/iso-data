#' Create New DB Source
#'
#' Creates a script for a new data source from a database connection and sets .Renviron variables.
#' Only "mySql" databases are supported.
#'
#' @param dataSourceName (character) name of the new database source, e.g. "xyDBname"
#' @param dbName (character) database name
#' @param dbUser (character) database user
#' @param dbPassword (character) database password
#' @param dbHost (character) database host
#' @param dbPort (character) database port
#' @param tableName name of the table containing the data
#' @param datingType (character) dating type for the database, e.g. "radiocarbon" or "expert"
#' @param coordType (character) coord type for the database, e.g. "decimal degrees"
#' @param scriptFolder (character) place to store the scripts.
#' @param rootFolder (character) root folder of the package, usually containing .Renviron,
#' DESCRIPTION, ...
#' @export
createNewDBSource <- function(dataSourceName,
                              dbName,
                              dbUser,
                              dbPassword,
                              dbHost,
                              dbPort,
                              tableName,
                              datingType,
                              coordType,
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
    file.path(system.file(package = "MpiIsoData"),
              "templates",
              "template-db-source.R") %>%
    readLines()

  dbScript <-
    tmpl(
      paste0(scriptTemplate, collapse = "\n"),
      dataSourceName = dataSourceName,
      tableName = tableName
    ) %>%
    as.character()

  logging("Creating new file: %s", file.path(scriptFolder, paste0("02-", dataSourceName, ".R")))
  writeLines(dbScript, con = file.path(scriptFolder, paste0("02-", dataSourceName, ".R")))

  setupRenviron(dataSourceName = dataSourceName,
                dbName = dbName,
                dbUser = dbUser,
                dbPassword = dbPassword,
                dbHost = dbHost,
                dbPort = dbPort,
                scriptFolder = file.path(rootFolder))

  updateDatabaseList(
    dataSourceName = dataSourceName,
    datingType = datingType,
    coordType = coordType,
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
           dbUser,
           dbPassword,
           dbName,
           dbHost,
           dbPort,
           scriptFolder = "") {
    renvironBegin <- c(
      "# Never upload any credentials to GitHub. The variable definitions are only placeholders",
      "# for Jenkins. Do not fill in credentials!",
      "# Uploading this script helps to maintain an overview for setting up all db connections."
    )

    renvironDef <-
      tmpl(
        paste0(
          c(
            "",
            "{{ dataSourceName }}_DBNAME=\"{{ dbName }}\"",
            "{{ dataSourceName }}_USER=\"{{ dbUser }}\"",
            "{{ dataSourceName }}_PASSWORD=\"{{ dbPassword }}\"",
            "{{ dataSourceName }}_HOST=\"{{ dbHost }}\"",
            "{{ dataSourceName }}_PORT={{ dbPort }}"
          ),
          collapse = "\n"
        ),
        dataSourceName = dataSourceName,
        dbName = dbName,
        dbUser = dbUser,
        dbPassword = dbPassword,
        dbHost = dbHost,
        dbPort = dbPort
      ) %>%
      as.character()

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
  function(dataSourceName,
           datingType,
           coordType,
           scriptFolder = "R") {
    newSource <- c(
      "        ),",
      "        singleSource (",
      paste0("          name = \"", dataSourceName, "\","),
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
