
sendQueryMPI <- function(...){
  dbtools::sendQuery(dbCreds(), ...)
}

sendDataMPI <- function(...){
  dbtools::sendData(dbCreds(), ...)
}
