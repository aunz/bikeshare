###
# Prediction
# compare models: lm, randomForest


###

library(data.table)
library(caret)

# weather, there are many columns, but only interested in Temp, dew point Temp and Rel Humidity
df.w = fread('./data/toronto_weather_2016.csv')[, .(Year, Month, Day, Time, Temp, dpTemp = DewPointTemp, RH = RelHum)]
# with rain, snow, ppt, wind
df.w2 = fread('./data/toronto_weather_with_rain_2016.csv')[, .(Month, Day, Temp = `Mean Temp (°C)`, Rain = `Total Rain (mm)`, Snow = `Total Snow (cm)`, Ppt = `Total Precip (mm)`, Wind = `Spd of Max Gust (km/h)`, WindDir = `Dir of Max Gust (10s deg)`)]
df.w2 = na.omit(df.w2)
# ridership
df.all = readRDS('./tmp/df.all.rds')


data = local({
  tmpW = df.w[, .(
    Temp = mean(Temp, na.rm = T),
    dpTemp = mean(dpTemp, na.rm = T),
    RH = mean(RH, na.rm = T)
  ), .(Month, Day)]
  
  tmpR = df.all[, sum(dur / 3600, na.rm = T), .(start_m, start_d, user_type)]
  setnames(tmpR, c('start_m', 'start_d'), c('Month', 'Day'))
  
  tmp = Reduce(function (x, y) merge(x, y, by = c('Month', 'Day')), list(tmpW, df.w2, tmpR))
  tmp[, Date := as.Date(paste('2016', tmp$Month, tmp$Day, sep = '-'))]
  tmp[, user_type := factor(user_type, levels = c('Member', 'Casual'))]
  tmp[, Week := (function () {
    w = as.character(as.POSIXlt(as.Date(Date))$wday)
    c('0' = 'Su', '1' = 'Mo', '2' = 'Tu', '3' = 'We', '4' = 'Th', '5' = 'Fr', '6' = 'Sa')[w]
  })(), seq_len(nrow(tmp))]
  
  tmp
})
data = data[, .(V1, Temp.x, dpTemp, RH, Rain, Snow, Ppt, Wind, WindDir, user_type, Week)]


# Split the data into training and test set
set.seed(123)

train.control = trainControl(method = 'repeatedcv', number = 10, repeats = 3)

# lm model
m1 = train(V1 ~ ., data = data, method = 'lm', trControl = train.control)
print(m1)

# randomFOrest
m2 = train(V1 ~ ., data = data, method = 'rf', trControl = train.control, allowParallel = T, importance = T, verbose = T)
print(m2)
varImp(m2)


m3 = train(V1 ~ ., data = data, method = 'gbm', trControl = train.control)
