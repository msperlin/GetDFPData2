# Package GetDFPData2

Improved and backwards incompatible version of package GetDFPData.

In development, soon to be released.

## Installation

```
if (!require(devtools)) install.packages('devtools')
if (!require(GetDFPData2)) devtools::install_github('msperlin/GetDFPData2') # not in CRAN yet
```

## Example of usage

```
library(GetDFPData2)
library(tidyverse)

# fetch information about companies
df_info <- get_info_companies()


# search for companies
df_search <- search_company('odontoprev')

# DFP annual data
id_cvm <- df_search$CD_CVM[1] # use NULL for all companies
l_dfp <- get_dfp_data(companies_cvm_codes = id_cvm, 
                       first_year = 2018,
                       last_year = 2019,
                       type_docs = c('DRE', 'BPA', 'BPP'), # income, assets, liabilities
                       type_format = 'con' # consolidated statements
                       )

glimpse(l_dfp)

# ITR quarterly data
l_itr <- get_itr_data(companies_cvm_codes = id_cvm, 
                       first_year = 2018,
                       last_year = 2020,
                       type_docs = 'DRE', # income statement
                       type_format = 'con' # consolidated statements
                       )

glimpse(l_itr)
```
