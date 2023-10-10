load.default <- function(x, ...) {
  logDebug("Entering 'default' lload method for '%s'", x$name)

  df <- x$dat
  db <- x$name

  data <- getDefaultData(df, db)
  extraCharacter <- getExtra(df, db, "character")
  extraNumeric <- getExtra(df, db, "numeric")

  if (nrow(df) > 0){
    sendQueryMPI(paste0("DELETE FROM `data` WHERE `source` = '", db, "';"));
    # update also new table 'IsoMemo_data'
    sendQueryMPI(paste0("DELETE FROM `IsoMemo_data` WHERE `source` = '", db, "';"));
    sendQueryMPI(paste0("DELETE FROM `extraCharacter` WHERE `source` = '", db, "';"));
    sendQueryMPI(paste0("DELETE FROM `extraNumeric` WHERE `source` = '", db, "';"));
    sendQueryMPI(paste0("DELETE FROM `warning` WHERE `source` = '", db, "';"));

    sendDataMPI(data, table = "data", mode = "insert")
    sendDataMPI(data, table = "IsoMemo_data", mode = "insert")
    sendDataMPI(extraCharacter, table = "extraCharacter", mode = "insert")
    sendDataMPI(extraNumeric, table = "extraNumeric", mode = "insert")
  }

  x
}

getDefaultData <- function(df, db){
  vars <- defaultVars()

  df %>%
    select_if(names(df) %in% vars) %>%
    mutate(source = db)
}

getExtra <- function(df, db, type = "character"){
  variable <- value <- id <- NULL

  defaultVars <- defaultVars()
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


defaultVars <- function(){
  c(
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
}
