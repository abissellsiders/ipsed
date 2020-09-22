get_fetns = function() {
  # download file
  path = tempfile()
  download.file("https://github.com/abissellsiders/ipsed/raw/master/data-raw/fetns/wimmermin.xls", path, mode="wb")
  # read from excel
  fetns_df = readxl::read_excel(path, sheet = "WimmerMin1.0")
  # data.frame to data.table
  fetns_dt = data.table(fetns_df)
  # whether war ended in that year
  fetns_dt[, war_ended := (yrend == year)]
  fetns_dt[, area_mountainous := exp(lmtnest)]
  fetns_dt[, oil_production := oil * 1000]
  # better column names
  colnames_new = c("cowcode" = "country_code",
                   "country" = "country_name",
                   "year" = "year",
                   "warno" = "war_code",
                   "warname" = "war_name",
                   "war" = "war_present",
                   "onset" = "war_started",
                   "war_ended" = "war_ended",
                   "wartype" = "war_type",
                   "yrbeg" = "war_started_year",
                   "yrend" = "war_ended_year",
                   "instab" = "instability",
                   "ethfrac" = "fractionalization_ethnic",
                   "relfrac" = "fractionalization_religious",
                   "imppower" = "imperial_name",
                   "implag" = "imperial_length",
                   "area2001" = "area",
                   "area_mountainous" = "area_mountainous",
                   "milperc" = "military_personnel",
                   "nsflag" = "nationstateformation_years_to",
                   "nsfyear" = "nationstateformation_year",
                   "oil_production" = "oil_production",
                   "oilpc" = "oil_production_percapita",
                   "nbcivil" = "neighbors_warcivil_count",
                   "nbconq" = "neighbors_warconquer_count",
                   "nbnatind" = "neighbors_warindependence_count",
                   "nbnonind" = "neighbors_warnonindependence_count",
                   "pdemnb" = "neighbors_democratic_proportion",
                   "pop" = "population")
}

Ukraine MIXED RULE
Moldova MIXED RULE
Slovakia MIXED RULE
Armenia MIXED RULE
Cameroon MIXED RULE
Croatia MIXED RULE
Sudan MIXED RULE
Togo MIXED RULE
Tunisia MIXED RULE
Yemen MIXED RULE

Namibia	South Africa
Tunisia	MIXED RULE
Sudan	MIXED RULE
Yemen	MIXED RULE

North Korea	Korea
South Korea	Japan

Togo	MIXED RULE
Cameroon	MIXED RULE
Somalia	MIXED RULE

#####
# colony status recodes
#####
# Austria by Germany: unreasonable
# should be Germany from 1938 to 1944: Austrian ruling Fascist opposition to Anschluss (1938) suggest the union was involuntary

# Czech Republic and Slovakia by Czechoslovakia: unreasonable
# should be none: both creation (as seen in 1920 elections) and dissolution (as seen in Velvet Divorce) suggest the union was voluntary

# Netherlands by Germany: unreasonable
# should be Germany from 1940 (German invasion)

# Poland by mixed rule, then Germany: mostly reasonable
# should be Germany + Austria + Russia from 1795 (third partition) to either 1918 (end of WW1) or 1921 (end of Bolshevik revolution)
# should be none from 1918 to 1939 (independence)
# should be Germany + Russia from 1939 to 1941 (Germany, USSR occupy Poland)
# should be Germany from 1941 to 1944 (Germany occupies Poland)
# should be none from 1945 (independence)

# Taiwan by China: mostly reasonable
# should be China from 1662 (China took Taiwan from Netherlands) to 1895 (China ceded Taiwan to Japan)
# should be Japan from 1895 to 1945
# should be none from 1945 (Chinese civil war)

#####
# colony status non-recodes
#####
# Bengladesh by Pakistan: reasonable
# should be Pakistan: persistent Bengali underrepresentation, 1971 genocide, and 1971 civil war suggest the union was involuntary

# Ireland	by United Kingdom: reasonable
# should be United Kingdom: Norman invasion of Ireland (1169) and frequent uprisings / terrorism suggest the union was involuntary

# Peru by Bolivia: reasonable
# should be Bolivia: imposition by Bolivia of the Peru-Bolivian Confederation of 1836-39 suggests the union was involuntary

#####
# other
#####
# poland has duplicated years to account for multiple wars -- wars should probably be recoded as a list or string

# Croatia
# Slovenia
# Yugoslavia
# austria-hungary
Macedonia	Yugoslavia
Croatia	Yugoslavia
Bosnia and Herzegovina	Yugoslavia
Slovenia	Yugoslavia
