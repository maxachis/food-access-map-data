#!/usr/bin/Rscript

# --------------------------- info
# name: auto_geocode.R
# authors: Max Chis | Catalina Moreno | Connor Tompkins
# last update: 2021-01-05
# info: This script reads in output from auto_text_process_name.R and uses mapboxapi to find 
#       lat / long for observations missing this information; 
#       a mapbox api token needs to be provided in CLI as argument (after script name, replace 'token', include '');
#       results are written out as stdout() for next step in data prep


# -------------------------- script
## load pkg
# if (!require("mapboxapi", character.only = TRUE)) {
#   suppressWarnings(install.packages("tidyverse", dependencies = TRUE))
# }
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(mapboxapi))

#install mapboxapi package from github if not already installed
# if (!require("mapboxapi", character.only = TRUE)) {
#   suppressWarnings(remotes::install_github("walkerke/mapboxapi", dependencies = TRUE))
# }

# get mapbox API
token <- commandArgs(trailingOnly=TRUE) 

suppressMessages(mb_access_token(token = token)) #install = TRUE, overwrite = TRUE))

run_geocode <- function(input_dat) {
  
  ## read.table() bc stdin input
  all_datasets <- read.table(input_dat)
  
  ## Geocoding locations without latitude and longitude
  df_geocode <- all_datasets %>% 
    filter(is.na(latitude) | is.na(longitude) | latitude==0 | longitude==0) %>% 
    transmute(address = str_c(address, city, state, zip_code, sep = ", "), id = id) %>% 
    mutate(geocode_data = map(address, mb_geocode),
           lon = map_dbl(geocode_data, 1),
           lat = map_dbl(geocode_data, 2))
  
  # replace empty lat/long in original data
  all_datasets <- all_datasets %>% left_join(df_geocode %>% select(id, lon, lat), by = "id")
  
  all_datasets <- all_datasets %>% mutate(longitude = ifelse(is.na(longitude), lon, longitude),
                                          latitude = ifelse(is.na(latitude), lat, latitude),
                                          latlng_source = ifelse(is.na(latlng_source), "Mapbox Geocode", latlng_source))
  
  all_datasets <- all_datasets %>% select(-lat, -lon) 
  
  ## write out as stdout
  write.table(all_datasets, stdout())
 
}

## read in stdin() from previous step
input <- file('stdin', 'r')

## run function with CLI input
run_geocode(input)
