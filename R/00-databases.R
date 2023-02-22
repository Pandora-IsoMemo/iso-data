databases <- function() {
    list(
        singleSource (
            name = '14CSea',
            datingType = 'radiocarbon',
            coordType = 'decimal degrees',
            mapping = 'Field_Mapping'
        ),
        singleSource (
            name = 'LiVES',
            datingType = 'radiocarbon',
            coordType = NA,
            mapping = 'Field_Mapping'
        ),
        singleSource (
            name = 'IntChron',
            datingType = 'radiocarbon',
            coordType = 'decimal degrees',
            mapping = 'Field_Mapping'
        ),
        singleSource (
           name = 'CIMA',
           datingType = 'radiocarbon',
           coordType = 'decimal degrees',
           mapping = 'Field_Mapping'
        )
    )
}

dbnames <- function() {
    unlist(lapply(databases(), `[[`, 'name'))
}

mappingNames <- function() {
  unlist(lapply(databases(), `[[`, 'mapping')) %>%
    unique()
}

singleSource <- function(name, datingType, coordType, ...) {
  out <- list(
    name = name,
    datingType = datingType,
    coordType = coordType,
    ...
  )
  class(out) <- c(name, 'list')
  out
}
