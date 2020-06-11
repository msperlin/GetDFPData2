# Package GetDFPData2

Second and backwards incompatible iteration of GetDFPData.


Package `GetCVMData` is an alternative to `GetDFPData`. Both have the same objective: fetch corporate data of Brazilian companies trading at B3, but diverge in their source. While `GetDFPData` imports data directly from the DFP and FRE systems, `GetCVMData` uses the [CVM ftp site](http://dados.cvm.gov.br/dados/CIA_ABERTA/) for grabbing compiled .csv files.

When doing large scale importations, `GetDFPData` fells sluggish due to the parsing of large xml files. As an example, building the dataset available in my [data page](https://www.msperlin.com/blog/data/data/) takes around six hours of execution using 10 cores of my home computer.

`GetCVMData` is lean and fast. Since the data is already parsed in csv files, all the code does is organize the files, download and read. For comparison, all DFP documents, annual financial reports, available in CVM can be imported in less than 1 minute. Additionally, `GetCVMData` can also parse ITR (quarterly) data, which was not available in `GetDFPData`.

However, be aware that the output data is not the same. I kept all original column names from CVM and some information, such as tickers, are not available in `GetCVMData`. Also, know that **the ITR data is accumulated**, meaning that that any account value in Q3, for example, is the sum of Q1, Q2 and Q3. 


## Installation

```
if (!require(devtools)) install.packages('devtools')
if (!require(GetCVMData)) devtools::install_github('msperlin/GetCVMData') # not in CRAN yet
```

## Example of usage

```
library(GetCVMData)
library(tidyverse)

# fetch information about companies
df_info <- get_info_companies()


# search for companies
df_search <- search_company('odontoprev')

# DFP annual data
id_cvm <- df_search$CD_CVM[1] # use NULL for all companies
df_dfp <- get_dfp_data(companies_cvm_codes = id_cvm, 
                       first_year = 2015,
                       last_year = 2019,
                       type_docs = 'DRE|BPA|BPP', # income, assets, liabilities
                       type_format = 'con' # consolidated statements
                       )

glimpse(df_dfp)

# ITR quarterly data
df_itr <- get_itr_data(companies_cvm_codes = id_cvm, 
                       first_year = 2010,
                       last_year = 2020,
                       type_docs = 'DRE|BPA|BPP', # income, assets, liabilities
                       type_format = 'con' # consolidated statements
                       )

glimpse(df_itr)

# FRE data (not yet implemented..)
#df_fre <- get_fre_data()
```
