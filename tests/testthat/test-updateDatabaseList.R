testthat::test_that("Function updateDatabaseList()", {
  file.copy(
    from = file.path(testthat::test_path("examples"), "00-databases.R"),
    to = file.path(testthat::test_path(), "00-databases.R")
  )

  updateDatabaseList(
    dataSourceName = formatDataSourceName("abc#123"),
    datingType = "radiocarbonXYZ",
    coordType = "ABC degrees",
    mappingName = "IsoMemo",
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
      "      datingType = 'radiocarbon',",
      "      coordType = 'decimal degrees',",
      "      mapping = 'IsoMemo'",
      "    ),",
      "    singleSource (",
      "      name = 'LiVES',",
      "      datingType = 'radiocarbon',",
      "      coordType = NA,",
      "      mapping = 'IsoMemo'",
      "    ),",
      "    singleSource (",
      "      name = 'IntChron',",
      "      datingType = 'radiocarbon',",
      "      coordType = 'decimal degrees',",
      "      mapping = 'IsoMemo'",
      "    ),",
      "    singleSource (",
      "      name = 'CIMA',",
      "      datingType = 'radiocarbon',",
      "      coordType = 'decimal degrees',",
      "      mapping = 'IsoMemo'",
      "        ),",
      "        singleSource (",
      "          name = 'abc_123',",
      "          datingType = 'radiocarbonXYZ',",
      "          coordType = 'ABC degrees',",
      "          mapping = 'IsoMemo'",
      "    )",
      "  )",
      "}",
      "",
      "dbnames <- function(mappingId = NULL) {",
      "  if (is.null(mappingId)) {",
      "    unlist(lapply(databases(), `[[`, 'name'))",
      "  } else {",
      "    isMapping <-",
      "      sapply(databases(), function(source)",
      "        source[[\"mapping\"]] == mappingId)",
      "    dbOfMapping <- databases()[isMapping]",
      "    unlist(lapply(dbOfMapping, `[[`, 'name'))",
      "  }",
      "}",
      "mappingNames <- function() {",
      "  unlist(lapply(databases(), `[[`, 'mapping')) %>%",
      "    unique()",
      "}",
      "singleSource <-",
      "  function(name, datingType, coordType, mapping, ...) {",
      "    out <- list(",
      "      name = name,",
      "      datingType = datingType,",
      "      coordType = coordType,",
      "      mapping = mapping,",
      "      ...",
      "    )",
      "    class(out) <- c(name, 'list')",
      "    out",
      "  }"
    )

  testthat::expect_equal(testScript, expectedScript)

  # clean up
  unlink(testthat::test_path("00-databases.R"))
})
