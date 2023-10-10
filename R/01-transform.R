transform.default <- function(x, ...) {
  logDebug("Entering 'default' transform method for '%s'", x$name)

  dat <- x$dat

  #map other fields and prepare data
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

  logging("... Length of data from %s: %i Preparing data ... ", x$name, nrow(dat))
  dat <- prepareData(dat, mapping, x$coordType)

  x$dat <- dat

  x
}
