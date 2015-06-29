require(data.table)
require(leaflet)
require(shinyapps)
require(shiny)
library(shinydashboard)
require(htmltools)

#setwd("~/Desktop/SHINY_CR/")
load("data/data_u2a_viz.RData")

#global variables
current_center_ID <<- NA
#centerAction = unique(data$CenterAction)