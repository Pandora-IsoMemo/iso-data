etl <- function(x, test = FALSE, ...) {
  logging("Extract:   %s", x$name)
  x <- extract(x, ...)
  logging("Transform: %s", x$name)
  x <- transform(x, ...)
  logging("Validate: %s", x$name)
  x <- validate(x, ...)

  if (!test) {
    logging("Load:      %s", x$name)
    lload(x, ...)
    report(x, ...)
  }

  x
}

extract <- function(x, ...) UseMethod("extract")
transform <- function(x, ...) UseMethod("transform")
validate <- function(x, ...) UseMethod("validate")
# to avoid name clash with base::load -> l(ocal)load:
lload <- function(x, ...) UseMethod("load")
report <- function(x, ...) UseMethod("report")

extract.NULL <- function(x, ...) {
  logDebug("Skipping extract because of NULL value")
  NULL
}
transform.NULL <- function(x, ...) {
  logDebug("Skipping transform because of NULL value")
  NULL
}
validate.NULL <- function(x, ...) {
  logDebug("Skipping validate because of NULL value")
  NULL
}
load.NULL <- function(x, ...) {
  logDebug("Skipping load because of NULL value")
  NULL
}
report.NULL <- function(x, ...) {
  logDebug("Skipping report because of NULL value")
  NULL
}

extract.default <- function(x, ...) {
  stop(sprintf("No extraction method found for %s. Please provide function 'extract.%s'", x$name, x$name))
}


report.default <- function(x, ...) {
  logDebug("Entering default 'report' for '%s'", x$name)
  updated <- data.frame(
    tableName = paste0(x$mapping, "_", x$name),
    completed = as.character(Sys.time()),
    nrow = nrow(x$dat),
    stringsAsFactors = FALSE
  )
  invisible(x$sendReport(updated, "updated"))
}
