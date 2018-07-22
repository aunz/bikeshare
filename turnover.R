# For a particular station, what is the turnover of bikes
# to find out when a station is "full" or "empty", we don't want it to be empty!


library(data.table)
library(ggplot2)
library(plotly)

# read the data
# df.all = readRDS('./tmp/df.all.rds')

# data.frame to hold events (1: bike returned to a station, -1: bike taken out from a station) 
# expect that a station would have the same number of 1 and -1 for a given period of time, and sum to 0
# if sum to > 0, there are more bike returned then left, and true for the opposite
df.e = {
  tmp = df.all[, .(
    time = as.POSIXct(start, format = '%d/%m/%Y %H:%M', tz = ''),
    dur,
    from,
    to
  )]

  tmp = rbindlist(list(
    tmp[, .(time, station = from, event = -1)], # -1 depart
    tmp[, .(time = time + dur, station = to, event = 1)] # 1 arrive
  ))

  tmp[!(is.na(time) | station == '')][order(time)]
}

# get an overview
local({
  tmp = df.e[, sum(event), station][order(V1)]
  tmp$station = factor(tmp$station, levels = tmp$station[order(tmp$V1)]) # reorder by V1
  p = ggplot(tmp) +
    geom_col(aes(x = station, y = V1)) +
    theme(axis.text.x = element_blank()) +
    ggtitle('Bike turnover at various stations in 2016') + labs(x = 'Station', y = 'Bike turnoever')
  print(ggplotly(p))
})
# mmm, many stations have turnover very different from 0
# i.e station Bay St / Wellesley St W is -2733, so nearly 3000 bikes were taken out
# Union Station: 3006, so over 3000 bikes were put in

# So have a closer look at each station

# this helper function calc the number of consecutive events between a time period
# i.e 
#    event n                from                  to  dur
# 1:    -1 2 2016-01-10 00:10:00 2016-01-10 00:13:00  180
# 2:     1 1 2016-01-10 00:20:03 2016-01-10 00:20:03    0
# 3:    -1 1 2016-01-10 00:58:00 2016-01-10 00:58:00    0
# 4:     1 3 2016-01-10 01:04:27 2016-01-10 01:20:11  944
# in row 1: from 00:10:00 to 00:13:00 (180 seconds), 2 bikes (n = 2) were taken out (-1)
# in row 2: from 00:20:03 to 00:20:03 (0 second), 1 bike (n = 1) was parked in (1)
helper = function (df) {
  events = df[, event]
  l = length(events)
  result_event = rep(NA, l) # pre allocate space for results
  result_n = rep(NA, l)
  result_from = rep(NA, l)
  result_to = rep(NA, l)

  result_pos = 1
  current = events[1]
  n = 0

  for (i in 1:l) {
    event = events[i]
    if (current != event) {
      result_event[result_pos] = current
      result_n[result_pos] = n
      result_to[result_pos] = df[i - 1, time]

      result_pos = result_pos + 1
      if (is.na(result_from[result_pos])) result_from[result_pos] = df[i, time]

      current = event
      n = 1
    } else {
      if (is.na(result_from[result_pos])) result_from[result_pos] = df[i, time]
      n = n + 1
    }
  }
  
  # the last row
  result_event[result_pos] = current
  result_n[result_pos] = n
  result_to[result_pos] = df[i - 1, time]

  tmp = data.table(
    event = result_event[which(!is.na(result_event))],
    n = result_n[which(!is.na(result_n))],
    from = as.POSIXct(result_from[which(!is.na(result_from))], origin = '1970-01-01'),
    to = as.POSIXct(result_to[which(!is.na(result_to))], origin = '1970-01-01')
  )

  tmp[, `:=`(dur = as.numeric(to - from), v = event * n)][]
}

# for union station
tmp = helper(df.e[station == 'Union Station'])

# over the year of 2016, there were 8923 events

tmp[order(n, decreasing = T)]
# on 2016-03-10, from 18:29 to 20:54 (8741 sec or 2.4 hours), there were 38 bikes parking in, on on average 3.8 mins per bike
# are there 38 racks in there?
# then on 2016-06-10 11:20 to 11:58, a total of 19 bike taken out

# plot
local({
  tmp = rbindlist(list(tmp[, .(from, v)], tmp[, .(to, v)]))[order(from)]
  p = ggplot(tmp, aes(x = from, y = v)) +
    geom_hline(yintercept = 0, linetype = 'dashed') +
    geom_line() +
    # geom_smooth(method = 'lm') +
    theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor.y = element_blank(),
      panel.background = element_blank(),
      axis.line = element_line(color = '#CCCCCC')
      # axis.text.x = element_blank()
    ) +
    scale_x_datetime(date_labels = '%m', date_breaks = '1 month') +
    ggtitle('Turnover in Union Station') + labs(x = 'Date & Time', y = 'Bike turnoever')
  ggsave('./graph/union_station_turnover.jpeg', p, device = 'jpeg', width = 50, limitsize = F)
  print(p)
  # print(ggplotly(p)) # throw ALTVEC error
})

