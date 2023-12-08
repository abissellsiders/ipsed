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
(wd = "C:/gdrive/rpackages/pesdint/data-raw/imf_public_spending")
setwd(wd)

# url
# https://www.imf.org/external/datamapper/datasets/FPP

#####
# read data
#####
exp = read_excel("expense.xls")
colnames(exp)[1]
exp = data.table(exp)
colnames(exp)[1] = "country"
exp_m = melt(exp, id.vars = "country", variable.name = "year", value.name = "expense_pct_gdp")
exp_m = exp_m[!is.na(country) & !str_detect(country, "©"), ]

rev = read_excel("revenue.xls")
colnames(rev)[1]
rev = data.table(rev)
colnames(rev)[1] = "country"
rev_m = melt(rev, id.vars = "country", variable.name = "year", value.name = "revenue_pct_gdp")
rev_m = rev_m[!is.na(country) & !str_detect(country, "©"), ]

#####
# merge data
#####
imf = merge(exp_m, rev_m, by = c("country", "year"))
imf[, year := as.numeric(as.character(year))]
cols_num = c("expense_pct_gdp", "revenue_pct_gdp")
imf[, (cols_num) := lapply(.SD, as.numeric), .SDcols = cols_num]
imf[, (cols_num) := lapply(.SD, function(x){x / 100}), .SDcols = cols_num]

#####
# graph data
#####
m1 = list(geom_point(),
          geom_line())
f1 = list(theme_sdl(),
          scale_y_continuous(limits = c(0,1), breaks = seq(0,1,by=.1), expand = c(0,0), labels = percent),
          scale_x_continuous(limits = c(1995, 2023), expand = c(0, 0)),
          labs(x = NULL,
               caption = c("@socdoneleft", "Sources:\nIMF Public Finances in Modern History dataset")))

gdt = imf[country %in% c("United States", "Norway", "Venezuela", "Bolivia", "Colombia", "Brazil"), ]
title_str = "Government expenses as % of GDP"
ggplot(gdt, aes(x = year, y = expense_pct_gdp, group = country, color = country)) +
  m1 + f1 +
  labs(title = title_str, y = title_str)
ggsave_sdl("public_expense_pct_gdp.png")

title_str = "Government revenue as % of GDP"
ggplot(gdt, aes(x = year, y = revenue_pct_gdp, group = country, color = country)) +
  m1 + f1 +
  labs(title = title_str, y = title_str)
ggsave_sdl("public_revenue_pct_gdp.png")
