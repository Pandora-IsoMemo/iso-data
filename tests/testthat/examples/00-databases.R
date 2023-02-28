databases <- function() {
  list(
    singleSource (
      name = '14CSea',
      datingType = 'radiocarbon',
      coordType = 'decimal degrees',
      mapping = 'IsoMemo'
    ),
    singleSource (
      name = 'LiVES',
      datingType = 'radiocarbon',
      coordType = NA,
      mapping = 'IsoMemo'
    ),
    singleSource (
      name = 'IntChron',
      datingType = 'radiocarbon',
      coordType = 'decimal degrees',
      mapping = 'IsoMemo'
    ),
    singleSource (
      name = 'CIMA',
      datingType = 'radiocarbon',
      coordType = 'decimal degrees',
      mapping = 'IsoMemo'
    )
  )
}

dbnames <- function() {
  unlist(lapply(databases(), `[[`, 'name'))
}

singleSource <- function(name, datingType, coordType, mapping, ...) {
  out <- list(
    name = name,
    datingType = datingType,
    coordType = coordType,
    mapping = mapping,
    ...
    )
  class(out) <- c(name, 'list')
  out
}
