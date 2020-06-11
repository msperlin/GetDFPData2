#' Helps users search for a company
#'
#' @param char_to_search Character for partial matching
#' @inheritParams get_dfp_data
#'
#' @return A dataframe with companies
#' @export
#'
#' @examples
#'
#' \dontrun{ # dontrun: keep cran check fast
#' df <- search_company('petrobras')
#' }
search_company <- function(char_to_search, cache_folder = 'gcvmd_cache') {

  df_cvm <- get_info_companies(cache_folder)

  unique_names <- unique(df_cvm$DENOM_SOCIAL)
  char_target <- iconv(stringr::str_to_lower(unique_names),to='ASCII//TRANSLIT')
  char_to_search <- iconv(stringr::str_to_lower(char_to_search),to='ASCII//TRANSLIT')

  idx <- stringr::str_detect(char_target, pattern = stringr::fixed(char_to_search))
  char_out <- stats::na.omit(unique_names[idx])

  temp_df <- unique(df_cvm[df_cvm$DENOM_SOCIAL %in% char_out, ])

  message('Found ', nrow(temp_df), ' companies:')

  for (i_company in seq(nrow(temp_df))) {

    message(paste0(temp_df$DENOM_SOCIAL[i_company],
                   ' | situation = ', temp_df$SIT_REG[i_company],
                   ' | sector = ', temp_df$SETOR_ATIV[i_company],
                   ' | CD_CVM = ',temp_df$CD_CVM[i_company]))
  }

  return(temp_df)

}
