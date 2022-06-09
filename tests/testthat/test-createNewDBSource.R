test_that("Function createNewDBSource()", {
  file.copy(
    from = file.path(testthat::test_path("examples"), "00-databases.R"),
    to = file.path(testthat::test_path(), "00-databases.R")
  )

  createNewDBSource(
    dbName = "DBname",
    tableName = "table",
    datingType = "radiocarbon",
    coordType = "decimal degrees",
    descriptionCreator = "paste(\"Description\", isoData$var1, isoData$var2)",
    scriptFolder = testthat::test_path(),
    rootFolder = testthat::test_path()
  )

  testScript <-
    readLines(testthat::test_path("02-DBname.R")) %>%
    cleanUpScript()

  testRenviron <-
    readLines(testthat::test_path(".Renviron"))

  expectedScript <-
    readLines(testthat::test_path("examples", "02-template-db.R")) %>%
    cleanUpScript()

  expectedRenviron <-
    c(
      "# Never upload any credentials to GitHub. The variable definitions are only placeholders",
      "# for Jenkins. Do not fill in credentials!",
      "# Uploading this script helps to maintain an overview for setting up all db connections.",
      "",
      "DBNAME_USER=\"\"",
      "DBNAME_PASSWORD=\"\"",
      "DBNAME_NAME=\"\"",
      "DBNAME_HOST=\"\"",
      "DBNAME_PORT=\"\""
    )

  expect_equal(testScript, expectedScript)
  expect_equal(testRenviron, expectedRenviron)

  # clean up
  unlink(testthat::test_path("02-DBname.R"))
  unlink(testthat::test_path(".Renviron"))
  unlink(testthat::test_path("00-databases.R"))
})


test_that("Function setupRenviron()", {
  setupRenviron(dbName = "dbName1", scriptFolder = testthat::test_path())

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

  expect_equal(testScript, expectedScript)

  setupRenviron(dbName = "dbXYZ", scriptFolder = testthat::test_path())

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

  expect_equal(testScript, expectedScript)

  # clean up
  unlink(testthat::test_path(".Renviron"))
})


test_that("Function updateDatabaseList()", {
  file.copy(
    from = file.path(testthat::test_path("examples"), "00-databases.R"),
    to = file.path(testthat::test_path(), "00-databases.R")
  )

  updateDatabaseList(dbName = "dbName1",
                     datingType = "radiocarbonXYZ",
                     coordType = "ABC degrees",
                     scriptFolder = testthat::test_path())

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
      "          name = \"dbName1\",",
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

  expect_equal(testScript, expectedScript)

  # clean up
  unlink(testthat::test_path("00-databases.R"))
})
