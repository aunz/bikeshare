# libraries
library(data.table)
library(igraph)


# read the data
setwd(getSrcDirectory(function () {}))
df.all = readRDS('./tmp/df.all.rds')



net = graph_from_data_frame(
  d = df.all[from != '' & to != '', .N, .(from, to)][, .(source = from, target = to, weight = N)],
  directed = T
)

# net2 = graph_from_data_frame(
#   d = df.all[from != '' & to != '', .N, .(from, to)]
#     [, .(source = from, target = to, weight = N)]
#     [source %in% sample(unique(df.all[, from]), 25)]
#     [target %in% unique(source)],
#   directed = T
# )


# plot it
plot(
  net2,
  edge.arrow.size = 0,
  edge.color = '#00000055',
  edge.width = log(E(net2)$weight + 1),
  vertex.frame.color = '#AAAAAA',
  vertex.label.color = '#333333',
  vertex.label.cex = 0.5,
  vertex.label.dist = 2,
  vertex.label = NA,
  # layout = layout.circle(net2),
  # layout = layout.sphere(net2),
  # layout = layout.fruchterman.reingold(net2),
  layout = layout.kamada.kawai(net2),
)
