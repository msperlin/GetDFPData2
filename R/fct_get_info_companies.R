#' Returns a up to date table with information about B3 companies
#'
#' Imports a dataset from cvm <http://sistemas.cvm.gov.br/cadastro/SPW_CIA_ABERTA.ZIP>, containing
#' up to date information about companies, active or not.
#'
#' @inheritParams get_dfp_data
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
get_info_companies <- function(cache_folder = 'gcvmd_cache') {

  # create folder
  if (!dir.exists(cache_folder)) dir.create(cache_folder)

  message('Fetching info on B3 companies')
  # check if cache file exists
  my_f_rdata <- file.path(cache_folder,
                          paste0('df_info_CACHED_',
                                 Sys.Date(), '.rds') )

  if (file.exists(my_f_rdata)) {
    message('\tFound cache file. Loading data..')
    df_cvm <- readRDS(my_f_rdata)

  } else {
    # get data from github
    message('\tDowloading file from CVM')

    link_cvm <- 'http://sistemas.cvm.gov.br/cadastro/SPW_CIA_ABERTA.ZIP'
    dest_file <-  file.path(tempfile(fileext = '.zip'))

    #suppressMessages({
    my_download_file(dl_link = link_cvm, dest_file = dest_file, max_dl_tries = 10)
    #})
    message('\tReading file from CVM')
    df_cvm <- readr::read_delim(dest_file,
                                delim = '\t',
                                locale = readr::locale(encoding = 'Latin1'),
                                col_types = readr::cols(CNPJ = readr::col_character()))

    # setting cnpj number
    df_cvm$cnpj_number <- as.numeric(df_cvm$CNPJ)

    message('\tSaving cache data')
    saveRDS(object = df_cvm, file = my_f_rdata)
  }

  # build message
  temp_df <- df_cvm[ ,c('DENOM_SOCIAL', 'SIT_REG')]
  n_actives <- sum(unique(temp_df)$SIT_REG == 'ATIVO')
  n_inactives <- sum(unique(temp_df)$SIT_REG != 'ATIVO' )

  message(paste0('\tGot ', nrow(df_cvm), ' lines for ', length(unique(df_cvm$DENOM_SOCIAL)), ' companies ',
                 '[Actives = ', n_actives, ' Inactives = ', n_inactives, ']') )

  return(df_cvm)

}
