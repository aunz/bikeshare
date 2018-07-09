# libraries
library(data.table)
library(leaflet)
library(DT)
library(crosstalk)


# read the data
setwd(getSrcDirectory(function () {}))
df.all = readRDS('./tmp/df.all.rds')


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
    fillOpacity = 0.75,
    label = ~as.character(paste0(from, ' (', N, ' trips)'))
  ) %>%
  addLegend(
    'bottomright',
    pal = color,
    values = ~N,
    title = 'Number of trip',
    opacity = 1
  )

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




## with crosstalk
sd = SharedData$new({
  tmp = rbindlist(list(
    df.all[, .(station = from, lng = from_lng, lat = from_lat)],
    df.all[, .(station = to, lng = to_lng, lat = to_lat)]
  ))
  tmp = tmp[station != '' & !is.na(lng), .(
    .N,
    lng = unique(lng),
    lat = unique(lat)
  ), station]
  tmp
})

filter_slider('tripNumber', 'Number of trip', sd, column = ~N, step = 1000, width = '100%')

bscols(
  bscols(
    leaflet(sd) %>%
      addTiles() %>%
      addCircleMarkers(
        lng = ~lng,
        lat = ~lat,
        radius = 10,
        color = ~color(N),
        stroke = F,
        fillOpacity = 0.8,
        label = ~as.character(paste0(station, ' (', N, ' trips)'))
      ) %>%
      addLegend(
        'bottomright',
        pal = color,
        values = ~N,
        title = 'Number of trip',
        opacity = 1
      ),
    datatable(
      sd,
      style = 'bootstrap',
      class = 'compact',
      width = '100%',
      options = list(deferRender = T, scrollY = 300, scroller = T))
  )
)
