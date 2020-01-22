# Generate a properly-formated CGM Profile
# tsv file that has two columns: timestamp  glucose_val

library(tidyverse)
library(dplyr)

library(lubridate)
library(feather)

library(DBI)
library(dbplyr)

# set the active configuration globally via Renviron.site or Rprofile.site
# Sys.setenv(R_CONFIG_ACTIVE = "local")
# Sys.setenv(R_CONFIG_ACTIVE = "cloud") # save to cloud
# Sys.setenv(R_CONFIG_ACTIVE = "default") # save to sqlite


conn_args <- config::get("dataconnection")
con <- DBI::dbConnect(drv = conn_args$driver,
                      user = conn_args$user,
                      host = conn_args$host,
                      dbname = conn_args$dbname,
                      port = conn_args$port,
                      password = conn_args$password)

glucose_raw <- tbl(con,"glucose_records") %>% collect()

glucose_raw %>% dplyr::filter(!is.na(scan)) %>% select(GlucoseDisplayTime = time,GlucoseValue = value) %>%
  write_tsv("sprague_glucose.tsv")


