library(testthat)
library(MpiIsoData)

Sys.setenv(ETL_TEST = "1")
on.exit(Sys.setenv(ETL_TEST = "0"))

test_check("MpiIsoData")
