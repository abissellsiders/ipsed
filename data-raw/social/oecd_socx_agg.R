#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("sdlutils")
library("stringr")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw/social")
setwd(wd)

#####
# read data
#####
# todo
oecd = fread("oecd_socx_agg.csv", header = TRUE)

# subset data
cols_keep = c("Source", "Branch", "Type of Expenditure", "Measure", "Country_Code", "Country", "Year", "Value")
oecd = oecd[, (cols_keep), with = FALSE]
cols_new = c("type2", "group1", "group2", "measure", "place1_iso3", "place1", "year", "value")
setnames(oecd, cols_keep, cols_new)
oecd = oecd[measure == "In percentage of Gross Domestic Product", ]
oecd = oecd[group2 == "Total", ]

# percent to proportion
oecd[, value := value / 100]

# add columns
oecd[, type1 := "social_spending"]
oecd[, unit := "percent of GDP"]
oecd[, source_name := "OECD SOCX"]
oecd[, source_loc := "https://stats.oecd.org/Index.aspx?DataSetCode=SOCX_AGG"]

# remove columns
cols_remove = c("measure")
oecd[, (cols_remove) := NULL]

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
social_oecd_socx_agg = oecd
usethis::use_data(social_oecd_socx_agg, overwrite = TRUE)
