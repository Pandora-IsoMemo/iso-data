load.default <- function(x, ...) {
  logDebug("Entering 'default' lload method for '%s'", x$name)

  df <- x$dat
  db <- x$name
  mapping <- x$mapping

  data <- getDefaultData(df, db, mapping = mapping)
  extraCharacter <- getExtra(df, db, mapping = mapping, type = "character")
  extraNumeric <- getExtra(df, db, mapping = mapping, type = "numeric")

  if (mapping == "Field_Mapping") {
    # update the tables for the old mapping without prefix (here a prefix was not used yet)
    mapping <- NULL
  }

  if (nrow(df) > 0){
    sendQueryMPI(deleteOldQry(mapping, table = "data", source = db));
    sendQueryMPI(deleteOldQry(mapping, table = "extraCharacter", source = db));
    sendQueryMPI(deleteOldQry(mapping, table = "extraNumeric", source = db));
    sendQueryMPI(deleteOldQry(mapping, table = "warning", source = db));

    sendDataMPI(data, table = paste0(c(mapping, "data"), collapse = "_"), mode = "insert")
    sendDataMPI(extraCharacter, table = paste0(c(mapping, "extraCharacter"), collapse = "_"), mode = "insert")
    sendDataMPI(extraNumeric, table = paste0(c(mapping, "extraNumeric"), collapse = "_"), mode = "insert")
  }

  x
}

deleteOldQry <- function(mappingName, table, source){
  dbtools::Query(
    "DELETE FROM `{{ table }}` WHERE `source` = '{{ source }}';",
    table  = paste0(c(mappingName, table), collapse = "_"),
    source = source
  )
}

getDefaultData <- function(df, db, mapping){
  vars <- defaultVars(mappingName = mapping)

  df %>%
    select_if(names(df) %in% vars) %>%
    mutate(source = db)
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
    tibble(
      source = character(0),
      id = character(0),
      variable = character(0),
      value = emptyVar
    )
  else
    data %>%
      gather(variable, value, -id) %>%
      mutate(source = db)
}


defaultVars <- function(mappingName){
  if (!(paste0(mappingName, ".csv") %in% dir(system.file('mapping', package = 'MpiIsoData')))) {
    stop("Mapping not found! Please add the mapping file to inst/mapping/.")
  }

  fieldMappingVars <- c(
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
  # currently we have only one mapping
  switch(mappingName,
          "Field_Mapping" = fieldMappingVars,
         fieldMappingVars
  )
}
