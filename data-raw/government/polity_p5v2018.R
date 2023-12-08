#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("sdlutils")
library("stringr")
library("readxl")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw/government")
setwd(wd)

#####
# read data
#####
# read from excel
polity_dt = data.table(read_excel("polity_p5v2018.xls", sheet = "p5v2018"))

#####
# munge data
#####
# convert dates
polity_dt[, polity_end := ISOdate(eyear, emonth, eday)]
polity_dt[, polity_begin := ISOdate(byear, bmonth, bday)]

# convert standardized authority codes

# prior & post removed -- unnecessary

# sf removed -- it's a combination of interim, polity, and change (except 1 instance)
# View(polity_dt[sf == 1 & !(polity %in% c(-66, -77, -88)) & !(interim %in% c(-66, -77, -88)) & !(change %in% c(-66, -77, -88, 96, 97, 98, 99)), ])
# View(polity_dt[country == "Burundi" & year %in% 1986:2006, ]) # Burundi 1996 -- unclear why this 1996 coup de etat would count as a state failure but others would not, eg: https://en.wikipedia.org/wiki/1990_Chadian_coup_d%27%C3%A9tat (invalid)

# regtrans removed -- it's a combination of interim, polity2, and change (except 3 instances, where it lags them)
# View(polity_dt[!(regtrans %in% c(-2,-1,0,1,2,3)) & !(regtrans == polity2) & !(regtrans == interim) & !(regtrans == change), ])
# View(polity_dt[country == "Haiti" & year %in% 2006:2018, ]) # Haiti 2016 -- regtrans of -77 carried over from prior year (possibly valid?)
# View(polity_dt[country == "Liberia" & year %in% 1986:2006, ]) # Liberia 1996 -- regtrans of -77 carried over from prior year (possibly valid?)
# View(polity_dt[country == "Congo Kinshasa" & year %in% 1955:1975, ]) # Congo Kinshasa 1965 -- implies country was created in 1960 & 1965 (invalid)

polity_dt[, `:=`(polity_occupation = -66 %in% c(interim, polity, change),
                 polity_anarchy = -77 %in% c(interim, polity, change),
                 polity_transition = -88 %in% c(interim, polity, change),
                 polity_transformation = 96 %in% c(interim, polity, change) | 97 %in% c(interim, polity, change),
                 polity_demise = 98 %in% c(interim, polity, change),
                 polity_creation = 99 %in% c(interim, polity, change)), by = c("scode", "year")]
polity_dt[, polity_unstable := any(polity_occupation, polity_anarchy, polity_transition), by = c("scode", "year")]

# better column names
colnames_new = c("scode" = "country_code",
                 "country" = "country_name",
                 "year" = "year",
                 "p5" = "polity_version",
                 "flag" = "polity_flagged",
                 "durable" = "polity_durability",
                 "polity" = "polity_score",
                 "polity2" = "polity_score_interpolated",
                 "democ" = "polity_democracy",
                 "autoc" = "polity_autocracy",
                 "xrreg" = "executive_recruitment_regulation",
                 "xrcomp" = "executive_recruitment_competition",
                 "xropen" = "executive_recruitment_openness",
                 "xconst" = "executive_restraints",
                 "parreg" = "participation_regulation",
                 "parcomp" = "participation_competitiveness",
                 "polity_occupation" = "polity_occupation",
                 "polity_anarchy" = "polity_anarchy",
                 "polity_transition" = "polity_transition",
                 "polity_unstable" = "polity_unstable",
                 "polity_transformation" = "polity_transformation",
                 "polity_demise" = "polity_demise",
                 "polity_creation" = "polity_creation",
                 "fragment" = "polity_fragmentation")
colnames(polity_dt) = colnames_new[colnames(polity_dt)]

# remove extra columns
polity_dt = polity_dt[, colnames_new, with = FALSE]

# reorder columns
setcolorder(polity_dt, unname(colnames_new))

#####
# standardize countries
#####
# countries = ipsed::countries
# convert country names
long_convert = setNames(countries[["master_long"]], countries[["polity_scode"]])
polity_dt[, country_name := long_convert[country_code]]

# convert country codes
short_convert = setNames(countries[["master_short"]], countries[["polity_scode"]])
polity_dt[, country_code := short_convert[country_code]]

# convert to factors
polity_dt[, polity_version := factor(polity_version, labels = c("Polity IV", "Polity 5"))]
polity_dt[, polity_flagged := factor(polity_flagged, labels = c("Confident", "Tentative", "Tenuous"))]
polity_dt[, polity_fragmentation := factor(polity_fragmentation, labels = c("0% fragmentation", "0-10% fragmentation", "10-25% fragmentation", "25-50% fragmentation"))]

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
govt_polity = polity_dt
usethis::use_data(govt_polity, overwrite = TRUE)
