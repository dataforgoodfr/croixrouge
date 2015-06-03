server <- function(input, output, session) {
  
  points <- reactive({
    t = data[ data$CenterAction == "Centre de Distribution Alimentaire" & abs(data$longitude) < 40 & data$latitude > 20, list(Total = sum(Total, na.rm=T), Moyenne = sum(Total,na.rm=T)/sum(Count,na.rm=T)),by='latitude,longitude,CenterName,CenterAction']
    return(t)
  })
  
  output$mymap <- renderLeaflet({
    t = points()
    leaflet(t) %>%
      addTiles %>%
      addCircleMarkers(lng = t$longitude,lat = t$latitude,radius = 30 * (t$Total-min(t$Total))/(max(t$Total) - min(t$Total)),popup = paste(paste0("<br>Center Name : ", t$CenterName), paste0("<br>Total transaction = ", round(t$Total,2)), paste0('<br>Transaction moyenne = ', round(t$Moyenne, 2)),sep = '</br>'), col = "red", opacity = 0.8)
  })
}