#####
# init
#####
# remove all objects
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("stringr")
library("sdlutils")
library("readxl")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw/charity")
setwd(wd)

#####
# read and clean data
#####
# read recipients data
gusourc = data.table(read_excel("givingusa.xlsx", "Giving by Source"))
# read recipients data
gurecip = data.table(read_excel("givingusa.xlsx", "Contributions by Recipient"))

# combine datasets
gu = merge(gusourc, gurecip, by = c("Year", "Reference"), suffixes = c("_source", "_recipient"))

# drop columns
cols_drop = str_subset(colnames(gu), "(?:Pct chg)|(?:Percent change)|Check")
gu[, (cols_drop) := NULL]

# rename columns
# remove extra characters
setnames(gu, str_replace_all(tolower(colnames(gu)), c(","="", " |-"="_", "_to"="")))
# move type to end
setnames(gu, str_replace_all(tolower(colnames(gu)), c("total_source,"="", " |-"="_", "_to"="")))
# change total names
cols_special_old = c("total_source", "total_recipient", "notes_source", "notes_recipient")
cols_special_new = c("source_total", "recipient_total", "source_notes", "recipient_notes")
setnames(gu, cols_special_old, cols_special_new)
# add source to source cols
cols_source_old = c("corporations", "foundations", "bequests", "individuals")
cols_source_new = paste0("source_", cols_source_old)
setnames(gu, cols_source_old, cols_source_new)
# add source to source cols
cols_recip_old = c("religion", "education", "human_services", "health", "public_society_benefit", "arts_culture_humanities", "international_affairs", "environment_animals", "gifts_foundations", "gifts_individuals", "unallocated")
cols_recip_new = paste0("recipient_", cols_recip_old)
setnames(gu, cols_recip_old, cols_recip_new)

# select most recent data
gu[, reference_year := as.numeric(str_replace_all(reference, ".*([[:digit:]]{4}).*", "\\1"))]
gu[, latest := (max(reference_year) == reference_year), by = c("year")]
gu = gu[latest == TRUE, ]
cols_remove = c("latest", "reference_year")
gu[, (cols_remove) := NULL]

#####
# quality check
#####
library("ggplot2")
id_vars = c("year", "reference")
measure_vars = c("source_total", cols_source_new)
mdt = melt(gu, id.vars = id_vars, measure.vars = measure_vars)
ggplot(mdt, aes(x = year, y = value, color = reference)) +
  geom_line() + geom_point() +
  facet_wrap(~ variable, scales = "free_y")

measure_vars = c("recipient_total", cols_recip_new)
mdt = melt(gu, id.vars = id_vars, measure.vars = measure_vars)
ggplot(mdt, aes(x = year, y = value, color = reference)) +
  geom_line() + geom_point() +
  facet_wrap(~ variable, scales = "free_y")

mdt = melt(gu[latest == TRUE, ], id.vars = id_vars, measure.vars = cols_recip_new)
ggplot(mdt, aes(x = year, y = value, fill = variable)) +
  geom_bar(stat = "identity", position = "stack", width = 1)

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
charity_givingusa = gu
usethis::use_data(charity_givingusa, overwrite = TRUE)
