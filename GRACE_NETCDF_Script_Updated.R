#Created by: Gabi Zuccolotto
#Last updated: 01/20/22

#Script for extracting time-series water equivalent thickness values for specific latitude, longitude
#from JPL GRACE and GRACE-FO Mascon Ocean, Ice, and Hydrology Equivalent Water Height JPL Release 06 Version 02
#Original data can be downloaded @ https://podaac.jpl.nasa.gov/dataset/TELLUS_GRAC-GRFO_MASCON_CRI_GRID_RL06_V2

library(tidyr)
library(ggplot2)
library(ncdf4)
library(dplyr)
library(ncdf4.helpers)
library(lubridate)
library(zoo)

#Set working directory
setwd("/Volumes/hydro3-raid/GRACE /NETCDF")

#Read in NETCDF file JPL GRACE and GRACE-FO Mascon Ocean, Ice, and Hydrology Equivalent Water Height JPL Release 06 Version 02 
GRACE <-nc_open('GRCTellus.JPL.200204_202110.GLO.RL06M.MSCNv02CRI.nc')

#Set variables
lon <-ncvar_get(GRACE, "lon")
lat <-ncvar_get(GRACE, "lat")
Days_Since_2002_01_01<- ncvar_get(GRACE,"time")
WET <- ncvar_get(GRACE, "lwe_thickness")

##Generate dates from days since 2002_01_01
D <- as.Date(Days_Since_2002_01_01, origin = '2002-01-01')
Date <- as_date(parse_date_time(D,"ymd")) 

#Make separate variable for years and months and create one data frame with both 
Y <- year(Date)
M <- month(Date)
YMonth <- data.frame(Y,M) 

#Combine separate year and month columns into one and create data frame
YearMon <- with(YMonth, sprintf("%d-%02d", Y, M))
YearMon <- data.frame(YearMon)

#Create new data frame with only WET values from lon and lat location, in this example: lon 33.8 (cell index 68), lat -24.8 (cell index 131)
#Can use Panoply Data Viewer to view water equivalent thickness layer and determine cell indices for longitude and latitude
Water_Equiv_Thickness<- WET[68, 131, ]
#The third dimension is time and is left intentionally blank so that values across entire time-series are collected

#Create data frame with columns for YearMon and WET values
data.frame(YearMon,Water_Equiv_Thickness) -> WatEquiv

#Average data by month using aggregate and write to new data frame
AvgMonthly_WET <- aggregate( Water_Equiv_Thickness ~ YearMon, WatEquiv, mean ) 
AvgMonthly_WET <- data.frame(AvgMonthly_WET)

#Write CSV with all WET values in the dataset
write.csv(WET_XaiXai_TS,file="XaiXaiGRACEdata.csv",row.names = TRUE)