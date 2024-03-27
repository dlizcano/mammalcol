#' colmap Dataset
#'
#' The colmap dataset Simple feature collection with 33 features and 11 fields. This version 
#' was obtained from: GDAM using: 
#' colmap <- sf::st_as_sf(gadm(country="COL", level=1, path=tempdir()))
#' al later apply st_simplify with a tolerance of 1km:
#' colmap <- st_simplify(colmap, preserveTopology = FALSE, dTolerance = 1000)
#'
#' @format Simple feature collection with 33 features and 11 fields:
#'   \describe{
#'     \item{GID_1}{id from original GDAM}
#'     \item{GID_0}{id from original GDAM}
#'     \item{COUNTRY}{Colombia.}
#'     \item{NAME_1}{Departamentos.}
#'     \item{VARNAME_1}{class name GDAM.}
#'     \item{NL_NAME_1}{order name of GDAM.}
#'     \item{TYPE_1}{family name of of GDAM.}
#'     \item{ENGTYPE_1}{name of of GDAM.}
#'     \item{CC_1}{name of of GDAM}
#'     \item{HASC_1}{name of of GDAM}
#'     \item{ISO_1}{name of of GDAM}
#'     \item{geometry}{polygons of GDAM}
#'   }
#'
#'
#' @details This dataset is designed to provide users with a companion map to
#' plot the mammal distribution per departamento
#'
#' @examples
#' # Load the mammalcol package
#' library(mammalcol)
#'
#' # Access the mammalcol_tab dataset
#' data("colmap")
#'
#' # Display the first few rows
#' head(colmap)
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
"colmap"
