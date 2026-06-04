read_dfp_csv <- function(file_in, clean_data) {

  if (clean_data) {
    cli::cli_alert_info("Reading & cleaning {basename(file_in)}")
  } else {
    cli::cli_alert_info("Reading {basename(file_in)}")
  }
  suppressMessages({

    VL_CONTA <- NULL

    df <- readr::read_csv2(file = file_in,
                           col_types = readr::cols(CD_CONTA = readr::col_character(),
                                                   VL_CONTA = readr::col_character(),
                                                   CD_CVM = readr::col_number()),
                           locale = readr::locale(decimal_mark = ',',
                                                  encoding = 'Latin1'),
                           progress = FALSE,
                           quote = '\\"') %>%
      dplyr::mutate(VL_CONTA = readr::parse_number(VL_CONTA))
  })

  if (clean_data) {

    df <- clean_dfp_itr_data(df, file_in)

  }

  return(df)
}
