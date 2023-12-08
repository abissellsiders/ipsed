#' @title Maddison Project Historical GDP and Population dataset
#' @description The Maddison Project, last updated in 2018, contains historical population and real GDP per capita data on countries from 1 to 2016.
#' @references Maddison Project Database, version 2018. Bolt, Jutta, Robert Inklaar, Herman de Jong and Jan Luiten van Zanden (2018), "Rebasing 'Maddison': new income comparisons and the shape of long-run economic development", Maddison Project Working paper 10
#' @source Data sources:
#' \itemize{
#' \item DATA: Maddison 2020 dataset: (see Sources sheet for some sources): <https://www.rug.nl/ggdc/historicaldevelopment/maddison/releases/maddison-project-database-2020>
#' \item INFO: Maddison 2020 working paper: <https://www.rug.nl/ggdc/historicaldevelopment/maddison/publications/wp15.pdf>
#' \item DATA: Maddison 2018 dataset: <https://www.rug.nl/ggdc/historicaldevelopment/maddison/releases/maddison-project-database-2018>
#' \item INFO: Maddison 2018 working paper: (see table 1 for some sources): <https://www.rug.nl/ggdc/html_publications/memorandum/gd174.pdf>
#' \item DATA: Maddison 2013 dataset: <https://www.rug.nl/ggdc/historicaldevelopment/maddison/releases/maddison-project-database-2013>
#' \item INFO: Maddison 2013 working paper: <https://www.rug.nl/ggdc/historicaldevelopment/maddison/publications/wp4.pdf>
#' \item DATA: Maddison 2010 dataset: <https://www.rug.nl/ggdc/historicaldevelopment/maddison/releases/maddison-database-2010>
#' \item INFO: Maddison 2010 archived website: <https://web.archive.org/web/20211102093357/http%3A%2F%2Fwww.ggdc.net%2Fmaddison%2Foriindex.htm>
#' \item INFO: "older additions [sources] can be found in an earlier update paper, and in Maddison's work"
#' \item INFO: A review of Maddison's original data quality by a centrist: <https://nofuturepast.wordpress.com/2016/09/26/gdp-reconstructions-for-the-early-modern-period/>
#' \item INFO: Another review focused on Portugal by a centrist: <https://nofuturepast.wordpress.com/2019/05/27/on-the-discrepancies-between-the-original-maddison-dataset-and-more-recent-gdp-reconstructions/>
#' }
#' @keywords gdp per capita, real gdp, gdppc, maddison, pop, population, historical gdp
#' @format A data table with 340704 rows and 8 variables:
#' \describe{
#' \item{country_code}{ISO 3166 country code}
#' \item{country_name}{ISO 3166 country name}
#' \item{year}{year (1 to 2016)}
#' \item{population}{mid-year population}
#' \item{gdppc}{preferred measure of real GDP per capita}
#' \item{pop}{preferred measure of population}
#' \item{gdp}{gdppc * pop}
#' }
"income_maddison_2020"
