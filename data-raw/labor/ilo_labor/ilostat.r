#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("sdlutils")
library("stringr")
library("Rilostat")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw/ilo_labor")
setwd(wd)

#####
# read data
#####
# toc = get_ilostat_toc(search = 'co-operative', lang = 'en')
# View(toc)

tb = get_ilostat(id = 'EMP_TEMP_SEX_INS_NB_A', segment = 'indicator')
emp = data.table(tb)

emp = emp[sex == "SEX_T", ]
cols_by = c("ref_area", "time")
emp[, value_total := max(obs_value * (classif1 == "INS_SECTOR_TOTAL")), by = cols_by]
emp[, prop := obs_value / value_total]
emp[, time := as.numeric(as.character(time))]

library("pesdint")
cols_keep = c("master_short", "master_long")
countries_ = countries[, (cols_keep), with = FALSE]
setnames(countries_, c("area_short", "area_long"))
countries_ = unique(countries_)
emp = merge(emp, countries_, by.x = c("ref_area"), by.y = c("area_short"), all.x = TRUE, fill = TRUE)
library("ggplot2")
library("scales")
gdt = emp[classif1 == "INS_SECTOR_PUB" & ref_area %in% c("USA", "NOR", "SWE", "VEN", "CHL", "BOL", "COL", "BRA", "CUB", "VNM", "LAO"), ]
ggplot(gdt, aes(x = time, y = prop, color = area_long)) +
  geom_point() + geom_line(size = 0.75) +
  scale_y_continuous(limits = c(0,1), breaks = seq(0,1,by=.1), expand = c(0,0), labels = percent) +
  scale_x_continuous(limits = c(2000, 2023), expand = c(0, 0)) +
  theme_sdl() +
  labs(title = "Proportion of workers in public sector",
       caption = c("@socdoneleft", "Sources:\nILOSTAT via RILOSTAT R package"),
       y = NULL,
       x = NULL)


gdt = emp[classif1 == "INS_SECTOR_PUB" & ref_area %in% c("USA", "NOR", "VEN", "BOL", "COL", "BRA"), ]
ggplot(gdt, aes(x = time, y = prop, color = area_long)) +
  geom_point() + geom_line(size = 0.75) +
  scale_y_continuous(limits = c(0,0.4), breaks = seq(0,1,by=.1), expand = c(0,0), labels = percent) +
  scale_x_continuous(limits = c(2000, 2023), expand = c(0, 0)) +
  theme_sdl() +
  labs(title = "Proportion of workers in public sector",
       caption = c("@socdoneleft", "Sources:\nILOSTAT via RILOSTAT R package"),
       y = NULL,
       x = NULL)
ggsave_sdl("publicemployment_venezuela_group1.png")

gdt = emp[classif1 == "INS_SECTOR_PUB" & ref_area %in% c("USA", "VEN", "CUB", "VNM", "LAO"), ]
ggplot(gdt, aes(x = time, y = prop, color = area_long)) +
  geom_point() + geom_line(size = 0.75) +
  scale_y_continuous(limits = c(0,1), breaks = seq(0,1,by=.1), expand = c(0,0), labels = percent) +
  scale_x_continuous(limits = c(2000, 2023), expand = c(0, 0)) +
  theme_sdl() +
  labs(title = "Proportion of workers in public sector",
       caption = c("@socdoneleft", "Sources:\nILOSTAT via RILOSTAT R package"),
       y = NULL,
       x = NULL)
ggsave_sdl("publicemployment_venezuela_group2.png")
