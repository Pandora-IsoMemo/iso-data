## Prevent NOTES in R CMD CHECK because of line
## select(shiny, fieldType, category)
utils::globalVariables(c("shiny", "fieldType", "category"))

#' Update ETL Mapping
#'
#' Updates mapping table in database
#'
#' @export
etlMapping <- function(){
  for (mappingName in mappingNames()) {
    mappingTable <- getMappingTable(mappingName = mappingName)

    mappingTable <- mappingTable %>%
      select(shiny, fieldType, category)

    mappingTable <- cbind(mappingId = mappingName, mappingTable)

    sendQueryMPI(deleteOldRowsQry(table = "mapping", mappingId = mappingName, source = db));
    sendDataMPI(mappingTable, table = "mapping", mode = "insert")
  }
  ## mappingSource <- mappingTable %>%
  ##   select(-fieldType, -category) %>%
  ##   gather("source", "field", -"shiny") %>%
  ##   filter(!is.na(field))

  ## sendData(mappingSource, table = "mappingSource", mode = "truncate")
}
