setwd(getSrcDirectory(function () {}))

# install libraries
library(data.table)
library(ggplot2)
library(plotly)


# read the data
df.all = readRDS('./tmp/df.all.rds')


### Exploratory
df.all[, .(
  .N, # total number of trip
  dur = sum(dur, na.rm = T) / 3600 / 24 / 365, # total duration (year)
  dur_mean = mean(dur, na.rm = T) / 60, # mean duration per trip (min)
  dur_sd = sd(dur / 60, na.rm = T),
  gg_dis = sum(gg_dis, na.rm = T) / 1000, # total distance (Km)
  gg_dis_mean = mean(gg_dis, na.rm = T) / 1000, # mean distance per trip (Km)
  gg_dis_sd = sd(gg_dis / 1000, na.rm = T),
  vel = mean(vel, na.rm = T),
  vel_sd = sd(vel, na.rm = T) # mean velocity per trip (Km/h)
), ][, `:=`(dur_se = dur_sd / sqrt(N), gg_dis_se = gg_dis_sd / sqrt(N), vel_se = vel_sd / sqrt(N)), ][]


### Ridership & total duration vs time
helper = function (var, xlab, scale_x) {
  tmp = df.all[, c(var = var, 'dur'), with = F]
  setnames(tmp, var, 'var')
  tmp = tmp[, .(dur = sum(dur) / 3600 / 24 / 365, .N), var][, .(
    var, N, dur, dur_rs = scales::rescale(c(0, dur), c(0, max(N)))[-1]
  )]
  
  y2breaks = seq(0, max(tmp$dur_rs), max(tmp$dur_rs) / 10)
  y2label = round(seq(0, max(tmp$dur), max(tmp$dur) / 10), 1)
  p = ggplot(tmp, aes(x = var))
  p = p + geom_point(aes(y = N, color = 'Number of ride')) + geom_line(aes(y = N, color = 'Number of ride'))
  p = p + geom_point(aes(y = dur_rs, color = 'Duration of ride')) + geom_line(aes(y = dur_rs, color = 'Duration of ride'))
  p = p + scale_y_continuous(
    expand = c(0.1, 0.1),
    breaks = scales::pretty_breaks(n = 8),
    # limits = c(0, max(tmp$N)),
    name = 'Total number of ride',
    sec.axis = sec_axis(~ ., name = 'Total duration of ride (year)', breaks = y2breaks, labels = y2label)
  )
  # p = p + theme(legend.position = c(0.105, 0.895), legend.title = element_blank())
  p = p + theme(legend.title = element_blank())
  if (!missing(xlab)) p = p + xlab(xlab)
  if (!missing(scale_x)) p = p + scale_x_continuous(breaks = scale_x)
  print(p)
  NA
}

helper('start_date', 'Date')
helper('start_m', 'Month', 1:12)
helper('start_wk', 'Week')
helper('start_w', 'Day of the week', 0:6)
helper('start_d', 'Day of the month', 1:31)
helper('start_h', 'Hour of the day', 0:23)


### Ridership and mean duration vs time
helper = function (var, xlab, scale_x) {
  tmp = df.all[, c(var = var, 'dur'), with = F]
  setnames(tmp, var, 'var')
  tmp = tmp[, .(dur = mean(dur) / 60, .N), var][, .(
    var, N, dur, dur_rs = scales::rescale(c(0, dur), c(0, max(N)))[-1]
  )]

  y2breaks = seq(0, max(tmp$dur_rs), max(tmp$dur_rs) / 10)
  y2label = round(seq(0, max(tmp$dur), max(tmp$dur) / 10), 1)
  
  p = ggplot(tmp, aes(x = var))
  p = p + geom_point(aes(y = N, color = 'Number of ride')) + geom_line(aes(y = N, color = 'Number of ride'))
  p = p + geom_point(aes(y = dur_rs, color = 'Duration of ride')) + geom_line(aes(y = dur_rs, color = 'Duration of ride'))
  p = p + scale_y_continuous(
    expand = c(0.1, 0.1),
    breaks = scales::pretty_breaks(n = 8),
    name = 'Total number of ride',
    sec.axis = sec_axis(~ ., name = 'Mean duration of each ride (minute)', breaks = y2breaks, labels = y2label)
  )
  p = p + theme(legend.position = c(0.105, 0.895), legend.title = element_blank())
  if (!missing(xlab)) p = p + xlab(xlab)
  if (!missing(scale_x)) p = p + scale_x_continuous(breaks = scale_x)
  print(p)
  NA
}

