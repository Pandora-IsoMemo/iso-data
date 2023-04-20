extract.14CSea <- function(x){
  #load data
  dataFile <- "http://www.14sea.org/img/14SEA_Full_Dataset_2017-01-29.xlsx"
  isoData <- read.xlsx(xlsxFile = dataFile, sheet = "14C Dates")

  #create Description
  isoData$description <- paste(isoData$Material, ",",
                               isoData$Level, ",", isoData$Provenance)

  # References
  isoData$databaseReference <- "Salesse, K., Fernandes, R., de Rochefort, X., Br\u016F \u017E ek, J., Castex, D. and Dufour, \u00C9 ., 2018. IsoArcH. eu: An open-access and collaborative isotope database for bioarchaeological samples from the Graeco-Roman world and its margins. Journal of Archaeological Science: Reports, 19, pp.1050-1055."
  isoData$databaseDOI <- "https://doi.org/10.1016/j.jasrep.2017.07.030"

  isoData$originalDataReference <- paste2(isoData$Reference.1, isoData$Reference.2, isoData$Reference.3, isoData$Reference.4)

  x$dat <- isoData

  x
}
