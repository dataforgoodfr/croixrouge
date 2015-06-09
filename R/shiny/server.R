server <- function(input, output, session) {
  
  points <- reactive({
    centerAction = input$centerAction
    t = data[ data$CenterAction %in% centerAction & abs(data$longitude) < 40 & data$latitude > 20, list(Total = sum(Total, na.rm=T), Moyenne = sum(Total,na.rm=T)/sum(Count,na.rm=T)),by='latitude,longitude,CenterName,CenterAction']
    return(t)
  })
  
  output$map <- renderLeaflet({
    t = points()
    if(nrow(t) == 0)
    {
      leaflet() %>%
        addTiles
    }
    else
    {
    leaflet(t) %>%
      addTiles %>%
      addCircleMarkers(lng = t$longitude,lat = t$latitude,radius = 30 * (t$Total-min(t$Total))/(max(t$Total) - min(t$Total)),popup = paste(paste0("<br>Center Name : ", t$CenterName), paste0("<br>Total transaction = ", round(t$Total,2)), paste0('<br>Transaction moyenne = ', round(t$Moyenne, 2)),sep = '</br>'), col = "red", opacity = 0.8)
    }
  })
}