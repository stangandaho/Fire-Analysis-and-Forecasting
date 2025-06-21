source("setup.R")

firedata <- read.csv("datasets/fire_data_200625.csv")

# Process sf
source("scripts/utils.R")
fireCoordsCore <- gee_to_sf_coords(gee_string = firedata$fireCoordsCore,
                                     IDs = firedata$IDs)
fireCoordsBuffer <- gee_to_sf_coords(gee_string = firedata$fireCoordsBuffer,
                 IDs = firedata$IDs)

firedata_sf <- firedata %>% 
  dplyr::left_join(x = ., 
                    y = fireCoordsCore %>% dplyr::rename(coreFirePoints = geometry),
                    by = "IDs") %>% 
  dplyr::left_join(x = ., 
                   y = fireCoordsBuffer %>% dplyr::rename(bufferFirePoints = geometry),
                   by = "IDs")

# Write
write.csv(firedata_sf, 
          "datasets/fire_data_200625.csv", 
          fileEncoding = "ISO-8859-1",
          row.names = FALSE)


## Write sf separatly
core_point_sf <- firedata_sf %>% 
  dplyr::select(forest, year, coreFirePoints) %>% 
  dplyr::filter(!sf::st_is_empty(coreFirePoints)) %>% 
  sf::st_as_sf()
buffer_point_sf <- firedata_sf %>% 
  dplyr::select(forest, year, bufferFirePoints) %>% 
  dplyr::filter(!sf::st_is_empty(bufferFirePoints)) %>% 
  sf::st_as_sf()

sf::st_write(core_point_sf %>% sf::st_cast(to = "POINT"), 
             "datasets/core_point.shp")
sf::st_write(buffer_point_sf %>% sf::st_cast(to = "POINT"), 
             "datasets/buffer_point.shp")

core_point_sf %>% dplyr::count(forest) %>% sf::st_drop_geometry() %>% 
  mutate(zone = "Core") %>% 
  bind_rows(buffer_point_sf %>% dplyr::count(forest) %>% sf::st_drop_geometry()
            %>% mutate(zone = "Buffer")) 

print(
  core_point_sf %>% dplyr::count(forest, year) %>% sf::st_drop_geometry() %>% 
    mutate(zone = "Core") %>% 
    bind_rows(buffer_point_sf %>% dplyr::count(forest, year) %>% sf::st_drop_geometry()
              %>% mutate(zone = "Buffer")),
  n = 200
)

## Daily period

firedata %>% dplyr::filter(activeFireCoreCount != 0) %>% 
  dplyr::count(forest, dayNaightCore) %>% 
  dplyr::mutate(zone = "Core") %>% 
  dplyr::bind_rows(
    firedata %>% dplyr::filter(activeFireBufferCount != 0) %>% 
      dplyr::count(forest, dayNaightCore) %>% 
      dplyr::mutate(zone = "Buffer")
  ) %>% 
  group_by(forest, zone) %>% 
  reframe(prop = n*100/sum(n), dayNaightCore = dayNaightCore) %>% 
  ggplot(mapping = aes(x = forest, y = prop, color = zone, fill = dayNaightCore))+
  geom_col(position = position_dodge2(), linewidth = 1.5)+
  theme_minimal()+
  geom_text(mapping = aes(label = paste0(round(prop, 2), "%"),
                          y = prop + 3),
            position = position_dodge2(width = 1), show.legend = FALSE,
            size = 6)+
  scale_color_manual(values = c("#044040", "#8C1F28"))+
  scale_fill_manual(values = c("#D9BB96", "#F2780C"))+
  labs(color = "", fill = "", x = "Forest")+
  guides(color = guide_legend(override.aes = list(fill = NA)))+
  theme(
    axis.text.y = element_blank(),
    axis.title = element_blank(),
    axis.text.x = element_text(size = 15),
    legend.text = element_text(size = 13)
  )
ggsave("plots/day_night_fire_detection.jpeg", width = 35, height = 16, units = "cm")
