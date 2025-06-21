# Load setup
source('setup.R')

# Import data
data <- read.csv("datasets/fire_data_200625.csv")
data <- data %>%
  dplyr::mutate(date = ymd(date))

# List of forest
forets <- unique(data$forest)

# Apply ARIMA for each forest
unlink('ARIMA.txt')
for (foret in forets) {
  cat("\n==============================\n", file = 'ARIMA.txt', append = TRUE)
  cat("Forêt :", foret, "\n", file = 'ARIMA.txt', append = TRUE)
  cat("==============================\n", file = 'ARIMA.txt', append = TRUE)
  
  # Filter data for the forest
  df_foret <- data %>% filter(forest == foret) %>%
    arrange(date) %>% 
    mutate(year = year(date), month = month(date)) %>%
    group_by(year, month) %>%
    summarize(rateBurnedBuffer = mean(rateBurnedBuffer, na.rm = TRUE), 
              rateBurnedCore = mean(rateBurnedCore, na.rm = TRUE),
              .groups = 'drop')
  
  # Create monthly time series
  frequency <- 12
  ts_buffer <- ts(df_foret$rateBurnedBuffer,
                  start = c(min(df_foret$year), min(df_foret$month)),
                  frequency = 12)
  ts_core <- ts(df_foret$rateBurnedCore, 
                start = c(min(df_foret$year), min(df_foret$month)),
                frequency = 12)
  
  # ARIMA for buffer
  fit_buffer <- auto.arima(ts_buffer)
  cat("ARIMA buffer : \n", file = 'ARIMA.txt', append = TRUE)
  capture.output(summary(fit_buffer), file = "ARIMA.txt", append = TRUE)
  
  #print(fit_buffer)
  
  # ARIMA for core
  fit_core <- auto.arima(ts_core)
  cat("ARIMA core : \n", file = 'ARIMA.txt', append = TRUE)
  capture.output(summary(fit_core), file = "ARIMA.txt", append = TRUE)
  
  # Forecasting (10 years (frequency*10))
  forecast_buffer <- forecast::forecast(fit_buffer, h = frequency*10)
  forecast_core <- forecast::forecast(fit_core, h = frequency*10)
  
  # Plots
  plt_buffer <- autoplot(forecast_buffer)+
    ggplot2::labs(title = paste("Fire forcast (Buffer) -", foret),
                  y = 'Burned area (%)', x = "")+
    ggplot2::theme_minimal()+
    scale_x_continuous(breaks = seq(2000, 2035, 1))+
    ggplot2::theme(
      axis.title = element_text(size = 12),
      axis.title.x = element_text(margin = margin(t = .5, unit = "lines")),
      axis.title.y = element_text(margin = margin(r = .5, unit = "lines")),
      axis.text = element_text(size = 11),
      axis.text.x = element_text(colour = NA)
    )
  
  plt_core <- autoplot(forecast_core)+
    ggplot2::labs(title = paste("Fire forcast (Core) -", foret),
                  y = 'Burned area (%)')+
    ggplot2::theme_minimal()+
    scale_x_continuous(breaks = seq(2000, 2035, 2))+
    ggplot2::theme(
      axis.title = element_text(size = 12),
      axis.title.x = element_text(margin = margin(t = .5, unit = "lines")),
      axis.title.y = element_text(margin = margin(r = .5, unit = "lines")),
      axis.text = element_text(size = 11)
    )
  
  plot_merged <- cowplot::plot_grid(plotlist = list(plt_buffer, plt_core),
                                    ncol = 1, nrow = 2)
  
  ggplot2::ggsave(filename = paste0('plots/forecast_fire_', foret, ".jpeg"),
                  width = 25, height = 15, units = "cm")
}
