build_quarterly_dre <- function(company_in, year_in, df_dfp, df_itr) {

  browser()

  all_docs <- bind_rows(df_dfp, df_itr) %>%
    filter(CNPJ_CIA == company_in)

  tbl <- all_docs %>%
    group_by(CNPJ_CIA, DENOM_CIA, lubridate::year(DT_REFER), GRUPO_DFP, DS_CONTA) %>%
    summarise(Q1 = VL_CONTA[1],
              Q2 = VL_CONTA[2] - VL_CONTA[1],
              Q3 = VL_CONTA[3] - VL_CONTA[2],
              Q4 = VL_CONTA[4])


}

my_build <- function(dt_inic, dt_fim, vl_conta, q_in) {
  browser()
}
