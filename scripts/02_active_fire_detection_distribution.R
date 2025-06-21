source("setup.R")

fire_df <- read.csv("datasets/fire_data_200625.csv")

# Count of fire per zone and per year
fire_df %>% 
  dplyr::select(year, forest, activeFireCoreCount, activeFireBufferCount) %>%
  tidyr::pivot_longer(cols = c(activeFireCoreCount, activeFireBufferCount),
                      names_to = "zone", values_to = "occurrence") %>% 
  dplyr::mutate(zone = case_when(zone == "activeFireCoreCount" ~ "Core",
                                 TRUE ~ "Buffer")) %>% 
  dplyr::filter(occurrence != 0) %>% 
  dplyr::group_by(forest, year, zone) %>% 
  dplyr::summarise(count = length(occurrence)) %>% 
  dplyr::ungroup() %>% 
  ggplot(mapping = aes(x = year, y = count, group = 1))+
  geom_line()+
  geom_point(size = 2, color = "gray10")+
  geom_point(size = .8, color = "gray60")+
  facet_grid(rows = c("zone", "forest"))+
  scale_y_continuous(breaks = seq(1, 50, 5))+
  scale_x_continuous(breaks = seq(2000, 2025, 1))+
  theme_minimal()+
  labs(x = "Year", y = "Active fire detected")+
  theme(
    # Axis text
    axis.text = element_text(size = 12),
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5, 
                               margin = margin(t = 1, unit = "lines")),
    axis.text.y = element_text(margin = margin(r = 1, unit = "lines")),
    axis.title = element_text(size = 14),
    panel.grid.minor.x = element_blank(),
    # Panel
    panel.background = element_rect(colour = "gray90"),
    # Strip
    strip.background = element_rect(fill = "gray10", color = NA),
    strip.text = element_text(size = 16, face = "bold", colour = "white")
  )

ggsave("plots/active_fire_detected_trend.jpeg", width = 35, height = 20, 
       units = "cm")

# Spatial distribution map was done with QGIS