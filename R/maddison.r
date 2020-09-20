#' @title
#' Maddison Project Dataset
#' @description
#' The Maddison Project, last updated in 2018, contains historical population and real GDP per capita data on countries from 1 to 2016.
#' @details
#' Maddison Project Database, version 2018. Bolt, Jutta, Robert Inklaar, Herman de Jong and Jan Luiten van Zanden (2018), "Rebasing 'Maddison': new income comparisons and the shape of long-run economic development", Maddison Project Working paper 10
#' @source
#' * Page: \url{https://www.rug.nl/ggdc/historicaldevelopment/maddison/releases/maddison-project-database-2018}
#' * Data: \url{https://www.rug.nl/ggdc/historicaldevelopment/maddison/data/mpd2018.xlsx}
#' * Documentation: \url{https://www.rug.nl/ggdc/html_publications/memorandum/gd174.pdf}
#' @keywords maddison, real, gdp, population, per, capita
#' @format A data table with 340704 rows and 8 variables:
#' \describe{
#'   \item{country_code}{ISO 3166 country code}
#'   \item{country_name}{ISO 3166 country name}
#'   \item{year}{year (1 to 2016)}
#'   \item{population}{mid-year population}
#'   \item{cgdppc}{preferred measure of real GDP per capita level across countries}
#'   \item{rgdpnapc}{preferred measure of real GDP per capita growth over time}
#'   \item{ppp_estimate_type}{whether PPP (purchasing power parity) estimate is benchmark estimate, interpolation between benchmarks, or extrapolation beyond benchmarks}
#'   \item{ppp_benchmark_type}{whether benchmark estimate data source is 1: ICP PPP estimates, 2: Historical income benchmarks, 3: Real wages and urbanization, 4: Multiple of subsistence, 5: Braithwaite (1968) PPPs}
#' }
"maddison"
