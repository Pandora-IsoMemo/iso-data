test_that("deleteOldDataQry", {
  testMapping <- "IsoMemo"
  for (db in dbnames()) {
    expect_equal(
      deleteOldDataQry(paste0(testMapping, "_data"), source = db) %>% as.character(),
      paste0("DELETE FROM `IsoMemo_data` WHERE `source` = '", db, "';")
    )
  }

  for (db in dbnames()) {
    expect_equal(
      deleteOldDataQry(table = "extraCharacter", source = db, mappingId = testMapping) %>% as.character(),
      paste0("DELETE FROM `extraCharacter` WHERE `mappingId` = 'IsoMemo' AND `source` = '", db, "';")
    )
  }
})

test_that("createTableQry", {
  testData <-
    structure(
      list(
        source = "14CSea",
        id = "DEM-518",
        description = "Charcoal , NA , Trench A3, layer 3, spit 4, depth 0.48 m, loose sediment",
        d13C = -25,
        d15N = NA_real_,
        latitude = NA_real_,
        longitude = NA_real_,
        site = "Kouveleiki Cave A",
        dateMean = 5881,
        dateLower = NA_real_,
        dateUpper = NA_real_,
        dateUncertainty = 43,
        datingType = NA_character_,
        calibratedDate = NA_real_,
        calibratedDateLower = NA_real_,
        calibratedDateUpper = NA_real_
      ),
      row.names = 885L,
      class = "data.frame"
    )

  expect_equal(
    createTableQry(testData, table = "IsoMemo_data") %>% as.character(),
    paste0("CREATE TABLE IF NOT EXISTS `IsoMemo_data` (",
           "'source' varchar(50) NOT NULL, ",
           "'id' varchar(50) NOT NULL, ",
           "'description' varchar(50) NOT NULL, ",
           "'d13C' decimal(12,6) DEFAULT NULL, ",
           "'d15N' decimal(12,6) DEFAULT NULL, ",
           "'latitude' decimal(12,6) DEFAULT NULL, ",
           "'longitude' decimal(12,6) DEFAULT NULL, ",
           "'site' varchar(50) NOT NULL, ",
           "'dateMean' decimal(12,6) DEFAULT NULL, ",
           "'dateLower' decimal(12,6) DEFAULT NULL, ",
           "'dateUpper' decimal(12,6) DEFAULT NULL, ",
           "'dateUncertainty' decimal(12,6) DEFAULT NULL, ",
           "'datingType' varchar(50) NOT NULL, ",
           "'calibratedDate' decimal(12,6) DEFAULT NULL, ",
           "'calibratedDateLower' decimal(12,6) DEFAULT NULL, ",
           "'calibratedDateUpper' decimal(12,6) DEFAULT NULL, ",
           "PRIMARY KEY (`source`,`id`)",
           ") ENGINE=InnoDB DEFAULT CHARSET=utf8;")
  )
})
