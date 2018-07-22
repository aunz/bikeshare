# Bike turnover

We want to make sure that in each station, there are enough bikes so whenever users want a bike, there should be a free one to take and when a user returns a bike, there should be an empty rack.

We assume that in each station, when a bike is taken out of a rack 🔓, there will be an empty "slot" which can be filled by another incoming bike 🔒. So on average, the number of "out" bikes should cancel out the number of "in" bikes.

But we find a different pattern
[![](graph/bike_turnover_year.jpeg)](https://aunz.github.io/bikeshare/graph/bike_turnoever_year.html)

Click the image above for more detail

- in Station Bay St / Wellesley St W, **2733** more bikes were taken out than anticipated
- in Union Station, **3006** more bikes were put in than anticipated


## Union Station
Let's have a closer look at Union Station. We will determine the kind of event (-1: bike taken out, 1: bike put back in), number of event (n) and the time range. Such as below

|| event | n | from | to | duration (sec) |
| --- | --- | --- | --- | --- | --- |
| 1 | -1 | 2 | 2016-01-10 00:10:00 | 2016-01-10 00:13:00 |180
| 2 | 1 | 1 | 2016-01-10 00:20:03 | 2016-01-10 00:20:03 | 0
| 3 | -1 | 1 | 2016-01-10 00:58:00 | 2016-01-10 00:58:00 | 0
| 4 | 1 | 3 | 2016-01-10 01:04:27 | 2016-01-10 01:20:11 | 944

The table shows that from 00:10:00 to 00:13:00 (3 minutes), 2 bikes were taken out. This is followed at 00:20:03 where 1 bike was put back in.

By tallying up these events, we found that:
- From 2016-03-10 18:29:07 to 2016-03-10 20:54:48 (146 minutes) 38 bikes were put in continuously with no bike being taken out. Mmm, there must be at least 38 racks at the station 🤔?
- From 2016-06-10 11:20:00 to 2016-06-10 11:58:00 (38 minutes) 19 bikes were taken out continuously. So at least there must be 19 racks too.

[![](graph/union_station_turnover_small.jpeg)](graph/union_station_turnover_large.jpeg)

Click the graph for a larger version.

The data is not complete, there are many periods when nothing happened 😣.