helper('start_date', 'Date')
helper('start_m', 'Month', 1:12)
helper('start_wk', 'Week')
helper('start_w', 'Day of the week', 0:6)
helper('start_d', 'Day of the month', 1:31)
helper('start_h', 'Hour of the day', 0:23)



length(df.all[dur > 1800, dur - 1800]) # trips over 30 mins
sum(df.all[dur > 1800, dur - 1800]) / 3600 # total time 



### Trip distance
helper = function (varX, varY = 'gg_dis', xlab, ylab = 'Trip distance (Km)', scale_x, scale_y) {
  tmp = df.all[, c(varX = varX, varY = varY), with = F]
  setnames(tmp, c(varX, varY), c('varX', 'varY'))
  tmp = tmp[, .(varY = sum(varY, na.rm = T) / 1000, .N), varX]
  
  
  p = ggplot(tmp, aes(x = varX))
  p = p + geom_point(aes(y = varY)) + geom_line(aes(y = varY))
  p = p + scale_y_continuous(
    expand = c(0.1, 0.1),
    breaks = scales::pretty_breaks(n = 8)
  )
  p = p + theme(legend.position = c(0.105, 0.895))
  if (!missing(xlab)) p = p + xlab(xlab)
  p = p + ylab(ylab)
  if (!missing(scale_x)) p = p + scale_x_continuous(breaks = scale_x)
  if (!missing(scale_y)) p = p + scale_y_continuous(breaks = scale_y)
  print(p)
  NA
}
helper('start_date', xlab = 'Date')
helper('start_m', xlab = 'Month', scale_x = 1:12)
helper('start_wk', xlab = 'Week', scale_x = 1:52)
helper('start_w', xlab = 'Day of the week', scale_x = 0:6)
helper('start_d', xlab = 'Day of the month', scale_x = 1:31)
helper('start_h', xlab = 'Hour of the day', scale_x = 0:23)



### Trip velocity
summary(df.all[, vel])
summary(df.all[, gg_vel])
summary(df.all[, vel_diff]) # some are super fast, how come?


helper = function (varX, varY = 'vel', xlab, ylab = 'Trip mean velocity (km/h)', scale_x, scale_y) {
  tmp = df.all[, c(varX = varX, varY = varY), with = F][varY > 0]
  setnames(tmp, c(varX, varY), c('varX', 'varY'))
  tmp = tmp[, .(varY = mean(varY, na.rm = T), .N), varX]
  
  p = ggplot(tmp, aes(x = varX))
  p = p + geom_point(aes(y = varY)) + geom_line(aes(y = varY))
  p = p + scale_y_continuous(
    expand = c(0.1, 0.1),
    breaks = scales::pretty_breaks(n = 8)
  )
  p = p + theme(legend.position = c(0.105, 0.895))
  if (!missing(xlab)) p = p + xlab(xlab)
  p = p + ylab(ylab)
  if (!missing(scale_x)) p = p + scale_x_continuous(breaks = scale_x)
  if (!missing(scale_y)) p = p + scale_y_continuous(breaks = scale_y)
  print(p)
  NA
}
helper('start_date', xlab = 'Date')
helper('start_m', xlab = 'Month', scale_x = 1:12)
helper('start_wk', xlab = 'Week', scale_x = 1:52)
helper('start_w', xlab = 'Day of the week', scale_x = 0:6)
helper('start_d', xlab = 'Day of the month', scale_x = 1:31)
helper('start_h', xlab = 'Hour of the day', scale_x = 0:23)

# Cut vel into groups
table(cut(df.all[, vel], c(0, 5, 10, 15, 20, 25, 50, 75, 100, 200, 1000)))


### Duration vs distance
# p = ggplot(df.all, aes(x = dur, y = gg_dis)) + geom_point() # took too long to draw
# print(p)


