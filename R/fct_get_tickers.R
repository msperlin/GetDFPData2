#' Retrieves a ticker list from cvm open data repository
#'
#' @param year year of the data (2018 onwards)
#'
#' @return
#' @export
#'
#' @examples
get_tickers <- function(year = lubridate::year(Sys.Date())) {

  min_year <- 2018
  max_year <- lubridate::year(Sys.Date())

  if (year < min_year) {
    cli::cli_abort("first year of data is {min_year}. You asked for {year}..")
  }

  if (year > max_year) {
    cli::cli_abort("max year of data is {max_year}. You asked for {year}..")
  }

  my_url <- glue::glue(
    "https://dados.cvm.gov.br/dados/CIA_ABERTA/DOC/FCA/DADOS/fca_cia_aberta_{year}.zip"
  )
  temp_zip <- fs::file_temp(ext = "zip")

  download.file(my_url, temp_zip)

  dir_to_unzip <- fs::file_temp("ticker-zip")
  fs::dir_create(dir_to_unzip)

  unzip(temp_zip, junkpaths = TRUE, exdir = dir_to_unzip)

  available_f <- fs::dir_ls(dir_to_unzip)

  str_to_search <- "fca_cia_aberta_valor_mobiliario"
  my_f <- stringr::str_subset(available_f, str_to_search)

  if (length(my_f) == 1) {
    cli::cli_alert_success("Found csv file!")
  } else {
    cli::cli_abort("cant find {str_to_search} csv file in zip..")
  }

  my_locale <- readr::locale(
    decimal_mark = ',',
    encoding = "latin1"
  )

  df_tickers <- readr::read_csv2(my_f, col_types = readr::cols(),
                                 locale = my_locale) |>
    janitor::clean_names() |>
    dplyr::mutate(year_file = year)

  cli::cli_alert_success("\tgot {nrow(df_tickers)} rows")

  return(df_tickers)
  }
