## Prevent NOTES in R CMD CHECK because of line
## select(shiny, fieldType, category)
utils::globalVariables(c("shiny", "fieldType", "category"))

#' Update ETL Mapping
#'
#' Updates mapping table in database
#'
#' @export
etlMapping <- function(){
  mappingTable <- getMappingTable()

  mapping <- mappingTable %>%
    select(shiny, fieldType, category)

  sendDataMPI(mapping, table = "mapping", mode = "truncate")

  ## mappingSource <- mappingTable %>%
  ##   select(-fieldType, -category) %>%
  ##   gather("source", "field", -"shiny") %>%
  ##   filter(!is.na(field))

  ## sendData(mappingSource, table = "mappingSource", mode = "truncate")
}
