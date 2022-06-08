# add dbname also to R/00-databases.R!
extract.dbname <- function(x){
  # OPTION 1: load data (remote file)
  dataFile <- "http://www.14sea.org/img/14SEA_Full_Dataset_2017-01-29.xlsx"
  isoData <- read.xlsx(xlsxFile = dataFile, sheet = "14C Dates")

  # OPTION 2: local file (add to inst/extdata/)
  dataFile <- system.file("extdata", "data.csv", package = "MpiIsoData")

  # specify import options
  isoData <- read.csv(file = dataFile, stringsAsFactors = FALSE,
                      check.names = FALSE, na.strings = c("", "NA"),
                      strip.white = TRUE)


  #create Description
  isoData$description <- paste("Description", isoData$var1, isoData$var2)

  # pass isoData to next steps (no need to change anything here)
  x$dat <- isoData

  x
}

