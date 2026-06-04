my_download_file <- function(dl_link, dest_file, max_dl_tries = 10, be_quiet = TRUE) {

  Sys.sleep(0.5)

  #browser()
  if (file.exists(dest_file)) {

    current_size <- find_file_size(dest_file)
    dl_size <- find_dl_size(dl_link)

    # BUG (see <https://github.com/msperlin/GetDFPData2/issues/8>)
    # - only happens in windows
    # - not sure why dl_size = NA, only in windows
    # FIX: if is NA, force equality of sizes (skipping download)
    if (is.na(dl_size)) dl_size <- current_size

    if (dl_size == current_size) {

      cli::cli_alert_info("File already exists (same size as current, skipping download)")
      return(TRUE)

    } else {
      cli::cli_alert_info("File already exists (but different size, downloading it..)")
    }

  } else {
    cli::cli_alert_info("File not found, downloading it..")
  }

  for (i_try in seq(max_dl_tries)) {

    try({
      # old code. See issue 11: https://github.com/msperlin/GetDFPData/issues/11/
      # utils::download.file(url = dl.link,
      #                      destfile = dest.file,
      #                      quiet = T,
      #                      mode = 'wb')

      # fix for issue 13: https://github.com/msperlin/GetDFPData/issues/13/
      my.OS <- tolower(Sys.info()["sysname"])
      if (my.OS == 'windows') {
        utils::download.file(url = dl_link,
                             destfile = dest_file,
                             #method = 'wget',
                             #extra = '--no-check-certificate',
                             quiet = TRUE,
                             mode = 'wb')
      } else {
        # new code (only works in linux)
        dl_link <- stringr::str_replace(dl_link, stringr::fixed('https'), 'http' )
        utils::download.file(url = dl_link,
                             destfile = dest_file,
                             method = 'wget',
                             extra = '--no-check-certificate',
                             quiet = TRUE,
                             mode = 'wb')
      }



    })

    if (file.size(dest_file) < 10  ){
      cli::cli_alert_warning("Error in downloading. Attempt {i_try}/{max_dl_tries}")
      Sys.sleep(1)
    } else {
      cli::cli_alert_success("Success")
      return(TRUE)
    }

  }

  return(FALSE)


}

find_dl_size <- function(url_in) {

  res <- RCurl::url.exists(url_in, .header=TRUE)
  size_out <- as.numeric(res['Content-Length'])

  return(size_out)
}

find_file_size <- function(path) {
  info <- file.info(path)
  size <- info$size
  return(size)
}



