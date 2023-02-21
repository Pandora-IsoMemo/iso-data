# Set up extract function for a database source ----

extract.{{ dataSourceName }} <- function(x) {
  # DO NOT MODIFY:
  # loads data
  isoData <- get{{ dataSourceName }}()

  # -------
  # CUSTOMIZE DATA PREPARATION:


  # e.g. paste two columns to define a new description column. For this, uncomment and update
  # column names.
  # adds a description
  #  isoData$description <- paste(isoData$var1, isoData$var2)


  # -------
  # DO NOT MODIFY:
  # passing data to next steps (no need to change anything here)
  x$dat <- isoData

  x
}


# set up credentials of a database

creds{{ dataSourceName }} <- function() {
  Credentials(
    drv = RMySQL::MySQL,
    user = Sys.getenv("{{ dataSourceName }}_USER"),
    password = Sys.getenv("{{ dataSourceName }}_PASSWORD"),
    dbname = Sys.getenv("{{ dataSourceName }}_NAME"),
    host = Sys.getenv("{{ dataSourceName }}_HOST"),
    port = as.numeric(Sys.getenv("{{ dataSourceName }}_PORT"))
  )
}

get{{ dataSourceName }} <- function() {
  query <- "select * from {{ tableName }};"

  dbtools::sendQuery(creds{{ dataSourceName }}(), query)
}


# Set up load function for a database source ----

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
