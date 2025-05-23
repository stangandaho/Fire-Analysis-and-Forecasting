# Fire Analysis and Forecasting

This repository contains R scripts and data for analyzing and forecasting 
burned areas in forest zones using ARIMA models. The project focuses on three 
forest zones: Monts Kouffe, Wari-Maro, and Ouémé Supérieur in Benin.

## Project Structure

- **datasets/**  
  Contains the dataset `Burned_Area_By_Zone_Core_Buffer.csv` with historical 
  burned area data for each forest zone. This dataset was collected the MODIS 
  MCD64A1 product with Google Earth Engine.

- **scripts/**  
  - `setup.R`: Installs and loads required R packages.  
  - `01_get_modis_collection.js`: Get burned area data from the MODIS MCD64A1 
  product with Google Earth Engine. This code must be executed in GEE. 
  - `02_forecasting.R`: Performs ARIMA modeling and forecasting for each forest 
  zone and generates plots.

- **plots/**  
  Stores forecast plots for each forest zone.

- **ARIMA.txt**  
  Contains ARIMA model summaries for each forest zone.

## Usage

1. Clone the repository and open the project in RStudio.
2. Run `scripts/setup.R` to install and load required packages.
3. Execute `scripts/02_forecasting.R` to:
   - Load the dataset.
   - Apply ARIMA models to each forest zone.
   - Generate forecasts and save plots in the `plots/` directory.
   - Save ARIMA model summaries in `ARIMA.txt`.
