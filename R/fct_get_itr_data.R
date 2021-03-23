get_itr_data <- function(companies_cvm_codes = NULL,
                         first_year = 2010,
                         last_year = lubridate::year(Sys.Date()),
                         type_docs = c('BPA', 'BPP', 'DRE'),
                         type_format = c('con', 'ind'),
                         individual_dre_quarters = TRUE,
                         clean_data = TRUE,
                         use_memoise = FALSE,
                         cache_folder = 'gdfpd2_cache') {

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

  # remove 2010 (no data in zip file) - NO MORE NEEDED 2020-10-17
  # idx <- df_ftp_itr_full$year_files > 2010
  # df_ftp_itr_full <- df_ftp_itr_full[idx, ]

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
                                        type_format = type_format,
                                        cache_folder = cache_folder))

  # do calculation of quarters
  if (individual_dre_quarters) {
    # making sure cran check doesnt complain about undefined globals
    CD_CONTA <- CD_CVM <- CNPJ_CIA <- COLUNA_DF <- DENOM_CIA <- NULL
    DS_CONTA <- DT_FIM_EXERC <- DT_REFER <- ESCALA_MOEDA <- NULL
    GRUPO_DFP <- MOEDA <- ORDEM_EXERC <- VL_CONTA <- NULL
    my_year <- quarter <- source_file <- NULL

    # get annual data
    df_dfp <- get_dfp_data(companies_cvm_codes = companies_cvm_codes,
                           first_year = first_year,
                           last_year = last_year,
                           type_docs = c('DRE'),
                           type_format = 'ind',
                           clean_data = clean_data,
                           use_memoise = use_memoise,
                           cache_folder = cache_folder)[[1]]


    df_dfp_itr <- dplyr::bind_rows(df_itr %>%
                              dplyr::filter(
                                stringr::str_detect(stringr::str_to_lower(source_file),
                                                    'dre_ind')),
                              df_dfp)

    tbl <- df_dfp_itr %>%
      dplyr::filter(stringr::str_detect(GRUPO_DFP, 'Individual')) %>%
      dplyr::group_by(CNPJ_CIA, CD_CVM, DENOM_CIA,
                      my_year = lubridate::year(DT_REFER),
                      GRUPO_DFP, CD_CONTA, DS_CONTA, COLUNA_DF ) %>%
      dplyr::summarise(Q1 = VL_CONTA[1],
                       Q2 = VL_CONTA[2] - VL_CONTA[1],
                       Q3 = VL_CONTA[3] - VL_CONTA[2],
                       Q4 = VL_CONTA[4] - VL_CONTA[3],
                       .groups = "drop_last" ) %>%
      dplyr::ungroup()


    dre_longer <- tidyr::pivot_longer(data = tbl, cols = c('Q1', 'Q2', 'Q3', 'Q4'),
                                      names_to = c('quarter'), values_to = 'VL_CONTA')

    name_group <- dre_longer$GRUPO_DFP[1]

    # figure out quarter dates
    df_extra <- df_dfp_itr %>%
      #dplyr::filter(stringr::str_detect(GRUPO_DFP, 'Individual')) %>%
      dplyr::mutate(quarter = quarters(DT_REFER, abbreviate = FALSE),
                    my_year = lubridate::year(DT_REFER)) %>%
      dplyr::select(CNPJ_CIA,
                    DT_REFER, DT_FIM_EXERC,
                    MOEDA, ESCALA_MOEDA, ORDEM_EXERC,
                    quarter, my_year) %>%
      unique() %>%
      dplyr::arrange(CNPJ_CIA, DT_REFER)

    # replace DRE Data, but keeping same columns
    df_itr <- df_itr %>%
      dplyr::filter(GRUPO_DFP != name_group) %>%
      dplyr::bind_rows(dre_longer %>%
                         dplyr::left_join(df_extra ) %>%
                         dplyr::select(-my_year) )


  }

  # split into list
  l_out <- split(df_itr, f = df_itr$GRUPO_DFP)

  return(l_out)

}
