#####
# init
#####
# remove all objects
rm(list=ls(all=TRUE))

# load packages
library("pesdint")
library("data.table")
library("stringr")
library("ggplot2")
library("sdlutils")
library("scales")
library("shadowtext")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/vignettes/")
setwd(wd)

#####
# read data
#####
ukr = copy(ukraine_polling)

# duplicate zois poll
zois1 = copy(ukr[region == "Both", ])
zois1[, region := "Luhansk"]
ukr[region == "Both", region := "Donetsk"]
ukr = rbind(ukr, zois1)

# cols necessary to establish a unique poll
cols_unique = c("pollster", "poll_date", "question", "location", "region")

# recalculate percentages ignoring non-answers
ukr = ukr[position != 0, ]
ukr[, proportion := percent / 100]
ukr[, proportion_adj := proportion / sum(proportion), by = cols_unique]

# calculate poll date
ukr[, poll_date_easy_date := as.Date(poll_date_easy, format = "%Y %b %d")]

# reorder
setorderv(ukr, c("poll_date_easy_date", "position"))

# create and factor label
ukr[, label := paste0(pollster, "\n", poll_date, "\n", str_wrap(question, width = 30))]
ukr[, label := factor(label, levels = unique(label))]

# create position locations
ukr[, weight := (sign(position * -1) + 1)/2]
ukr[, max := sum(proportion_adj * weight), by = cols_unique]
ukr[, low := max - cumsum(proportion_adj), by = cols_unique]
ukr[, upp := low + proportion_adj, by = cols_unique]
ukr[, mid := (low + upp) / 2]

# create answer labels
ukr[, answer_split := str_replace_all(answer, c(" in "="\nin "))]
ukr[, answer_split := str_wrap(answer_split, width = 9)]

#####
# graph data
#####
# ggplot(gdt, aes(x = proportion_adj, y = label, fill = position)) +
#   geom_bar(position = "stack", stat = "identity") +
#   theme_sdl()

f = list(geom_rect(mapping = aes(y = label, ymin = ..y..-.4, ymax = ..y..+.4, xmin = low, xmax = upp, fill = factor(position)),
                   color = "NA"),
         geom_shadowtext(mapping = aes(x = mid, y = label, label = answer_split),
                         size = 3),
         scale_x_continuous(labels = scales::percent),
         scale_fill_brewer(palette = "RdBu", direction = -1, guide = "none"),
         labs(x = "", y = "",
              subtitle = '"Referendums" run by the Russian gov\'t give a strong "yes"\nPolls give a strong "unsure" or weak "no"',
              caption = c("@socdoneleft", "Note:\nCNN poll includes larger region (all of Southern or Eastern Ukraine)\nAll other polls include just Donetsk/Luhansk or just DPR/LPR\n\nSources: https://socdoneleft.substack.com/p/those-russian-annexation-referendums")),
         theme_sdl())

ggplot(ukr[region == "Donetsk", ]) + f +
  labs(title = "Do people in Donetsk want to be annexed by Russia?")
ggsave_sdl("ukraine_polling_donetsk.png")
