#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/vignettes/")
setwd(wd)

# load packages
library("data.table")
library("ggplot2")
library("ggrepel")
library("pesdint")
library("stringr")
library("sdlutils")
library("scales")

#####
# load data
#####
picy = pesdint_counyear

#####
# graphing allen 2003 style univariate control
#####
oecd_countries = unique(picy[oecd_1961 == TRUE, country_name])
oecd_compare = paste0(oecd_countries, collapse = "|")

# create lists of variables to plug into the below
dl = list(compare = oecd_compare, highlight = "Soviet Union", years = c(1950, 1990), xlim = c(0, 20000), ylim = c(0, 7.5))
dl = list(compare = oecd_compare, highlight = "Soviet Union|Yugoslavia|Albania|Poland|Czechoslovakia|Hungary|Romania|Bulgaria", years = c(1950, 1973), xlim = c(0, 20000), ylim = c(0, 7.5))
dl = list(compare = oecd_compare, highlight = "Sweden|Norway|Denmark|Finland", years = c(1950, 1973), xlim = c(0, 20000), ylim = c(0, 7.5))

# create copy of data
gdt = copy(picy)
# create new vars
gdt[str_detect(country_name, dl$compare),
    `:=`(compare = TRUE, group_ = "compare", label = country_name)]
gdt[str_detect(country_name, dl$highlight),
    `:=`(highlight = TRUE, group_ = "highlight", label = country_name)]
gdt = gdt[year %between% dl$years & !is.na(gdppc), ]
gdt[year %in% dl$years, N := .N, by = c("country_name")]
# create new vars
gdt[, `:=`(gdppc_t1 = max(gdppc * (year == dl$years[1]), na.rm = TRUE),
           gdppc_t2 = max(gdppc * (year == dl$years[2]), na.rm = TRUE),
           gdppc_growth_mean = mean(gdppc_growth, na.rm = TRUE),
           gdppc_growth_median = median(gdppc_growth, na.rm = TRUE)),
    by = c("country_name")]
# # quality check
# gdt[country_name == "Sweden" & year %between% dl$years, c("year", "gdppc_growth", "gdppc_growth_mean")]
# mean(gdt[country_name == "Sweden" & year %between% dl$years, c("year", "gdppc_growth")][["gdppc_growth"]])
# subset data
gdt = gdt[N > 1 & year == dl$years[2], ]
# calculate ratio
gdt[, gdppc_ratio := gdppc_t2 / gdppc_t1]
gdt[, color := "gray"]

#####
# graph data
#####
# formatting
f = list(theme_sdl(),
         geom_point(),
         geom_segment(aes(xend = gdppc_t1, yend = predicted)),
         geom_text_repel(segment.color = NA),
         scale_x_continuous(limits = dl$xlim, expand = c(0,0), oob = squish),
         scale_y_continuous(limits = dl$ylim, expand = c(0,0), oob = squish))

# create linear fits
fit1 = glm(gdppc_ratio ~ gdppc_t1, data = gdt[compare == TRUE, ])
fit2 = glm(gdppc_ratio ~ gdppc_t1, data = gdt[highlight == TRUE, ])
# add predicted data
gdt[compare == TRUE, predicted := predict(fit1)]
gdt[highlight == TRUE, predicted := predict(fit2)]
ggplot(gdt, aes(x = gdppc_t1, y = gdppc_ratio, label = label, color = group_)) + f +
  geom_abline(intercept = coef(fit1)[1], slope = coef(fit1)[2], color = "#F8766D") +
  geom_abline(intercept = coef(fit2)[1], slope = coef(fit2)[2], color = "#00BFC4") +
  labs(title = paste0("Real GDP/person growth ", dl$years[1], "-", dl$years[2], " and starting GDP/person"),
       x = paste0("STARTING: ", dl$years[1], " real GDP per person"),
       y = paste0("GROWTH: Ratio of real GDP per person in ", dl$years[2], " and in ", dl$years[1]))

# create linear fits
fit1 = glm(gdppc_growth_mean ~ gdppc_t1, data = gdt[compare == TRUE, ])
fit2 = glm(gdppc_growth_mean ~ gdppc_t1, data = gdt[highlight == TRUE, ])
# add predicted data
cols_new = c("predicted", "predicted_se")
gdt[compare == TRUE, (cols_new) := list(predict(fit1), predict(fit1, se.fit = TRUE)$se.fit)]
gdt[highlight == TRUE, predicted := predict(fit2)]
ggplot(gdt, aes(x = gdppc_t1, y = gdppc_growth_mean, label = label, color = group_)) +f +
  scale_y_continuous(limits = c(-0.005, 0.075), expand = c(0,0), oob = squish, labels = percent) +
  geom_abline(intercept = coef(fit1)[1], slope = coef(fit1)[2], color = "#F8766D") +
  geom_abline(intercept = coef(fit2)[1], slope = coef(fit2)[2], color = "#00BFC4")
