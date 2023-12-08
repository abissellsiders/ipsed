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
(wd = "C:/gdrive/rpackages/pesdint/")
setwd(wd)

#####
# maddison: format countries
#####
# read data
paths_rda = list.files("data", ".rda", full.names = TRUE)
for (path in paths_rda) {load(path)}

# convert country codes
short_convert = setNames(countries[["master_short"]], countries[["maddison_long"]])
maddison_project_gdp[, country_code := short_convert[country_name]]

# convert country names
long_convert = setNames(countries[["master_long"]], countries[["maddison_long"]])
maddison_project_gdp[, country_name := long_convert[country_name]]

#####
# combine countries
#####
# get list of datasets
dt_list = list(maddison_project_gdp, cpi_corruption)

# merge function
merge_codenameyear = function(...) {
  merge(..., by = c("country_code", "country_name", "year"), all = TRUE)
}

# merge all data by code, name, year
pesdint_counyear = Reduce(merge_codenameyear, dt_list)

# add oecd column
convert = setNames(!is.na(countries[["oecd_1961"]]), countries[["master_long"]])
pesdint_counyear[, oecd_1961 := convert[country_name]]
convert = setNames(!is.na(countries[["oecd_2000"]]), countries[["master_long"]])
pesdint_counyear[, oecd_2000 := convert[country_name]]
convert = setNames(!is.na(countries[["oecd_2020"]]), countries[["master_long"]])
pesdint_counyear[, oecd_2020 := convert[country_name]]

# add continent column
convert = setNames(countries[["continent"]], countries[["master_long"]])
pesdint_counyear[, continent := convert[country_name]]

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
pesdint_counyear = pesdint_counyear
usethis::use_data(pesdint_counyear, overwrite = TRUE)
