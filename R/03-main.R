#' Run the ETL
#'
#' Starts the ETL.
#'
#' @param sources (list) see result of \code{databases()}
#'
#' @export
main <- function(sources = databases()) {
  res <- lapply(sources, function(x) try(etl(x)))
  invisible(
    if (any(unlist(lapply(res, inherits, what = "try-error")))) 1
    else 0
  )
}

etlTest <- function(sources = databases(), full = FALSE) {
  if (full) {
    Sys.setenv(ETL_TEST = "0")
  } else {
    Sys.setenv(ETL_TEST = "1")
  }

  lapply(sources, function(x) etl(x, test = TRUE))
}

isTest <- function() {
    Sys.getenv("ETL_TEST") == "1"
}
