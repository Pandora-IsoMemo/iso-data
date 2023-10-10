# this script contains functions needed for the transform step of the etl

# Apply the mapping table ----
mapFields <- function(isoData, mapping, dataBase){
  names(isoData) <- stri_escape_unicode(names(isoData))

  fields <- mapping %>%
    select(.data$shiny, db = dataBase)

  fieldsRename <- fields %>%
    filter(!is.na(.data$db), nchar(.data$db) > 0)

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
    filter(.data$db %in% names(isoData))

  isoData <- isoData %>%
    dplyr::rename_at(dplyr::vars(fieldsRename$db), ~ fieldsRename$shiny)

  fieldsFill <- setdiff(fields$shiny, names(isoData))

  lapply(fieldsFill, function(x) { isoData[[x]] <<- NA })

  isoData <- isoData %>%
    dplyr::select_at(fields$shiny)

  return(isoData)
}

# Set IDs ----

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

# Prepare data ----

#' Prepare Data
#'
#' Prepares data within the transform step of the ETL. Following updates are done:
#' types of variables are set, latitude and longitude is converted into decimal degrees,
#' implausible latitude and longitude values are deleted, DOIs are added.
#'
#' @param isoData mapped data
#' @param mapping mapping table that was used
#' @inheritParams createNewFileSource
prepareData <- function(isoData, mapping, coordType){
  logging("... set variable types ... ")
  isoData <- setVariableType(isoData, mapping)

  if (is.na(coordType)) {
    logging("... CoordType not specified. Trying 'decimal degrees' ... ")
    tmpData <- try(convertLatLong(isoData, coordType = "decimal degrees"))
    if (!inherits(tmpData, "try-error")) {
      coordType <- "decimal degrees"
    }
  }

  if (coordType %in% c("decimal degrees", "degrees decimal minutes", "degrees minutes seconds")) {
    logging("... convert latitude and longitude into decimal degrees ... ")
    isoData <- convertLatLong(isoData, coordType = coordType)
    logging("... delete implausible latitude and longitude values ... ")
    isoData <- deleteInplausibleLatLong(isoData)
  } else if (!is.na(coordType)) {
    logging("... CoordType not valid. Conversion of latitude and longitude skipped ... ")
    warning("CoordType not valid. Conversion of latitude and longitude skipped.")
  } else {
    # if still is.na(coordType)
    logging("... Conversion of latitude and longitude failed and skipped ... ")
    warning("Conversion of latitude and longitude failed and skipped.")
  }

  logging("... add DOIs. ")
  isoData <- addDOIs(isoData)
  isoData
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

  oldLat <- isoData$latitude[inplausibleLat]
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
  isoData[[longitude]] <- convertCoordinates(isoData[[longitude]], from = coordType)
  isoData[[latitude]] <- convertCoordinates(isoData[[latitude]], from = coordType)
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
