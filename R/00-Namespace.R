#' @importFrom dbtools testConnection Credentials
#' @importFrom devtools load_all
#' @importFrom dplyr select filter tibble as_tibble select_if mutate
#' @importFrom httr GET timeout
#' @importFrom magrittr "%>%"
#' @importFrom openxlsx read.xlsx
#' @importFrom rlang .data
#' @importFrom stringi stri_escape_unicode
#' @importFrom stats na.exclude setNames
#' @importFrom templates tmpl
#' @importFrom tidyr gather
#' @importFrom utils read.csv read.csv2
NULL

if (getRversion() >= "2.15.1")  utils::globalVariables(c("."))
