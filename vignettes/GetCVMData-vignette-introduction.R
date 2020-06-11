## ---- eval=FALSE--------------------------------------------------------------
#  # Release version in CRAN
#  install.packages('GetDFPData')
#  
#  # Development version in Github
#  devtools::install_github('msperlin/GetDFPData')

## ---- eval=FALSE--------------------------------------------------------------
#  library(GetDFPData)
#  library(tibble)
#  
#  gdfpd.search.company('petrobras', cache.folder = tempdir())
#  

## ---- eval=FALSE--------------------------------------------------------------
#  df.info <- gdfpd.get.info.companies(type.data = 'companies', cache.folder = tempdir())
#  
#  glimpse(df.info)

## ---- eval=FALSE--------------------------------------------------------------
#  name.companies <- 'PETRÓLEO BRASILEIRO  S.A.  - PETROBRAS'
#  first.date <- '2004-01-01'
#  last.date  <- '2006-01-01'
#  
#  df.reports <- gdfpd.GetDFPData(name.companies = name.companies,
#                                 first.date = first.date,
#                                 last.date = last.date,
#                                 cache.folder = tempdir())

## ---- eval=FALSE--------------------------------------------------------------
#  glimpse(df.reports)

## ---- eval=FALSE--------------------------------------------------------------
#  df.income.long <- df.reports$fr.income[[1]]
#  
#  glimpse(df.income.long)

## ---- eval=FALSE--------------------------------------------------------------
#  df.income.wide <- gdfpd.convert.to.wide(df.income.long)
#  
#  knitr::kable(df.income.wide )

## ---- eval=FALSE--------------------------------------------------------------
#  my.basename <- 'MyExcelData'
#  my.format <- 'csv' # only supported so far
#  gdfpd.export.DFP.data(df.reports = df.reports,
#                        base.file.name = my.basename,
#                        type.export = my.format)

