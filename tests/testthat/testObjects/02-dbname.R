# Template to set up a new data source
# add dbname also to R/00-databases.R!
extract.dbname <- function(x){
# set path to file
  dataFile <- system.file("extdata", "IntChron.csv" , package = "MpiIsoData")
# specify import options
  isoData <- read.csv(file = dataFile, stringsAsFactors = FALSE, 
                      check.names = FALSE, na.strings = c("", "NA"), 
                      strip.white = TRUE)

  # create Description
  isoData$description <- paste("Description", isoData$var1, isoData$var2)

# pass isoData to next steps (no need to change anything here)
  x$dat <- isoData

  x
}

