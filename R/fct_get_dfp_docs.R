#' Get data from dfp docs
#'
#' @inheritParams get_dfp_data
#'
#' @return A dataframe
#' @export
#'
#' @examples
#' \dontrun{
#' # no example
#' }
get_dfp_docs <- function(companies_cvm_codes,
                         type_docs, type_format, first_year, last_year, clean_data,
                         use_memoise,
                         cache_folder) {

  message('\nDownloading ', type_docs)
  ftp_url <- paste0('http://dados.cvm.gov.br/dados/CIA_ABERTA/DOC/DFP/',
                    type_docs ,
                    '/DADOS/')
  df_ftp_full <- get_contents_ftp(ftp_url)

  # filter dates
  idx <- df_ftp_full$year_files >= first_year & df_ftp_full$year_files <= last_year

  df_ftp <- df_ftp_full[idx, ]

  if (nrow(df_ftp) == 0 ) {
    stop('Cant find years in ftp. Available years: .',
         paste0(df_ftp_full$year_files, collapse = ', '))
  }

  message('\tFound ', nrow(df_ftp), ' files at ftp')

  # setup memoise
  if (use_memoise) {
    mem_cache <- memoise::cache_filesystem(path = file.path(cache_folder, 'mem_cache'))
    download_read_dfp_zip_file <- memoise::memoise(download_read_dfp_zip_file,
                                                   cache = mem_cache)
  }


  df_doc <- dplyr::bind_rows(purrr::map(df_ftp$full_links,
                                        download_read_dfp_zip_file,
                                        clean_data = clean_data,
                                        type_format = type_format,
                                        companies_cvm_codes = companies_cvm_codes))


  return(df_doc)


}
