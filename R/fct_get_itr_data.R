#' Downloads and reads ITR datasets
#'
#' The ITR (informacoes trimestrais) is the quarterly reporting system of companies
#' traded at B3. This function will access the CVM ftp and parse all available files according to user
#' choices
#'
#' @inheritParams get_dfp_data
#' @param individual_quarters Should the function calculate single quarters for companies: TRUE (default) or FALSE. Be aware the original data
#' only includes accumulated quarters
#'
#' @return Dataframe with ITR data
#' @export
#'
#' @examples
#'
#' \dontrun{ # dontrun: keep cran check fast
#' df_itr <- get_itr_data() # fetches all available datasets
#' }
get_itr_data <- function(companies_cvm_codes = NULL,
                         first_year = 2010,
                         last_year = lubridate::year(Sys.Date()),
                         type_docs = c('BPA', 'BPP', 'DRE'),
                         type_format = c('con', 'ind'),
                         individual_quarters = TRUE,
                         clean_data = TRUE,
                         use_memoise = FALSE,
                         cache_folder = 'gcvmd_cache') {

  # check args
  available_docs <- c('BPA',
                      'BPP',
                      'DFC_MD',
                      'DFC_MI',
                      'DMPL',
                      'DRE',
                      'DVA')

  if (any(type_docs == '*')) {
    type_docs  <- available_docs
  }

  idx <- type_docs %in% available_docs
  if (any(!idx)) {
    stop(paste0('Cant find type type_docs: ', paste0(type_docs[!idx], collapse = ', ')),
         '\n\n',
         'Available type_docs are: ', paste0(available_docs, collapse = ', '))
  }

  available_formats <- c("ind",
                         "con" )

  idx <- type_format %in% available_formats
  if (any(!idx)) {
    stop(paste0('Cant find type type_format: ', paste0(type_format[!idx], collapse = ', ')),
         '\n\n',
         'Available type_format are: ', paste0(available_formats, collapse = ', '))
  }

  df_ftp_itr_full <- get_contents_ftp('http://dados.cvm.gov.br/dados/CIA_ABERTA/DOC/ITR/DADOS/')

  # remove 2010 (no data in zip file)
  idx <- df_ftp_itr_full$year_files > 2010
  df_ftp_itr_full <- df_ftp_itr_full[idx, ]


  # filter dates
  idx <- (df_ftp_itr_full$year_files >= first_year) & df_ftp_itr_full$year_files <= last_year
  df_ftp_itr <- df_ftp_itr_full[idx, ]

  if (nrow(df_ftp_itr) == 0 ) {
    stop('Cant find years in ftp. Available years: .',
         paste0(df_ftp_itr_full$year_files, collapse = ', '))
  }


  if (use_memoise) {
    # setup memoise

    mem_cache <- memoise::cache_filesystem(path = file.path(cache_folder, 'mem_cache'))
    download_read_itr_zip_file <- memoise::memoise(download_read_itr_zip_file,
                                                       cache = mem_cache)
  }

  df_itr <- dplyr::bind_rows(purrr::map(df_ftp_itr$full_links,
                                        download_read_itr_zip_file,
                                        clean_data = clean_data,
                                        companies_cvm_codes = companies_cvm_codes,
                                        type_docs = type_docs,
                                        type_format = type_format))

  # do calcuation of quarters
  if (individual_quarters) {
    # get annual data

    df_dfp <- get_dfp_data(companies_cvm_codes = companies_cvm_codes,
                             first_year = first_year,
                             last_year = last_year,
                             type_docs = c('DRE'),
                             type_format = type_format,
                             clean_data = clean_data,
                             use_memoise = use_memoise,
                             cache_folder = cache_folder)

    my_company <- df_itr$CNPJ_CIA[1]
    year_in <- 2019

    #build_quarterly_dre(my_company, year_in, df_itr, df_dfp)

    df_dfp_itr <- bind_rows(df_itr, df_dfp)

    browser()
    tbl <- df_dfp_itr %>%
      group_by(CNPJ_CIA, DENOM_CIA, lubridate::year(DT_REFER),
               GRUPO_DFP, CD_CONTA, DS_CONTA, COLUNA_DF) %>%
      summarise(Q1 = VL_CONTA[1],
                Q2 = VL_CONTA[2] - VL_CONTA[1],
                Q3 = VL_CONTA[3] - VL_CONTA[2],
                Q4 = VL_CONTA[4] - VL_CONTA[3])


    tidyr::pivot_longer(data = tbl, cols = c('Q1', 'Q2', 'Q3', 'Q4'),
                        names_to = c('quarter'), values_to = 'VL_CONTA')

    months(df_dfp$DT_FIM_EXERC)

  }

  return(df_itr)

}
