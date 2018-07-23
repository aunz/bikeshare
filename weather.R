# download data from ftp://ftp.tor.ec.gc.ca/Pub/Get_More_Data_Plus_de_donnees/
# check the instruction readme.txt and station ID
# station ID for toronto: 31688
#  stationID=31688; for year in `seq 2016 2016`;do for month in `seq 1 12`;do curl -o "toronto_weather_${month}.csv" "http://climate.weather.gc.ca/climate_data/bulk_data_e.html?format=csv&stationID=${stationID}&Year=${year}&Month=${month}&Day=14&timeframe=1&submit=Download+Data" ;done;done


library(data.table)

# read data

# weather, there are many columns, but only interested in Temp, dew point Temp and Rel Humidity
# df.w = fread('./data/toronto_weather_2016.csv')[, .(Year, Month, Day, Time, Temp, dpTemp = DewPointTemp, RH = RelHum)]
# with rain
# df.w2 = fread('./data/toronto_weather_with_rain_2016.csv')[, .(Year, Month, Day, Temp = `Mean Temp (°C)`, Rain = `Total Rain (mm)`, Snow = `Total Snow (cm)`, Ppt = `Total Precip (mm)`, Wind = `Spd of Max Gust (km/h)`, WindDir = `Dir of Max Gust (10s deg)`)]
# df.w2 = na.omit(df.w2)
# ridership
# df.all = readRDS('./tmp/df.all.rds')


# check range
df.w[, summary(Temp)] # -24.40    2.10   10.50   10.79   20.00   34.90      51 
df.w[, summary(dpTemp)] # -31.900  -3.300   3.700   3.768  11.900  24.100      50 
df.w[, summary(RH)] #   12.00   53.00   66.00   64.67   77.00   98.00      50 

df.w2[, summary(Temp)]

# agg weather data by day
tmpW = df.w[, .(
  Temp = mean(Temp, na.rm = T),
  dpTemp = mean(dpTemp, na.rm = T),
  RH = mean(RH, na.rm = T)
), .(Month, Day)]


# agg rider ship data by dat
tmpR = df.all[, .N, .(start_m, start_d)]
setnames(tmpR, c('start_m', 'start_d'), c('Month', 'Day'))


# merge them
tmp = merge(tmpR, tmpW, by = c('Month', 'Day'))

# simple correlation
cor(tmp[, .(N, Temp, dpTemp, RH)])
#                 N       Temp      dpTemp          RH
# N       1.0000000  0.6628283  0.60590704 -0.33939497
# Temp    0.6628283  1.0000000  0.95737683 -0.33308547
# dpTemp  0.6059070  0.9573768  1.00000000 -0.05067047
# RH     -0.3393950 -0.3330855 -0.05067047  1.00000000

local({
  # temp vs ride N
  p = ggplot(tmp, aes(x = N, y = Temp)) + geom_point() + geom_smooth()
  print(p)
  
  # RH vs ride N
  p = ggplot(tmp, aes(x = N, y = RH)) + geom_point() + geom_smooth()
  print(p)
  
})

# simple regression
local({
  m1 = lm(N ~ Temp, tmp)
  print(summary(m)) # R2 of 0.4361
  
  m2 = lm(N ~ RH, tmp)
  print(summary(m)) # R2 of 0.1101
  
  m3 = lm(N ~ Temp + RH, tmp)
  print(summary(m)) # R2 of 0.4488
  
  anova(m1, m3) # p 0.02669, so adding RH is justtified

})



# weather vs duration of rides
tmpR = df.all[, sum(dur, na.rm = T), .(start_m, start_d)]
setnames(tmpR, c('start_m', 'start_d'), c('Month', 'Day'))

tmp = merge(tmpR, tmpW, by = c('Month', 'Day'))
cor(tmp[, .(V1, Temp, dpTemp, RH)])
# duration higher cor
# V1       Temp      dpTemp          RH
# V1      1.0000000  0.7413395  0.66961278 -0.39867326
# Temp    0.7413395  1.0000000  0.95737683 -0.33308547
# dpTemp  0.6696128  0.9573768  1.00000000 -0.05067047
# RH     -0.3986733 -0.3330855 -0.05067047  1.00000000

local({
  # temp vs ride N
  p = ggplot(tmp, aes(x = V1, y = Temp)) + geom_point() + geom_smooth()
  print(p)
  
  # RH vs ride N
  p = ggplot(tmp, aes(x = V1, y = RH)) + geom_point() + geom_smooth()
  print(p)
})

local({
  m1 = lm(V1 ~ Temp, tmp)
  print(summary(m)) # R2 of 0.4488
  
  m2 = lm(V1 ~ RH, tmp)
  print(summary(m)) # R2 of 0.1541
  
  m3 = lm(V1 ~ Temp + RH, tmp)
  print(summary(m)) # R2 of 0.4488
  
  anova(m1, m3) # p 0.001438, so adding RH is justtified
  
})

