#' distribution Dataset
#'
#' The distribution dataset comprises a data frame containing information
#' regarding mammal species distribution documented in Colombia, sourced from the "List of the
#' mammals of Colombia" compiled by Ramírez-Chaves 2021. It encompasses various
#' details, including locality, source, threat status and appendix CITES of each species. 
#' The table is a variant of the distribution table from https://doi.org/10.15472/kl1whs
#'
#' @format A data frame with 548 rows and 8 columns:
#'   \describe{
#'     \item{id}{id from original taxon table.}
#'     \item{locality}{Departamento were the mammal is present.}
#'     \item{countryCode}{Code for Colombia.}
#'     \item{establishmentMeans}{Is endemic?. Endémica=Yes}
#'     \item{threatStatus}{categorization previous to 2021}
#'     \item{appendixCITES}{Apendix form CITES}
#'     \item{source}{reference for distribution}
#'     \item{occurrenceRemarks}{region were the species occurs.}
#'   }
#'
#'
#' @details This dataset is designed to provide users with comprehensive
#' information about the mammal species found in Colombia, as documented
#' by Ramírez-Chaves 2021. It is organized for easy access and utilization within
#' the R environment.
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
"distribution"
