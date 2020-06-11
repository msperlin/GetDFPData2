#' Reads ITR csv file
#'
#' @param file_in path of csv file
#' @inheritParams get_itr_data
#'
#' @return A dataframe
#' @export
#'
#' @examples
#'
#' \dontrun{
#' # no example
#' }
#'
read_itr_csv <- function(file_in, clean_data) {

  message('\t\tReading ', basename(file_in), appendLF = TRUE)
  df <- readr::read_csv2(file = file_in,
                         col_types = readr::cols(CD_CVM = readr::col_number(),
                                                 CD_CONTA = readr::col_character(),
                                                 VL_CONTA = readr::col_number()),
                         locale = readr::locale(decimal_mark = ',', encoding = 'Latin1'),
                         progress = FALSE)

  if (nrow(df) == 0) {
    warning('Found 0 row table in file ', basename(file_in))
    return(dplyr::tibble())
  }


  if (clean_data) {

    df <- clean_dfp_itr_data(df, file_in)

  }


  return(df)
}
