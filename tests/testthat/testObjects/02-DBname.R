# Template to set up a new data source
# add dbname also to R/00-databases.R!
extract.DBname <- function(x){
# load data
  isoData <- getDBname()

  # create Description
  isoData$description <- paste("Description", isoData$var1, isoData$var2)

# pass isoData to next steps (no need to change anything here)
  x$dat <- isoData

  x
}


# Template for the credentials of the database
credsDBname <- function(){
    Credentials(
        drv = RMySQL::MySQL,
        user = Sys.getenv("DBNAME_USER"),
        password = Sys.getenv("DBNAME_PASSWORD"),
        dbname = Sys.getenv("DBNAME_NAME"),
        host = Sys.getenv("DBNAME_HOST"),
        port = as.numeric(Sys.getenv("DBNAME_PORT")),
    )
}

getDBname <- function(){
  query <- paste(
      "select * from table;"
  )

  dbtools::sendQuery(credsDBname(), query)
}
