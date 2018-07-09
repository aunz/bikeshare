# libraries
library(data.table)
library(igraph)


# read the data
setwd(getSrcDirectory(function () {}))
# df.all = readRDS('./tmp/df.all.rds')
# df.geo = fread('./data/station-geo.csv')



net = graph_from_data_frame(
  d = df.all[from != '' & to != '', .N, .(from, to)][, .(source = from, target = to, weight = N)],
  directed = T
) 


# plot it
plot(
  net,
  edge.arrow.size = 0.375,
  vertex.frame.color = '#aaaaaa',
  vertex.label.color = '#333333',
  vertex.label.cex = 0.5,
  vertex.label.dist = 2
)

