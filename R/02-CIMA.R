# add dbname also to R/00-databases.R!
extract.CIMA <- function(x){
  # OPTION 1: load data (remote file)
  dataFile <- "https://pandoradata.earth/dataset/cbbc35e0-af60-4224-beea-181be10f7f71/resource/f7581eb1-b2b8-4926-ba77-8bc92ddb4fdb/download/cima-humans.xlsx"
  isoData <- read.xlsx(xlsxFile = dataFile)

  # names(isoData)
  #
  isoData$description <- paste(isoData$Submitter.ID, isoData$Individual.ID)

  #create Description
  # isoData$description <- paste("Description", isoData$var1, isoData$var2)

  # pass isoData to next steps (no need to change anything here)
  x$dat <- isoData

  x
}