### regression
print(summary(lm(dur ~ as.factor(start_m), df.all)))
print(summary(lm(dur ~ as.factor(start_wk), df.all)))
print(summary(lm(dur ~ as.factor(start_w), df.all)))
print(summary(lm(dur ~ as.factor(start_d), df.all)))
print(summary(lm(dur ~ gg_dis, df.all))) # R2 only 0.0152, too low



### Station
df.all[, .N, from][order(N)]
df.all[, .N, to][order(N)]


df.all[, .N, .(from, to)][order(N, decreasing = T)]

# trips with only 1 instance
tmp = df.all[, .(.N, dur = mean(dur), gg_dis = mean(gg_dis, na.rm = T), vel = mean(vel, na.rm = T)), .(from, to)][order(N)]

summary(tmp[, dur])
summary(tmp[, gg_dis])
summary(tmp[, vel])

summary(tmp[N == 1, dur])
summary(tmp[N == 1, gg_dis])
summary(tmp[N == 1, vel])

summary(tmp[N > 500, dur])
summary(tmp[N > 500, gg_dis])
summary(tmp[N > 500, vel])

tmp[from == to, ]
summary(tmp[from == to, N])
sum(tmp[from == to, N])
summary(tmp[from == to, dur])
sum(tmp[from == to, dur])
sum(df.all[from == to, dur])

df.all[, .(.N), route][order(N)] # in terms of number of trip
df.all[, .(N = sum(dur, na.rm = T) / 3600), route][order(N)]
df.all[, .(N = sum(gg_dis, na.rm = T)), route][order(N)]
df.all[!is.na(vel), .(N = mean(vel, na.rm = T)), route][order(N)]

df.all[from != to, .(.N), route][order(N)] # in terms of number of trip
df.all[from != to, .(N = sum(dur, na.rm = T) / 3600), route][order(N)]
df.all[from != to, .(N = sum(gg_dis, na.rm = T) / 1000), route][order(N)]
df.all[from != to & !is.na(vel), .(vel = median(vel, na.rm = T), .N), route][order(vel)][N > 500]
df.all[from != to & !is.na(vel), .(vel = median(vel, na.rm = T), .N), route][order(vel)][N > 100 & N < 500]

# which route has vel > 25 and N > 100
df.all[from != to & !is.na(vel), .(vel = median(vel, na.rm = T), .N), route][order(vel)][vel > 25 & N > 100][order(N)]
# some examples
df.all[route == '161 Bleecker St (South of Wellesley) York St / Queens Quay W', .(.N, vel = median(vel, na.rm = T)), from]
tmp = df.all[route == '161 Bleecker St (South of Wellesley) York St / Queens Quay W']
tmp[, .(
  .N,
  dur = sum(dur, na.rm = T) / 3600,
  mean_dur = mean(dur, na.rm = T) / 60,
  median_dur = median(dur, na.rm = T) / 60,
  mean_vel = mean(vel, na.rm = T),
  median_vel = median(vel, na.rm = T)
), from]


df.all[route == "161 Bleecker St (South of Wellesley) HTO Park (Queen's Quay W)", .(.N, vel = median(vel, na.rm = T)), from]
df.all[route == '161 Bleecker St (South of Wellesley) Queens Quay W / Lower Simcoe St', .(.N, vel = median(vel, na.rm = T)), from]


### user type
df.all[, .N, user_type][, .(user_type, N, p = N / sum(N) * 100)]
df.all[, .(dur = sum(dur, na.rm = T) / 3600 / 24 / 365), user_type]
df.all[, .(dur = mean(dur, na.rm = T) / 60), user_type]
df.all[, .(gg_dis = sum(gg_dis, na.rm = T) / 1000), user_type]
df.all[, .(gg_dis = mean(gg_dis, na.rm = T) / 1000), user_type]
df.all[, .(vel = mean(vel, na.rm = T)), user_type]


# where pick up and drop off were the same
df.all[from == to, .N, user_type][, .(user_type, N, p = N / sum(N) * 100)]
df.all[from == to, .(dur = sum(dur, na.rm = T) / 3600 / 24 / 365), user_type]
df.all[from == to, .(dur = mean(dur, na.rm = T) / 60), user_type]
df.all[from == to, .(gg_dis = sum(gg_dis, na.rm = T) / 1000), user_type]
df.all[from == to, .(gg_dis = mean(gg_dis, na.rm = T) / 1000), user_type]
df.all[from == to, .(vel = mean(vel, na.rm = T)), user_type]

