# upload_glucotype_to_db.R
# writes glucotype info to a database


library(tidyverse)
library(dplyr)
library(zoo)
library(xts)

library(lubridate)
library(feather)

library(DBI)
library(dbplyr)

# set the active configuration globally via Renviron.site or Rprofile.site
# Sys.setenv(R_CONFIG_ACTIVE = "local")
Sys.setenv(R_CONFIG_ACTIVE = "cloud") # save to cloud  (set to SigAI AWS server and dbname = 'qs')
# Sys.setenv(R_CONFIG_ACTIVE = "default") # save to sqlite


conn_args <- config::get("dataconnection")
con <- DBI::dbConnect(drv = conn_args$driver,
                      user = conn_args$user,
                      host = conn_args$host,
                      dbname = conn_args$dbname,
                      port = conn_args$port,
                      password = conn_args$password)

source("glucotyper.R")  # brings in new XTS frame 'gt'

new_records <- gt %>% fortify.zoo() %>% as_tibble() %>% dplyr::rename(timeStart = Index) %>% mutate(user = 1230)
DBI::dbWriteTable(con, name = "glucotype_records", value = new_records, row.names = FALSE, overwrite = TRUE)


