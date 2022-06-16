testthat::test_that("Function createNewDBSource()", {
  file.copy(
    from = file.path(testthat::test_path("examples"), "00-databases.R"),
    to = file.path(testthat::test_path(), "00-databases.R")
  )

  createNewDBSource(
    dbName = "myDBname",
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
    readLines(testthat::test_path(".Renviron"))

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
      "# Never upload any credentials to GitHub. The variable definitions are only placeholders",
      "# for Jenkins. Do not fill in credentials!",
      "# Uploading this script helps to maintain an overview for setting up all db connections.",
      "",
      "MYDBNAME_USER=\"\"",
      "MYDBNAME_PASSWORD=\"\"",
      "MYDBNAME_NAME=\"\"",
      "MYDBNAME_HOST=\"\"",
      "MYDBNAME_PORT=\"\""
    )

  testthat::expect_equal(testScript, expectedScript)
  testthat::expect_equal(testRenviron, expectedRenviron)

  # clean up
  unlink(testthat::test_path("02-MYDBNAME.R"))
  unlink(testthat::test_path(".Renviron"))
  unlink(testthat::test_path("00-databases.R"))
})


testthat::test_that("Function setupRenviron()", {
  setupRenviron(dbName = formatDBName("dbName1"),
                scriptFolder = testthat::test_path())

  testScript <-
    readLines(testthat::test_path(".Renviron"))

  expectedScript <-
    c(
      "# Never upload any credentials to GitHub. The variable definitions are only placeholders",
      "# for Jenkins. Do not fill in credentials!",
      "# Uploading this script helps to maintain an overview for setting up all db connections.",
      "",
      "DBNAME1_USER=\"\"",
      "DBNAME1_PASSWORD=\"\"",
      "DBNAME1_NAME=\"\"",
      "DBNAME1_HOST=\"\"",
      "DBNAME1_PORT=\"\""
    )

  testthat::expect_equal(testScript, expectedScript)

  setupRenviron(dbName = formatDBName("dbXYZ"),
                scriptFolder = testthat::test_path())

  testScript <-
    readLines(testthat::test_path(".Renviron"))

  expectedScript <-
    c(
      "# Never upload any credentials to GitHub. The variable definitions are only placeholders",
      "# for Jenkins. Do not fill in credentials!",
      "# Uploading this script helps to maintain an overview for setting up all db connections.",
      "",
      "DBNAME1_USER=\"\"",
      "DBNAME1_PASSWORD=\"\"",
      "DBNAME1_NAME=\"\"",
      "DBNAME1_HOST=\"\"",
      "DBNAME1_PORT=\"\"",
      "",
      "DBXYZ_USER=\"\"",
      "DBXYZ_PASSWORD=\"\"",
      "DBXYZ_NAME=\"\"",
      "DBXYZ_HOST=\"\"",
      "DBXYZ_PORT=\"\""
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
    dbName = formatDBName("dbName1"),
    datingType = "radiocarbonXYZ",
    coordType = "ABC degrees",
    scriptFolder = testthat::test_path()
  )

  testScript <-
    readLines(testthat::test_path("00-databases.R"))

  expectedScript <-
    c(
      "databases <- function() {",
      "    list(",
      "        singleSource (",
      "            name = '14CSea',",
      "            datingType = \"radiocarbon\",",
      "            coordType = \"decimal degrees\"",
      "        ),",
      "        singleSource (",
      "            name = 'LiVES',",
      "            datingType = \"radiocarbon\",",
      "            coordType = NA",
      "        ),",
      "        singleSource (",
      "            name = 'IntChron',",
      "            datingType = \"radiocarbon\",",
      "            coordType = \"decimal degrees\"",
      "        ),",
      "        singleSource (",
      "           name = \"CIMA\",",
      "           datingType = \"radiocarbon\",",
      "           coordType = \"decimal degrees\"",
      "        ),",
      "        singleSource (",
      "          name = \"DBNAME1\",",
      "          datingType = \"radiocarbonXYZ\",",
      "          coordType = \"ABC degrees\"",
      "        )",
      "    )",
      "}",
      "",
      "dbnames <- function() {",
      "    unlist(lapply(databases(), `[[`, \"name\"))",
      "}",
      "singleSource <- function(name, datingType, coordType, ...) {",
      "  out <- list(",
      "    name = name,",
      "    datingType = datingType,",
      "    coordType = coordType,",
      "    ...",
      "  )",
      "  class(out) <- c(name, \"list\")",
      "  out",
      "}"
    )

  testthat::expect_equal(testScript, expectedScript)

  # clean up
  unlink(testthat::test_path("00-databases.R"))
})
