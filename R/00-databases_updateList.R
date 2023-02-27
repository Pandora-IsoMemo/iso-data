#' Update Database List
#'
#' Updates the list of all data sources.
#'
#' @param dataSourceName (character) name of the new data source, something like "xyDBname",
#'  "14CSea", "CIMA", "IntChron", "LiVES". The name of the source must be contained exactly
#'  as a column name in the mapping file.
#' @param datingType (character) dating type for the database, e.g. "radiocarbon" or "expert"
#' @param coordType (character) coordinate type of latitude and longitude columns; one of
#'  "decimal degrees" (e.g. 40.446 or 79.982),
#'  "degrees decimal minutes" ("40° 26.767' N" or "79° 58.933' W"),
#'  "degrees minutes seconds" ("40° 26' 46'' N" or "79° 58' 56'' W")
#' @param mappingName (character) name of the mapping without file extension, e.g. "Field_Mapping".
#'  The mapping (a .csv file) must be available under "inst/mapping/".
#' @param scriptFolder (character) place to store the scripts.
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
            "          mapping = '{{ mappingName }}'"
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

#' Clean Up Script
#'
#' @param script (character) script to extract data
cleanUpScript <- function(script) {
  script <-
    script[!grepl("^#|^..#", script)]    # remove all comments from script
  script <-
    script[script != ""]                 # remove empty lines from script
}
