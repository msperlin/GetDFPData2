
`GetDFPData2` is the second and backwards incompatible version of `GetDPFData`,  a R package for downloading annual financial reports from B3, the Brazilian financial exchange. Unlike its first iteration, `GetDFPData2` imports data using a  database of csv files from [CVM](http://dados.cvm.gov.br/dados/CIA_ABERTA/), which makes it execute much faster than its predecessor. However, the output is slightly different.

A shiny app -- web interface -- is also available at  [https://www.msperlin.com/shiny/GetDFPData2/](https://www.msperlin.com/shiny/GetDFPData2/).


# Installation

```r
# only in github, soon in CRAN
devtools::install_github('msperlin/GetDFPData2')
```

# Examples of Usage

## Information about available companies

```r
library(GetDFPData2)

# information about companies
df_info <- get_info_companies(tempdir())
print(df_info )
```

## Searching for companies

```{r}
search_company('grendene', cache_folder = tempdir())
```

## Downloading Financial Reports

```r
library(GetDFPData2)

# downloading DFP data
l_dfp <- get_dfp_data(companies_cvm_codes = 19615, 
                      use_memoise = FALSE,
                      clean_data = TRUE,
                      cache_folder = tempdir(), # use local folder in live code
                      type_docs = c('DRE'), 
                      type_format = 'con',
                      first_year = 2019, 
                      last_year = 2020)

str(l_dfp)

```

