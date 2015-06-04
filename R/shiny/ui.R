library(shinydashboard)
library(leaflet)

header <- dashboardHeader(
  title = "Croix Rouge"
)

body <- dashboardBody(
  fluidRow(
    column(width = 9,
           box(width = NULL, solidHeader = TRUE,
               leafletOutput("map", height = 500)
           )
    ),
    column(width = 3,
           box(width = NULL, status = "warning",
               uiOutput("centerSelect"),
               selectInput(inputId = "centerAction",
                           label = "Type de centre",
                           selected  = "Centre de Distribution Alimentaire",
                           choices = centerAction,
                           multiple = T)
               ),
               actionButton("refresh", "Recalcul")
        )
    )
)

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)