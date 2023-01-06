#' getMappingTable
#'
#' @param mappingFile file name of the mapping
#' @export
getMappingTable <- function(mappingFile = "Field_Mapping.csv") {
  mappingfile <- system.file("mapping", mappingFile, package = "MpiIsoData")
  mapping <- read.csv2(file = mappingfile, stringsAsFactors = FALSE, check.names = FALSE,
                       na.strings = c("", "NA"), strip.white = TRUE)
  mapping
}
