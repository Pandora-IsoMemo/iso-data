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
