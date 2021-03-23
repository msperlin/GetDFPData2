download_read_dfp_zip_file <- function(url_in,
                                       companies_cvm_codes,
                                       type_format,
                                       type_docs,
                                       cache_folder,
                                       clean_data,
                                       do_shiny_progress) {

  # shiny progress
  # find year
  year <- stringr::str_extract(basename(url_in), '(\\d\\d\\d\\d)')

  if (do_shiny_progress) {
    my_drink <- select_responsible_beverage()

    shiny::incProgress(amount = 1,
                       message = paste0('Fetching Data for Year ', year),
                       detail = paste0('\nThis might take a while.. grab some ',
                                       my_drink, '.' ))

  }
  # create folder
  dir_zip <- file.path(cache_folder, 'DFP_zip_files')
  if (!dir.exists(dir_zip)) dir.create(dir_zip, recursive = TRUE)

  message('\tDowloading ', basename(url_in), appendLF = TRUE)
  dest_file <- file.path(dir_zip, basename(url_in))

  flag_dl <- my_download_file(dl_link = url_in,
                              dest_file = dest_file,
                              max_dl_tries = 10, be_quiet = TRUE)

  message('\t\tUnzipping', appendLF = TRUE)
  # unzip file in tempdir
  #message('\t\t\tunzipping file')
  unzip_dir <- file.path(tempdir(), tools::file_path_sans_ext(
    basename(url_in) ) )
  utils::unzip(zipfile = dest_file,exdir = unzip_dir,
        junkpaths = TRUE)

  unzipped_files <- list.files(unzip_dir, full.names = TRUE)

  # remove metadata file
  unzipped_files <- unzipped_files[2:length(unzipped_files)]

  # find types of docs and formats
  temp_str <-stringr::str_match_all(
    stringr::str_to_lower(basename(unzipped_files)),
    'aberta_(.*)_(ind|con)_\\d\\d\\d\\d')

  type_files_doc <- stringr::str_to_upper(as.character(purrr::map(temp_str, 2)))
  type_files_format <- as.character(purrr::map(temp_str, 3))

  # filter by type and format
  idx <- (type_files_doc %in% type_docs)&(type_files_format %in% type_format)
  unzipped_files <- unzipped_files[idx]

  if (length(unzipped_files) == 0) {
    stop('Cant find any files for selected type_docs')
  }

  #message('\t\t\t\tfound ', length(unzipped_files), ' files')
  #message('\t\t\treading files', appendLF = FALSE)
  df_out <- dplyr::bind_rows(purrr::map(unzipped_files,
                                        read_dfp_csv, clean_data = clean_data))

  # filter by company
  if (!is.null(companies_cvm_codes)) {
    idx <- df_out$CD_CVM %in% companies_cvm_codes
    df_out <- df_out[idx, ]
  }

  message('\t\tGot ', nrow(df_out), ' rows | ', length(unique(df_out$CD_CVM)), ' companies')

  # clean up zip dir
  unlink(unzip_dir, recursive = TRUE)

  return(df_out)

}
