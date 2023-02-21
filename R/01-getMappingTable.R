#' getMappingTable
#'
#' @inheritParams createNewFileSource
#' @export
getMappingTable <- function(mappingName) {
  if (!(mappingName %in% dir(system.file('mapping', package = 'MpiIsoData')))) {
    stop("Mapping not found! Please add the mapping file to inst/mapping/.")
  }

  mappingFile <- paste0(mappingName, ".csv")
  mappingFile <- system.file("mapping", mappingFile, package = "MpiIsoData")
  mapping <- read.csv2(file = mappingFile, stringsAsFactors = FALSE, check.names = FALSE,
                       na.strings = c("", "NA"), strip.white = TRUE)
  mapping
}
