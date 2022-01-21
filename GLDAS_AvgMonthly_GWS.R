library(readr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(lubridate)
library(ncdf4)
library(ncdf4.helpers)

#Set working directory 
setwd("/Volumes/hydro3-raid/GLDAS/")

#Read in CSV of GLDAS data and set variables
GLDAS_GWS <- read.csv('GLDAS_GWS.20030101-20210831.33E_25S_33E_25S.csv')
Daily_GWS <- GLDAS_GWS$AreaAvg..GWS..mm.
Dt <- GLDAS_GWS$Date
#Use lubridate to change character into date class
Dt <- mdy(Dt)

#Create separate year and month variables and create one data frame with both 
Year <- year(Dt)
Month <- month(Dt)
YearMonth <- data.frame(Year,Month) 

#Create a data frame that displays dates as only year and month 
YM <- with(YearMonth, sprintf("%d-%02d", Year, Month))
YM <- data.frame(YM)

#Combine YM and Daily_GWS into one data frame
GWS <- data.frame(YM, Daily_GWS)

#Average daily data by month using aggregate and write to new data frame
AvgMonthly_GWS <- aggregate( Daily_GWS ~ YM, GWS, mean ) 
AvgMonthly_GWS <- data.frame(AvgMonthly_GWS)

#Rename column 
names(AvgMonthly_GWS) [2] <- 'Monthly_GWS(mm)'

####### COMBINE GRACE AND GLDAS DATA FOR PLOTTING #######################

#Add another column called variable to each dataframe 
AvgMonthly_GWS <- mutate(AvgMonthly_GWS, Variable = "GLDAS")
AvgMonthly_WET <- mutate(AvgMonthly_WET, Variable = "GRACE")

#Convert water equivalent thickness values from cm to mm 
#Not exactly sure what we did here to be honest
GRACEmon <- AvgMonthly_WET %>%
  mutate(Value=10*`Monthly_WET(cm)`) %>%
  select(-`Monthly_WET(cm)`)

GLDASmon <- AvgMonthly_GWS %>%
  mutate(Value=`Monthly_GWS(mm)`) %>%
  select(-`Monthly_GWS(mm)`)

#Change YM into YearMon so that it matches the GLDAS column heading
GRACEmon <- rename(GRACEmon, YM=YearMon)

#Row bind GRACE and GLDAS in a new dataframe
long <- rbind(GRACEmon,GLDASmon)

#Use pivot wider to align rows with each other and fill in missing data 
long <- long %>%
  pivot_wider(names_from = Variable, 
              values_from = "Value")



