#' taxon Dataset
#'
#' The taxon dataset comprises a tibble containing information
#' regarding mammal species documented in Colombia, sourced from the "List of the
#' mammals of Colombia" compiled by Ramírez-Chaves 2021. It encompasses various
#' details, including scientific names, English names, Spanish names, order,
#'  family, threat status and distribution of each species. The table is a 
#'  variant of the taxon table from https://doi.org/10.15472/kl1whs
#'
#' @format A tibble with 548 rows and 25 columns:
#'   \describe{
#'     \item{id}{id from original taxon table.}
#'     \item{scientificName}{Scientific name of the mammal species.}
#'     \item{kingdom}{kingdom name of the mammal species.}
#'     \item{phylum}{phylum name of the mammal species.}
#'     \item{class}{class name of the mammal species.}
#'     \item{order}{order name of the mammal species.}
#'     \item{family}{family name of the mammal species.}
#'     \item{genus}{genus name of the mammal species.}
#'     \item{specificEpithet}{specificEpithet name of the mammal species.}
#'     \item{taxonRank}{taxon Rank name of the mammal species.}
#'     \item{scientificNameAuthorship}{species name´s author of the mammal species.}
#'     \item{taxonRemarks}{elevation of the mammal species.}
#'     \item{bibliographicCitation}{bibliographicCitation of the mammal species.}
#'     \item{inMDD}{1 if it is included on the Mammal Diverity Data Base, 0 not included.}
#'     \item{Col_redlist}{conservation status in Colombia for the mammal species.}
#'     \item{distribution}{Departamento were the mammal is present.}
#'     \item{source}{reference for the distribution.}
#'     \item{endemic}{Yes if it is endemic from Colombia, otherwise No.}
#'     \item{english_name}{english_name of the mammal species.}
#'   }
#'
#'
#' @details This dataset is designed to provide users with comprehensive
#' information about the mammal species found in Colombia, as documented
#' by Ramírez-Chaves 2021. It is organized for easy access and utilization within
#' the R environment.
#'
#' @examples
#' # Load the mammalcol package
#' library(mammalcol)
#'
#' # Access the mammalcol_tab dataset
#' data("taxon")
#'
#' # Display the first few rows
#' head(taxon)
#'
#' @seealso
#' For more information about the "mammalcol" package and the data sources, visit
#' the package's GitHub repository: \url{https://github.com/dlizcano/mammalcol}
#'
#' @references
#' The dataset is based on the "List of the Mammals of Colombia" by Ramírez-Chaves 2021.
#'
#' @author
#' Data compilation: Ramírez-Chaves 2021, Package implementation: Diego J. Lizcano
#'
#' @keywords dataset
"taxon"
