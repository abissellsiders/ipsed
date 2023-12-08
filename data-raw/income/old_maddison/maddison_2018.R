#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw/maddison_project_gdp")
setwd(wd)

# load packages
library("readxl")
library("data.table")

#####
# read data
#####
# read xlsx
maddison = data.table(read_excel("mpd2020.xlsx", sheet = "Full data"))

# better column names
colnames_new = c("countrycode" = "country_code",
                 "country" = "country_name",
                 "year" = "year",
                 "pop" = "population",
                 "cgdppc" = "cgdppc",
                 "rgdpnapc" = "rgdpnapc",
                 "i_cig" = "gdppc_estimate_type",
                 "i_bm" = "gdppc_benchmark_type")
colnames(maddison) = colnames_new[colnames(maddison)]

# reorder columns
setcolorder(maddison, unname(colnames_new))

# countries = ipsed::countries

# convert country codes
short_convert = setNames(countries[["master_short"]], countries[["maddison_long"]])
maddison[, country_code := short_convert[country_name]]

# convert country names
long_convert = setNames(countries[["master_long"]], countries[["maddison_long"]])
maddison[, country_name := long_convert[country_name]]

# convert to factors
colnames_factors = c("gdppc_estimate_type", "gdppc_benchmark_type")
maddison[, (colnames_factors) := lapply(.SD, factor), .SDcols = colnames_factors]
maddison[, country_code := short_convert[country_name]]

# population in thousands to population in ones
maddison[, population := population * 1000]

# add delta columns
maddison[, cgdppc_delta := (cgdppc/shift(cgdppc) - 1)]
maddison[, rgdpnapc_delta := (rgdpnapc/shift(rgdpnapc) - 1)]

# add simple moving averages
windows = 2:10
maddison[, paste0("cgdppc_sma_", windows) := frollmean(cgdppc, windows, align="center")]
maddison[, paste0("cgdppc_delta_sma_", windows) := frollmean(cgdppc_delta, windows, align="center")]
maddison[, paste0("rgdpnapc_sma_", windows) := frollmean(rgdpnapc, windows, align="center")]
maddison[, paste0("rgdpnapc_delta_sma_", windows) := frollmean(rgdpnapc_delta, windows, align="center")]

# cgdppc vs rgdpnapc https://medium.com/@Enopoletus/understanding-and-reconciling-the-two-real-gdp-series-in-maddison-project-2018-3414349c78ad
