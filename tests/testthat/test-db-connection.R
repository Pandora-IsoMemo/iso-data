context("Database connection")

test_that("Database connection can be established", {
  skip("Manual/CI only: requires database access and credentials.")
  expect_error({
    con <- DBI::dbConnect(RMySQL::MySQL(),
                         dbname = Sys.getenv("DB_NAME"),
                         host = Sys.getenv("DB_HOST"),
                         user = Sys.getenv("DB_USER"),
                         password = Sys.getenv("DB_PASSWORD"),
                         port = as.integer(Sys.getenv("DB_PORT", unset = 3306)))
    DBI::dbDisconnect(con)
  }, NA)
})
