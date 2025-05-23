# Necessary package
packages <- c('forecast', 'dplyr', 'lubridate', 'ggplot2')
# Install if not insalled
for (pkg in packages) {
  if (!pkg %in% rownames(installed.packages())) {
    install.packages(pkg)
  }
}

suppressMessages({
  library(forecast)
  library(dplyr)
  library(lubridate)
  library(ggplot2)
})

message('Setup loaded')