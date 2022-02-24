dbCreds <- function(){
  Credentials(
    drv = RMySQL::MySQL,
    user = Sys.getenv("DB_USER"),
    password = Sys.getenv("DB_PASSWORD"),
    dbname = Sys.getenv("DB_NAME"),
    host = Sys.getenv("DB_HOST"),
    port = as.numeric(Sys.getenv("DB_PORT"))
  )
}
