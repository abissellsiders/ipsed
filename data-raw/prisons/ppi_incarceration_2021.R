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
(wd = "C:/gdrive/rpackages/pesdint/data-raw/prisons")
(wd = "/Volumes/GoogleDrive/My Drive/rpackages/pesdint/data-raw/prisons")
setwd(wd)

#####
# read data
#####
ppi = fread("ppi_incarceration_2021.csv", header = TRUE)

setnames(ppi, tolower(colnames(ppi)))
setnames_regex(ppi, c(" "="_", "[^A-Za-z _]*"=""))

ppi[, federal_origin_percentage := str_replace_all(federal_origin_percentage, c("%"=""))]
cols_numeric = colnames(ppi)[-1]
ppi[, (cols_numeric) := lapply(.SD, as.numeric), .SDcols = cols_numeric]

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
prisons_ppi_us21 = ppi
usethis::use_data(prisons_ppi_us21, overwrite = TRUE)
