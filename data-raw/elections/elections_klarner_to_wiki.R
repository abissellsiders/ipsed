#####
# init
#####
library(data.table)
library(stringr)
library(scales)
library(toOrdinal)

wd = "C:/Users/abiss/Downloads"
setwd(wd)

#####
# read and munge data: references
#####
refs = fread("references.txt", sep = "", header = FALSE, col.names = "refs")
refs = refs[["refs"]]

#####
# read and munge data: state legislatures
#####
slers = read_dta("SLERS1967to2016_20180908.dta")
slers = data.table(slers)

sort(unique(str_subset(slers[["party"]], "peace")))

cols_view = c("year", "sab", "party", "last", "first", "vote")
party_ = "freedomandpeace"
party_ = c("peaceandfreedom", "peaceafreedom")
View(slers[party %in% party_, (cols_view), with = FALSE])

sort(unique(str_subset(slers[["party"]], "[0-9]")))
# see Appendix C for notes -- all numeric codes are some kind of oddity, not a unique party