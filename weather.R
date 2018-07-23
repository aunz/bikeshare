# download data from ftp://ftp.tor.ec.gc.ca/Pub/Get_More_Data_Plus_de_donnees/
# check the instruction readme.txt and station ID
# station ID for toronto: 31688
#  stationID=31688; for year in `seq 2016 2016`;do for month in `seq 1 12`;do curl -o "toronto_weather_${month}.csv" "http://climate.weather.gc.ca/climate_data/bulk_data_e.html?format=csv&stationID=${stationID}&Year=${year}&Month=${month}&Day=14&timeframe=1&submit=Download+Data" ;done;done


library(data.table)
library(corrplot)
library(ggplot2)

# read data

# weather, there are many columns, but only interested in Temp, dew point Temp and Rel Humidity
df.w = fread('./data/toronto_weather_2016.csv')[, .(Year, Month, Day, Time, Temp, dpTemp = DewPointTemp, RH = RelHum)]
# with rain, snow, ppt, wind
df.w2 = fread('./data/toronto_weather_with_rain_2016.csv')[, .(Month, Day, Temp = `Mean Temp (°C)`, Rain = `Total Rain (mm)`, Snow = `Total Snow (cm)`, Ppt = `Total Precip (mm)`, Wind = `Spd of Max Gust (km/h)`, WindDir = `Dir of Max Gust (10s deg)`)]
df.w2 = na.omit(df.w2)
# ridership
df.all = readRDS('./tmp/df.all.rds')


# check range
df.w[, summary(Temp)] # -24.40    2.10   10.50   10.79   20.00   34.90      51 
df.w[, summary(dpTemp)] # -31.900  -3.300   3.700   3.768  11.900  24.100      50 
df.w[, summary(RH)] #   12.00   53.00   66.00   64.67   77.00   98.00      50 

df.w2[, summary(Temp)]
df.w2[, summary(Rain)] # not much rain in Toronto huh, df.w2[, sum(Rain)] -> 478.3
df.w2[, summary(Snow)]
df.w2[, sum(Snow)]
df.w2[, summary(Ppt)]
df.w2[, sum(Ppt)]
df.w2[, summary(Wind)]
df.w2[, summary(WindDir)]


# agg weather data by day
tmpW = df.w[, .(
  Temp = mean(Temp, na.rm = T),
  dpTemp = mean(dpTemp, na.rm = T),
  RH = mean(RH, na.rm = T)
), .(Month, Day)]


# agg rider ship data by dat
tmpR = df.all[, .(V1 = .N), .(start_m, start_d)]
setnames(tmpR, c('start_m', 'start_d'), c('Month', 'Day'))


# merge them
tmp = Reduce(function (x, y) merge(x, y, by = c('Month', 'Day')), list(tmpW, df.w2, tmpR))
tmp[, Date := as.Date(paste('2016', tmp$Month, tmp$Day, sep = '-'))]

# simple correlation
cor(tmp[ , !c('Month', 'Day', 'Date')])
corrplot(cor(tmp[ , !c('Month', 'Day', 'Date')]), type = 'upper')
# V1 is correlated to Temp, dpTemp, somewhat to RH

local({
  print(ggplot(tmp, aes(x = V1, y = Temp.x)) + geom_point() + geom_smooth())
  print(ggplot(tmp, aes(x = V1, y = RH)) + geom_point() + geom_smooth())
  print(ggplot(tmp, aes(x = V1, y = Rain)) + geom_point() + geom_smooth())
  print(ggplot(tmp, aes(x = V1, y = Snow)) + geom_point() + geom_smooth())
  print(ggplot(tmp, aes(x = V1, y = Ppt)) + geom_point() + geom_smooth())
  print(ggplot(tmp, aes(x = V1, y = Wind)) + geom_point() + geom_smooth())
  print(ggplot(tmp, aes(x = V1, y = WindDir)) + geom_point() + geom_smooth())
  
})

