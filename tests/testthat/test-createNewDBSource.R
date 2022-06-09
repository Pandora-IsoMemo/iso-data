test_that("Function createNewDBSource()", {
  createNewDBSource(
    dbName = "DBname",
    tableName = "table",
    dbUser = NULL,
    dbPassword = NULL,
    dbHost = NULL,
    dbPort = NULL,
    descriptionCreator = "paste(\"Description\", isoData$var1, isoData$var2)",
    templateFolder = getFolderForTestedTemplates()
  )

  testScript <-
    readLines(testthat::test_path("02-DBname.R")) %>%
    cleanUpScript()

  expectedScript <-
    readLines(testthat::test_path("examples", "02-template-db.R")) %>%
    cleanUpScript()

  expect_equal(testScript, expectedScript)

  # clean up
  unlink(testthat::test_path("02-DBname.R"))
})
