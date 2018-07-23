library(data.table)
library(ggplot2)
library(plotly)
library(shiny)

# data
# df.t = readRDS('./tmp/df.t.rds')


userTypeInput = checkboxGroupInput(
  'userType',
  span('User type'),
  choices = list(
    All = 'All',
    Member = 'Member',
    Casual = 'Casual'
  ),
  selected = c('All', 'Member', 'Casual')
)

timeTypeInput = radioButtons(
  'timeType',
  span('Time type'),
  choices = list(
    'Date of year' = 'start_date',
    'Month of year' = 'start_m',
    'Week of year' = 'start_wk',
    'Date of month' = 'start_d',
    'Day of Week' = 'start_w',
    'Hour of day' = 'start_h'
  ),
  selected = c('start_m')
)

plotHeight = '480px'

ui = fluidPage(
  fluidRow(
    column(2, h2('Toronto bikeshare ridership 2016')),
    column(2, userTypeInput),
    column(2, timeTypeInput),
    column(6, plotlyOutput(outputId = 'plot1', height = plotHeight)) # number of total trips
  ),
  fluidRow(
    column(6, plotlyOutput(outputId = 'plot2', height = plotHeight)), # total duration 
    column(6, plotlyOutput(outputId = 'plot3', height = plotHeight)) # mean duration
  ),
  fluidRow(
    column(6, plotlyOutput(outputId = 'plot4', height = plotHeight)), # total distance 
    column(6, plotlyOutput(outputId = 'plot5', height = plotHeight)) # mean distance
  ),
  fluidRow(
    column(6, plotlyOutput(outputId = 'plot6', height = plotHeight)) # velocity
  )
)

server = function (input, output) {

  dataInput = reactive({
    tmp = df.t
    
    v = input$userType
    if (length(v) > 0) tmp = tmp[userType %in% v]
    
    v = input$timeType; tmp = tmp[timeType %in% v]
    
    if (v == 'start_date') tmp[, time := as.Date(time)]
    else tmp[, time := as.integer(time)]
    tmp
  })
  
  xlabInput = reactive({
    timeType = switch(
      input$timeType,
      'start_date' = 'Date of year',
      'start_m' = 'Month of year',
      'start_wk' = 'Week of year',
      'start_d' = 'Date of month',
      'start_w' = 'Day of Week',
      'start_h' = 'Hour of day'
    )
    xlab(timeType)
  })
  
  scaleXInput = reactive({
    timeType = input$timeType
    if (timeType == 'start_date') tmp = scale_x_date(date_labels = '%b', date_breaks = '1 month', limits = c(as.Date('2016-01-01'), as.Date('2016-12-31')))
    if (timeType == 'start_m') tmp = scale_x_continuous(breaks = 1:12, limits = c(1, 12))
    if (timeType == 'start_wk') tmp = scale_x_continuous(breaks = c(1, seq(0, 50, by = 5)[2:11]), limits = c(1, 52))
    if (timeType == 'start_d') tmp = scale_x_continuous(breaks = 1:31, limits = c(1, 31))
    if (timeType == 'start_w') tmp = scale_x_continuous(breaks = 0:6, limits = c(0, 6), labels = c('Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'))
    if (timeType == 'start_h') tmp = scale_x_continuous(breaks = 0:23, limits = c(0, 23))
    tmp
  })
  
  colorScale = scale_color_manual(
    labels = c('All', 'Member', 'Casual'),
    values = c('#001f3f', '#0074D9', '#FF851B')
  )

  
  p0 = ggplot(mapping = aes(x = time, color = userType)) +
    scale_y_continuous(
      expand = c(0.1, 0.1),
      breaks = scales::pretty_breaks(n = 8)
    ) +
    labs(color = 'User type') +
    colorScale + guides(color = F)
  
  output$plot1 = renderPlotly({
    data = dataInput()[measureFuncType == 'sum']
    aes = aes(y = N)
    p = p0 + geom_point(aes, data) + geom_line(aes, data) +
      xlabInput() +
      scaleXInput() +
      ylab('Total number of ride')
      
    ggplotly(p)
  })
  
  output$plot2 = renderPlotly({
    data = dataInput()[measureType == 'dur' & measureFuncType == 'sum']
    aes = aes(y = measure / 31536000) # convert to year
    p = p0 + geom_point(aes, data) + geom_line(aes, data) +
      xlabInput() +
      scaleXInput() +
      ylab('Total duration (year)')
    
    ggplotly(p)
  })
  
  output$plot3 = renderPlotly({
    data = dataInput()[measureType == 'dur' & measureFuncType == 'mean']

    aes = aes(y = measure / 60) # convert to minute
    p = p0 + geom_point(aes, data) + geom_line(aes, data) +
      xlabInput() +
      scaleXInput() +
      ylab('Mean duration per ride (minute)') +
      geom_hline(
        aes(yintercept = V1, color = userType),
        data[, mean(measure / 60, na.rm = T), userType],
        linetype = 'dashed',
        alpha = 1/3,
        show.legend = F
      )
    
    ggplotly(p)
  })
  
  output$plot4 = renderPlotly({
    data = dataInput()[measureType == 'gg_dis' & measureFuncType == 'sum']
    aes = aes(y = measure)
    p = p0 + geom_point(aes, data) + geom_line(aes, data) +
      xlabInput() +
      scaleXInput() +
      ylab('Total distance (km)')
    
    ggplotly(p)
  })
  
  output$plot5 = renderPlotly({
    data = dataInput()[measureType == 'gg_dis' & measureFuncType == 'mean']

    aes = aes(y = measure)
    p = p0 + geom_point(aes, data) + geom_line(aes, data) +
      xlabInput() +
      scaleXInput() +
      ylab('Mean distance per ride (Km)') +
      geom_hline(
        aes(yintercept = V1, color = userType),
        data[, mean(measure, na.rm = T), userType],
        linetype = 'dashed',
        alpha = 1/3,
        show.legend = F
      )
    
    ggplotly(p)
  })
  output$plot6 = renderPlotly({
    data = dataInput()[measureType == 'vel']
    aes = aes(y = measure)
    p = p0 + geom_point(aes, data) + geom_line(aes, data) +
      xlabInput() +
      scaleXInput() +
      ylab('Mean velocity per ride (Km/h)') +
      geom_hline(
        aes(yintercept = V1, color = userType),
        data[, mean(measure, na.rm = T), userType],
        linetype = 'dashed',
        alpha = 1/3,
        show.legend = F
      )

    ggplotly(p)
  })
}

shinyApp(ui, server)