#merge_duplicates_test.R
# 2020-12-08 |  Max Chis | Initial Development
# Modifies merged_dataset file and outputs as merge_duplicates_input.csv
# Modifications assign group id's that will be used by merge_duplicates to merge rows

library(tidyverse)

md <- read_csv("merged_datasets.csv")
md$merged_record = '0'

#initial list of tests
test_list <- list()
test_list[[length(test_list) + 1]] <- c(1290,1291, 1630) 
test_list[[length(test_list) + 1]] <- c(458, 124) 
test_list[[length(test_list) + 1]] <- c(759, 1758, 56) 
test_list[[length(test_list) + 1]] <- c(2, 756) 

#TEST: Add "group_id" column
md$group_id <- NA

#TEST: Assign group ids to rows specified in testList
#Find values whose id in test_list[[i]], and set them to group_id i
for (i in 1:length(test_list)){
  md$group_id[md$id %in% test_list[[i]]] <- i
}

md %>% write_csv("merge_duplicates_input_test.csv")