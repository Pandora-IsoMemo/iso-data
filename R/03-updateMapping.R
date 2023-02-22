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

    mapping <- mappingTable %>%
      select(shiny, fieldType, category)

    # check if table exists, if not create one -> which column specs are required?
    # -> IF OBJECT_ID('TableName', 'U') IS NOT NULL to check for a table

    if (mappingName == "Field_Mapping") {
      # update the old mapping table without prefix (here a prefix was not used yet)
      sendDataMPI(mapping, table = "mapping", mode = "truncate")
    } else {
      sendDataMPI(mapping, table = paste0(c(mappingName, "mapping"), collapse = "_"), mode = "truncate")
    }
  }
  ## mappingSource <- mappingTable %>%
  ##   select(-fieldType, -category) %>%
  ##   gather("source", "field", -"shiny") %>%
  ##   filter(!is.na(field))

  ## sendData(mappingSource, table = "mappingSource", mode = "truncate")
}
