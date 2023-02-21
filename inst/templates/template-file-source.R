# Set up extract function for a file source ----

extract.{{ dataSourceName }} <- function(x) {
  logDebug("Entering extract method for '%s'", x$name)
  # DO NOT MODIFY:
  # path to file
  dataFile <- {{ filePath }}

  # import options
  isoData <- {{ fileImport }}

  # -------
  # CUSTOMIZE DATA PREPARATION:


  # e.g. paste two columns to define a new description column. For this, uncomment and update
  # column names.
  # adds a description
  #  isoData$description <- paste(isoData$var1, isoData$var2)


  # -------
  # DO NOT MODIFY:
  # passing isoData to next steps (no need to change anything here)
  x$dat <- isoData

  x
}


# Set up load function for a file source ----

load.{{ dataSourceName }} <- function(x, ...) {
  logDebug("Entering lload method for '%s'", x$name)

  df <- x$dat
  db <- x$name
  mapping <- x$mapping

  data <- getDefaultData(df, db)
  extraCharacter <- getExtra(df, db, "character")
  extraNumeric <- getExtra(df, db, "numeric")

  if (nrow(df) > 0){
    sendQueryMPI(paste0("DELETE FROM `", mapping, "_data` WHERE `source` = '", db, "';"));
    sendQueryMPI(paste0("DELETE FROM `", mapping, "_extraCharacter` WHERE `source` = '", db, "';"));
    sendQueryMPI(paste0("DELETE FROM `", mapping, "_extraNumeric` WHERE `source` = '", db, "';"));
    sendQueryMPI(paste0("DELETE FROM `", mapping, "_warning` WHERE `source` = '", db, "';"));

    sendDataMPI(data, table = paste0(mapping, "_data"), mode = "insert")
    sendDataMPI(extraCharacter, table = paste0(mapping, "_extraCharacter"), mode = "insert")
    sendDataMPI(extraNumeric, table = paste(mapping, "_extraNumeric"), mode = "insert")
  }

  x
}
