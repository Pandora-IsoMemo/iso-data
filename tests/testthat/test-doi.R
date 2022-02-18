context("Lookup DOI")

test_that("DOI already present", {
    df <- data.frame(
        ref = c("a", "a"),
        doi = c("1", ""),
        auto = c(TRUE, FALSE)
    )

    res <- fillDOI(df, "ref", "doi", "auto")

    expect_equal(res$ref, df$ref)
    expect_equal(res$doi, c("1", "1"))
    expect_equal(res$auto, c(TRUE, TRUE))
})

test_that("Single Reference", {
    df <- data.frame(
        ref = "Salesse, K., Fernandes, R., de Rochefort, X., Brůžek, J., Castex, D. and Dufour, É., 2018.
            IsoArcH. eu: An open-access and collaborative isotope database for bioarchaeological samples
            from the Graeco-Roman world and its margins. Journal of Archaeological Science: Reports, 19,
            pp.1050-1055.",
        doi = "",
        auto = FALSE
    )

    res <- fillDOI(df, "ref", "doi", "auto")

    expect_equal(res$ref, df$ref)
    expect_equal(res$doi, "http://dx.doi.org/10.1016/j.jasrep.2017.07.030")
    expect_equal(res$auto, TRUE)
})

test_that("Empty ref", {
    df <- data.frame(
        ref = c("", NA),
        doi = "",
        auto = FALSE
    )

    res <- fillDOI(df, "ref", "doi", "auto")

    expect_equal(res, df)
})