#' @title
#' From Empire to Nation-State 2006 Dataset
#' @description
#' Wimmer and Min 2006, titled "From Empire to Nation-State", includes data on wars and colonial status of most countries from 1816 to 2001.
#'
#' For code see `/data-raw/fetns.r` in source.
#' @details
#' Wimmer and Min. "From empire to nation-state: Explaining war in the modern world, 1816-2001", American Sociological Review 71(6):867-897, 2006.
#' @format A data table with 28162 rows and 67* variables:
#' \describe{
#'   \item{country_code}{Correlates of War (COW) code (not equivalent to ISO 3166)}
#'   \item{country_name}{FETNS country name (not equivalent to ISO 3166)}
#'   \item{year}{year (1816 to 2001)}
#'   \item{war_code}{war code (combination of COW and Wimmer and Min 2006)}
#'   \item{war_name}{war name}
#'   \item{war_present}{whether a war was present in that territory in that year}
#'   \item{war_started}{whether a war started in that territory in that year}
#'   \item{war_ended}{whether a war ended in that territory in that year}
#'   \item{fractionalization_ethnic}{ethnic fractionalization (from 0 to 1); probability 2 random individuals are different ethnic identity; from Fearon and Laitin 2003}
#'   \item{fractionalization_religious}{religious fractionalization (from 0 to 1); probability 2 random individuals are different religious identity; from Fearon and Laitin 2003}
#'   \item{imperial_name}{name of imperial power over territory}
#'   \item{imperial_length}{length of current imperial power over territory (negative if independent but imperialized in future)}
#'   \item{area}{area of 2001 territory in km^2; from World Bank Development Indicators}
#'   \item{area_mountainous}{item_description}
#'   \item{military_personnel}{"Deviation from 5-year average of governing military's personnel" from COW National Material Capabilities 3.0}
#'   \item{oil_production}{oil production in metric tons; from Mitchell, International Historical Statistics}
#'   \item{itme_name}{item_description}
#' }
#' @source
#' * Page: \url{http://www.columbia.edu/~aw2951/Datasets.html}
#' * Data: \url{http://www.columbia.edu/~aw2951/WimmerMin1.0.xls}
#' * Documentation: \url{http://www.columbia.edu/~aw2951/EmpireNSdataset.pdf}
"fetns"
