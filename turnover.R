setwd(getSrcDirectory(function () {}))

# libraries
library(data.table)

# read the data
# df.all = readRDS('./tmp/df.all.rds')

# df.e = {
#   tmp = df.all[, .(
#     time = as.POSIXct(start, format = '%d/%m/%Y %H:%M', tz = ''),
#     dur,
#     from,
#     to
#   )]
# 
#   tmp = rbindlist(list(
#     tmp[, .(time, station = from, event = -1)], # -1 depart
#     tmp[, .(time = time + dur, station = to, event = 1)] # 1 arrive
#   ))
# 
#   tmp[!(is.na(time) | station == '')][order(time)]
# }

df.e[, sum(event), station][order(V1)]

tmp = df.e[station == 'Union Station']

helper = function () {
  events = tmp[, event]
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
      result_to[result_pos] = tmp[i - 1, time]

      result_pos = result_pos + 1
      if (is.na(result_from[result_pos])) result_from[result_pos] = tmp[i, time]

      current = event
      n = 1
    } else {
      if (is.na(result_from[result_pos])) result_from[result_pos] = tmp[i, time]
      n = n + 1
    }
  }
  
  # the last row
  result_event[result_pos] = current
  result_n[result_pos] = n
  result_to[result_pos] = tmp[i - 1, time]

  tmp = data.table(
    event = result_event[which(!is.na(result_event))],
    n = result_n[which(!is.na(result_n))],
    from = as.POSIXct(result_from[which(!is.na(result_from))], origin = '1970-01-01'),
    to = as.POSIXct(result_to[which(!is.na(result_to))], origin = '1970-01-01')
  )

  tmp[, dur := as.numeric(to - from)][]
  
}

tt = helper()
