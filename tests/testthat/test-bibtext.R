test_that("split_doi splits DOI URLs correctly", {
  # Standard DOI URL with http://dx.doi.org/
  res <- split_doi("http://dx.doi.org/10.7717/peerj.3074/table-2")
  expect_equal(res$prefix, "http://dx.doi.org/")
  expect_equal(res$doi, "10.7717/peerj.3074/table-2")

  res <- split_doi("http://dx.doi.org/10.7717/peerjcs.88/table-1")
  expect_equal(res$prefix, "http://dx.doi.org/")
  expect_equal(res$doi, "10.7717/peerjcs.88/table-1")

  # Standard DOI URLs
  res1 <- split_doi("https://doi.org/10.1234/abcd")
  expect_equal(res1$prefix, "https://doi.org/")
  expect_equal(res1$doi, "10.1234/abcd")

  res2 <- split_doi("http://dx.doi.org/10.5678/efgh")
  expect_equal(res2$prefix, "http://dx.doi.org/")
  expect_equal(res2$doi, "10.5678/efgh")

  # DOI without URL prefix
  res3 <- split_doi("10.9999/xyz")
  expect_equal(res3$prefix, "")
  expect_equal(res3$doi, "10.9999/xyz")

  # Empty string
  res4 <- split_doi("")
  expect_equal(res4$prefix, "")
  expect_equal(res4$doi, "")

  # NA input
  res5 <- split_doi(NA_character_)
  expect_equal(res5$prefix, NA_character_)
  expect_equal(res5$doi, NA_character_)

  # Vectorized input
  urls <- c("https://doi.org/10.1/one", "http://dx.doi.org/10.2/two", "10.3/three")
  res6 <- split_doi(urls)
  expect_equal(res6$prefix, c("https://doi.org/", "http://dx.doi.org/", ""))
  expect_equal(res6$doi, c("10.1/one", "10.2/two", "10.3/three"))
})

test_that("add_bibtex works with real API calls (manual only)", {
  skip("Testing add_bibtex(): Manual test only. Requires internet and real API calls to CrossRef.")

  test_df <- structure(list(
    id = c("Hd-21015", "Lyon-7621 SacA-22582", "UBA-18098", "Bln-607=Bln-5742", "OxA-13687"),
    description = c(
      "Unidentified charcoal , Early Neolithic II/4 , NA",
      "Charcoal , DT II , Sect. 2, unit 2087, 54.80 m asl",
      "Animal bone , Criş I , Complex 57 unit 2865",
      "Charcoal , NA , 2,20–2,50 m depth",
      "Human bone , NA , Burial 10"
    ),
    d13C = c(NA, NA, NA, NA, -19.1),
    d15N = c(NA_real_, NA_real_, NA_real_, NA_real_, NA_real_),
    latitude = c(NA_real_, NA_real_, NA_real_, NA_real_, NA_real_),
    longitude = c(NA_real_, NA_real_, NA_real_, NA_real_, NA_real_),
    site = c("Bademaǧacı", "Dikili Tash", "Măgura-Boldul lui Moș Ivănuș", "Căscioarele-Ostrovel", "Varna Cemetery"),
    dateMean = c(7481, 5750, 6959, 5560, 5569),
    dateLower = c(NA_real_, NA_real_, NA_real_, NA_real_, NA_real_),
    dateUpper = c(NA_real_, NA_real_, NA_real_, NA_real_, NA_real_),
    dateUncertainty = c(40, 30, 28, 100, 32),
    datingType = c(NA_character_, NA_character_, NA_character_, NA_character_, NA_character_),
    calibratedDate = c(NA_real_, NA_real_, NA_real_, NA_real_, NA_real_),
    calibratedDateLower = c(NA_real_, NA_real_, NA_real_, NA_real_, NA_real_),
    calibratedDateUpper = c(NA_real_, NA_real_, NA_real_, NA_real_, NA_real_),
    measure = c(NA_character_, NA_character_, NA_character_, NA_character_, NA_character_),
    databaseReference = rep(
      "Salesse, K., Fernandes, R., de Rochefort, X., Brů ž ek, J., Castex, D. and Dufour, É ., 2018. IsoArcH. eu: An open-access and collaborative isotope database for bioarchaeological samples from the Graeco-Roman world and its margins. Journal of Archaeological Science: Reports, 19, pp.1050-1055.",
      5
    ),
    databaseDOI = rep("https://doi.org/10.1016/j.jasrep.2017.07.030", 5),
    databaseDOIAuto = rep(NA_real_, 5),
    compilationReference = rep(NA_character_, 5),
    compilationDOI = rep(NA_character_, 5),
    compilationDOIAuto = rep(NA_real_, 5),
    originalDataReference = c(
      "Thissen 2002: 317 Duru 2002: 588",
      "Maniatis et al. 2016: Table 1 Tsirtsoni 2016: 290",
      "Balasse et al. 2013: 222, 223 Table 1",
      "Dumitrescu 1974: 23–39 Reingruber & Rassamakin 2016: Appendix",
      "Higham et al. 2008: 95–114 Higham et al. 2007: 640–654 Reingruber 2015: Appendix"
    ),
    originalDataDOI = c(
      "https://doi.org/10.1093/gmo/9781561592630.article.o002725",
      "https://doi.org/10.7717/peerj.3968/table-1",
      "https://doi.org/10.1484/j.ra.5.147957",
      "https://doi.org/10.2307/j.ctv171vv.10",
      "https://doi.org/10.7717/peerj.18652/fig-2"
    ),
    originalDataDOIAuto = rep(1, 5)
  ),
  row.names = c(613L, 1263L, 2267L, 2517L, 2650L),
  class = "data.frame"
  )

  result <- add_bibtex(test_df)
  expect_true(all(c("databaseBibtex", "compilationBibtex", "originalDataBibtex") %in% names(result)))
  print(result[, c("databaseDOI", "databaseBibtex", "compilationDOI", "compilationBibtex", "originalDataDOI", "originalDataBibtex")])
  print(colnames(result))
})
