# Set up for a data source from a database

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
