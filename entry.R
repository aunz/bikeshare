# set working dir to this script
setwd(getSrcDirectory(function () {}))

# libraries
sapply(setdiff(c(
  'data.table',
  'ggplot2',
  'plotly',
  'geosphere',
  'leaflet',
  'DT',
  'crosstalk',
  'igraph',
  'shiny',
  'caret',
  'randomForest',
  'corrplot'
), installed.packages()), install.packages)

df.all = readRDS('./tmp/df.all.rds')