#' Reads DFP csv file
#'
#' @param file_in path of csv file
#' @inheritParams get_dfp_data
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
read_dfp_csv <- function(file_in, clean_data) {

  message('\t\tReading ', basename(file_in))
  df <- readr::read_csv2(file = file_in,
                         col_types = readr::cols(CD_CONTA = readr::col_character(),
                                                 VL_CONTA = readr::col_number()),
                         locale = readr::locale(decimal_mark = ',', encoding = 'Latin1'),
                         progress = FALSE)

  if (clean_data) {

    df <- clean_dfp_itr_data(df, file_in)

  }

  return(df)
}
