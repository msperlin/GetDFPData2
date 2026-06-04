library(GetDFPData2)
library(testthat)

skip_on_cran()
skip_if_offline()

test_list <- function(l_in) {
  expect_true(is.list(l_in))
  expect_true(length(l_in) > 0)
}

my_temp_folder <- fs::path_temp("getdfpdata2-cache-dfp")
fs::dir_create(my_temp_folder)

first_year <- 2020
last_year <- 2020

test_that("Get dfp data (no cache) - vanilla call", {

  l_dfp <- get_dfp_data(companies_cvm_codes = 9512,
               first_year = first_year,
               last_year = last_year,
               cache_folder = my_temp_folder)

  test_list(l_dfp)

})

test_that("Get dfp data (with cache)  - vanilla call", {

  l_dfp <- get_dfp_data(companies_cvm_codes = 9512,
                        first_year = first_year,
                        last_year = last_year,
                        cache_folder = my_temp_folder)

  test_list(l_dfp)

})

test_that("Get dfp data (with cache)  - all reports", {

  l_dfp <- get_dfp_data(companies_cvm_codes = 9512,
                        first_year = first_year,
                        last_year = last_year,
                        type_docs = '*',
                        cache_folder = my_temp_folder)

  test_list(l_dfp)

})

test_that("Get dfp data (with cache)  - 2 companies", {

  l_dfp <- get_dfp_data(companies_cvm_codes = c(9512, 19615),
                        first_year = first_year,
                        last_year = last_year,
                        cache_folder = my_temp_folder)

  test_list(l_dfp)

})
