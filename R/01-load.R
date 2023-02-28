load.default <- function(x, ...) {
  logDebug("Entering 'default' lload method for '%s'", x$name)

  df <- x$dat
  db <- x$name
  mapping <- x$mapping

  data <- getDefaultData(df, db, mapping = mapping)
  extraCharacter <- getExtra(df, db, mapping = mapping, type = "character")
  extraNumeric <- getExtra(df, db, mapping = mapping, type = "numeric")

  if (nrow(df) > 0){
    # check if table exists
    tableExists <- sendQueryMPI(dataTableExistsQry(mappingId = mapping))
    if (tableExists == 1) {
      # update if exists:
      sendQueryMPI(deleteOldRowsFromDataQry(mapping, source = db));
      sendDataMPI(data, table = paste0(c(mapping, "data"), collapse = "_"), mode = "insert")
    } else {
      # create if not exists:
      # if not create one -> which column specs are required?
      # create table query ...
    }

    # only update the tables:
    sendQueryMPI(deleteOldRowsQry("extraCharacter", mappingId = mapping, source = db));
    sendQueryMPI(deleteOldRowsQry("extraNumeric", mappingId = mapping, source = db));
    sendQueryMPI(deleteOldRowsQry("warning", mappingId = mapping, source = db));

    sendDataMPI(extraCharacter, table = "extraCharacter", mode = "insert")
    sendDataMPI(extraNumeric, table = "extraNumeric", mode = "insert")
  }

  x
}

dataTableExistsQry <- function(mappingId) {
  dbtools::Query(
    "IF OBJECT_ID ('{{ mappingId }}_data', 'U') IS NOT NULL SELECT 1 AS res ELSE SELECT 0 AS res;",
    mappingId = mappingId
    )
}

deleteOldRowsFromDataQry <- function(mappingId, source){
  dbtools::Query(
    "DELETE FROM `{{ mappingId }}_data` WHERE `source` = '{{ source }}';",
    mappingId = mappingId,
    source = source
  )
}

deleteOldRowsQry <- function(table, mappingId, source){
  dbtools::Query(
    "DELETE FROM `{{ table }}` WHERE `mappingId` = '{{ mappingId }}' AND `source` = '{{ source }}';",
    table  = table,
    mappingId = mappingId,
    source = source
  )
}

getDefaultData <- function(df, db, mapping){
  vars <- defaultVars(mappingName = mapping)

  df %>%
    select_if(names(df) %in% vars) %>%
    mutate(source = db)
}

getDefaultDataTypes <- function() {
 # ...
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
