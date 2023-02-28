#' Clean up database
#'
#' @param mappingNames mappings to be used
#'
#' @export
cleanUp <- function(mappingNames = mappingNames()){
  for (mappingName in mappingNames) {
    sendQueryMPI(cleanUpDataQry(mappingId = mappingName))
    sendQueryMPI(cleanUpQry(mappingId = mappingName, "extraCharacter"))
    sendQueryMPI(cleanUpQry(mappingId = mappingName, "extraNumeric"))
    sendQueryMPI(cleanUpQry(mappingId = mappingName, "warning"))
  }
}

cleanUpDataQry <- function(mappingId, sources = dbnames()){
  # delete data from removed sources
  sources <- dbtools::sqlParan(sources, function(x) dbtools::sqlEsc(x, with = "'"))
  dbtools::Query(
    "DELETE FROM `{{ mappingId }}_data` where `source` not in {{ sources }};",
    mappingId  = mappingId,
    sources = sources
  )
}

cleanUpQry <- function(mappingId, table, sources = dbnames()){
  # delete data from removed sources
  sources <- dbtools::sqlParan(sources, function(x) dbtools::sqlEsc(x, with = "'"))
  dbtools::Query(
    "DELETE FROM {{ table }} where `mappingId` = '{{ mappingId }}' AND `source` not in {{ sources }};",
    table  = table,
    mappingId = mappingId,
    sources = sources
  )
}
