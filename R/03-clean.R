#' Clean up database
#' 
#' @export
cleanUp <- function(){
  sendQueryMPI(cleanUpQry("data"))
  sendQueryMPI(cleanUpQry("extraCharacter"))
  sendQueryMPI(cleanUpQry("extraNumeric"))
  sendQueryMPI(cleanUpQry("warning"))
}

cleanUpQry <- function(table, sources = dbnames()){
  sources <- dbtools::sqlParan(sources, function(x) dbtools::sqlEsc(x, with = "'"))
  dbtools::Query(
    "DELETE FROM {{ table }} where `source` not in {{ sources }};",
    table  = table,
    sources = sources
  )
}
