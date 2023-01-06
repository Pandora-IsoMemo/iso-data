transform.default <- function(x, ...) {
  logDebug("Entering 'default' transform method for '%s'", x$name)

  dat <- x$dat

  #map other fields and prepare data
  # sources will contain a new entry x$mapping, then:
  # mapping <- getMappingTable(mappingFile = x$mapping)
  mapping <- getMappingTable()
  dat <- mapFields(dat, mapping, x$name)
  dat <- handleIDs(dat)

  # do not use the full data when testing
  if (isTest()) {
    subset <- sort(sample(seq_len(nrow(dat)), min(nrow(dat), 5)))
    dat <- dat[subset, ]
  }

  if (is.null(dat$datingType)) {
    dat$datingType <- x$datingType
  }

  dat <- prepareData(dat, mapping, x$coordType)

  x$dat <- dat

  x
}
