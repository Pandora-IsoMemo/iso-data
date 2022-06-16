# Set up for a data source

extract.{{ dbName }} <- function(x) {
  # load data
  isoData <- get{{ dbName }}()

  # create Description
  #
  # e.g. paste two columns to define a new description column. For this, uncomment and update
  # column names.
  # add code here if required ->>>

  #  isoData$description <- paste(isoData$var1, isoData$var2)

  # <<<- until here

  # pass data to next steps (no need to change anything here)
  x$dat <- isoData

  x
}


# set up credentials of a database

creds{{ dbName }} <- function() {
  Credentials(
    drv = RMySQL::MySQL,
    user = Sys.getenv("{{ dbName }}_USER"),
    password = Sys.getenv("{{ dbName }}_PASSWORD"),
    dbname = Sys.getenv("{{ dbName }}_NAME"),
    host = Sys.getenv("{{ dbName }}_HOST"),
    port = as.numeric(Sys.getenv("{{ dbName }}_PORT"))
  )
}

get{{ dbName }} <- function() {
  query <- "select * from {{ tableName }};"

  dbtools::sendQuery(creds{{ dbName }}(), query)
}
