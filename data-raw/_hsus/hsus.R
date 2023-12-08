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
(wd = "C:/gdrive/rpackages/pesdint/data-raw/_hsus")
setwd(wd)

#####
# read data
#####
# read xlsx
income = data.table(read_excel("Eg217-222.xls", skip = 0))

# read xlsx
income = data.table(read_excel("Ca184-191.xls", skip = 0))
