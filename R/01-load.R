load.default <- function(x, ...) {
  logDebug("Entering 'default' lload method for '%s'", x$name)

  df <- x$dat
  db <- x$name
  mapping <- x$mapping

  data <- getDefaultData(df, db, mapping = mapping)
  extraCharacter <- getExtra(df, db, mapping = mapping, type = "character")
  extraNumeric <- getExtra(df, db, mapping = mapping, type = "numeric")

  if (nrow(df) > 0){
    # check if table "{{ mapping }}_data" exists
    dataTbl <- paste0(mapping, "_data")
    tableExists <- sendQueryMPI(tableExistsQry(dataTbl))
    if (tableExists == 1) {
      # update table:
      sendQueryMPI(deleteOldDataQry(dataTbl, source = db));
      sendDataMPI(data, table = dataTbl, mode = "insert")
    } else {
      # create table:
      sendQueryMPI(createTableQry(data, table = dataTbl))
      # update table:
      sendDataMPI(data, table = dataTbl, mode = "insert")
    }

    # only update the tables "extraCharacter", "extraNumeric", "warning":
    sendQueryMPI(deleteOldDataQry("extraCharacter", mappingId = mapping, source = db))
    sendQueryMPI(deleteOldDataQry("extraNumeric", mappingId = mapping, source = db))
    sendQueryMPI(deleteOldDataQry("warning", mappingId = mapping, source = db))

    sendDataMPI(extraCharacter, table = "extraCharacter", mode = "insert")
    sendDataMPI(extraNumeric, table = "extraNumeric", mode = "insert")
  }

  x
}

#' Table exists query
#'
#' Gives a query to check if a table exists
#'
#' @param table (character) name of the table
tableExistsQry <- function(table) {
  dbtools::Query(
    "IF OBJECT_ID ('{{ table }}', 'U') IS NOT NULL SELECT 1 AS res ELSE SELECT 0 AS res;",
    table = table
    )
}

#' Delete Old Data Query
#'
#' Gives a query to delete old data from a table for a specific source (and mapping if given)
#'
#' @param table (character) name of the table
#' @param source (character) name of the source
#' @param mappingId (character) name of the mapping
deleteOldDataQry <- function(table, source, mappingId = NULL){
  if (is.null(mappingId)) {
    dbtools::Query(
      "DELETE FROM `{{ table }}` WHERE `source` = '{{ source }}';",
      table = table,
      source = source
    )
  } else {
    dbtools::Query(
      "DELETE FROM `{{ table }}` WHERE `mappingId` = '{{ mappingId }}' AND `source` = '{{ source }}';",
      table  = table,
      mappingId = mappingId,
      source = source
    )
  }
}

#' Create Table Query
#'
#' Gives a query to create a new table taking into account the column types of given data
#'
#' @param dat (data.frame) data to create the table for
#' @param table (character) name of the new table
createTableQry <- function(dat, table) {
  defaultTypes <- getDefaultDataTypes(dat)

  tableCols <-  sapply(names(defaultTypes), function(x) dbtools::sqlEsc(x, with = "'"))
  colDefs <- paste(tableCols, defaultTypes) %>%
    paste0(collapse = ", ")

  dbtools::Query(
    "CREATE TABLE IF NOT EXISTS `{{ table }}` ({{ colDefs }}, PRIMARY KEY (`source`,`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;",
    table = table,
    colDefs = colDefs
  )
}

#' Get Default Data Types
#'
#' Get the datatypes for the default columns
#'
#' @param dat (data.frame) data
getDefaultDataTypes <- function(dat) {
  colTypes <- sapply(dat, typeof)

  validType <- colTypes %in% c("character", "double")
  if (any(!validType)) {
    stop(paste("CREATE TABLE failed. No rule found for data type: ",
               paste0(validType[!validType], collapse = ", ")))
  }

  # rules to setup data type:
  colTypes[colTypes %in% c("character")] <- "varchar(50) NOT NULL"
  colTypes[colTypes %in% c("double")] <- "decimal(12,6) DEFAULT NULL"

  colTypes
}

getDefaultData <- function(df, db, mapping){
  vars <- defaultVars(mappingName = mapping)

  df %>%
    select_if(names(df) %in% vars)

  cbind(source = db, df)
}

getExtra <- function(df, db, mapping, type = "character"){
  variable <- value <- id <- NULL

  defaultVars <- defaultVars(mappingName = mapping)
  idVar <- names(df) == "id"

  is.type <- get(paste0("is.", type), mode = "function")
  emptyVar <- get(type, mode = "function")(0)

  typeVars <- unlist(lapply(df, is.type))

  data <- df %>%
    select_if( (!(names(df) %in% defaultVars) & typeVars | idVar))

  if (ncol(data) < 2)
    res <- tibble(
      source = character(0),
      id = character(0),
      variable = character(0),
      value = emptyVar
    )
  else
    res <- data %>%
      gather(variable, value, -id) %>%
      mutate(source = db)

  # add a new column "mappingId" to the front
  cbind(mappingId = mapping, res)
}


#' Default Vars
#'
#' Variables that are stored in the table "{{ mappingName }}_data" on the server
#'
#' @inheritParams updateDatabaseList
defaultVars <- function(mappingName){
  if (!(paste0(mappingName, ".csv") %in% dir(system.file('mapping', package = 'MpiIsoData')))) {
    stop("Mapping not found! Please add the mapping file to inst/mapping/ and update defaultVars().")
  }

  isoMemo_vars <- c(
    "id",
    "description",
    "d13C",
    "d15N",
    "latitude",
    "longitude",
    "site",
    "dateMean",
    "dateLower",
    "dateUpper",
    "dateUncertainty",
    "datingType",
    "calibratedDate",
    "calibratedDateLower",
    "calibratedDateUpper"
  )

  # optionally define other mapping specific defaultVars, maybe by removing non-default variables
  #   from getMappingTable(mappingName)$shiny ?
  # currently we have only one mapping, the new name is "IsoMemo"
  switch(mappingName,
         "Field_Mapping" = isoMemo_vars,
         "IsoMemo" = isoMemo_vars,
         isoMemo_vars
  )
}

#' Extra Vars
#'
#' Variables for which there is no column in the table "{{ mappingName }}_data" on the server
extraVars <- function() {
  c("measure", "databaseReference", "databaseDOI", "databaseDOIAuto",
    "compilationReference", "compilationDOI", "compilationDOIAuto",
    "originalDataReference", "originalDataDOI", "originalDataDOIAuto"
  )
}
