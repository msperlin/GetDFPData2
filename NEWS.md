## Version 0.6.5 (2026-06-04)

- Migrated all console message printing from `message()` to the `cli` package, introducing structured headers (`cli_h1`, `cli_h2`) and semantic alerts (`cli_alert_info`, `cli_alert_success`, `cli_alert_warning`, `cli_text`).
- Implemented year-doc level RDS caching (`gdfpd2_cache/processed_RDS/`) to avoid redundant unzipping and parsing of CSV files.
- Implemented early row filtering by company codes before binding data frames in memory, reducing footprint and overhead.
- Resolved type-coercion compatibility issues with logical/character classes in `dplyr::bind_rows` for zero-row filtered dataframes.
- Memoised CVM FTP directory listings session-wide to avoid redundant web scraping latency.

## Version 0.6.4 (2023-09-25)

- new function get_tickers() [issue #11](https://github.com/msperlin/GetDFPData2/issues/11)

## Version 0.6.3 (2023-04-24)

- Fixed [issue #8](https://github.com/msperlin/GetDFPData2/issues/8)
- Moved all "http://" addresses to https:// 

## Version 0.6.2 (2022-06-09)

- Fixed issue with ftp change in CVM

## Version 0.6.1 (2022-03-02)

- Fixed issue with cran check on oldrel (new pipeline only available in R>4.1)

## Version 0.6 (2022-02-18)

- Fixed issue with get_info_companies(). See [issue #6](https://github.com/msperlin/GetDFPData2/issues/6/).
- Fixed issue with cvm_id = 22179 ([issue #1](https://github.com/msperlin/GetDFPData2/issues/1/)).

## Version 0.5 (2020-06-11)

- First
