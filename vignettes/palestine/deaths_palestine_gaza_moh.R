#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/vignettes/palestine")
setwd(wd)

# load packages
library("data.table")
library("ggplot2")
library("ggrepel")
library("gridExtra")
library("shadowtext")
library("stringr")
library("pesdint")
library("sdlutils")

#####
# load data
#####
maddison = deaths_palestine_gaza_moh[!is.na(pop), ]
