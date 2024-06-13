#testcoords<- read.csv("Coordinate_Validator/test_data_coordiantes.csv", header = T)
#library(mammalcol)
#library(terra)

mamm_coords_validator <- function(df, taxon = NULL, colmap = NULL) {
    cat("\n")
  # Validation: Check if taxon and colmap are provided, if not, throw error or handle default behavior
    # Validation: Check if taxon and colmap are provided
  if (is.null(taxon) || is.null(colmap)) {
    stop("Both 'taxon' and 'colmap' arguments must be provided.")
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

  #Species not validated
  notValispp <- df[!df$species %in% vlid_spp_nm,]
  notValispp$validation_result <- NA
  
  # Initialize a placeholder for the final result
  finalVal <- NA
  
  # Loop through each valid species
  for (i in 1:nrow(vlid_spp)) {
    spp.i <- df[df$species %in% vlid_spp$name_submitted[i], ]
    
    # Extract geographic coordinates
    vect.spp.i <- vect(spp.i, geom = c('decimalLongitude', 'decimalLatitude'), crs = "+proj=longlat +datum=WGS84")
    vect.spp.i.t <- terra::extract(vect(colmap), vect.spp.i)
    spp.i$validDpto <- vect.spp.i.t$NAME_1
    
    # Append the subset to the final result
    finalVal <- rbind(finalVal, spp.i)
  }
  finalVal<- finalVal[-1,]
  # Split distribution information
  distribution_list <- strsplit(taxon$distribution, "\\|")
  deptos <- as.data.frame(cbind(Depto = unique(colmap$NAME_1)))
  
  # Loop through each valid species again
  for (j in 1:nrow(vlid_spp)) {
    sp_id.j <- which(taxon$scientificName == vlid_spp$name_submitted[j])
    unos <- trimws(distribution_list[[sp_id.j]])
    
    # Check if department matches known distribution
    finalVal$validation_result <- ifelse(finalVal$validDpto %in% unos, 1, 0)
    finalVal<- subset(finalVal, select=-c(validDpto))

  }

finalVal<- rbind(finalVal, notValispp)


# Print the counts
cat("Number of records with correct State:", length(which(finalVal$validation_result == 1)), "\n")
cat("Number of records with different State:", length(which(finalVal$validation_result == 0)), "\n \n")
cat("All of the validation were development using the publication Ramirez-Chaves et al 2024 \n")

  return(finalVal)
}

#as<- mamm_coords_validator(testcoords, taxon = taxon, colmap = colmap)

