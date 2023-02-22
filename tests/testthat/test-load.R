test_that("deleteOldQry", {
  for (mapping in mappingNames()) {
    for (db in dbnames()) {
      expect_equal(
        deleteOldQry(mappingName = mapping, table = "data", source = db) %>% as.character(),
        paste0("DELETE FROM `", paste0(c(mapping, "data"), collapse = "_"), "` WHERE `source` = '", db, "';")
        )
    }
  }
})