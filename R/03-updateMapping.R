## Prevent NOTES in R CMD CHECK because of line
## select(shiny, fieldType, category)
utils::globalVariables(c("shiny", "fieldType", "category"))

#' Update ETL Mapping
#'
#' Updates mapping table in database
#'
#' @param sources (list) see result of \code{databases()}
#'
#' @export
etlMapping <- function(sources = databases()){
  listOfMappings <- sapply(sources, function(source) source[["mapping"]]) %>%
    unique()

  for (mappingName in listOfMappings) {
    mappingTable <- getMappingTable(mappingName = mappingName)

    mapping <- mappingTable %>%
      select(shiny, fieldType, category)

    if (mappingName == "Field_Mapping") {
      # remove prefix for this mappingName
      # here a prefix was not used yet
      mappingName <- NULL
    }
    sendDataMPI(mapping, table = paste0(c(mappingName, "mapping"), collapse = "_"), mode = "truncate")
  }
  ## mappingSource <- mappingTable %>%
  ##   select(-fieldType, -category) %>%
  ##   gather("source", "field", -"shiny") %>%
  ##   filter(!is.na(field))

  ## sendData(mappingSource, table = "mappingSource", mode = "truncate")
}
