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
# helper functions
#####
# deprecated, use toOrdinal::toOrdinal()
cardinal_to_ordinal_1 = function(x) {
  switch(as.character(x),
         "1" = "1st",
         "2" = "2nd",
         "3" = "3rd",
         "4" = "4th",
         "5" = "5th",
         "6" = "6th",
         "7" = "7th",
         "8" = "8th",
         "9" = "9th",
         "0" = "0th"
  )
}

# deprecated, use toOrdinal::toOrdinal()
cardinal_to_ordinal = function(x) {
  if (str_detect(x, ".*[^[0-9]]+.*")) {
    return(x)
  }
  if (str_length(x) > 1) {
    district = paste0(str_sub(x,1,1), cardinal_to_ordinal_1(str_sub(x,2,-1)))
  } else {
    district = cardinal_to_ordinal_1(x)
  }
  return(district)
}

#####
# read and munge data: references
#####
refs = fread("references.txt", sep = "", header = FALSE, col.names = "refs")
refs = refs[["refs"]]

#####
# read and munge data: congress
#####
# read csvs
house = fread("1976-2022-house.csv")
senate = fread("1976-2020-senate.csv")

# test before merging data
colnames(house)[!(colnames(house) %in% colnames(senate))]
colnames(senate)[!(colnames(senate) %in% colnames(house))]
senate[party_simplified == "DEMOCRAT" & party_simplified != party_detailed, ]
senate[party_simplified == "REPUBLICAN" & party_simplified != party_detailed, ]
senate[party_simplified == "LIBERTARIAN" & party_simplified != party_detailed, ]

# merge data
setnames(senate, "party_detailed", "party")
cols_delete = c("party_simplified")
senate[, (cols_delete) := NULL]
cols_new = c("runoff", "fusion_ticket")
senate[, (cols_new) := NA]
congress = rbind(house, senate)

# calculate percent of votes received
congress[, votepct := candidatevotes / totalvotes]
congress[, votepct_str := paste0(round(votepct * 10000)/100)]

# calculate winner
cols_by = c("year", "state_fips", "special")
congress[, votepct_max := max(votepct), by = cols_by]
congress[, winner := (votepct == votepct_max)]

# reorder data
cols_order = c("year")
setorderv(congress, cols = cols_order, order = -1L)

# standardize data
congress[, stage := toupper(stage)]

# view parties
str_subset(sort(unique(congress[["party"]])), "SOC")

#####
# create wiki table: congress
#####
# subset data
party_ = "PEACE AND FREEDOM"
congress_tabler = function(party_) {
  congress_sub = congress[party == party_ & stage == "GEN", ]
  
  # helper function
  row_to_table = function(row_) {
    state_ = str_to_title(row_[["state"]])
    candidate_ = str_to_title(str_replace_all(row_[["candidate"]], c(" [A-Za-z] "=" ")))
    candidatevotes_comma = label_comma()(row_[["candidatevotes"]])
    votepct_str = row_[["votepct_str"]]
    
    # chamber
    chamber1 = switch(row_[["office"]],
                      "US HOUSE" = "House of Representatives",
                      "US SENATE" = "Senate")
    chamber2 = switch(row_[["office"]],
                      "US HOUSE" = "House",
                      "US SENATE" = "Senate")
    if (row_[["winner"]] == TRUE) {
      wonlost = "{{yes2}} Won"
    } else {
      wonlost = "{{no2}} Lost"
    }
    
    year_ = row_[["year"]]
    if (year_ >= 1984) {
      ref = paste0("FEC", year_)
    } else {
      ref = paste0("HC", year_)
    }
    
    district_ = row_[["district"]]
    if (!is.na(as.numeric(district_))) {
      district_ord = toOrdinal(as.numeric(district_))
      district_str = paste0("| [[", state_, "'s ", district_ord, " congressional district|", district_ord,"]]")
    } else {
      district_str = "| At-Large"
    }
    
    # full text
    text_ = c("|-",
              paste0("| [[", year_," United States ", chamber1, " elections|", year_, "]]"),
              paste0("| ", candidate_),
              paste0("| [[United States ", chamber1, "|", chamber2, "]]"),
              paste0("| ", state_),
              district_str,
              paste0("| ", candidatevotes_comma),
              paste0("| {{Percentage bar|", votepct_str, "|hex=FF0000}}"),
              paste0("| ", wonlost),
              paste0("| "),
              paste0("| <ref name=", ref, " />")
    )
    return(text_)
  }
  
  # mw-collapsible mw-collapsed
  text_init = '{| class="wikitable sortable" style="font-size:80%"
  ! Year
  ! Candidate
  ! Chamber
  ! State
  ! District
  ! Votes
  ! %
  ! Result
  ! Notes
  ! Ref'
  text_end = '|}'
  
  texts_ = lapply(1:nrow(congress_sub), function(index){row_to_table(congress_sub[index, ])})
  rows_ = c(text_init, sapply(texts_, paste0, collapse = "\n"), text_end)
}

fileConn = file("congress_out.txt")
writeLines(rows_, fileConn)
close(fileConn)

mean(congress_sub[["votepct"]])

#####
# read and munge data: congress
#####
# read csvs
pres = fread("1976-2020-president.csv")
cols_by = c("year", "candidate")
pres[, candidatevotes_sum := sum(candidatevotes), by = cols_by]

uniq = unique(pres[year == 2020 & candidatevotes_sum > 1e3, ][, c("candidate", "party_detailed", "candidatevotes_sum"), with = FALSE])
fwrite(uniq, "uniq.csv")

pres_lean = fread("pres_lean_candidates_parties.csv")
cols_by = c("year", "candidate", "party_detailed")
pres = merge(pres, pres_lean, by = cols_by, all.x = TRUE)

pres[year == 2020, candidatevotes_sum_alignment := sum(candidatevotes), by = c("alignment")]
recode = c("Left" = -2,
           "Dem" = -1,
           "Center" = 0,
           "LeanRep" = mean(c(0.6, -0.32)),
           "Rep" = 1,
           "Right" = 2)
pres[, alignment_num := recode[alignment]]

library(ggplot2)
ggplot(pres, aes(x = alignment_num, y = candidatevotes_sum_alignment)) +
  geom_col()
