testthat::test_that("Function updateDatabaseList()", {
  file.copy(
    from = file.path(testthat::test_path("examples"), "00-databases.R"),
    to = file.path(testthat::test_path(), "00-databases.R")
  )

  updateDatabaseList(
    dataSourceName = formatDataSourceName("abc#123"),
    datingType = "radiocarbonXYZ",
    coordType = "ABC degrees",
    mappingName = "Field_Mapping",
    scriptFolder = testthat::test_path()
  )

  testScript <-
    readLines(testthat::test_path("00-databases.R"))

  expectedScript <-
    c("databases <- function() {",
      "  list(",
      "    singleSource (",
      "      name = '14CSea',",
      "      datingType = 'radiocarbon',",
      "      coordType = 'decimal degrees',",
      "      mapping = 'Field_Mapping'",
      "    ),",
      "    singleSource (",
      "      name = 'LiVES',",
      "      datingType = 'radiocarbon',",
      "      coordType = NA,",
      "      mapping = 'Field_Mapping'",
      "    ),",
      "    singleSource (",
      "      name = 'IntChron',",
      "      datingType = 'radiocarbon',",
      "      coordType = 'decimal degrees',",
      "      mapping = 'Field_Mapping'",
      "    ),",
      "    singleSource (",
      "      name = 'CIMA',",
      "      datingType = 'radiocarbon',",
      "      coordType = 'decimal degrees',",
      "      mapping = 'Field_Mapping'",
      "        ),",
      "        singleSource (",
      "          name = 'ABC_123',",
      "          datingType = 'radiocarbonXYZ',",
      "          coordType = 'ABC degrees',",
      "          mapping = 'Field_Mapping'",
      "    )",
      "  )",
      "}",
      "",
      "dbnames <- function() {",
      "  unlist(lapply(databases(), `[[`, 'name'))",
      "}",
      "singleSource <- function(name, datingType, coordType, mapping, ...) {",
      "  out <- list(",
      "    name = name,",
      "    datingType = datingType,",
      "    coordType = coordType,",
      "    mapping = mapping,",
      "    ...",
      "    )",
      "  class(out) <- c(name, 'list')",
      "  out",
      "}"
    )

  testthat::expect_equal(testScript, expectedScript)

  # clean up
  unlink(testthat::test_path("00-databases.R"))
})
