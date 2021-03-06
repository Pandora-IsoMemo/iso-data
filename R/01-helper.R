# To prevent R CMD check from Complaining in line
# filter(!is.na(db), nchar(db) > 0)
utils::globalVariables("db")

mapFields <- function(isoData, mapping, dataBase){
  names(isoData) <- stri_escape_unicode(names(isoData))

  fields <- mapping %>%
    select(shiny, db = dataBase)

  fieldsRename <- fields %>%
    filter(!is.na(db), nchar(db) > 0)

  # partial matches
  pMatch <- lapply(fieldsRename$db, function(x){
    if (x %in% names(isoData)) NULL
    else {
      mm <- grep(x, names(isoData))
      if (length(mm) == 1) setNames(mm, x)
      else NULL
    }
  }) %>% unlist

  fieldsRename$db[match(names(pMatch), fieldsRename$db)] <- names(isoData)[pMatch]
  #

  fieldsRename <- fieldsRename %>%
    filter(db %in% names(isoData))

  isoData <- isoData %>%
    dplyr::rename_at(dplyr::vars(fieldsRename$db), ~ fieldsRename$shiny)

  fieldsFill <- setdiff(fields$shiny, names(isoData))

  lapply(fieldsFill, function(x) { isoData[[x]] <<- NA })

  isoData <- isoData %>%
    dplyr::select_at(fields$shiny)

  return(isoData)
}

setVariableType <- function(isoData, mapping){
  isoData <- isoData[, mapping$shiny]
  isoData[mapping$fieldType == "numeric"] <-
    sapply(isoData[mapping$fieldType == "numeric"],
           function(x) suppressWarnings(as.numeric(x)))
  isoData[mapping$fieldType == "character"] <-
    sapply(isoData[mapping$fieldType == "character"],
           function(x) suppressWarnings(as.character(x)))
  return(isoData)
}

handleIDs <- function(isoData){
  isoData$id <- as.character(isoData$id)
  isoData$id <- trimws(isoData$id)
  oldID <- isoData$id

  # handle NA
  isoData$id[is.na(isoData$id)] <- paste("NA", 1:sum(is.na(isoData$id)), sep = "-")

  # handle not unique ID's
  distinctify <- function(x){
    if (length(x) == 1) return(x)
    paste(x, seq_along(x), sep = "-")
  }

  while (any(duplicated(tolower(isoData$id)))){

    dump <- tapply(1:nrow(isoData), tolower(isoData$id), function(i){
      isoData$id[i] <<- distinctify(isoData$id[i])
    })

  }

  idConversions <- is.na(oldID) | isoData$id != oldID

  if (sum(idConversions) > 0)
    isoData <- addWarning(
      isoData,
      isoData$id[idConversions],
      paste("Id not unique. Changed from", oldID[idConversions],
            "to", isoData$id[idConversions])
    )

  isoData
}


deleteInplausibleLatLong <- function(isoData){
  inplausibleLong <- !is.na(isoData$longitude) & (
    isoData$longitude > 180 |
    isoData$longitude < - 180 |
    isoData$longitude == 0
  )
  oldLong <- isoData$longitude[inplausibleLong]
  isoData$longitude[inplausibleLong] <- NA

  inplausibleLat <- !is.na(isoData$latitude) & (
    isoData$latitude > 90 |
    isoData$latitude < - 90 |
    isoData$latitude == 0
  )

  oldLat <- isoData$Latiude[inplausibleLat]
  isoData$latitude[inplausibleLat] <- NA

  if (sum(inplausibleLong) > 0)
    isoData <- addWarning(
      isoData,
      isoData$id[inplausibleLong],
      paste("Inplausible Longitude Value: ", oldLong)
    )

  if (sum(inplausibleLat) > 0)
    isoData <- addWarning(
      isoData,
      isoData$id[inplausibleLat],
      paste("Inplausible Latitude Value: ", oldLat)
    )

  isoData
}

convertLatLong <- function(isoData, coordType,
                           latitude = "latitude", longitude = "longitude"){
  isoData[, longitude] <- convertCoordinates(isoData[, longitude], coordType)
  isoData[, latitude] <- convertCoordinates(isoData[, latitude], coordType)
  isoData
}

prepareData <- function(isoData, mapping, CoordType){
  isoData <- setVariableType(isoData, mapping)
  isoData <- deleteInplausibleLatLong(isoData)
  isoData <- convertLatLong(isoData, coordType = "decimal degrees")
  isoData <- addDOIs(isoData)
  isoData
}

convertCoordinates <- function(x, from = "decimal degrees", digits = 4){
  x <- gsub(",", ".", x)
  if (from == "decimal degrees"){
    return(round(as.numeric(x), digits))
  }
  x <- gsub("\u2032", "'", x)
  x <- gsub("`", "'", x)
  if (from == "degrees decimal minutes"){
    deg <- sapply(strsplit(x, c("\ub0")), function(k) k[1])
    min <- sapply(strsplit(x, c("\ub0")), function(k) k[2])
    min <- sapply(strsplit(min, split = "[']+"), function(k) k[1])
    dd <- as.numeric(deg) + as.numeric(min) / 60
    dd[grepl("W", x) | grepl("S", x)] <- -dd[grepl("W", x) | grepl("S", x)]
  }
  if (from == "degrees minutes seconds"){
    deg <- sapply(strsplit(x, c("\ub0")), function(k) k[1])
    rest <- sapply(strsplit(x, c("\ub0")), function(k) k[2])
    min <- sapply(strsplit(rest, c("'")), function(k) k[1])
    sec <- sapply(strsplit(rest, c("'")), function(k) k[2])
    sec <- unlist(regmatches(sec, gregexpr("[-+.e0-9]*\\d", sec)))
    dd <- as.numeric(deg) + as.numeric(min) / 60 + as.numeric(sec) / 3600
    dd[grepl("W", x) | grepl("S", x)] <- -dd[grepl("W", x) | grepl("S", x)]
  }

  dd <- round(dd, digits)

  return(dd)
}

addWarning <- function(isoData, id, warning){
  attr(isoData, "warning") <- rbind(
    attr(isoData, "warning"),
    data.frame(
      id = id,
      warning = warning,
      stringsAsFactors = FALSE
    )
  )
  isoData
}

 paste2 <- function (..., sep = " ", collapse = NULL, recycle0 = FALSE) {
      args <- list(...)

      args <- lapply(args, function(x) {
          x[is.na(x)] <- ""
          x
      })

      args$sep <- sep
      args$collapse <- collapse
      args$recycle0 <- recycle0

      trimws(do.call(paste, args))
  }

  isEmpty <- function(x) {
    is.null(x) | is.na(x) | x == ""
  }
