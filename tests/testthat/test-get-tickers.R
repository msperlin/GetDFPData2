library(GetDFPData2)
library(testthat)

skip_on_cran()
skip_if_offline()

test_info <- function(df_in) {
  expect_true(nrow(df_in) > 0)
  expect_true(ncol(df_in) > 0)
}

test_that("Get tickers", {

  years <- 2018:lubridate::year(Sys.Date())

  df_tickers <- purrr::map_df(years, get_tickers)
  test_info(df_tickers)

})
