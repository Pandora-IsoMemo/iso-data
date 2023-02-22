#' Clean up database
#'
#' @param mappingNames mappings to be used
#'
#' @export
cleanUp <- function(mappingNames = mappingNames()){
  for (mappingName in mappingNames) {
    sendQueryMPI(cleanUpQry(mappingName, "data"))
    sendQueryMPI(cleanUpQry(mappingName, "extraCharacter"))
    sendQueryMPI(cleanUpQry(mappingName, "extraNumeric"))
    sendQueryMPI(cleanUpQry(mappingName, "warning"))
  }
}

cleanUpQry <- function(mappingName, table, sources = dbnames()){
  sources <- dbtools::sqlParan(sources, function(x) dbtools::sqlEsc(x, with = "'"))
  dbtools::Query(
    "DELETE FROM {{ table }} where `source` not in {{ sources }};",
    table  = paste0(c(mappingName, table), collapse = "_"),
    sources = sources
  )
}
