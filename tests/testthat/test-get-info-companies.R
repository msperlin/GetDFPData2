library(GetDFPData2)
library(testthat)

skip_on_cran()
skip_if_offline()

test_info <- function(df_in) {
  expect_true(nrow(df_in) > 0)
  expect_true(ncol(df_in) > 0)
}

my_temp_folder <- fs::path_temp("getdfpdata2-cache-infocompanies")
fs::dir_create(my_temp_folder)

test_that("Get info companies (no cache)", {
  df_info <- get_info_companies(my_temp_folder )

  test_info(df_info)

})

test_that("Get info companies (with cache)", {
  df_info <- get_info_companies(my_temp_folder )

  test_info(df_info)

})
