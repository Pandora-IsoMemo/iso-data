#' getMappingTable
#'
#' @param mappingName file name of the mapping
#' @export
getMappingTable <- function(mappingName = "Field_Mapping.csv") {
  mappingfile <- system.file("mapping", mappingName, package = "MpiIsoData")
  mapping <- read.csv2(file = mappingfile, stringsAsFactors = FALSE, check.names = FALSE,
                       na.strings = c("", "NA"), strip.white = TRUE)
  mapping
}
