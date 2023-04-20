# Set up for a data source from a file

extract.{{ dataSourceName }} <- function(x) {
  # DO NOT MODIFY:
  # path to file
  dataFile <- {{ filePath }}

  # import options
  isoData <- {{ fileImport }}

  # -------
  # CUSTOMIZE DATA PREPARATION:


  # e.g. paste two columns to define a new description column. For this, uncomment and update
  # column names.
  # adds a description
  #  isoData$description <- paste(isoData$var1, isoData$var2)


  # -------
  # DO NOT MODIFY:
  # passing isoData to next steps (no need to change anything here)
  x$dat <- isoData

  x
}
