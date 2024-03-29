load.default <- function(x, ...) {
  logDebug("Entering 'default' lload method for '%s'", x$name)

  df <- x$dat
  db <- x$name
  mapping <- x$mapping

  # exclude columns of extraVars(), the information is stored in extraCharacter and extraNumeric
  data <- getDefaultData(df, db, mapping = mapping)

  extraCharacter <- getExtra(df, db, mapping = mapping, type = "character")
  extraNumeric <- getExtra(df, db, mapping = mapping, type = "numeric")

  if (nrow(df) > 0){
    if (mapping == "IsoMemo") {
      # Keep updating the deprecated table 'data' until the CRAN package,
      #  the API and the app are updated to use only the new table 'IsoMemo_data'!
      # delete old data:
      sendQueryMPI(paste0("DELETE FROM `data` WHERE `source` = '", db, "';"));
      # send new data:
      sendDataMPI(data, table = "data", mode = "insert")
    }

    dataTblName <- paste0(mapping, "_data")
    colDefs <- getColDefs(dat = data, table = dataTblName)

    logging("Create table if not exists:   %s,   %s", dataTblName, colDefs)
    logging("Delete old data of source:   %s", db)
    sendQueryMPI("mappingId_data",
                 tableName = dbtools::sqlEsc(dataTblName, with = "`"),
                 dbSource = dbtools::sqlEsc(db, with = "'"),
                 colDefs = colDefs)

    # not re-create but only update the tables "extraCharacter", "extraNumeric", "warning":
    sendQueryMPI("deleteOldData",
                 tableName = dbtools::sqlEsc("extraCharacter", with = "`"),
                 mappingId = dbtools::sqlEsc(mapping, with = "'"),
                 dbSource = dbtools::sqlEsc(db, with = "'"))
    sendQueryMPI("deleteOldData",
                 tableName = dbtools::sqlEsc("extraNumeric", with = "`"),
                 mappingId = dbtools::sqlEsc(mapping, with = "'"),
                 dbSource = dbtools::sqlEsc(db, with = "'"))
    sendQueryMPI("deleteOldData",
                 tableName = dbtools::sqlEsc("warning", with = "`"),
                 mappingId = dbtools::sqlEsc(mapping, with = "'"),
                 dbSource = dbtools::sqlEsc(db, with = "'"))

    logging("Send:   %s", dataTblName)
    sendDataMPI(data, table = dataTblName, mode = "insert")
    logging("Send:   %s", "extraCharacter")
    sendDataMPI(extraCharacter, table = "extraCharacter", mode = "insert")
    logging("Send:   %s", "extraNumeric")
    sendDataMPI(extraNumeric, table = "extraNumeric", mode = "insert")
  }

  x
}

#' Get Col Defs
#'
#' Get definitions of columns to create a new table
#'
#' @param dat (data.frame) data
#' @param table (character) table name
getColDefs <- function(dat, table) {
  defaultTypes <- getDefaultDataTypes(dat)

  tableCols <-  sapply(names(defaultTypes), function(x) dbtools::sqlEsc(x, with = "`"))
  paste(tableCols, defaultTypes) %>%
    paste0(collapse = ", ")
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

  df <- df %>%
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
