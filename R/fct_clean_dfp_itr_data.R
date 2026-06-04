clean_dfp_itr_data <- function(df_in, file_in) {

  # filter penultimo cases
  possible_cases <- sort(unique(df_in$ORDEM_EXERC))
  idx <- df_in$ORDEM_EXERC == possible_cases[2]
  df_in <- df_in[idx, ]

  # change order of columns
  my_cols <- names(df_in)
  full_cols <- c("CNPJ_CIA", "CD_CVM", "DT_REFER", "DT_INI_EXERC", "DT_FIM_EXERC",
                  "DENOM_CIA", "VERSAO", "GRUPO_DFP",
                  "MOEDA", "ESCALA_MOEDA", "ORDEM_EXERC",
                  "CD_CONTA", "DS_CONTA", "VL_CONTA", "COLUNA_DF")

  missing_cols <- full_cols[!(full_cols %in% my_cols)]

  if (length(missing_cols) != 0) {
    default_nas <- list(
      CNPJ_CIA = NA_character_,
      CD_CVM = NA_real_,
      DT_REFER = as.Date(NA),
      DT_INI_EXERC = as.Date(NA),
      DT_FIM_EXERC = as.Date(NA),
      DENOM_CIA = NA_character_,
      VERSAO = NA_real_,
      GRUPO_DFP = NA_character_,
      MOEDA = NA_character_,
      ESCALA_MOEDA = NA_character_,
      ORDEM_EXERC = NA_character_,
      CD_CONTA = NA_character_,
      DS_CONTA = NA_character_,
      VL_CONTA = NA_real_,
      COLUNA_DF = NA_character_
    )
    for (col in missing_cols) {
      df_in[[col]] <- default_nas[[col]]
    }
  }

  df_in <- df_in[, full_cols]

  # if DT_INI_EXERC is.na, set first date of year
  if (all(is.na(df_in$DT_INI_EXERC))) {

    #browser()
  }
  # set filename
  df_in$source_file <- basename(file_in)

  # set col for cnpj number (deprecated)

  #unique_cnpj <- unique(df$CNPJ_CIA)
  #number_cnpj <- sapply(unique_cnpj, fix_cnpj)

  #idx <- match(df$CNPJ_CIA, unique_cnpj)
  #df$cnpj_number <- number_cnpj[idx]

  return(df_in)

}
