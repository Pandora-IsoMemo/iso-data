context("data explorer get mapping table")

testthat::test_that("function getMappingTable", {

  mapping <- getMappingTable()
  testthat::expect_is(mapping, "data.frame")
  testthat::expect_true(nrow(mapping) > 0)
  testthat::expect_true(all(c("shiny", "fieldType", "category") %in% names(mapping)))

})

testthat::test_that("function mapFields", {
  df1 <- data.frame(
    idField = c(1, 2),
    var = c("a", "b"),
    description = c("e", "f"),
    stringsAsFactors = FALSE
  )

  df2 <- data.frame(
    ID = c(3, 4),
    DESCRIPTION = c("c", "d"),
    stringsAsFactors = FALSE
  )

  # partial matching and missing cols
  df3 <- data.frame(
    theDescription = c("g", "h"),
    stringsAsFactors = FALSE
  )

  mapping <- data.frame(
    shiny = c("id", "description"),
    fieldType = c("numeric", "character"),
    category = c("Sample description", "Sample description"),
    db1 = c("idField", NA),
    db2 = c("ID", "DESCRIPTION"),
    db3 = c("id", "Description"),
    stringsAsFactors = FALSE
  )

  res1 <- mapFields(df1, mapping, "db1")
  res2 <- mapFields(df2, mapping, "db2")
  res3 <- mapFields(df3, mapping, "db3")


  expect_equal(
    res1,
    data.frame(
      id = c(1, 2),
      description = c("e", "f"),
      stringsAsFactors = FALSE
    )
  )


  expect_equal(
    res2,
    data.frame(
      id = c(3, 4),
      description = c("c", "d"),
      stringsAsFactors = FALSE
    )
  )

  expect_equal(
    res3,
    data.frame(
      id = c(NA, NA),
      description = c("g", "h"),
      stringsAsFactors = FALSE
    )
  )
})
