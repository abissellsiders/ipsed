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
income = data.table(read_excel("mpd2020.xlsx", sheet = "Full data"))

# better column names
colnames_new = c("countrycode" = "place1_abbr",
                 "country" = "place1")
setnames_named(income, colnames_new)

#####
# munge data
#####
# convert from thousands
cols_thousand = c("pop")
income[, (cols_thousand) := lapply(.SD, function(x){x*1e3}), .SDcols = cols_thousand]

# calculate gdp
income[, gdp := pop * gdppc]

# set 0 gdp values to na
income[gdppc == 0, gdppc := NA]

# add na years for missing years by country
income[, N := 1]
years = seq(min(income[["year"]]), max(income[["year"]]), by=1)
cols_replicate = c("place1", "place1_abbr")
rep_n = nrow(unique(income[, (cols_replicate), with = FALSE]))
dt1 = data.table(year = rep(years, rep_n),
                N = 2)
dt2 = unique(income[, (cols_replicate), with = FALSE])[rep(1:.N, each = length(years))]
dt = cbind(dt1, dt2)
income = rbindlist(list(income, dt), fill=TRUE)
income[, N_min := (N == min(N)), by = c("place1", "year")]
income = income[N_min == 1, ]
cols_del = c("N", "N_min")
income[, (cols_del) := NULL]
cols_order = c("place1", "year")
setorderv(income, cols = cols_order)

# source
income[, source_name := "Maddison Project Database 2020"]

#####
# NOTE TO SELF: rbindlist all maddison databases above this point
#####

# add lag and lead columns
windows = 1:2
income[, paste0("gdppc_lag", windows) := shift(gdppc, windows), by = c("place1")]
income[, paste0("gdppc_lead", windows) := shift(gdppc, -windows), by = c("place1")]

# add growth column
income[, year_delta := shift(year, -1) - year, by = c("place1")]
income[, gdppc_delta := (gdppc_lead1 - gdppc) / year_delta, by = c("place1")]
income[, gdppc_growth := (gdppc_delta / gdppc)]
income[, year_delta := NULL]

# quality check
qa_cols = c("place1", "year", "gdppc", "gdppc_lead1", "gdppc_growth")
income[gdppc_growth >  0.2, (qa_cols), with = FALSE]
income[gdppc_growth < -0.5, (qa_cols), with = FALSE]
income[place1_abbr == "AFG" & year %between% c(1998, 2005), (qa_cols), with = FALSE]
income[place1_abbr == "ZAF" & year %between% c(1800, 1840), (qa_cols), with = FALSE]

# add simple moving averages
windows = 2:10
income[, paste0("gdppc_sma_", windows) := frollmean(gdppc, windows, align="center"), by = c("place1")]
income[, paste0("gdppc_delta_sma_", windows) := frollmean(gdppc_delta, windows, align="center"), by = c("place1")]
income[, paste0("gdppc_growth_sma_", windows) := frollmean(gdppc_growth, windows, align="center"), by = c("place1")]

#####
# melt data
#####
# melt
cols_id = c("year", "place1", "place1_abbr", "source_name")
cols_measure = NULL
income = melt(income, id.vars = cols_id, measure.vars = cols_measure)

income[, type1 := "GDP"]
income[str_detect(variable, "delta"), type1 := "GDP change"]
income[str_detect(variable, "growth"), type1 := "GDP growth"]
income[str_detect(variable, "lead"), type1 := "GDP in next year"]
income[str_detect(variable, "lag"), type1 := "GDP in prior year"]
income[str_detect(variable, "pop"), type1 := "population"]

income[, type2 := "real"]
income[str_detect(variable, "pop"), type2 := NA]

income[, units := "dollars"]
income[str_detect(variable, "pop"), units := "people"]
income[str_detect(variable, "growth"), type1 := "percent growth"]
income[str_detect(variable, "gdppc_sma"), units := "dollars, simple moving average"]
income[str_detect(variable, "gdppc_growth_sma"), units := "percent growth, simple moving average"]

# remove variable column
cols_del = c("variable")
income[, (cols_del) := NULL]

# remove rows with na value
income = income[!is.na(value), ]

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
income_maddison_2020 = income[source_name == "Maddison Project Database 2020", ]
usethis::use_data(income_maddison_2020, overwrite = TRUE)
