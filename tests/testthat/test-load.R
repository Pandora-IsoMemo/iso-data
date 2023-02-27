test_that("deleteOldDataQry", {
  testMapping <- "Field_Mapping"
  for (db in dbnames()) {
    expect_equal(
      deleteOldDataQry(mappingName = testMapping, table = "data", source = db) %>% as.character(),
      paste0("DELETE FROM `data` WHERE `source` = '", db, "';")
    )
  }
})
