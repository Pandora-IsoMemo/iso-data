#' Update ETL Mapping
#'
#' Updates mapping table in database
#'
#' @export
etlMapping <- function(){
  for (mappingName in mappingNames()) {
    mappingTable <- getMappingTable(mappingName = mappingName)

    mappingTable <- mappingTable %>%
      select(.data$shiny, .data$fieldType, .data$category)

    mappingTable <- cbind(mappingId = mappingName, mappingTable)

    sendQueryMPI("deleteOldMapping", mappingId = dbtools::sqlEsc(mappingName, with = "'"))
    sendDataMPI(mappingTable, table = "mapping", mode = "insert")
  }
  ## mappingSource <- mappingTable %>%
  ##   select(-fieldType, -category) %>%
  ##   gather("source", "field", -"shiny") %>%
  ##   filter(!is.na(field))

  ## sendData(mappingSource, table = "mappingSource", mode = "truncate")
}