### Total number of ride, total duration of ride, group by user type
helper = function (var, xlab, scale_x) {
  tmp = df.all[, c(var = var, 'dur', 'user_type'), with = F]
  setnames(tmp, var, 'var')
  tmp = tmp[, .(dur = sum(dur) / 3600 / 24 / 365, .N), .(var, user_type)][, .(
    var, N, dur,
    user_type = factor(user_type, levels = c('Member', 'Casual')),
    dur_rs = scales::rescale(c(0, dur), c(0, max(N)))[-1]
  )]
  
  y2breaks = seq(0, max(tmp$dur_rs), max(tmp$dur_rs) / 10)
  y2label = round(seq(0, max(tmp$dur), max(tmp$dur) / 10), 1)
  
  p = ggplot(tmp, aes(x = var))
  p = p + geom_point(aes(y = N, color = 'Number of ride')) + geom_line(aes(y = N, color = 'Number of ride', linetype = user_type))
  p = p + geom_point(aes(y = dur_rs, color = 'Duration of ride')) + geom_line(aes(y = dur_rs, color = 'Duration of ride', linetype = user_type))
  p = p + scale_y_continuous(
    expand = c(0.1, 0.1),
    breaks = scales::pretty_breaks(n = 10),
    name = 'Total number of ride',
    sec.axis = sec_axis(~ ., name = 'Total duration of ride (year)', breaks = y2breaks, labels = y2label)
  )
  # p = p + theme(legend.position = c(0.105, 0.895))
  p = p + guides(color = guide_legend(title = NULL))
  if (!missing(xlab)) p = p + xlab(xlab)
  if (!missing(scale_x)) p = p + scale_x_continuous(breaks = scale_x)
  print(p)
  NA
}

helper('start_date', 'Date')
helper('start_m', 'Month', 1:12)
helper('start_wk', 'Week')
helper('start_w', 'Day of the week', 0:6)
helper('start_d', 'Day of the month', 1:31)
helper('start_h', 'Hour of the day', 0:23)


### Total number of ride, mean duration of ride, group by user type
helper = function (var, xlab, scale_x) {
  tmp = df.all[, c(var = var, 'dur', 'user_type'), with = F]
  setnames(tmp, var, 'var')
  tmp = tmp[, .(dur = mean(dur / 60), .N), .(var, user_type)][, .(
    var, N, dur,
    user_type = factor(user_type, levels = c('Member', 'Casual')), 
    dur_rs = scales::rescale(c(0, dur), c(0, max(N)))[-1]
  )]

  y2breaks = seq(0, max(tmp$dur_rs), max(tmp$dur_rs) / 10)
  y2label = round(seq(0, max(tmp$dur), max(tmp$dur) / 10), 1)
  
  p = ggplot(tmp, aes(x = var))
  p = p + geom_point(aes(y = N, color = 'Number of ride')) + geom_line(aes(y = N, color = 'Number of ride', linetype = user_type))
  p = p + geom_point(aes(y = dur_rs, color = 'Mean duration of ride')) + geom_line(aes(y = dur_rs, color = 'Mean duration of ride', linetype = user_type))
  p = p + scale_y_continuous(
    expand = c(0.1, 0.1),
    breaks = scales::pretty_breaks(n = 10),
    name = 'Total number of ride',
    sec.axis = sec_axis(~ ., name = 'Mean duration of each ride (minute)', breaks = y2breaks, labels = y2label)
  )
  p = p + guides(color = guide_legend(title = NULL))
  if (!missing(xlab)) p = p + xlab(xlab)
  if (!missing(scale_x)) p = p + scale_x_continuous(breaks = scale_x)
  print(p)
  NA
}

helper('start_date', 'Date')
helper('start_m', 'Month', 1:12)
helper('start_wk', 'Week')
helper('start_w', 'Day of the week', 0:6)
helper('start_d', 'Day of the month', 1:31)
helper('start_h', 'Hour of the day', 0:23)
