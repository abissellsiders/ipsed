#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("sdlutils")
library("stringr")
library("ggplot2")
library("scales")
library("pesdint")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/vignettes/aid_over_time")
setwd(wd)

#####
# load data
#####
charity = pesdint_charity
social = pesdint_social
mutual = pesdint_mutual

#####
# qa
#####
# qa
gdt = social[group1 == "total minus education" & unit == "percent of GDP" & place1 %in% c("United States", "USA"), ]
ggplot(gdt, aes(x = year, y = value, group = source_name, color = source_name)) +
  geom_point() + geom_line() +
  scale_x_continuous(expand = c(0.01,0), breaks = (0:300)*50) +
  scale_y_continuous(expand = c(0,0), limits = c(0,.2), label = percent) +
  theme_sdl()

# qa
gdt1 = social[group1 %in% c("total minus education") & unit == "percent of GDP" & place1 %in% c("United States", "USA"), ]
recode_source = c("Lindert Data Garden" = 1, "Lindert 2021 How Was Life Vol II" = 2, "Lindert 1994" = 3)
gdt1[, source_num := recode_source[source_name]]
gdt1[, keep := min(source_num), by = c("year")]
gdt1 = gdt1[source_num == keep, ]
gdt1b = social[group1 %in% c("Total") & type2 == "Public" & unit == "percent of GDP" & place1 %in% c("United States", "USA"), ]
gdt2 = charity[group1 == "total" & type2 == "source" & unit == "percent of GDP" & str_detect(source_name, "Andrews|Giving"), ]
gdt3 = mutual[group2 == "total" & unit == "percent of GDP" & str_detect(source_name, "Beito"), ]
gdt = rbindlist(list(gdt1, gdt2, gdt3), fill = TRUE)
# gdt[year >= 1960 & type1 == "social_spending" & source_name == "Lindert 2021 How Was Life Vol II", value := NA]
# ggplot(gdt, aes(x = year, y = value, group = source_name, color = source_name)) +
#   geom_point() + geom_line() +
#   scale_x_continuous(expand = c(0.01,0), breaks = (0:300)*50) +
#   scale_y_continuous(expand = c(0,0), limits = c(0,.2), label = percent) +
#   theme_sdl() +
#   labs(title = "Social spending and private charity, USA, 1820-2020")

ggplot(gdt, aes(x = year, y = value, group = type1, color = type1)) +
  geom_point() + geom_line() +
  scale_x_continuous(expand = c(0.01,0), breaks = seq(1800,2050,by=10)) +
  scale_y_continuous(expand = c(0,0), limits = c(0,.2), label = percent) +
  theme_sdl() +
  labs(title = "US social spending, private charity, and mutual aid, 1820-2020",
       subtitle = "since 1929, social spending has dramatically increased and charity slowly increased",
       y = "percent of GDP",
       x = NULL,
       caption = c("@socdoneleft", "Sources and notes:\nCHARITY:\nEstimated charity includes all sources of funds (individual, corporate, bequest, foundation)\n(1929-1949) Andrews 1950, *Philanthropic Giving*, Table 13\n(1952-2020) Giving USA yearly reports 1956, 1957, 1958, 1980, 2012, 2019, 2020, 2021\nMUTUAL AID:\nEstimated mutual aid includes 174 fraternal societies\n(1910-1940) Beito 2000, 'Mutual Aid', Tables 11.1 and 12.1\nSOCIAL SPENDING:\nEstimated social spending does not include education spending\n(1820-1950) Lindert 2021, 'Social Spending', in *How Was Life: Volume II', OECD\n(1960-2019) Lindert 2023, Data Garden"))
ggsave_sdl("aid_over_time_social_charity_mutual.png")
