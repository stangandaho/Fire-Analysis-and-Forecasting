# Fire Analysis and Forecasting

This repository contains R scripts and data for analyzing and forecasting 
burned areas in forest zones using ARIMA models. The project focuses on three 
forest zones: Monts Kouffe, Wari-Maro, and Ouémé Supérieur in Benin.

## Project Structure

- **datasets/**  
  Contains the dataset `fire_data_200625.csv` with historical 
  burned area data and relevant information for each forest zone. This dataset was collected from the MODIS 
  MOD14A1.061 product with Google Earth Engine (GEE). The project repository can be accessed 
  [here](https://code.earthengine.google.com/?accept_repo=users/gandahostanmah/fire_analysis_carlos)

- **scripts/**  
  - `setup.R`: Installs and loads required R packages.  
  - `01_process_gee_output.R`: Process raw data output from GEE.
  - `02_active_fire_detection_distribution.R`: Plot fire detection trend over years per forest zone.
  - `03_forecasting.R`: Performs ARIMA modeling and forecasting for each forest 
  - `utils.R`: Util functions

- **plots/**  
  Stores plots.

- **ARIMA.txt**  
  Contains ARIMA model summaries for each forest zone.

## Usage

1. Clone the repository and open the project in RStudio.
2. Run `setup.R` to install and load required packages.
3. Execute the scripts in order.