# simple regression
local({
  summary(lm(V1 ~ Temp.x, tmp)) # R2 of 0.4359
  summary(lm(V1 ~ RH, tmp)) # R2 of 0.1387
  summary(lm(V1 ~ Rain, tmp)) # R2 of 0.00446
  summary(lm(V1 ~ Snow, tmp)) # R2 of 0.04907
  summary(lm(V1 ~ Ppt, tmp)) # R2 of 0.02187
  summary(lm(V1 ~ Wind, tmp)) # R2 of 0.04791
  summary(lm(V1 ~ WindDir, tmp)) # R2 of 0.04726

  summary(lm(V1 ~ Temp.x + RH + Rain + Snow + Ppt + Wind + WindDir, tmp)) # R2 of 0.4359
  
  # +: Temp, PPt
  # -: Rain, Snow
  # No effect: wind, windDir, RH
  
  summary(lm(V1 ~ Temp.x + RH + Rain + Snow + Ppt, tmp)) # R2 of 0.4899
  summary(lm(V1 ~ Temp.x + Rain + Snow + Ppt, tmp)) # R2 of 0.4899
})



# weather vs duration of rides
tmpR = df.all[, sum(dur, na.rm = T), .(start_m, start_d)]
setnames(tmpR, c('start_m', 'start_d'), c('Month', 'Day'))

tmp = Reduce(function (x, y) merge(x, y, by = c('Month', 'Day')), list(tmpW, df.w2, tmpR))
tmp[, Date := as.Date(paste('2016', tmp$Month, tmp$Day, sep = '-'))]


# simple correlation
cor(tmp[ , !c('Month', 'Day', 'Date')])
corrplot(cor(tmp[ , !c('Month', 'Day', 'Date')]), type = 'upper')


local({
  print(ggplot(tmp, aes(x = V1, y = Temp.x)) + geom_point() + geom_smooth())
  print(ggplot(tmp, aes(x = V1, y = RH)) + geom_point() + geom_smooth())
  print(ggplot(tmp, aes(x = V1, y = Rain)) + geom_point() + geom_smooth())
  print(ggplot(tmp, aes(x = V1, y = Snow)) + geom_point() + geom_smooth())
  print(ggplot(tmp, aes(x = V1, y = Ppt)) + geom_point() + geom_smooth())
  print(ggplot(tmp, aes(x = V1, y = Wind)) + geom_point() + geom_smooth())
  print(ggplot(tmp, aes(x = V1, y = WindDir)) + geom_point() + geom_smooth())
  
})

# simple regression
local({
  summary(lm(V1 ~ Temp.x, tmp)) # R2 of 0.5633
  summary(lm(V1 ~ RH, tmp)) # R2 of 0.1866
  summary(lm(V1 ~ Rain, tmp)) # R2 of 0.003408
  summary(lm(V1 ~ Snow, tmp)) # R2 of 0.04232
  summary(lm(V1 ~ Ppt, tmp)) # R2 of 0.01977
  summary(lm(V1 ~ Wind, tmp)) # R2 of 0.05692
  summary(lm(V1 ~ WindDir, tmp)) # R2 of 0.05033
  
  summary(lm(V1 ~ Temp.x + RH + Rain + Snow + Ppt + Wind + WindDir, tmp)) # R2 of 0.6268
  
  # +: Temp, PPt, RH, Rain
  # No effect: snow, ppt, wind, windDir
  
  summary(lm(V1 ~ Temp.x + RH + Rain, tmp)) # R2 of 0.6085
})



# weather vs duration of rides
tmpR = df.all[, sum(dur / 3600, na.rm = T), .(start_m, start_d, user_type)]
setnames(tmpR, c('start_m', 'start_d'), c('Month', 'Day'))

tmp = Reduce(function (x, y) merge(x, y, by = c('Month', 'Day')), list(tmpW, df.w2, tmpR))
tmp[, Date := as.Date(paste('2016', tmp$Month, tmp$Day, sep = '-'))]

cor(tmp[user_type == 'Member', !c('Month', 'Day', 'Date', 'user_type')])
corrplot(cor(tmp[user_type == 'Member', !c('Month', 'Day', 'Date', 'user_type')]), type = 'upper')

cor(tmp[user_type == 'Casual', !c('Month', 'Day', 'Date', 'user_type')])
corrplot(cor(tmp[user_type == 'Casual', !c('Month', 'Day', 'Date', 'user_type')]), type = 'upper')


