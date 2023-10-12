
validate.default <- function(x, ...) {
  logDebug("Entering 'default' validate method for '%s'", x$name)

  dat <- x$dat

  mapping <- getMappingTable(mappingName = x$mapping)
  stopifnot(all(names(dat) %in% mapping$shiny))

  lapply(names(dat), function(n) {
      map <- as.list(mapping[mapping$shiny == n, ])
      if (!is.type(map$fieldType)(dat[[n]])) {
          stop(sprintf("Field %s of Database %s is not of class %s", n, x$name, map$fieldType))
      }
  })

  x
}

is.type <- function(type) {
    switch(
        type,
        numeric = function(x) is.numeric(x) || is.integer(x),
        character = is.character
    )
}
