# Set up for a data source from a file

extract.{{ dbName }} <- function(x) {
  # set path to file
  dataFile <- {{ filePath }}

  # specify import options
  isoData <- {{ fileImport }}

  # create Description
  #
  # e.g. paste two columns to define a new description column. For this, uncomment and update
  # column names.
  # add code here if required ->>>

  #  isoData$description <- paste(isoData$var1, isoData$var2)

  # <<<- until here

  # pass isoData to next steps (no need to change anything here)
  x$dat <- isoData

  x
}
