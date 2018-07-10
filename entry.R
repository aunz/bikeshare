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
  'shiny'
), installed.packages()), install.packages)