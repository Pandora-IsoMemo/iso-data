test_that("Function createNewFileSource() duplicate dbName", {
  expect_error(
    createNewFileSource(
      dbName = "CiMa",
      datingType = "radiocarbon",
      coordType = "decimal degrees",
      locationType = "remote",
      fileName = "cima-humans.xlsx",
      remotePath = "https://pandoradata.earth/dataset/cbbc35e0-af60-4224-beea-181be10f7f71/resource/f7581eb1-b2b8-4926-ba77-8bc92ddb4fdb/download/",
      scriptFolder = testthat::test_path()
    )
  )
})


test_that("Function createNewFileSource() for 02-CIMA.R file", {
  file.copy(
    from = file.path(testthat::test_path("examples"), "00-databases.R"),
    to = file.path(testthat::test_path(), "00-databases.R")
  )

  createNewFileSource(
    dbName = "CIMA2",
    datingType = "radiocarbon",
    coordType = "decimal degrees",
    locationType = "remote",
    fileName = "cima-humans.xlsx",
    remotePath = "https://pandoradata.earth/dataset/cbbc35e0-af60-4224-beea-181be10f7f71/resource/f7581eb1-b2b8-4926-ba77-8bc92ddb4fdb/download/",
    scriptFolder = testthat::test_path()
  )

  testScript <-
    readLines(testthat::test_path("02-CIMA2.R")) %>%
    cleanUpScript()

  expectedScript <-
    c(
      "extract.CIMA2 <- function(x){",
      "  dataFile <- \"https://pandoradata.earth/dataset/cbbc35e0-af60-4224-beea-181be10f7f71/resource/f7581eb1-b2b8-4926-ba77-8bc92ddb4fdb/download/cima-humans.xlsx\"",
      "  isoData <- read.xlsx(xlsxFile = dataFile)",
      "  x$dat <- isoData",
      "  x",
      "}"
    )
  # readLines(testthat::test_path("examples", "02-CIMA.R")) %>%
  # cleanUpScript()

  expect_equal(testScript, expectedScript)

  # clean up
  unlink(testthat::test_path("02-CIMA2.R"))
  unlink(testthat::test_path("00-databases.R"))
})


test_that("Function createNewFileSource() for remote xlsx file", {
  file.copy(
    from = file.path(testthat::test_path("examples"), "00-databases.R"),
    to = file.path(testthat::test_path(), "00-databases.R")
  )

  createNewFileSource(
    dbName = "dbname",
    datingType = "radiocarbon",
    coordType = "decimal degrees",
    locationType = "remote",
    fileName = "14SEA_Full_Dataset_2017-01-29.xlsx",
    remotePath = "http://www.14sea.org/img/",
    sheetName = "14C Dates",
    scriptFolder = testthat::test_path()
  )

  testScript <-
    readLines(testthat::test_path("02-DBNAME.R")) %>%
    cleanUpScript()

  expectedScript <-
    c(
      "extract.DBNAME <- function(x){",
      "  dataFile <- \"http://www.14sea.org/img/14SEA_Full_Dataset_2017-01-29.xlsx\"",
      "  isoData <- read.xlsx(xlsxFile = dataFile, sheet = \"14C Dates\")",
      "  x$dat <- isoData",
      "  x",
      "}"
    )

  expect_equal(testScript, expectedScript)

  # clean up
  unlink(testthat::test_path("02-DBNAME.R"))
  unlink(testthat::test_path("00-databases.R"))
})


test_that("Function createNewFileSource() for local csv file", {
  file.copy(
    from = file.path(testthat::test_path("examples"), "00-databases.R"),
    to = file.path(testthat::test_path(), "00-databases.R")
  )

  createNewFileSource(
    dbName = "dbname",
    datingType = "radiocarbon",
    coordType = "decimal degrees",
    locationType = "local",
    fileName = "IntChron.csv",
    scriptFolder = testthat::test_path()
  )

  testScript <-
    readLines(testthat::test_path("02-DBNAME.R")) %>%
    cleanUpScript()

  expectedScript <-
    c(
      "extract.DBNAME <- function(x){",
      "  dataFile <- system.file(\"extdata\", \"IntChron.csv\" , package = \"MpiIsoData\")",
      "  isoData <- read.csv(file = dataFile, stringsAsFactors = FALSE, ",
      "                      check.names = FALSE, na.strings = c(\"\", \"NA\"), ",
      "                      strip.white = TRUE)",
      "  x$dat <- isoData",
      "  x",
      "}"
    )

  expect_equal(testScript, expectedScript)

  # clean up
  unlink(testthat::test_path("02-DBNAME.R"))
  unlink(testthat::test_path("00-databases.R"))
})
