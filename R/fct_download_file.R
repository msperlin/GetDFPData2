my_download_file <- function(dl_link, dest_file, max_dl_tries = 10, be_quiet = TRUE) {

  Sys.sleep(0.5)

  #browser()
  if (file.exists(dest_file)) {
    message('\tFile already exists', appendLF = FALSE)

    current_size <- find_file_size(dest_file)
    dl_size <- find_dl_size(dl_link)

    # BUG (see <https://github.com/msperlin/GetDFPData2/issues/8>)
    # - only happens in windows
    # - not sure why dl_size = NA, only in windows
    # FIX: if is NA, force equality of sizes (skipping download)
    if (is.na(dl_size)) dl_size <- current_size

    if (dl_size == current_size) {

      message(' -- same size as current, skipping download', appendLF = TRUE)
      return(TRUE)

    } else {
      message(' -- but differente size, downloading it..', appendLF = TRUE)
    }

  } else {
    message('\tFile not found, downloading it..', appendLF = TRUE)
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
      message(paste0('\t\tError in downloading. Attempt ',i_try,'/', max_dl_tries),
              appendLF = FALSE)
      Sys.sleep(1)
    } else {
      message('\tSuccess', appendLF = TRUE)
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



