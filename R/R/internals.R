# Function to clean species list names
#' @keywords internal
standardize_names <- function(splist) {
  fixed1 <- simple_cap(trimws(splist)) # all up
  fixed2 <- gsub("cf\\.", "", fixed1)
  fixed3 <- gsub("aff\\.", "", fixed2)
  fixed4 <- trimws(fixed3) # remove trailing and leading space
  fixed5 <-
    gsub("_", " ", fixed4) # change names separated by _ to space
  
  # Hybrids
  fixed6 <- gsub("(^x )|( x$)|( x )", " ", fixed5)
  hybrids <- fixed5 == fixed6
  if (!all(hybrids)) {
    sp_hybrids <- splist[!hybrids]
    warning(
      paste(
        "The 'x' sign indicating hybrids have been removed in the",
        "following names before search:",
        paste(paste0("'", sp_hybrids, "'"), collapse = ", ")
      ),
      immediate. = TRUE,
      call. = FALSE
    )
  }
  # Merge multiple spaces
  fixed7 <-
    gsub("(?<=[\\s])\\s*|^\\s+|\\s+$", "", fixed6, perl = TRUE)
  return(fixed7)
}

#' @keywords internal
simple_cap <- function(x) {
  # Split each string into words, remove unnecessary white spaces, and convert to lowercase
  words <-
    sapply(strsplit(x, "\\s+"), function(words)
      paste(tolower(words), collapse = " "))
  
  # Capitalize the first letter of each word
  capitalized <- sapply(strsplit(words, ""), function(word) {
    if (length(word) > 0) {
      word[1] <- toupper(word[1])
    }
    paste(word, collapse = "")
  })
  
  return(capitalized)
}

#' @keywords internal
#'
find_duplicates <- function(vector) {
  # Count the frequency of each word
  word_counts <- table(vector)
  # Find words with a frequency greater than 1
  duplicated_words <- names(word_counts[word_counts > 1])
  return(duplicated_words)
}

#' Function to standtardized Departamentos names
#' @keywords internal
fix_departamentos <- function(x, column = 'locality') {
  stopifnot(
    inherits(x, 'data.frame'), # secure tidy manipulation
    column  %in% colnames(x), # name of the column exists and
    length(column) == 1, # is only one column and
    is_character(column) # is type character
  )
  # x <- distribution
  # column = 'locality'
  
  modx <- x %>% select(id, !!sym(column)) %>%
    nest_by(id) %>%
    mutate(data = map(data, ~ .x %>%
                        str_split('\\|', simplify = T) %>%
                        str_squish)) %>%
    unnest(data) %>% ungroup() %>%
    mutate(
      data = case_when(
        data %in% c("Guanía", "Guainia", "Guinía",
                    "Guaínia", "Guania") ~ "Guainía",
        data %in% c("Antoquia", "Anitoquia") ~ "Antioquia",
        data == "San Andrés" ~ "San Andrés y Providencia",
        data == "Guaviaré" ~ "Guaviare",
        data == "Caqueta" ~ "Caquetá",
        data == "César" ~ " Cesar",
        data == "Quindio" ~ "Quindío",
        data == "Cordoba" ~ "Córdoba",
        data == "Víchada" ~ "Vichada",
        data %in% c("", "Antioquia (?)", "Nariño (?)") ~ NA,
        .default = as.character(data)
      )
    ) %>%
    nest_by(id) %>%
    mutate(localityCorrected = map_chr(data, ~ paste(.x, collapse = ' | ')) %>% 
             unname()) %>% 
    unnest(localityCorrected) %>% ungroup()
  
  out <- left_join(x, modx[,c('id', 'localityCorrected')], by = "id")
  stopifnot(all(out$id  %in% x$id))
  
  return(out)
}
