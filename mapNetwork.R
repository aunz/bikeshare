# libraries
library(data.table)
library(igraph)


# read the data
setwd(getSrcDirectory(function () {}))
df.all = readRDS('./tmp/df.all.rds')

# directed net
net = graph_from_data_frame(
  d = df.all[from != '' & to != '', .N, .(from, to)][, .(source = from, target = to, weight = N)],
  directed = T
)

# a smaller set for testing out codes
# net2 = graph_from_data_frame(
#   d = df.all[from != '' & to != '', .N, .(from, to)]
#     [, .(source = from, target = to, weight = N)]
#     [source %in% sample(unique(df.all[, from]), 25)]
#     [target %in% unique(source)],
#   directed = T
# )


# plot it
plot(
  net,
  edge.arrow.size = 0,
  edge.color = '#00000055',
  edge.width = log(E(net)$weight + 1),
  vertex.frame.color = '#AAAAAA',
  vertex.label.color = '#333333',
  vertex.label.cex = 0.5,
  vertex.label.dist = 2,
  vertex.label = NA,
  # layout = layout.circle(net),
  # layout = layout.sphere(net),
  # layout = layout.fruchterman.reingold(net),
  layout = layout.kamada.kawai(net),
)

# Some descriptive stats
# http://kateto.net/networks-r-igraph

ecount(net) / (vcount(net) * (vcount(net) - 1))
reciprocity(net)
dyad_census(net)
transitivity(net, type = 'global')
transitivity(net, type = 'local')
triad_census(net)

diameter(net, directed = T)

degree(net, mode = 'all')
