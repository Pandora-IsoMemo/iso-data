#' Log info message
#'
#' @param msg the message
#' @param ... passed to futile.logger::flog.info
#'
#' @export
logging <- function(msg, ...) {
  futile.logger::flog.info(msg, ...)
}

logDebug <- function(msg, ...) {
  futile.logger::flog.debug(msg, ...)
}

logWarning <- function(msg, ...) {
  futile.logger::flog.warn(msg, ...)
}

logError <- function(msg, ...) {
  futile.logger::flog.error(msg, ...)
}
