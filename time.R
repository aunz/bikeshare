# convert wide to long format for plotting in a shiny app, take a min to run
# with these vars:
# time (Date)
# timeType (Char): start_date, start_m, start_wk, start_d, start_w, start_h
# N (Int): number of trip
# measure (Num): duration, gg_distance, velocity
# measureFuncType (Char): sum, mean
# userType (Char): All, Member, Casual


library(data.table)

df.all = readRDS('./tmp/df.all.rds')

# change to long format
helper = function (timeType, measureType, measureFunc, ...) {
  time = substitute(timeType)
  timeType = deparse(time)
  
  measure = substitute(measureType)
  measureType = deparse(measure)
  measureFuncType = deparse(substitute(measureFunc))
  
  print(time)  
  print(timeType)
  
  rbindlist(lapply(c('All', 'Member', 'Casual'), function (x) {
    if (x == 'All') rows = 1:nrow(df.all)
    else rows = df.all[user_type == x, which = T] 
    tmp = df.all[rows, .(
      timeType = timeType,
      .N,
      measure = measureFunc(eval(measure), ...),
      measureType = measureType,
      measureFuncType = measureFuncType,
      userType = x
    ), time]
    tmp[, time := as.character(time)]
  }))
}

tmp1 = rbindlist(list(
  helper(start_date, dur, sum, na.rm = T),
  helper(start_m, dur, sum, na.rm = T),
  helper(start_wk, dur, sum, na.rm = T),
  helper(start_d, dur, sum, na.rm = T),
  helper(start_w, dur, sum, na.rm = T),
  helper(start_h, dur, sum, na.rm = T)
))

tmp2 = rbindlist(list(
  helper(start_m, dur, mean, na.rm = T),
  helper(start_wk, dur, mean, na.rm = T),
  helper(start_d, dur, mean, na.rm = T),
  helper(start_w, dur, mean, na.rm = T),
  helper(start_h, dur, mean, na.rm = T)
))

tmp3 = rbindlist(list(
  helper(start_date, gg_dis, sum, na.rm = T),
  helper(start_m, gg_dis, sum, na.rm = T),
  helper(start_wk, gg_dis, sum, na.rm = T),
  helper(start_d, gg_dis, sum, na.rm = T),
  helper(start_w, gg_dis, sum, na.rm = T),
  helper(start_h, gg_dis, sum, na.rm = T)
))

tmp4 = rbindlist(list(
  helper(start_date, gg_dis, mean, na.rm = T),
  helper(start_m, gg_dis, mean, na.rm = T),
  helper(start_wk, gg_dis, mean, na.rm = T),
  helper(start_d, gg_dis, mean, na.rm = T),
  helper(start_w, gg_dis, mean, na.rm = T),
  helper(start_h, gg_dis, mean, na.rm = T)
))

tmp5 = rbindlist(list(
  helper(start_date, vel, mean, na.rm = T),
  helper(start_m, vel, mean, na.rm = T),
  helper(start_wk, vel, mean, na.rm = T),
  helper(start_d, vel, mean, na.rm = T),
  helper(start_w, vel, mean, na.rm = T),
  helper(start_h, vel, mean, na.rm = T)
))

tmp = rbindlist(list(tmp1, tmp2, tmp3, tmp4, tmp5))
tmp[, userType := factor(userType, levels = c('All', 'Member', 'Casual'))]

saveRDS(tmp, './tmp/df.t.rds')

