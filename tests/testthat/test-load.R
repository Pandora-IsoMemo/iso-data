test_that("deleteOldRowsQry", {
  testMapping <- "IsoMemo"
  for (db in dbnames()) {
    expect_equal(
      deleteOldRowsFromDataQry(testMapping, source = db) %>% as.character(),
      paste0("DELETE FROM `IsoMemo_data` WHERE `source` = '", db, "';")
    )
  }

  for (db in dbnames()) {
    expect_equal(
      deleteOldRowsQry(testMapping, table = "extraCharacter", source = db) %>% as.character(),
      paste0("DELETE FROM `extraCharacter` WHERE `mappingId` = 'IsoMemo' AND `source` = '", db, "';")
    )
  }
})
