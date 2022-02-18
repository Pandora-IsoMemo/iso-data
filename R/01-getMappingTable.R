#' getMappingTable
#'
#' @export
getMappingTable <- function() {
  mappingfile <- system.file("mapping", "Field_Mapping.csv", package = "MpiIsoData")
  mapping <- read.csv2(file = mappingfile, stringsAsFactors = FALSE, check.names = FALSE,
                       na.strings = c("", "NA"), strip.white = TRUE)
  mapping
}
