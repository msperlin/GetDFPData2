download_read_dfp_zip_file <- function(url_in,
                                       companies_cvm_codes,
                                       type_format,
                                       type_docs,
                                       cache_folder,
                                       clean_data,
                                       do_shiny_progress) {

  # find year
  year <- stringr::str_extract(basename(url_in), '(\\d\\d\\d\\d)')

  # Cache directory for RDS files
  rds_cache_dir <- file.path(cache_folder, "processed_RDS")
  if (!dir.exists(rds_cache_dir)) dir.create(rds_cache_dir, recursive = TRUE)

  # Check if all requested combinations are cached
  combinations <- expand.grid(doc = type_docs, format = type_format, stringsAsFactors = FALSE)
  rds_filenames <- paste0("dfp_cia_aberta_", combinations$doc, "_", combinations$format, "_", year, "_cleaned_", clean_data, ".rds")
  rds_paths <- file.path(rds_cache_dir, rds_filenames)

  if (all(file.exists(rds_paths))) {
    cli::cli_h2("Processing Year {year} (Using Cached RDS)")
    read_and_filter <- function(path) {
      df <- readRDS(path)
      if (!is.null(companies_cvm_codes)) {
        idx <- df$CD_CVM %in% companies_cvm_codes
        df <- df[idx, ]
      }
      return(df)
    }
    df_out <- dplyr::bind_rows(purrr::map(rds_paths, read_and_filter))
    cli::cli_alert_success("Got {nrow(df_out)} rows | {length(unique(df_out$CD_CVM))} companies")
    return(df_out)
  }

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

  cli::cli_h2("Processing Year {year}")
  cli::cli_alert_info("Downloading {basename(url_in)}")
  dest_file <- file.path(dir_zip, basename(url_in))

  flag_dl <- my_download_file(dl_link = url_in,
                              dest_file = dest_file,
                              max_dl_tries = 10, be_quiet = TRUE)

  cli::cli_alert_info("Unzipping")
  # unzip file in tempdir
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
  idx_target <- (type_files_doc %in% type_docs)&(type_files_format %in% type_format)
  unzipped_target <- unzipped_files[idx_target]
  type_target_doc <- type_files_doc[idx_target]
  type_target_format <- type_files_format[idx_target]

  if (length(unzipped_target) == 0) {
    stop('Cant find any files for selected type_docs')
  }

  process_file <- function(file_path, doc, format) {
    df <- read_dfp_csv(file_path, clean_data = clean_data)
    
    # Save full parsed and cleaned data frame to RDS cache
    cached_path <- file.path(rds_cache_dir, paste0("dfp_cia_aberta_", doc, "_", format, "_", year, "_cleaned_", clean_data, ".rds"))
    saveRDS(df, cached_path)

    if (!is.null(companies_cvm_codes)) {
      idx <- df$CD_CVM %in% companies_cvm_codes
      df <- df[idx, ]
    }
    return(df)
  }

  df_out <- dplyr::bind_rows(
    purrr::pmap(
      list(unzipped_target, type_target_doc, type_target_format),
      process_file
    )
  )

  cli::cli_alert_success("Got {nrow(df_out)} rows | {length(unique(df_out$CD_CVM))} companies")

  # clean up zip dir
  unlink(unzip_dir, recursive = TRUE)

  return(df_out)

}
