# libraries
library(data.table)
library(leaflet)


# read the data
setwd(getSrcDirectory(function () {}))
# df.all = readRDS('./tmp/df.all.rds')
# df.geo = fread('./data/station-geo.csv')



color = colorNumeric('RdBu', df.all[, .N, from][, N], reverse = T, alpha = F)

m = df.all[!is.na(from_lng) & !is.na(from_lat), .(
  .N,
  lng = unique(from_lng),
  lat = unique(from_lat)
), from] %>%
  leaflet() %>%
  addTiles() %>%
  addCircleMarkers(
    lng = ~lng,
    lat = ~lat,
    radius = 10,
    color = ~color(N),
    stroke = F,
    fillOpacity = 0.55,
    label = ~as.character(paste0(from, ' (', N, ' trips)'))
  )
  # addCircles(lng = ~lng, lat = ~lat)

print(m)

# two furthest station, no trip, 
df.all[from == 'Bloor St W / Dundas St W' & to == 'Danforth Ave / Barrington Ave']
df.all[to == 'Bloor St W / Dundas St W' & from == 'Danforth Ave / Barrington Ave']
# but each
df.all[from %in% c('Bloor St W / Dundas St W', 'Danforth Ave / Barrington Ave')] # 1037 trips
df.all[to %in% c('Bloor St W / Dundas St W', 'Danforth Ave / Barrington Ave')] # 1121 trips
df.all[from == 'Bloor St W / Dundas St W'] # 818 trips
df.all[to == 'Bloor St W / Dundas St W'] # 902 trips
df.all[from == 'Danforth Ave / Barrington Ave'] # 218 trips
df.all[to == 'Danforth Ave / Barrington Ave'] # 219 trips
