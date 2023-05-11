testthat::test_that("Function createNewDBSource()", {
  file.copy(
    from = file.path(testthat::test_path("examples"), "00-databases.R"),
    to = file.path(testthat::test_path(), "00-databases.R")
  )

  createNewDBSource(
    dataSourceName = "myDBname",
    dbName = "myDB",
    dbUser = "myUser",
    dbPassword = "myPw",
    dbHost = "abc-dbxy.fgj.com",
    dbPort = 567,
    tableName = "myTable",
    datingType = "radiocarbon",
    coordType = "decimal degrees",
    mappingName = "myMapping",
    scriptFolder = testthat::test_path(),
    rootFolder = testthat::test_path(),
    isTest = TRUE
  )

  # test extract script
  testScript <-
    readLines(testthat::test_path("02-myMapping_myDBname.R")) %>%
    cleanUpScript()

  expectedScript <-
    c(
      "extract.myDBname <- function(x) {",
      "  isoData <- get_myDBname()",
      "  x$dat <- isoData",
      "  x",
      "}",
      "creds_myDBname <- function() {",
      "  Credentials(",
      "    drv = RMySQL::MySQL,",
      "    user = Sys.getenv('MYDBNAME_USER'),",
      "    password = Sys.getenv('MYDBNAME_PASSWORD'),",
      "    dbname = Sys.getenv('MYDBNAME_NAME'),",
      "    host = Sys.getenv('MYDBNAME_HOST'),",
      "    port = as.numeric(Sys.getenv('MYDBNAME_PORT'))",
      "  )",
      "}",
      "get_myDBname <- function() {",
      "  query <- 'select * from myTable;'",
      "  dbtools::sendQuery(creds_myDBname(), query)",
      "}"
    )

  testthat::expect_equal(testScript, expectedScript)

  # test Renviron
  testRenviron <-
    readLines(testthat::test_path(".Renviron")) %>%
    cleanUpScript()

  expectedRenviron <-
    c(
      "MYDBNAME_DBNAME='myDB'",
      "MYDBNAME_USER='myUser'",
      "MYDBNAME_PASSWORD='myPw'",
      "MYDBNAME_HOST='abc-dbxy.fgj.com'",
      "MYDBNAME_PORT=567"
    )

  testthat::expect_equal(testRenviron, expectedRenviron)

  # test databases list, runs only locally
  # source(testthat::test_path("00-databases.R"))
  # testthat::expect_equal(mappingNames(), c("IsoMemo", "myMapping"))
  # testthat::expect_equal(dbnames(), c("14CSea", "LiVES", "IntChron", "CIMA", "myDBname"))
  # testthat::expect_equal(dbnames(mappingId = "myMapping"), c("myDBname"))
  # rm(list = ls(envir = .GlobalEnv), envir = .GlobalEnv)

  # clean up
  unlink(testthat::test_path("02-myMapping_myDBname.R"))
  unlink(testthat::test_path(".Renviron"))
  unlink(testthat::test_path("00-databases.R"))
})


testthat::test_that("Function setupRenviron()", {
  setupRenviron(
    dataSourceName = formatDataSourceName("gh-67*", toUpper = TRUE),
    dbName = "myDB",
    dbUser = "myUser",
    dbPassword = "myPw",
    dbHost = "abc-dbxy.fgj.com",
    dbPort = 567,
    scriptFolder = testthat::test_path()
  )

  testScript <-
    readLines(testthat::test_path(".Renviron")) %>%
    cleanUpScript()

  expectedScript <-
    c(
      "GH_67_DBNAME='myDB'",
      "GH_67_USER='myUser'",
      "GH_67_PASSWORD='myPw'",
      "GH_67_HOST='abc-dbxy.fgj.com'",
      "GH_67_PORT=567"
    )

  testthat::expect_equal(testScript, expectedScript)

  setupRenviron(
    dataSourceName = formatDataSourceName("dbXYZ", toUpper = TRUE),
    dbName = "myDB2",
    dbUser = "myUser2",
    dbPassword = "myPw2",
    dbHost = "mno-dbxy.stu.com",
    dbPort = 567,
    scriptFolder = testthat::test_path()
  )

  testScript <-
    readLines(testthat::test_path(".Renviron")) %>%
    cleanUpScript()

  expectedScript <-
    c(
      "GH_67_DBNAME='myDB'",
      "GH_67_USER='myUser'",
      "GH_67_PASSWORD='myPw'",
      "GH_67_HOST='abc-dbxy.fgj.com'",
      "GH_67_PORT=567",
      "DBXYZ_DBNAME='myDB2'",
      "DBXYZ_USER='myUser2'",
      "DBXYZ_PASSWORD='myPw2'",
      "DBXYZ_HOST='mno-dbxy.stu.com'",
      "DBXYZ_PORT=567"
    )

  testthat::expect_equal(testScript, expectedScript)

  # clean up
  unlink(testthat::test_path(".Renviron"))
})
