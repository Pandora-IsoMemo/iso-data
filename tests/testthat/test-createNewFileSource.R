testthat::test_that("Function createNewFileSource() duplicate dataSourceName", {
  expect_error(
    createNewFileSource(
      dataSourceName = "CiMa",
      datingType = "radiocarbon",
      coordType = "decimal degrees",
      mappingName = "IsoMemo",
      locationType = "remote",
      fileName = "cima-humans.xlsx",
      remotePath = "https://pandoradata.earth/dataset/cbbc35e0-af60-4224-beea-181be10f7f71/resource/f7581eb1-b2b8-4926-ba77-8bc92ddb4fdb/download/",
      scriptFolder = testthat::test_path(),
      isTest = TRUE
    )
  )
})


testthat::test_that("Function createNewFileSource() for 02-CIMA.R file", {
  file.copy(
    from = file.path(testthat::test_path("examples"), "00-databases.R"),
    to = file.path(testthat::test_path(), "00-databases.R")
  )

  createNewFileSource(
    dataSourceName = "CIMA2",
    datingType = "radiocarbon",
    coordType = "decimal degrees",
    mappingName = "IsoMemo",
    locationType = "remote",
    fileName = "cima-humans.xlsx",
    remotePath = "https://pandoradata.earth/dataset/cbbc35e0-af60-4224-beea-181be10f7f71/resource/f7581eb1-b2b8-4926-ba77-8bc92ddb4fdb/download",
    scriptFolder = testthat::test_path(),
    isTest = TRUE
  )

  testScript <-
    readLines(testthat::test_path("02-IsoMemo_CIMA2.R")) %>%
    cleanUpScript()

  expectedScript <-
    c(
      "extract.CIMA2 <- function(x) {",
      "  logDebug(\"Entering extract method for '%s'\", x$name)",
      "  dataFile <- file.path('https://pandoradata.earth/dataset/cbbc35e0-af60-4224-beea-181be10f7f71/resource/f7581eb1-b2b8-4926-ba77-8bc92ddb4fdb/download', 'cima-humans.xlsx')",
      "  isoData <- read.xlsx(xlsxFile = dataFile, sheet = 1)",
      "  x$dat <- isoData",
      "  x",
      "}"
    )

  testthat::expect_equal(testScript, expectedScript)


  # Test databases list, runs only locally
  # source(testthat::test_path("00-databases.R"))
  # testthat::expect_equal(mappingNames(), c("IsoMemo", "IsoMemo"))
  # testthat::expect_equal(dbnames(), c("14CSea", "LiVES", "IntChron", "CIMA", "CIMA2"))
  # testthat::expect_equal(dbnames(mappingId = "IsoMemo"), c("CIMA2"))
  # rm(list = ls(envir = .GlobalEnv), envir = .GlobalEnv)

  # clean up
  unlink(testthat::test_path("02-IsoMemo_CIMA2.R"))
  unlink(testthat::test_path("00-databases.R"))
})


testthat::test_that("Function createNewFileSource() for remote xlsx file", {
  file.copy(
    from = file.path(testthat::test_path("examples"), "00-databases.R"),
    to = file.path(testthat::test_path(), "00-databases.R")
  )

  createNewFileSource(
    dataSourceName = "dbname",
    datingType = "radiocarbon",
    coordType = "decimal degrees",
    mappingName = "IsoMemo",
    locationType = "remote",
    fileName = "14SEA_Full_Dataset_2017-01-29.xlsx",
    remotePath = "http://www.14sea.org/img",
    sheetNumber = 1,
    scriptFolder = testthat::test_path(),
    isTest = TRUE
  )

  testScript <-
    readLines(testthat::test_path("02-IsoMemo_dbname.R")) %>%
    cleanUpScript()

  expectedScript <-
    c(
      "extract.dbname <- function(x) {",
      "  logDebug(\"Entering extract method for '%s'\", x$name)",
      "  dataFile <- file.path('http://www.14sea.org/img', '14SEA_Full_Dataset_2017-01-29.xlsx')",
      "  isoData <- read.xlsx(xlsxFile = dataFile, sheet = 1)",
      "  x$dat <- isoData",
      "  x",
      "}"
    )

  testthat::expect_equal(testScript, expectedScript)

  # Test databases list, runs only locally
  # source(testthat::test_path("00-databases.R"))
  # testthat::expect_equal(mappingNames(), c("IsoMemo", "IsoMemo"))
  # testthat::expect_equal(dbnames(), c("14CSea", "LiVES", "IntChron", "CIMA", "dbname"))
  # testthat::expect_equal(dbnames(mappingId = "IsoMemo"), c("dbname"))
  # rm(list = ls(envir = .GlobalEnv), envir = .GlobalEnv)

  # clean up
  unlink(testthat::test_path("02-IsoMemo_dbname.R"))
  unlink(testthat::test_path("00-databases.R"))
})


testthat::test_that("Function createNewFileSource() for local csv file", {
  file.copy(
    from = file.path(testthat::test_path("examples"), "00-databases.R"),
    to = file.path(testthat::test_path(), "00-databases.R")
  )

  createNewFileSource(
    dataSourceName = "dbname",
    datingType = "radiocarbon",
    coordType = "decimal degrees",
    mappingName = "IsoMemo",
    locationType = "local",
    fileName = "IntChron.csv",
    scriptFolder = testthat::test_path(),
    isTest = TRUE
  )

  testScript <-
    readLines(testthat::test_path("02-IsoMemo_dbname.R")) %>%
    cleanUpScript()

  expectedScript <-
    c(
      "extract.dbname <- function(x) {",
      "  logDebug(\"Entering extract method for '%s'\", x$name)",
      "  dataFile <- file.path(system.file('extdata', package = 'MpiIsoData'), 'IntChron.csv')",
      "  isoData <- read.csv2(file = dataFile, sep = ';', dec = ',', stringsAsFactors = FALSE, check.names = FALSE, na.strings = c('', 'NA'), strip.white = TRUE)",
      "  x$dat <- isoData",
      "  x",
      "}"
    )

  testthat::expect_equal(testScript, expectedScript)

  # Test databases list, runs only locally
  # source(testthat::test_path("00-databases.R"))
  # testthat::expect_equal(dbnames(), c("14CSea", "LiVES", "IntChron", "CIMA", "dbname"))
  # testthat::expect_equal(mappingNames(), c("IsoMemo", "IsoMemo"))
  # testthat::expect_equal(dbnames(mappingId = "IsoMemo"), c("dbname"))
  # rm(list = ls(envir = .GlobalEnv), envir = .GlobalEnv)

  # clean up
  unlink(testthat::test_path("02-IsoMemo_dbname.R"))
  unlink(testthat::test_path("00-databases.R"))
})
