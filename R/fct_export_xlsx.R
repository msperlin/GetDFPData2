#' Export DFP/ITR data to a xlsx file
#'
#' @param l_dfp A list from get_dfp_data or get_itr_data
#' @param f_xlsx Path to xlsx file
#'
#' @return A dataframe with several information about B3 companies
#' @export
#'
#' @examples
#'
#' \dontrun{ # keep cran check fast
#' df_info <- get_info_companies()
#' str(df_info)
#' }
export_xlsx <- function(l_dfp, f_xlsx = 'GetDFPData-XLSX.xlsx') {

  my_file_ext <- tools::file_ext(f_xlsx)

  if (my_file_ext != 'xlsx') stop('File extension for f_xlsx should be .xlsx')

  message('Exporting file to ', f_xlsx)
  writexl::write_xlsx(x = l_dfp,
                      path = f_xlsx)

  message(stringr::str_glue('\nDone! File saved at {f_xlsx}.') )
  return(invisible(TRUE))

}
