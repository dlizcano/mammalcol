#' Validate mammal species distribution data based on geographic coordinates.
#' 
#' This function validates species distribution data provided in a data frame
#' against known mammal species lists and geographic coordinates. It outputs
#' a data frame with validation results and additional information.
#'
#' @param df A data frame containing species distribution data with columns 'species',
#'        'decimalLongitude', and 'decimalLatitude'.
#' @param sp_names Name of the column containing species names (Genus + Specific Epithet).
#' @param taxon A data frame with distribution information, including 'scientificName' and 'distribution'.
#'              The scientificName must be in binomial form, and the distribution should contain names separated by |.
#'              By default, the function uses the checklist available at https://www.gbif.org/dataset/e8b9ed9b-f715-4eac-ae24-772fbf40d7ae.
#' @param colmap A spatial object in vector format representing the geographic area to validate against.
#'               By default, the function uses the Colombia Administrative Boundaries available in the geodata package.
#' @param lon Name of the column containing longitude values in df. Default is 'decimalLongitude'.
#' @param lat Name of the column containing latitude values in df. Default is 'decimalLatitude'.
#' @param adm_names Name of the column in colmap representing administrative boundaries. Default is 'NAME_1'.
#' @param oceanmap A spatial object representing the ocean area to validate against.
#' @param oce_adm_names Name of the column in oceanmap representing administrative boundaries for ocean areas. Default is 'ocean'.
#' @return A data frame with validated species records and validation results.

