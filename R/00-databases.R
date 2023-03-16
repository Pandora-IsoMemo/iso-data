databases <- function() {
    list(
        singleSource (
            name = '14CSea',
            datingType = "radiocarbon",
            coordType = "decimal degrees"
        ),
        singleSource (
            name = 'LiVES',
            datingType = "radiocarbon",
            coordType = NA
        ),
        singleSource (
            name = 'IntChron',
            datingType = "radiocarbon",
            coordType = "decimal degrees"
        ),
        singleSource (
           name = "CIMA",
           datingType = "radiocarbon",
           coordType = "decimal degrees"
        )
    )
}

dbnames <- function() {
    unlist(lapply(databases(), `[[`, "name"))
}

singleSource <- function(name, datingType, coordType, ...) {
  out <- list(
    name = name,
    datingType = datingType,
    coordType = coordType,
    sendReport = sendDataMPI,
    ...
  )
  class(out) <- c(name, "list")
  out
}
