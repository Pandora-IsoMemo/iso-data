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
    scriptFolder = testthat::test_path(),
    rootFolder = testthat::test_path()
  )

  testScript <-
    readLines(testthat::test_path("02-MYDBNAME.R")) %>%
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
      "    user = Sys.getenv(\"MYDBNAME_USER\"),",
      "    password = Sys.getenv(\"MYDBNAME_PASSWORD\"),",
      "    dbname = Sys.getenv(\"MYDBNAME_NAME\"),",
      "    host = Sys.getenv(\"MYDBNAME_HOST\"),",
      "    port = as.numeric(Sys.getenv(\"MYDBNAME_PORT\"))",
      "  )",
      "}",
      "getMYDBNAME <- function() {",
      "  query <- \"select * from myTable;\"",
      "  dbtools::sendQuery(credsMYDBNAME(), query)",
      "}"
    )
  # readLines(testthat::test_path("examples", "02-template-db.R")) %>%
  # cleanUpScript()

  expectedRenviron <-
    c(
      "MYDBNAME_DBNAME=\"myDB\"",
      "MYDBNAME_USER=\"myUser\"",
      "MYDBNAME_PASSWORD=\"myPw\"",
      "MYDBNAME_HOST=\"abc-dbxy.fgj.com\"",
      "MYDBNAME_PORT=567"
    )

  testthat::expect_equal(testScript, expectedScript)
  testthat::expect_equal(testRenviron, expectedRenviron)

  # clean up
  unlink(testthat::test_path("02-MYDBNAME.R"))
  unlink(testthat::test_path(".Renviron"))
  unlink(testthat::test_path("00-databases.R"))
})


testthat::test_that("Function setupRenviron()", {
  setupRenviron(
    dataSourceName = formatDBName("gh-67*"),
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
      "GH_67_DBNAME=\"myDB\"",
      "GH_67_USER=\"myUser\"",
      "GH_67_PASSWORD=\"myPw\"",
      "GH_67_HOST=\"abc-dbxy.fgj.com\"",
      "GH_67_PORT=567"
    )

  testthat::expect_equal(testScript, expectedScript)

  setupRenviron(
    dataSourceName = formatDBName("dbXYZ"),
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
      "GH_67_DBNAME=\"myDB\"",
      "GH_67_USER=\"myUser\"",
      "GH_67_PASSWORD=\"myPw\"",
      "GH_67_HOST=\"abc-dbxy.fgj.com\"",
      "GH_67_PORT=567",
      "DBXYZ_DBNAME=\"myDB2\"",
      "DBXYZ_USER=\"myUser2\"",
      "DBXYZ_PASSWORD=\"myPw2\"",
      "DBXYZ_HOST=\"mno-dbxy.stu.com\"",
      "DBXYZ_PORT=567"
    )

  testthat::expect_equal(testScript, expectedScript)

  # clean up
  unlink(testthat::test_path(".Renviron"))
})


testthat::test_that("Function updateDatabaseList()", {
  file.copy(
    from = file.path(testthat::test_path("examples"), "00-databases.R"),
    to = file.path(testthat::test_path(), "00-databases.R")
  )

  updateDatabaseList(
    dataSourceName = formatDBName("abc#123"),
    datingType = "radiocarbonXYZ",
    coordType = "ABC degrees",
    scriptFolder = testthat::test_path()
  )

  testScript <-
    readLines(testthat::test_path("00-databases.R"))

  expectedScript <-
    c(
      "databases <- function() {",
      "  list(",
      "    singleSource (",
      "      name = '14CSea',",
      "      datingType = \"radiocarbon\",",
      "      coordType = \"decimal degrees\"",
      "    ),",
      "    singleSource (",
      "      name = 'LiVES',",
      "      datingType = \"radiocarbon\",",
      "      coordType = NA",
      "    ),",
      "    singleSource (",
      "      name = 'IntChron',",
      "      datingType = \"radiocarbon\",",
      "      coordType = \"decimal degrees\"",
      "    ),",
      "    singleSource (",
      "      name = \"CIMA\",",
      "      datingType = \"radiocarbon\",",
      "      coordType = \"decimal degrees\"",
      "        ),",
      "        singleSource (",
      "          name = \"ABC_123\",",
      "          datingType = \"radiocarbonXYZ\",",
      "          coordType = \"ABC degrees\"",
      "    )",
      "  )",
      "}",
      "",
      "dbnames <- function() {",
      "  unlist(lapply(databases(), `[[`, \"name\"))",
      "}",
      "singleSource <- function(name, datingType, coordType, ...) {",
      "  out <- list(name = name,",
      "              datingType = datingType,",
      "              coordType = coordType,",
      "              ...)",
      "  class(out) <- c(name, \"list\")",
      "  out",
      "}"
    )

  testthat::expect_equal(testScript, expectedScript)

  # clean up
  unlink(testthat::test_path("00-databases.R"))
})
