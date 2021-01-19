#!/bin/bash

Rscript auto_agg_clean_data.R ../food-data/Cleaned_data_files/ | Rscript auto_text_process_name.R | Rscript auto_geocode.R 'token' | Rscript auto_write_to_csv.R

