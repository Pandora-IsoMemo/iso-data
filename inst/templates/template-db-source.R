# Set up extract function for a database source ----

extract.{{ dataSourceName }} <- function(x) {
  # DO NOT MODIFY:
  # loads data
  isoData <- get_{{ dataSourceName }}()

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

creds_{{ dataSourceName }} <- function() {
  Credentials(
    drv = RMySQL::MySQL,
    user = Sys.getenv('{{ dataSourceNameCreds }}_USER'),
    password = Sys.getenv('{{ dataSourceNameCreds }}_PASSWORD'),
    dbname = Sys.getenv('{{ dataSourceNameCreds }}_NAME'),
    host = Sys.getenv('{{ dataSourceNameCreds }}_HOST'),
    port = as.numeric(Sys.getenv('{{ dataSourceNameCreds }}_PORT'))
  )
}

get_{{ dataSourceName }} <- function() {
  query <- 'select * from {{ tableName }};'

  dbtools::sendQuery(creds_{{ dataSourceName }}(), query)
}
