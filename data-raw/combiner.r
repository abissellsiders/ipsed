#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("sdlutils")
library("stringr")
library("ggplot2")
library("scales")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw")
setwd(wd)

#####
# set global options
#####
options(datatable.prettyprint.char=10L)

#####
# load data
#####
# load rdas
paths_rda = list.files("../data", ".rda", full.names = TRUE)
for (path in paths_rda) {load(path)}
(list_data = ls(all=TRUE))

#####
# helper value reformatter function
#####
get_dt_valuechar = function(x) {
  dt = get(x)
  print(x)
  print(colnames(dt))
  print("---")
  dt[, value := as.character(value)]
  return(dt)
}

# sapply(list_data2, function(x) { class(get(x)[["value"]]) })






#####
# combine income data
#####
# us gdp divider
source("../R/fredr_income.R")
fed = fredr_prep_mult_all(c("GDPA"))
fed[, gdpa := gdpa * 1e9]
income_fed = fed[, c("year", "gdpa"), with = FALSE]
income_fed[, source_name := "FRED"]
income_fed[, type1 := "GDP"]
income_fed[, type2 := "nominal"]
income_fed[, place1 := "United States"]
income_fed[, units := "dollars"]
setnames(income_fed, "gdpa", "value")

# comparing measures (note maddison is real)
income = rbindlist(list(income_fed, income_maddison_2020, income_mw), fill = TRUE)

income[type1 == "GDP" & units == "dollars" & place1 == "United States", ]
ggplot(gdt, aes(x = year, y = value, color = source, group = source)) +
  geom_point() + geom_line()

# gdp series
nominal_gdp_usa = income[type1 == "GDP" & type2 == "nominal" & units == "dollars" & place1 == "United States", ]
nominal_gdp_usa[, keep := ((str_detect(source_name, "FRED") & year >= 1929) | (str_detect(source_name, "Measuring Worth") & year <= 1928))]
nominal_gdp_usa = nominal_gdp_usa[keep == 1, ]
cols_keep = c("year", "value")
nominal_gdp_usa = nominal_gdp_usa[, (cols_keep), with = FALSE]
cols_new = c("year", "gdpa")
setnames(nominal_gdp_usa, cols_new)

# compare fred and measuring worth
# gdt2 = dcast(gdt, year ~ source, value.var = "gdpa")
# gdt2[, diff := FRED - `Measuring Worth 2023`]
# gdt2[, diff_prop := diff / FRED]
# ggplot(gdt2, aes(x = year, y = diff_prop)) +
#   geom_point() + geom_line()

# save data
pesdint_income = income
usethis::use_data(pesdint_income, overwrite = TRUE)





#####
# combine charity data
#####
# find relevant datasets
list_data2 = str_subset(list_data, "^charity")

# merge data
charity = rbindlist(lapply(list_data2, get_dt_valuechar), fill = TRUE)
charity[, value := as.numeric(value)]

# check for empty values
unique(charity[is.na(unit), ][["source_name"]])
unique(charity[is.na(type), ][["source_name"]])

# check what sources exist
unique(charity[["source_name"]])
sort(unique(charity[["place1"]]))

# calculate percent of GDP
# convert year to numeric
charity[, year := as.numeric(year)]
# TODO need to standardize place1
# TODO need to create income dataset first -- FRED or World Bank > PWT > Maddison -- then can easily standardize GDP across all countries w/o subsetting
charity_dollars = charity[unit == "dollars" & place1 %in% c("USA", "United States of America"), ]
charity_dollars = merge(charity_dollars, nominal_gdp_usa, by = c("year"), all.x = TRUE)
charity_dollars[, value := value / gdpa]
charity_dollars[, unit := "percent of GDP"]
charity_dollars[, gdpa := NULL]
charity = rbind(charity, charity_dollars)

# # qa
# gdt = charity[group1 == "total" & unit == "percent of GDP" & str_detect(source_name, "Andrews|^GU"), ]
# ggplot(gdt, aes(x = year, y = value, group = source_name, color = source_name)) +
#   geom_point() + geom_line() +
#   scale_x_continuous(expand = c(0.01,0), breaks = (0:300)*10) +
#   scale_y_continuous(expand = c(0,0), limits = c(0,0.03), labels = percent) +
#   theme_sdl()
# gdt = charity[group1 != "total" & type2 == "source" & unit == "percent of GDP" & str_detect(source_name, "Andrews|Giving"), ]
# gdt[is.na(value), value := 0]
# ggplot(gdt, aes(x = year, y = value, group = group1, fill = group1)) +
#   geom_area() +
#   scale_x_continuous(expand = c(0.01,0), breaks = (0:300)*10) +
#   scale_y_continuous(expand = c(0,0), limits = c(0,0.03), labels = percent) +
#   theme_sdl()

# rename dataset (doesn't use memory until acted upon)
pesdint_charity = charity
usethis::use_data(pesdint_charity, overwrite = TRUE)



#####
# combine mutual aid data
#####
# find relevant datasets
list_data2 = str_subset(list_data, "^mutual")

# merge data
mutual = rbindlist(lapply(list_data2, get_dt_valuechar), fill = TRUE)
mutual[, value := as.numeric(value)]
mutual[, year := as.numeric(as.character(year))]

# check what sources exist
unique(mutual[["source_name"]])
sort(unique(mutual[["place1"]]))

# calculate percent of GDP
# TODO need to standardize place1
# TODO need to create income dataset first -- FRED or World Bank > PWT > Maddison -- then can easily standardize GDP across all countries w/o subsetting
mutual_dollars = mutual[unit == "dollars" & place1 %in% c("USA", "United States of America"), ]
mutual_dollars = merge(mutual_dollars, nominal_gdp_usa, by = c("year"), all.x = TRUE)
mutual_dollars[, value := value / gdpa]
mutual_dollars[, unit := "percent of GDP"]
mutual_dollars[, gdpa := NULL]
mutual = rbind(mutual, mutual_dollars)

# rename dataset (doesn't use memory until acted upon)
pesdint_mutual = mutual
usethis::use_data(pesdint_mutual, overwrite = TRUE)



#####
# combine social spending data
#####
# find relevant datasets
list_data2 = str_subset(list_data, "^social")

# merge data
social = rbindlist(lapply(list_data2, get_dt_valuechar), fill = TRUE)
social[, value := as.numeric(value)]
social[, year := as.numeric(as.character(year))]

setcolorder(social, c("year", "place1", "place1_iso3", "type1", "type2", "group1", "group2", "value", "unit", "notes", "source_name", "source_loc"))
fwrite(social, "pesdint_social.csv")

# check for empty values
unique(social[is.na(unit), ][["source_name"]])

# check what sources exist
unique(social[["source_name"]])
sort(unique(social[["place1"]]))
sort(unique(social[["group1"]]))

# rename dataset (doesn't use memory until acted upon)
pesdint_social = social
usethis::use_data(pesdint_social, overwrite = TRUE)
