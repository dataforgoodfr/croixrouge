header <- dashboardHeader(
  title = "Croix Rouge"
)

body <- dashboardBody(
  fluidRow(
    column(width = 7, 
           box(width = NULL, solidHeader = TRUE,
               leafletOutput("map", height = 500)
          )
    ),
    column(width = 5,
           actionButton("refresh", label = "Refresh"),
           box(width = NULL, solidHeader = T, 
               checkboxInput("pb_centers", label = "Centres sous-provisionnes", value = F)),
           box(width = NULL, solidHeader = TRUE,
               h4(textOutput("nm_centre"), style = "color:red"),
               p(div("identifiant: ",style = "text-decoration: underline"), textOutput("id_centre")),
               p(div("action: ",style = "text-decoration: underline"), textOutput("action_centre")),
               plotOutput("exPlot") 
           ),
           box(width = NULL, solidHeader = TRUE,
               plotOutput("info_shop_other") 
           )
    )       
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)