## Function to parse coordinate from GEE '[1.710107, 8.603617]' to simple feature 'POINT (1.710107 8.603617)'

gee_to_sf_coords <- function(gee_string, IDs = NULL) {
  if(is.null(IDs))IDs <- 1:length(gee_string)
  if (length(gee_string) != length(IDs)) {
    stop("Size of gee_string is not equal to the size of IDs")
  }
  if (is.character(IDs)) {
    stop("IDs must be numeric vector")
  }
  
  # Parse coordinate entries
  parsed_coords <- lapply(gee_string, function(x) {
    jsonlite::fromJSON(x)
  })
  
  # Flatten the list and handle both point and multipoint cases
  coords_list <- do.call(rbind, lapply(1:length(parsed_coords), function(x) {
    coord <- parsed_coords[[x]]
    if (length(coord) == 0){
      coord <- cbind(matrix(c(NA, NA), nrow = 1), IDs[x])
      return(coord)
    }
    # multipoint
    if (is.matrix(coord)) {
      coord <- cbind(coord, rep(IDs[x], nrow(coord)))
      return(coord)
    } 
    # single point
    if (is.numeric(coord)) {
      coord <- cbind(matrix(coord, nrow=1), IDs[x])
      return(coord)
    } 
  }))
  
  # Convert to a data.frame with geometry
  
  coord_df <- as.data.frame(coords_list)
  colnames(coord_df) <- c("lon", "lat", "IDs")
  coord_df <- coord_df %>% tidyr::drop_na(lon, lat)
  # Convert to sf object
  sf_points <- sf::st_as_sf(coord_df, coords = c("lon", "lat"), crs = 4326) %>% 
    dplyr::summarise(geometry = sf::st_union(geometry), .by = "IDs")
  
  return(sf_points)
}
