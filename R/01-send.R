sendQueryMPI <- function(query, ...){
  query <- dbtools::Query(getQuery(query), ...)
  dbtools::sendQuery(dbCreds(), query, ...)
}

sendDataMPI <- function(...){
  dbtools::sendData(dbCreds(), ...)
}

getQuery <- function(query) {
  if (grepl(";$", query)) query
  else file(system.file(
    sprintf("sql/%s.sql", sub("\\.sql$", "", query, ignore.case = TRUE)),
    package = "MpiIsoApi",
    mustWork = TRUE
  ))
}
