context("Add warnings")

test_that("Add warnings", {
  isoData <- data.frame(id = 1:10)

  isoData <- addWarning(isoData, 2:3, "Problem")

  expect_equal(attr(isoData, "warning"), data.frame(
    id = 2:3,
    warning = "Problem",
    stringsAsFactors = FALSE
  ))

  isoData <- addWarning(isoData, 3:4, "Another Problem")

  expect_equal(attr(isoData, "warning"), data.frame(
    id = c(2:3, 3:4),
    warning = rep(c("Problem", "Another Problem"), each = 2),
    stringsAsFactors = FALSE
  ))
})
