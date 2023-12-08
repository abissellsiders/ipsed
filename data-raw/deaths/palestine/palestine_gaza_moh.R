#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("sdlutils")
library("stringr")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw/deaths/palestine")
setwd(wd)

#####
# read data
#####
# read csv
pgmoh = fread("Palestine_Gaza_MOH_2023-10-26_Death_Toll_Table1.csv")

# remove index
pgmoh[, index := NULL]

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
deaths_palestine_gaza_moh = pgmoh
usethis::use_data(deaths_palestine_gaza_moh, overwrite = TRUE)

#####
# graph data
#####
library(ggplot2)
gdt = pgmoh[, .(N = .N), by = c("age_clean", "gender")]
gdt = gdt[age_clean < 100, ]
recode_ = c("F" = "Female",
            "M" = "Male")
gdt[, gender := recode_[gender]]
ggplot(data = gdt, aes(x = age_clean, y = N, fill = gender)) + theme_sdl() +
  # geom_col(position = "dodge", color = NA) +
  geom_col(color = NA, width = 1) + facet_grid(gender ~ .) +
  geom_rect(data = data.table(age_left = c(-0.5, 59.5), age_right = c(17.5, 100), ymin = c(0,0), ymax = c(150, 150)),
            mapping = aes(x = NULL, y = NULL, fill = NULL, xmin = age_left, xmax = age_right, ymin = ymin, ymax = ymax),
            alpha = .3, fill = "black", color = NA) +
  geom_labelled_vline(xvec = 17.5, yvec = 120, labs = "children", xoffset = -0.5) +
  geom_labelled_vline(xvec = 59.5, yvec = 120, labs = "elderly", xoffset = 0) +
  scale_x_continuous(breaks = seq(0, 100, by = 5), expand = c(0, 0)) +
  scale_y_continuous(breaks = seq(0, 1000, by = 25), expand = c(0, 0)) +
  guides(fill = "none") +
  labs(x = "Age", y = "Number killed",
       title = "68% of those killed in Gaza were children, elderly, or female",
       subtitle = "From 7 to 26 October, Israel killed over 7,000 people in Gaza",
       caption = c("@socdoneleft", "SOURCE: Palestinian Ministry of Health,\n'A detailed report on the victims of the Israeli aggression on the Gaza Strip during the period 7-26 October 2023'"))
ggsave_sdl("palestine_gaza_moh_by_age_by_gender.png")

# children, elderly, female
cef = sum(gdt[!(age_clean %between% c(18,59)) | gender == "Female", ][["N"]])
tot = sum(gdt[["N"]])
cef/tot
