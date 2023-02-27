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
    mappingName = "Field_Mapping",
    scriptFolder = testthat::test_path(),
    rootFolder = testthat::test_path()
  )

  testScript <-
    readLines(testthat::test_path("02-Field_Mapping_MYDBNAME.R")) %>%
    cleanUpScript()

  testRenviron <-
    readLines(testthat::test_path(".Renviron")) %>%
    cleanUpScript()

  expectedScript <-
    c(
      "extract.MYDBNAME <- function(x) {",
      "  isoData <- getMYDBNAME()",
      "  x$dat <- isoData",
      "  x",
      "}",
      "credsMYDBNAME <- function() {",
      "  Credentials(",
      "    drv = RMySQL::MySQL,",
      "    user = Sys.getenv('MYDBNAME_USER'),",
      "    password = Sys.getenv('MYDBNAME_PASSWORD'),",
      "    dbname = Sys.getenv('MYDBNAME_NAME'),",
      "    host = Sys.getenv('MYDBNAME_HOST'),",
      "    port = as.numeric(Sys.getenv('MYDBNAME_PORT'))",
      "  )",
      "}",
      "getMYDBNAME <- function() {",
      "  query <- 'select * from myTable;'",
      "  dbtools::sendQuery(credsMYDBNAME(), query)",
      "}"
    )
  # readLines(testthat::test_path("examples", "02-template-db.R")) %>%
  # cleanUpScript()

  expectedRenviron <-
    c(
      "MYDBNAME_DBNAME='myDB'",
      "MYDBNAME_USER='myUser'",
      "MYDBNAME_PASSWORD='myPw'",
      "MYDBNAME_HOST='abc-dbxy.fgj.com'",
      "MYDBNAME_PORT=567"
    )

  testthat::expect_equal(testScript, expectedScript)
  testthat::expect_equal(testRenviron, expectedRenviron)

  # clean up
  unlink(testthat::test_path("02-Field_Mapping_MYDBNAME.R"))
  unlink(testthat::test_path(".Renviron"))
  unlink(testthat::test_path("00-databases.R"))
})


testthat::test_that("Function setupRenviron()", {
  setupRenviron(
    dataSourceName = formatDataSourceName("gh-67*"),
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
    dataSourceName = formatDataSourceName("dbXYZ"),
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
