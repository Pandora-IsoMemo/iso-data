test_that("Function generateTemplateDataSource() expect errors", {
  expect_error(
    generateTemplateDataSource(dbName = "DBname",
                               dbType = "abc"),
    "dbType not found. Only use 'file' or 'database'."
  )

  expect_error(
    generateTemplateDataSource(dbName = "DBname",
                               dbType = "database"),
    "tableName not found. Please provide 'tableName' for dbType = 'database'."
  )
})


test_that("Function generateTemplateDataSource() for 02-CIMA.R file", {
  testScript <- generateTemplateDataSource(
    dbName = "CIMA",
    dbType = "file",
    locationType = "remote",
    fileName = "cima-humans.xlsx",
    remotePath = "https://pandoradata.earth/dataset/cbbc35e0-af60-4224-beea-181be10f7f71/resource/f7581eb1-b2b8-4926-ba77-8bc92ddb4fdb/download/",
    descriptionCreator = "paste(isoData$Submitter.ID, isoData$Individual.ID)",
    sheetName = NULL,
    dbUser = NULL,
    dbPassword = NULL,
    dbHost = NULL,
    dbPort = NULL,
    tableName = NULL
  ) %>%
    cleanUpScript()

  expectedScript <-
    readLines(testthat::test_path("examples", "02-CIMA.R")) %>%
    cleanUpScript()

  expect_equal(testScript, expectedScript)
})


test_that("Function generateTemplateDataSource() from remote xlsx file", {
  testScript <- generateTemplateDataSource(
    dbName = "dbname",
    dbType = "file",
    locationType = "remote",
    fileName = "14SEA_Full_Dataset_2017-01-29.xlsx",
    remotePath = "http://www.14sea.org/img/",
    sheetName = "14C Dates"
  ) %>%
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
})


test_that("Function generateTemplateDataSource() from local csv file", {
  testScript <- generateTemplateDataSource(
    dbName = "dbname",
    dbType = "file",
    locationType = "local",
    fileName = "IntChron.csv",
    sheetName = "14C Dates",
    descriptionCreator = "paste(\"Description\", isoData$var1, isoData$var2)",
  ) %>%
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
})


test_that("Function generateTemplateDataSource() from db", {
  testScript <- generateTemplateDataSource(
    dbName = "DBname",
    dbType = "database",
    descriptionCreator = "paste(\"Description\", isoData$var1, isoData$var2)",
    locationType = NULL,
    fileName = NULL,
    remotePath = NULL,
    sheetName = NULL,
    dbUser = NULL,
    dbPassword = NULL,
    dbHost = NULL,
    dbPort = NULL,
    tableName = "table"
  ) %>%
    cleanUpScript()

  expectedScript <-
    readLines(testthat::test_path("examples", "02-template-db.R")) %>%
    cleanUpScript()

  expect_equal(testScript, expectedScript)
})
