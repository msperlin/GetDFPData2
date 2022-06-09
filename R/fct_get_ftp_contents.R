#' @importFrom magrittr %>%
get_contents_ftp <- function(ftp_url) {

  my_html <- xml2::read_html(ftp_url)

  all_links <- my_html %>%
    rvest::html_node('pre') %>%
    rvest::html_nodes('a') %>%
    rvest::html_text()

  idx <- stringr::str_detect(
    stringr::str_to_lower(all_links), 'cia_aberta|/'
    )

  all_links  <- all_links[idx]

  full_links <- paste0(ftp_url, all_links)

  year_files <- as.numeric(stringr::str_extract_all(full_links, '\\d\\d\\d\\d'))

  df_out <- dplyr::tibble(file_name = all_links,
                          full_links,
                          year_files) %>%
    dplyr::arrange(year_files) %>%
    stats::na.omit()

  return(df_out)

}
