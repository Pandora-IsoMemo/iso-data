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

    updateOrCreateTableMPI(dat = mapping, prefix = mappingName, table = "mapping", mode = "truncate")
  }
  ## mappingSource <- mappingTable %>%
  ##   select(-fieldType, -category) %>%
  ##   gather("source", "field", -"shiny") %>%
  ##   filter(!is.na(field))

  ## sendData(mappingSource, table = "mappingSource", mode = "truncate")
}

#' Update Or Create Table MPI
#'
#' @param dat (data.frame) data to write
#' @param prefix (character) prefix of table, e.g. mappingName
#' @param table (character) name of table on the server without prefix, e.g. "mapping"
#' @param mode (character) mode
updateOrCreateTableMPI <- function(dat, prefix, table, mode) {
  browser()
  if (prefix == "Field_Mapping") {
    # update the old table without prefix (here a prefix was not used yet)
    sendDataMPI(dat, table = table, mode = mode)
  } else {
    # check if table exists
    table <- paste0(c(prefix, table), collapse = "_")
    tableExists <- sendQueryMPI(dbtools::Query(tableExistsQry(), table = table))
    if (tableExists == 1) {
      sendDataMPI(dat, table = table, mode = mode)
    } else {
      # if not create one -> which column specs are required?
      # create table query ...
    }
  }
}

tableExistsQry <- function() {
  "IF OBJECT_ID ('{{ table }}', 'U') IS NOT NULL SELECT 1 AS res ELSE SELECT 0 AS res;"
}