#' @details
#' This function validates species distribution data by checking species names against a
#' known list and verifying geographic coordinates against specified maps ('colmap' and 'oceanmap').
#' It assigns a validation result ('validation_result') where 1 means coincidence and 0 means
#' no match. Additional details are provided in the returned data frame.
#'
#' @examples
#' validated_data <- mamm_coords_validator(test_data_coordiantes, sp_names = "species")
#'
#' @export
mamm_coords_validator <- function(df, sp_names, taxon = NULL, colmap = NULL, lon = NULL, lat = NULL, adm_names = NULL, oceanmap = NULL, oce_adm_names = NULL) {
  
  ## Info added
  # require(sf)
  # require(geodata)
  
  # Initialize function
  
  # Validate input and set defaults if necessary
  df <- as.data.frame(df)
  oriNames <- names(df)
  
  # Check if species column name is provided and follows binomial structure
  if (missing(sp_names)) {
    stop("You must specify the name of the column containing species names (sp_names) using binomial structure (Genus + specifiepithet).")
  }
  
  # Validation: Check if taxon, colmap, and column names are provided
  if (is.null(taxon))  {
    taxon <- mammalcol::taxon
  }
  
  if (is.null(adm_names)) {
    adm_names = 'NAME_1'
  }
  
  if (is.null(colmap)) {
    
    # load('data/colmap_igac.rda')
    # require(geodata)
    colmap <-sf::st_as_sf(geodata::gadm('COL', level = 1,  path=tempdir()))
    colmap[[adm_names]] <- tolower(colmap[[adm_names]])
  } else {
    colmap <- sf::st_as_sf(colmap)
    colmap[[adm_names]] <- tolower(colmap[[adm_names]])
  }
  
  # Set default column names for longitude and latitude if not provided
  if (is.null(lon) & is.null(lat))  {
    lon = 'decimalLongitude'
    lat = 'decimalLatitude'
  } 
  
  # Set default ocean map and administrative boundary name for ocean if not provided
  if (is.null(oceanmap)) {
    #load('data/colombian_sea.rda')
    oceanmap <- mammalcol::Colombian_sea
  }  else {
    oceanmap <- sf::st_as_sf(oceanmap)
  }
  
  if (is.null(oce_adm_names)) {
    oceanmap[[adm_names]] <- 'ocean'
  } else {
    oceanmap[[adm_names]] <- oce_adm_names
  }
  
  ## Start the data process
  
  df$IDVal <- paste0('M', 1:nrow(df))
  
  # Extract unique species names from the data frame
  sppnms <- unique(df[[sp_names]])
  
  # Validate species names against known species list
  vlid_spp <- search_mammalcol(sppnms, max_distance = 0.1)
  
  # Display summary of species validation
  if (length(vlid_spp$name_submitted) == 0) {
    cat("There aren't valid species in the dataset. Please review the species names before using this function.")
  } else {
    cat(length(sppnms), "species found in the matrix and ", nrow(vlid_spp), "is/are valid.\n")
  }
  
  Valispp <- df[df[[sp_names]] %in% unique(vlid_spp$name_submitted), ]
  
  # Initialize placeholder for final validated results
  finalVal <- NA
  
  # Loop through each valid species
  for (i in 1:nrow(vlid_spp)) {
    spp.i <- Valispp[Valispp[[sp_names]] %in% vlid_spp$name_submitted[i], ]
    
    vect.spp.i <- sf::st_as_sf(x = spp.i,                         
             coords = c("decimalLongitude", "decimalLatitude"),
             crs = "+proj=longlat +datum=WGS84")
    vect.spp.i.t <- suppressWarnings(sf::st_intersection(vect.spp.i, colmap))
    
    
    if (nrow(vect.spp.i.t) > 0) {
      vect.spp.i.t2 <- as.data.frame(vect.spp.i.t)
      coordinates <-as.data.frame(sf::st_coordinates(vect.spp.i.t))
      names(coordinates) <- c(lon, lat)
      vect.spp.i.t2 <- cbind(vect.spp.i.t2, coordinates)
      spp.i.f <- vect.spp.i.t2[,names(spp.i)]
      spp.i.f$validDpto<- vect.spp.i.t2[[adm_names]]
    } else {
      spp.i.f <- NULL
    } 
    
    
    # Handle cases where records are not fully evaluated
    if (nrow(vect.spp.i) > nrow(vect.spp.i.t) ) {
      
      vect.spp.i.novali <- vect.spp.i[!(vect.spp.i$IDVal %in% vect.spp.i.t$IDVal), ]
      vect.spp.i.novali2 <- suppressWarnings(sf::st_intersection(vect.spp.i.novali, oceanmap))
      
      if (nrow(vect.spp.i.novali2) == 0) {
        
        coordinates.i <-as.data.frame(sf::st_coordinates(vect.spp.i.novali))
        names(coordinates.i) <- c(lon, lat)
        vect.spp.i.novali <- as.data.frame(vect.spp.i.novali)
        vect.spp.i.novali <- cbind(vect.spp.i.novali, coordinates.i)
        vect.spp.i.novali.f <- vect.spp.i.novali[, names(spp.i)]
        vect.spp.i.novali.f$validDpto <- 'Other'
        spp.i.f <- rbind(spp.i.f, vect.spp.i.novali.f)
      } else {
        
        coordinates.i <-as.data.frame(sf::st_coordinates(vect.spp.i.novali2))
        names(coordinates.i) <- c(lon, lat)
        vect.spp.i.novali <- as.data.frame(vect.spp.i.novali2)
        vect.spp.i.novali <- cbind(vect.spp.i.novali, coordinates.i)
        vect.spp.i.novali.f <- vect.spp.i.novali[, names(spp.i)]
        vect.spp.i.novali.f$validDpto <- 'Ocean'
        spp.i.f <- rbind(spp.i.f, vect.spp.i.novali.f)
      }
    }
    
  
    # Check for duplicate records and assign appropriate validation
    if (any(duplicated(spp.i.f$IDVal))) {
      dupspp <- spp.i.f[duplicated(spp.i.f$IDVal), ]
      spp.i.f$dup.areas.val <- ifelse(spp.i.f$IDVal %in% dupspp$IDVal, 1, 0)
    } else {
      spp.i.f$dup.areas.val <- 0
    }
    
    # Append validated species subset to final results
    finalVal <- rbind(finalVal, spp.i.f)
  }
  
  finalVal <- finalVal[-1, ]
  
  # Additional validation based on species distribution
  distribution_list <- strsplit(taxon$distribution, "\\|")
  finaleva <- NA
  
  for (j in 1:nrow(vlid_spp)) {
    sp_id.j <- which(taxon$scientificName == vlid_spp$name_submitted[j])
    unos <- tolower(trimws(distribution_list[[sp_id.j]]))
    validdepto.i <- finalVal[finalVal[[sp_names]] %in% vlid_spp$name_submitted[j], ]
    
    evaluate_text <- function(text) {
      if (text %in% unos) {
        return(1)
      } else if (text == 'Other') {
        return(3)
      } else if (text == 'Ocean') {
        return(2)
      } else {
        return(0)
      }
    }
    
    # Apply the evaluation function to assign 'validation_result'
    validdepto.i$validation_result <- sapply(validdepto.i$validDpto, evaluate_text)
    validdepto.i <- subset(validdepto.i, select = -c(validDpto))
    finaleva <- rbind(finaleva, validdepto.i)
  }
  
  finaleva <- finaleva[-1, ]
  
  # Additional checks for duplicated records
  t.dupl <- NA
  tn.dupl <- NA
  
  if (any(finaleva$dup.areas.val %in% 1)) {
    t.dupl <- finaleva[finaleva$dup.areas.val == 1, ]
    tn.dupl <- finaleva[finaleva$dup.areas.val == 0, ]
    c.dup <- unique(t.dupl$IDVal)
    
    for (h in 1:length(c.dup)) {
      t.dupl.h <- t.dupl[t.dupl$IDVal %in% c.dup[h], ]
      if (all(t.dupl.h$validation_result == 1)) {
        tn.dupl <- rbind(tn.dupl, t.dupl.h[1, ])
      } else if (all(t.dupl.h$validation_result == 0)) {
        tn.dupl <- rbind(tn.dupl, t.dupl.h[1, ])
      } else {
        t.dupl.h$validation_result <- 3
        tn.dupl <- rbind(tn.dupl, t.dupl.h[1, ])
      }
    }
  } else {
    tn.dupl <- finaleva
  }
  
  # Combine final validated and non-validated species data
  # Separate species into validated and non-validated
  
  notValispp <- df[!df[[sp_names]] %in% unique(vlid_spp$name_submitted), ]
  
  if (nrow(notValispp) > 0) {
    notValispp$validation_result <- 4
    notValispp$dup.areas.val <- NA
     finalVal <- rbind(tn.dupl, notValispp)
  } else {
    finalVal <- tn.dupl
  }
  
  # Return final validated data frame
  finalValT <- finalVal[, c(oriNames, 'validation_result')]
  
  cat('Validation Finished.\n')
  cat('A total of', nrow(df), 'records were evaluated. The evaluation results are recorded in the "validation_result" column as follows:\n')
  cat('- 0 = Valid species but records not registered within the analyzed boundaries.\n')
  cat('- 1 = Valid species and coordinates according to official publications.\n')
  cat('- 2 = Valid species and coordinates are registered in the ocean.\n')
  cat('- 3 = Valid species and coordinates are within the limits of the ocean administrative boundaries. We recommend reviewing the location manually.\n')
  cat('- 4 = Not valid species that are not validated.\n')
  
  return(finalValT)
}
