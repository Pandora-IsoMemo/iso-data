#' Update Database List
#'
#' Updates the list of all data sources.
#'
#' @inheritParams createNewFileSource
updateDatabaseList <-
  function(dataSourceName,
           datingType,
           coordType,
           mappingName,
           scriptFolder = "R") {
    newSource <-
      tmpl(
        paste0(
          c(
            "        ),",
            "        singleSource (",
            "          name = '{{ dataSourceName }}',",
            "          datingType = '{{ datingType }}',",
            "          coordType = '{{ coordType }}',",
            "          mapping = '{{ mappingName }}',"
          ),
          collapse = "\n"
        ),
        dataSourceName = dataSourceName,
        datingType = datingType,
        coordType = coordType,
        mappingName = mappingName
      ) %>%
      as.character()

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
