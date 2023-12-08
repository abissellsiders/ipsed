#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("sdlutils")
library("ggrepel")
library("stringr")
library("readxl")

# set working directory
(wd1 = "C:/gdrive/rpackages/pesdint/data-raw/deaths/pirus_march2023")
(wd2 = "C:/gdrive/rpackages/pesdint/data-raw/deaths/")

#####
# read data
#####
# read excel
setwd(wd1)
pirus = read_excel("PIRUS_V4.xlsx", col_types = "text")
pirus = data.table(pirus)

# read coding
setwd(wd2)
codes = fread("pirus_coding.csv")

#
cols_sd = paste0("Ideological_Sub_Category", 1:3)
cols_new = paste0("ideology_official", 1:3)
pirus[, (cols_new) := lapply(.SD, function(x){factor(x, levels = codes[["code"]], labels = codes[["official"]])}), .SDcols = cols_sd]
cols_new = paste0("ideology_leftright", 1:3)
pirus[, (cols_new) := lapply(.SD, function(x){factor(x, levels = codes[["code"]], labels = codes[["leftright"]])}), .SDcols = cols_sd]
cols_new = paste0("ideology_detailed", 1:3)
pirus[, (cols_new) := lapply(.SD, function(x){factor(x, levels = codes[["code"]], labels = codes[["detailed"]])}), .SDcols = cols_sd]

#
library("ggplot2")
gdt = pirus[Primary_Event_Mass_Casualty_Incident_Type == 1, ]
ggplot(gdt, aes(x = Year_Exposure, fill = ideology_leftright1)) +
  geom_bar(color = NA)

#####
# examine dcast
#####
# merge values and best
mdc = dcast(data = dc, formula = f, value.var = "value")
