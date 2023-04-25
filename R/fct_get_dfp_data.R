#' Downloads and reads DFP datasets
#'
#' The DFP (demonstrativos financeiros padronizados) is the annual reporting system of companies
#' traded at B3. This function will access the CVM ftp and parse all available files according to user
#' choices
#'
#' @param companies_cvm_codes Numeric CVM code  of companies. IF set to NULL (default), will return data for all available companies.
#' @param first_year First year of selected data
#' @param last_year Last year of selected data
#' @param type_docs Type of financial documents. E.g. c('DRE', 'BPA'). Definitions: '*' = fetch all docs,  'BPA' = Assets (ativos),
#'                 'BPP' = Liabilities (passivo),
#'                 'DRE' = income statement (demonstrativo de resultados),
#'                 'DFC_MD' = cash flow by direct method (fluxo de caixa pelo metodo direto),
#'                 'DFC_MI' = cash flow by indirect method (fluxo de caixa pelo metodo indireto),
#'                 'DMPL' = statement of changes in equity (mutacoes do patrimonio liquido),
#'                 'DVA' = value added report (desmonstrativo de valor agregado)
#' @param type_format Type of format of document (con = consolidated, ind = individual). Default = c('con', 'ind')
#' @param clean_data Clean data or return raw data? See read_dfp|itr_csv() for details
#' @param use_memoise Use memoise caching? If no (default), the function will read all .csv files. If yes, will use package
#'                    memoise for caching results (execution speed increases significantly)
#' @param cache_folder Path of cache folder to keep memoise and zip files
#' @param do_shiny_progress Whether to use shiny progress indicator (default = FALSE)
#'
#' @return A list of tibbles containing all requested financial data. Each element of the list is a table from DFP.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' df_dfp <- get_dfp_data(companies_cvm_codes = NULL)
#' }
get_dfp_data <- function(companies_cvm_codes = NULL,
                         first_year = 2010,
                         last_year = lubridate::year(Sys.Date()),
                         type_docs = c('BPA', 'BPP', 'DRE'),
                         type_format = c('con', 'ind'),
                         clean_data = TRUE,
                         use_memoise = FALSE,
                         cache_folder = 'gdfpd2_cache',
                         do_shiny_progress = FALSE) {

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

  if ((!is.null(companies_cvm_codes))&(!is.numeric(companies_cvm_codes))) {
    stop('Input companies_cvm_codes should be numeric (e.g. ')
  }


  df_ftp_dfp_full <- get_contents_ftp('https://dados.cvm.gov.br/dados/CIA_ABERTA/DOC/DFP/DADOS/')

  # filter dates
  idx <- (df_ftp_dfp_full$year_files >= first_year) & df_ftp_dfp_full$year_files <= last_year
  df_ftp_dfp <- df_ftp_dfp_full[idx, ]

  if (nrow(df_ftp_dfp) == 0 ) {
    stop('Cant find data for requested years in ftp. \n\nAvailable years: ',
         paste0(df_ftp_dfp$year_files, collapse = ', '))
  }

  if (use_memoise) {
    # setup memoise
    mem_folder <- file.path(cache_folder, 'mem_cache')
    if (!dir.exists(mem_folder)) dir.create(mem_folder)

    mem_cache <- memoise::cache_filesystem(path = mem_folder)
    download_read_dfp_zip_file <- memoise::memoise(download_read_dfp_zip_file,
                                                   cache = mem_cache)
  }

  if (do_shiny_progress) {

    if (do_shiny_progress) {

      shiny::incProgress(amount = 0,
                         message = paste0('Done!'),
                         detail = paste0('\nCongrats :)'))

    }
  }

  df_dfp <- dplyr::bind_rows(
    purrr::map(df_ftp_dfp$full_links,
               download_read_dfp_zip_file,
               cache_folder = cache_folder,
               clean_data = clean_data,
               companies_cvm_codes = companies_cvm_codes,
               type_docs = type_docs,
               type_format = type_format,
               do_shiny_progress = do_shiny_progress)
  )

  l_out <- split(df_dfp, f = df_dfp$GRUPO_DFP)

  return(l_out)

}
