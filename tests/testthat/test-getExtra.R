test_that("getExtra returns empty tibble when no extra variables", {
  df <- data.frame(id = 1:2, description = c("a", "b"), stringsAsFactors = FALSE)
  mapping <- "IsoMemo"
  db <- "testdb"
  res <- getExtra(df, db, mapping, type = "character")
  expect_true(is.data.frame(res))
  expect_equal(nrow(res), 0)
  expect_equal(names(res), c("mappingId", "source", "id", "variable", "value"))
})

test_that("getExtra returns extra character variables", {
  df <- data.frame(
    id = 1:2,
    description = c("a", "b"),
    num1 = c(10, 20),
    num2 = c(1.5, 2.5),
    char1 = c("x", "y"),
    char2 = c("foo", "bar"),
    stringsAsFactors = FALSE
  )
  mapping <- "IsoMemo"
  db <- "testdb"
  res <- getExtra(df, db, mapping, type = "character")
  expect_true(is.data.frame(res))
  expect_equal(unique(res$mappingId), mapping)
  expect_equal(unique(res$source), db)
  expect_equal(unique(res$id), 1:2)
  expect_setequal(res$variable, c("char1", "char2"))
  expect_setequal(res$value, c("x", "y", "foo", "bar"))
})

test_that("getExtra returns extra numeric variables", {
  df <- data.frame(
    id = 1:2,
    description = c("a", "b"),
    num1 = c(10, 20),
    num2 = c(1.5, 2.5),
    char1 = c("x", "y"),
    char2 = c("foo", "bar"),
    stringsAsFactors = FALSE
  )
  mapping <- "IsoMemo"
  db <- "testdb"
  res <- getExtra(df, db, mapping, type = "numeric")
  expect_true(is.data.frame(res))
  expect_equal(unique(res$mappingId), mapping)
  expect_equal(unique(res$source), db)
  expect_equal(unique(res$id), 1:2)
  expect_setequal(res$variable, c("num1", "num2"))
  expect_setequal(res$value, c(10, 20, 1.5, 2.5))
})

test_that("getExtra works with only id column", {
  df <- data.frame(id = 1:2)
  mapping <- "IsoMemo"
  db <- "testdb"
  res <- getExtra(df, db, mapping, type = "character")
  expect_true(is.data.frame(res))
  expect_equal(nrow(res), 0)
  expect_equal(names(res), c("mappingId", "source", "id", "variable", "value"))
})
