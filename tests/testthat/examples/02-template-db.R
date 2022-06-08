# Please, rename "dbname" with the respective name of the database to be added.
# Add "dbname" also to R/00-databases.R!

extract.DBname <- function(x){
  #load data
  isoData <- getDBname()

  #create Description
  isoData$description <- paste("Description", isoData$var1, isoData$var2)

  # pass isoData to next steps (no need to change anything here)
  x$dat <- isoData

  x
}

# Template for the credentials of the database "DBname".
# Details for the format of "DBNAME_USER", "DBNAME_PASSWORD",... can be found in
# "02-template-Renviron.R".
# "DBNAME" is a placeholder and should be replaced with the name of the database in capital letters.

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
