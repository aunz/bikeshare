setwd(getSrcDirectory(function () {})) # set working dir to this script

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


# source('./importData.R')

df.all = readRDS('./tmp/df.all.rds')


