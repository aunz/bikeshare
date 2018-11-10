library(data.table)
library(geosphere)

# read the data
df.rides = rbindlist(list(
  fread('./data/2016_Bike_Share_Toronto_Ridership_Q3.csv'),
  fread('./data/2016_Bike_Share_Toronto_Ridership_Q4.csv')
))

# reset name to shorter
setnames(
  df.rides,
  c('trip_id', 'trip_start_time', 'trip_stop_time', 'trip_duration_seconds', 'from_station_name', 'to_station_name'),
  c('id', 'start', 'stop', 'dur', 'from', 'to')
)

df.geo = fread('./data/station-geo.csv') # lat, lon of stations, results from calling google Geo API
df.ma = fread('./data/distancMatrix.csv') # distance and duration from station to station, results from calling google

# add year, month, week, weekday, day of month, hour
# take about 2 mins to run
df.rides[, c(c(
  'start_date', 'start_y', 'start_m', 'start_wk', 'start_w', 'start_d', 'start_h',
  'stop_date', 'stop_y','stop_m', 'stop_wk', 'stop_w', 'stop_d', 'stop_h',
  'overnight'
)) := (function (x, y) {
  x = as.POSIXct(x, tz = 'UTC', format = '%d/%m/%Y %H:%M') # extract to postixcl (epoch)
  x = as.POSIXlt(x, tz = 'EST') # change time zone
  y = as.POSIXct(y, tz = 'UTC', format = '%d/%m/%Y %H:%M')
  y = as.POSIXlt(y, tz = 'EST')
  x.date = as.Date(x)
  y.date = as.Date(y)
  list(
    x.date, x$year + 1900, x$mon + 1, floor(x$yday / 7), x$wday, x$mday, x$hour,
    y.date, y$year + 1900, y$mon + 1, floor(y$yday / 7), y$wday, y$mday, y$hour,
    y.date - x.date > 0
  )
})(start, stop)]


### merge all df.rides, df.geo, df.ma together

# firstly, merge df.ma and df.geo
df.all = merge(df.ma, df.geo[, .(station, from_lat = lat, from_lng = lng)], by.x = 'from', by.y = 'station', all = T)
df.all = merge(df.all, df.geo[, .(station, to_lat = lat, to_lng = lng)], by.x = 'to', by.y = 'station', all = T)

# calculate distance between from and to using geosphere package
# this takes 1 min to run
# df.all[, ge_dis := distm(c(from_lng, from_lat), c(to_lng, to_lat), fun = distVincentyEllipsoid), seq_len(nrow(df.all))]
df.all[, ge_dis := distGeo(c(from_lng, from_lat), c(to_lng, to_lat)), seq_len(nrow(df.all))]


# now merge with df.rides
setnames(df.all, c('distance', 'duration'), c('gg_dis', 'gg_dur'))
df.all = merge(df.rides, df.all, by = c('from', 'to'), all.x = T)

# derive velocity (km/hour) = distance (m) / duration (sec) * 3.6 (to conver m/sec to km/hour)
df.all[gg_dis != 0 & dur != 0, vel := gg_dis / dur * 3.6]
df.all[gg_dis != 0 & gg_dur != 0, gg_vel := gg_dis / gg_dur * 3.6]
df.all[, vel_diff := vel - gg_vel]
df.all[, dis_diff := ge_dis - gg_dis]

# remove the odd ones
df.all = df.all[!(start_y < 2016 | stop_y < 2016)]

# make route "circle"
df.all[, route := ifelse(from < to, paste(from, to), paste(to, from)) ]

saveRDS(df.all, file = './tmp/df.all.rds')