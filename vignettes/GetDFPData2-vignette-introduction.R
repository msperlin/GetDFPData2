## ---- include=FALSE-----------------------------------------------------------
knitr::opts_chunk$set(eval=FALSE)

## ---- eval=FALSE--------------------------------------------------------------
#  # only in github, soon in CRAN
#  devtools::install_github('msperlin/GetDFPData2')

## ---- eval=FALSE--------------------------------------------------------------
#  # not in CRAN, install from github
#  devtools::install_github('msperlin/GetFREData')

## -----------------------------------------------------------------------------
#  library(GetDFPData2)
#  
#  # information about companies
#  df_info <- get_info_companies(tempdir())
#  print(df_info )

## -----------------------------------------------------------------------------
#  search_company('grendene', cache_folder = tempdir())

## ---- message=FALSE-----------------------------------------------------------
#  library(GetDFPData2)
#  
#  # downloading DFP data
#  l_dfp <- get_dfp_data(companies_cvm_codes = 19615,
#                        use_memoise = FALSE,
#                        clean_data = TRUE,
#                        cache_folder = tempdir(), # use local folder in live code
#                        type_docs = c('DRE'),
#                        type_format = 'con',
#                        first_year = 2019,
#                        last_year = 2020)
#  
#  str(l_dfp)
#  

