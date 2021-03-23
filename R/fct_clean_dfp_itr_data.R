clean_dfp_itr_data <- function(df_in, file_in) {

  message(' | Cleaning table' )

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

  if (length(missing_cols) !=0 ) {
    df_in[, missing_cols] <- NA
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
