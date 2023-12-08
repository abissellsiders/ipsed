#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# set working directory
wd = paste0("C:/rpackages/pesdint/data-raw/unesco_education")
setwd(wd)

# load packages
library("data.table")
library("ggplot2")
library("readxl")
library("hrbrthemes")
library("stringr")
library("scales")

#####
# read data
#####
# get list of files
csv_filenames = list.files(pattern = ".csv")

# reader function
read_unesco = function(filename) {
  dt = fread(filename)
  colnames(dt)[1] = "indicator_code"
  return(dt)
}

# combine datasets
unesco = rbindlist(lapply(csv_filenames, read_unesco))

# drop time column
cols_drop = c("TIME")
unesco[, (cols_drop) := NULL]

# change column names
colnames(unesco) = str_replace_all(tolower(colnames(unesco)), c("location"="country_code", "^country$"="country_name", "^time$"="year", " "="_"))

# long to wide
cols_var = c("value")
cols_keep = colnames(unesco)[!(colnames(unesco) %in% c(cols_var, "indicator", "indicator_code", "flags", "flag_codes"))]
formula_ = as.formula(paste0(paste0(cols_keep, collapse = "+"), "~indicator", sep = ""))
unesco = dcast(unesco, formula = formula_, value.var = cols_var)

# change column names
colnames(unesco) = str_replace_all(tolower(colnames(unesco)), c("\\(%\\)"="percent", "\\(number\\)"="count", " "="_", ","=""))

#####
# graph data
#####
id_vars = c("country_name", "year")
measure_vars = str_subset(str_subset(colnames(unesco), "completion_rate.*_percent"), "rural|urban", negate = TRUE)

# subset function
unesco_graph_subset = function(measure_vars) {
  mdt = melt(unesco, id.vars = id_vars, measure.vars = measure_vars)
  mdt[, sex := str_match(variable, "_(both|male|female)")[,2]]
  mdt[, level := str_match(variable, "_(upper_secondary|lower_secondary|primary|tertiary)")[,2]]
  mdt = mdt[country_name == "Afghanistan" & sex != "both" & !is.na(value), ]
  return(mdt)
}

# graph achievement level as percent of school age population
measure_vars = str_subset(str_subset(colnames(unesco), "enrolment_in_(upper_secondary|lower_secondary|primary|tertiary_education_all).*_count"), "rural|urban", negate = TRUE)
mdt1 = unesco_graph_subset(measure_vars)
setnames(mdt1, "value", "enrolled")
measure_vars = str_subset(str_subset(colnames(unesco), "school_age_population_(upper_secondary|lower_secondary|primary|tertiary).*_count"), "rural|urban", negate = TRUE)
mdt2 = unesco_graph_subset(measure_vars)
setnames(mdt2, "value", "school_age_population")
mdt = merge(mdt1, mdt2, by = c("country_name", "year", "sex", "level"))
mdt[, prop_enrolled := enrolled / school_age_population]
mdt[, level := factor(level, levels = c("primary", "lower_secondary", "upper_secondary", "tertiary"))]

f = list(geom_area(position = "identity", color = "white"),
         geom_point(size = 1, color = "white"),
         facet_grid(sex ~ .),
         geom_vline(xintercept = c(1979, 1989, 2001, 2021), color = "white"),
         theme_ft_rc(),
         scale_x_continuous(expand = c(0,0)),
         scale_y_continuous(labels = comma),
         labs(subtitle = "Afghanistan was invaded by the Soviet Union from 1979-1989 and the United States from 2001-2021",
              caption = c("@socdoneleft", "Source: UNESCO UIS database: data.uis.unesco.org")),
         theme(plot.caption = element_text(hjust=c(1, 0)), panel.grid.minor = element_blank()))

ggplot(mdt, aes(x = year, y = enrolled, fill = level)) + f +
  labs(title = "Afghanistan: Number enrolled in education, by sex and school level")

ggplot(mdt, aes(x = year, y = prop_enrolled, color = level, fill = level)) + f +
  labs(title = "Afghanistan: Proportion of school-age people enrolled in education, by sex and school level")
