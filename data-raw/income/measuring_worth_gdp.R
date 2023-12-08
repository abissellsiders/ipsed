#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("readxl")
library("sdlutils")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw/income")
setwd(wd)

#####
# read data
#####
# read xlsx
income = data.table(read_excel("measuring_worth_gdp.xlsx", sheet = "E11 - GDP 1790-2021", skip = 8))

#####
# munge data
#####
# better column names
colnames_new = c("year", "real_gdp_2012", "nominal_gdp", "gdp_deflator", "population", "real_gdppc", "nominal_gdppc")
setnames(income, colnames_new)

# numeric
cols_sd = colnames_new
income[, (cols_sd) := lapply(.SD, as.numeric), .SDcols = colnames_new]

# only numeric years
income = income[!is.na(year), ]

# convert from billions
cols_billion = c("real_gdp_2012", "nominal_gdp")
income[, (cols_billion) := lapply(.SD, function(x){x*1e9}), .SDcols = cols_billion]

# convert from thousands
cols_thousand = c("population")
income[, (cols_thousand) := lapply(.SD, function(x){x*1e3}), .SDcols = cols_thousand]

# melt
cols_id = c("year")
cols_measure = NULL
income = melt(income, id.vars = cols_id, measure.vars = cols_measure)

income[, type1 := "GDP"]
income[str_detect(variable, "population"), type1 := "population"]

income[, units := "dollars"]
income[str_detect(variable, "deflator"), units := "deflator"]
income[str_detect(variable, "population"), units := "people"]
income[str_detect(variable, "gdppc"), units := "dollars per person"]

income[, place1 := "United States"]

income[, type2 := "real"]
income[str_detect(variable, "nominal"), type2 := "nominal"]
income[str_detect(variable, "deflator"), type2 := "deflator"]
income[str_detect(variable, "population"), type2 := NA]

# source
income[, source_name := "Measuring Worth 2023"]

# remove variable column
cols_del = c("variable")
income[, (cols_del) := NULL]

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
income_mw = income
usethis::use_data(income_mw, overwrite = TRUE)
