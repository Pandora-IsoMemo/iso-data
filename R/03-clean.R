#' Clean up database
#'
#' @param mappings mappings to be used
#' @param sources sources to be used
#'
#' @export
cleanUp <- function(mappings = mappingNames(), sources = dbnames()){
  # delete data from removed sources
  sources <- dbtools::sqlParan(sources, function(x) dbtools::sqlEsc(x, with = "'"))

  if (mappingName == "IsoMemo") {
    # Keep cleaning the deprecated table 'data' until the CRAN package,
    #  the API and the app are updated to use only the new table 'IsoMemo_data'!
    dbtools::Query(
      "DELETE FROM {{ table }} where `source` not in {{ sources }};",
      table = "data",
      sources = sources
    ) %>%
      sendQueryMPI()
  }

  for (mappingName in mappings) {
    sendQueryMPI("removeOldSourceFromData", mappingId  = mappingName, sources = sources)
    sendQueryMPI("removeOldSourceFromTable", mappingId = mappingName, table = "extraCharacter", sources = sources)
    sendQueryMPI("removeOldSourceFromTable", mappingId = mappingName, table = "extraNumeric", sources = sources)
    sendQueryMPI("removeOldSourceFromTable", mappingId = mappingName, table = "warning", sources = sources)
  }
}
