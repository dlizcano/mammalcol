#' test_data_coordiantes Dataset
#'
#' A test data set for the function `mamm_coords_validator`
#'
#' @format A tibble with 20 rows and 50 columns:
#'   \describe{
#'     \item{species}{scientific name in binomial form}
#'     \item{decimalLatitude}{latitude}
#'     \item{decimalLongitude}{longitude}
#'   }
#'
#'
#' @details 
#' This data set provides a sample from GBIF to test the function mamm_coords_validator
#'
#' @examples
#' 
#' # Load the mammalcol package
#' library (mammalcol)
#'
#' # Access the mammalcol_tab dataset
#' data ("test_data_coordiantes")
#'
#' # Display the first few rows
#' head (test_data_coordiantes)
#'
#'
#' @seealso
#' For more information about the "mammalcol" package and the data sources, visit
#' the package's GitHub repository: \url{https://github.com/dlizcano/mammalcol}
#'
#' @references
#' The dataset is based on the "List of the Mammals of Colombia" by:
#' Ramírez-Chaves H E, Leuro Robles N G, Castaño Rivera A, Morales-Martínez D M, 
#' Suárez Castro A F, Rodríguez-Posada M E, Zurc D, Concha Osbahr D C, Trujillo A, 
#' Noguera Urbano E A, Pantoja Peña G E, González Maya J F, Pérez Torres J, 
#' Mantilla Meluk H, López Castañeda C, Velásquez Valencia A, Zárrate Charry D (2024): 
#' Mamíferos de Colombia. v1.14. Sociedad Colombiana de Mastozoología. Dataset/Checklist
#' \href{https://ipt.biodiversidad.co/sib/resource?r=mamiferos_col#anchor-citation}{SiB Colombia}
#' 
#' @author
#' Data compilation: Ramírez-Chaves 2021, Function implementation: Cristian A. Cruz-R.
#'
"test_data_coordiantes"
