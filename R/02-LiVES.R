extract.LiVES <- function(x){

  dataFile <- system.file("extdata", "Individuen_Rosenstock.csv", package = "MpiIsoData")
  dataFile2 <- system.file("extdata", "Fundorte_Rosenstock.csv", package = "MpiIsoData")

  sites <-  read.csv2(file = dataFile2, stringsAsFactors = FALSE, check.names = FALSE,
                      na.strings = c("", "NA"), strip.white = TRUE, encoding = "UTF-8")
  names(sites) <- stri_escape_unicode(names(sites))

  individuals <-  read.csv2(file = dataFile,
                            stringsAsFactors = FALSE, check.names = FALSE,
                            na.strings = c("", "NA"),
                            strip.white = TRUE, encoding = "UTF-8")
  names(individuals) <- stri_escape_unicode(names(individuals))

  isoData <- merge(individuals, sites, by.x = "Fundort-ID", by.y = "ID", all.x = TRUE)

  #data Prep
  isoData$description <- paste(isoData$Fundort_Individuum, ",", isoData$`rel Dat`)

  isoData$datingType <- NA
  isoData$datingType[!is.na(isoData$Radiocarbon)] <- "radiocarbon"
  isoData$datingType[is.na(isoData$Radiocarbon)] <- "expert"

  isoData$Radiocarbon[is.na(isoData$Radiocarbon)] <-
    (isoData$lower_dat + isoData$upper_dat)[is.na(isoData$Radiocarbon)] / 2
  isoData$`Radiocarbon unc`[is.na(isoData$`Radiocarbon unc`)] <-
    (isoData$lower_dat - isoData$upper_dat)[is.na(isoData$`Radiocarbon unc`)] / 4

  x$dat <- isoData
  
  x
}
