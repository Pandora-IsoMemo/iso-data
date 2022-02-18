# add dbname also to R/00-databases.R!
extract.dbname <- function(x){
  #load data
  isoData <- getDBname()

  #create Description
  isoData$description <- paste("Description", isoData$var1, isoData$var2)

  # pass isoData to next steps (no need to change anything here)
  x$dat <- isoData

  x
}

credsDBname <- function(){
    Credentials(
        drv = RMySQL::MySQL,
        user = "user",
        password = "password",
        dbname = "db",
        host = "www.domain.com",
        port = 3306
    )
}

getDBname <- function(){
  query <- paste(
      "select * from table;"
  )

  dbtools::sendQuery(credsDBname(), query)
}
