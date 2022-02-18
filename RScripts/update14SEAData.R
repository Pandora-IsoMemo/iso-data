library(magrittr)

filePath <- "inst/extdata/14SEA_Full_Dataset.csv"

openxlsx::read.xlsx("http://www.14sea.org/img/14SEA_Full_Dataset_2017-01-29.xlsx") %>%
  data.table::fwrite(., file = filePath)



