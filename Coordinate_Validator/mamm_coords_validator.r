#testcoords<- read.csv("Coordinate_Validator/test_data_coordiantes.csv", header = T)
#library(mammalcol)
#library(terra)

#' Validate mammal species distribution data based on geographic coordinates.
#'
#' This function validates species distribution data provided in a data frame
#' against known mammal species lists and geographic coordinates. It outputs
#' a data frame with validation results and additional information.
#'
#' @param df A data frame containing species distribution data with columns 'species',
#'        'decimalLongitude', and 'decimalLatitude'.
#' @param taxon A data frame with distribution information, including 'scientificName' and 'distribution'.
#' @param colmap A spatial object (e.g., raster or vector) representing the geographic area to validate against.
#' @return A data frame with validated species records and validation results.
#'
#' @details
#' This function validates species distribution data by checking species names against a
#' known list and verifying geographic coordinates against a specified map ('colmap').
#' It assigns a validation result ('validation_result') where 1 means coincidence and 0 theoposive
#' to each species record in 'df'.
#'
#' @references
#' Ramírez-Chaves H E, Leuro Robles N G, Castaño Rivera A, Morales-Martínez D M, Zurc D, Suárez Castro A F, 
#' Concha Osbahr D C, Trujillo A, Noguera Urbano E A, Pantoja Peña G E, Rodríguez-Posada M E, 
#' González Maya J F, Pérez Torres J, Mantilla Meluk H, López Castañeda C, Velásquez Valencia A,
#'  Zárrate Charry D (2024). Mamíferos de Colombia. Version 1.14. Sociedad Colombiana de Mastozoología.
#'  Checklist dataset https://doi.org/10.15472/kl1whs accessed via GBIF.org on 2024-06-21.
#' 
#' @examples
#' # Example usage:
#' df <- read.csv("Coordinate_Validator/test_data_coordiantes.RData")
#' load('data/taxon.rda')
#' colmap <- load('data/colmap.rda')
#' validated_data <- mamm_coords_validator(df, taxon = taxon, colmap = colmap)
#'
#' @export
mamm_coords_validator <- function(df, distribution = NULL, colmap = NULL) {


  # Validation: Check if distribution and colmap are provided
  if (is.null(distribution))  {
  load('data/taxon.rda')
  }
  
  if (is.null(colmap)) {
load('data/colmap.rda')
  }



  # Extract unique species names from the data frame
  sppnms <- unique(df$species)
  
  # Validation of species
  vlid_spp <- search_mammalcol(sppnms, max_distance = 0.0)
  vlid_spp_nm <- unique(vlid_spp$name_submitted)
  
  # Display number of species found and validated
  if (length(vlid_spp_nm) == 0) {
    cat("There aren't valid species in the data set. Please review the species names before using this function")
  } else {
    cat(length(sppnms), "species found in the matrix and ", nrow(vlid_spp), "is/are valid \n")
  }
  cat("...\n")
  
  # Species not validated
  notValispp <- df[!df$species %in% vlid_spp_nm,]
  notValispp$validation_result <- NA
  
  # Initialize a placeholder for the final result
  finalVal <- NA
  
  # Loop through each valid species
  for (i in 1:nrow(vlid_spp)) {
    spp.i <- df[df$species %in% vlid_spp$name_submitted[i], ]
    
    # Extract geographic coordinates
    vect.spp.i <-  terra::vect(spp.i, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
    vect.spp.i.t <- terra::extract(terra::vect(colmap), vect.spp.i)
    spp.i$validDpto <- vect.spp.i.t$NAME_1
    
    # Append the subset to the final result
    finalVal <- rbind(finalVal, spp.i)
  }
  finalVal <- finalVal[-1,]
  
  # Split distribution information
  distribution_list <- strsplit(taxon$distribution, "\\|")
  deptos <- as.data.frame(cbind(Depto = unique(colmap$NAME_1)))
  
  # Loop through each valid species again
  for (j in 1:nrow(vlid_spp)) {
    sp_id.j <- which(taxon$scientificName == vlid_spp$name_submitted[j])
    unos <- trimws(distribution_list[[sp_id.j]])
    
    # Check if department matches known distribution
    finalVal$validation_result <- ifelse(finalVal$validDpto %in% unos, 1, 0)
    finalVal <- subset(finalVal, select = -c(validDpto))
    
  }
  
  finalVal <- rbind(finalVal, notValispp)
  
  # Print the counts
  cat("Number of records with correct State:", length(which(finalVal$validation_result == 1)), "\n")
  cat("Number of records with different State:", length(which(finalVal$validation_result == 0)), "\n \n")
   if (is.null(distribution))  {
  cat("All of the validation were development using the publication 'Ramirez-Chaves et. al, 2024' \n")
  }
  return(finalVal)
}