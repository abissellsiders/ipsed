#####
# init
#####
# remove all objects
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("stringr")
library("readxl")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw/polling")
setwd(wd)

#####
# read data
#####
# read csv
mult = read_excel("multiparty.xlsx")
mult = data.table(mult)

# recalculate value
mult[!is.na(n), value := n/pop * 100]

# dates
cols_date = paste0("date", c(1,2))
mult[, (cols_date) := lapply(.SD, as.Date), .SDcols = cols_date]

# sort
setorderv(mult, cols = "date1")

# label
mult[, label := str_replace_all(source, c("Echelon Insights Omnibus " = ""))]
relabel = c("Stop illegal immigration.*" = "Nationalist",
            "Defend the American.*" = "Conservative",
            "Advance social progress.*" = "Liberal",
            "Put the middle class first.*" = "Labor",
            "Pass a Green New Deal.*" = "Green")
mult[, party := str_replace_all(answer, relabel)]

#####
# graph data
#####
# factor party and date
party_levels = c("Nationalist", "Conservative", "Liberal", "Labor", "Green", "Unsure")
party_colors = paste0("#", c("2F3147", "0564C0", "F5AF41", "C82506", "00882B", "B0B5BB"))
mult[, party_fac := factor(party, party_levels)]

mult[, label_fac := factor(label, unique(mult[["label"]]))]

# rescale value
mult[, value_unsure := max(value * (party == "Unsure")), by = c("label", "group2")]
mult[, value_rescaler := 1 - value_unsure/100]
mult[, value_rescale := value / value_rescaler]
mult[party == "Unsure", value_rescale := 0]

# graph data
library("ggplot2")
library("sdlutils")
ggplot(mult[group2 == "registered voters", ], aes(x = label_fac, y = value_rescale, fill = party_fac)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = party_colors) +
  scale_y_continuous(expand = c(0,0), breaks = seq(0,100,10)) +
  theme_sdl() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
        plot.caption = element_text(hjust = c(1, 0), size = 8)) +
  labs(x = "", y = "Percent of respondents",
       title = "Party choices in Echelon Insight's multiparty polls, USA 2019-2023",
       fill = "Party",
       subtitle = "Respondents heard a short party description ('put America first') but not the party label",
       caption = c("@socdoneleft", "SOURCES:\nEchelon Insights Verified Voter Omnibus polls for dates noted above\nNOTES:\nNationalist: 'Stop illegal immigration, put America First, stand up to political correctness, and end unfair trade deals'\nConservative: 'Defend the American system of free enterprise, promote traditional family values, and ensure a strong military'\nLiberal: 'Advance social progress including women’s rights and LGBTQ rights, work with other countries through free trade and diplomacy, cut the deficit, and reform capitalism with sensible regulation.'\nLabor: 'Put the middle class first, pass universal health insurance, strengthen labor unions, and raise taxes on the wealthy to support programs for those less well off'\nGreen: 'Pass a Green New Deal to build a carbon-free economy with jobs for all, break up big corporations, end systemic inequality, and promote social and economic justice'"))
ggsave_sdl("multiparty.png")

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
polling_multiparty = mult
usethis::use_data(polling_multiparty, overwrite = TRUE)
