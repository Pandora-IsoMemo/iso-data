test_that("Function createNewFileSource() for 02-CIMA.R file", {
  createNewFileSource(
    dbName = "CIMA",
    locationType = "remote",
    fileName = "cima-humans.xlsx",
    remotePath = "https://pandoradata.earth/dataset/cbbc35e0-af60-4224-beea-181be10f7f71/resource/f7581eb1-b2b8-4926-ba77-8bc92ddb4fdb/download/",
    descriptionCreator = "paste(isoData$Submitter.ID, isoData$Individual.ID)",
    scriptFolder = getFolderForTestedTemplates()
  )

  testScript <-
    readLines(testthat::test_path("02-CIMA.R")) %>%
    cleanUpScript()

  expectedScript <-
    readLines(testthat::test_path("examples", "02-CIMA.R")) %>%
    cleanUpScript()

  expect_equal(testScript, expectedScript)

  # clean up
  unlink(testthat::test_path("02-CIMA.R"))
})


test_that("Function createNewFileSource() for remote xlsx file", {
  createNewFileSource(
    dbName = "dbname",
    locationType = "remote",
    fileName = "14SEA_Full_Dataset_2017-01-29.xlsx",
    remotePath = "http://www.14sea.org/img/",
    sheetName = "14C Dates",
    scriptFolder = getFolderForTestedTemplates()
  )

  testScript <-
    readLines(testthat::test_path("02-dbname.R")) %>%
    cleanUpScript()

  expectedScript <-
    c(
      "extract.dbname <- function(x){",
      "  dataFile <- \"http://www.14sea.org/img/14SEA_Full_Dataset_2017-01-29.xlsx\"",
      "  isoData <- read.xlsx(xlsxFile = dataFile, sheet = \"14C Dates\")",
      "  x$dat <- isoData",
      "  x",
      "}"
    )

  expect_equal(testScript, expectedScript)

  # clean up
  unlink(testthat::test_path("02-dbname.R"))
})


test_that("Function createNewFileSource() for local csv file", {
  createNewFileSource(
    dbName = "dbname",
    locationType = "local",
    fileName = "IntChron.csv",
    sheetName = "14C Dates",
    descriptionCreator = "paste(\"Description\", isoData$var1, isoData$var2)",
    scriptFolder = getFolderForTestedTemplates()
  )

  testScript <-
    readLines(testthat::test_path("02-dbname.R")) %>%
    cleanUpScript()

  expectedScript <-
    c(
      "extract.dbname <- function(x){",
      "  dataFile <- system.file(\"extdata\", \"IntChron.csv\" , package = \"MpiIsoData\")",
      "  isoData <- read.csv(file = dataFile, stringsAsFactors = FALSE, ",
      "                      check.names = FALSE, na.strings = c(\"\", \"NA\"), ",
      "                      strip.white = TRUE)",
      "  isoData$description <- paste(\"Description\", isoData$var1, isoData$var2)",
      "  x$dat <- isoData",
      "  x",
      "}"
    )

  expect_equal(testScript, expectedScript)

  # clean up
  unlink(testthat::test_path("02-dbname.R"))
})