local({
  print(ggplot(tmp, aes(x = V1, y = Temp.x, shape = user_type)) + geom_point() + geom_smooth())
  print(ggplot(tmp, aes(x = V1, y = RH, shape = user_type)) + geom_point() + geom_smooth())
  print(ggplot(tmp, aes(x = V1, y = Rain, shape = user_type)) + geom_point() + geom_smooth())
  print(ggplot(tmp, aes(x = V1, y = Snow, shape = user_type)) + geom_point() + geom_smooth())
  print(ggplot(tmp, aes(x = V1, y = Ppt, shape = user_type)) + geom_point() + geom_smooth())
  print(ggplot(tmp, aes(x = V1, y = Wind, shape = user_type)) + geom_point() + geom_smooth())
  print(ggplot(tmp, aes(x = V1, y = WindDir, shape = user_type)) + geom_point() + geom_smooth())
  
})

local({
  summary(lm(V1 ~ user_type * Temp.x, tmp)) # R2 of 0.42
  summary(lm(V1 ~ user_type * RH, tmp)) # R2 of 0.1409
  summary(lm(V1 ~ user_type * Rain, tmp)) # R2 of 0.005991
  summary(lm(V1 ~ user_type * Snow, tmp)) # R2 of 0.03139
  summary(lm(V1 ~ user_type * Ppt, tmp)) # R2 of 0.01656
  summary(lm(V1 ~ user_type * Wind, tmp)) # R2 of 0.0428
  summary(lm(V1 ~ user_type * WindDir, tmp)) # R2 of 0.03765
  
  summary(lm(V1 ~ user_type * (Temp.x + RH + Rain + Snow + Ppt + Wind + WindDir), tmp)) # R2 of 0.4578
  
  # +: Temp, RH, user_type:Temp.x

  
  summary(lm(V1 ~ user_type * (Temp.x + RH), tmp)) # R2 of 0.442
})



# plotting V1 with other var in the same graph
local({
  
  # helper function to plot duration of ride vs variable v2
  helper = function (V2, v2name, df = tmp) {
    tmpData = df[variable %in% c('V1', V2)]
    
    v2value = tmpData[variable == V2, value]
    y2label = scales::pretty_breaks(8)(tmpData[variable == V2, value])
    value_rs = scales::rescale(c(y2label, v2value), c(0, tmpData[variable == 'V1', max(value)]))
    
    y2breaks = value_rs[1:length(y2label)]
    v2value = value_rs[(length(y2label) + 1):length(value_rs)]
    tmpData[variable == V2, value_rs := v2value]
    tmpData[variable == 'V1', value_rs := value]
    
    p = ggplot(tmpData, aes(x = Date)) +
      geom_line(aes(y = value_rs, color = variable)) +
      scale_y_continuous(
        expand = c(0.1, 0.1),
        breaks = scales::pretty_breaks(n = 8),
        name = 'Duration of ride per day (Hour)',
        sec.axis = sec_axis(~ ., name = v2name, breaks = y2breaks, labels = y2label)
      ) +
      scale_x_date(date_labels = '%b', date_breaks = '1 month') +
      scale_color_manual(
        labels = c('Duration of ride', v2name),
        values = c('#0074D9', '#FF4136'),
        name = ''
      ) +
      xlab(label = '') +
      theme(legend.position = c(0.125, 0.95), legend.background = element_blank())
    print(p)
  }
  
  
  
  tmp = melt(
    tmp,
    id.vars = c('Date', 'user_type'),
    measure.vars = c('Temp.x', 'RH', 'Rain', 'Snow', 'Ppt', 'Wind', 'WindDir', 'V1')
  )
  
  
  tmp2 = tmp[, .(value = mean(value)), .(Date, variable)]
  tmp2[variable == 'V1', value := value * 2 ]
  helper('Temp.x', 'Temperature (°C)', tmp2)
  helper('RH', 'Relative humidity', tmp2)
  helper('Rain', 'Rain (mm)', tmp2)
  helper('Snow', 'Snow (mm)', tmp2)
  helper('Ppt', 'Total precipitation (mm)', tmp2)
  helper('Wind', 'Wind (km/h)', tmp2)
  helper('WindDir', 'Direction of wind (10s deg)', tmp2)
  
  
  helper('Temp.x', 'Temperature (°C)', tmp[user_type == 'Member'])
  helper('RH', 'Relative humidity', tmp[user_type == 'Member'])
  
  helper('Temp.x', 'Temperature (°C)', tmp[user_type == 'Casual'])
  helper('RH', 'Relative humidity', tmp[user_type == 'Casual'])
})

