server <- function(input, output, session) {
  
  output$map <- renderLeaflet({
    input$refresh
    #centres = centres[1:10,]
    leaflet() %>%
    addTiles() %>%
    addCircleMarkers(lng = centres$longitude,
                       lat = centres$latitude,
                       radius = 2,
                       layerId = centres$Code.U2A,
                       col = "red")
  })
  
  filteredData <- reactive({
    near_shop[near_shop$centre == as.character(input$map_marker_click$id), ]
  })
  
  output$nm_centre <- renderText({ 
    data <- filteredData()
    paste(htmlEscape(as.character(centres[centres$Code.U2A == data$centre,][["Libellé.U2A"]])))
  })
  
  output$id_centre <- renderText({ 
    data <- filteredData()
    as.character(data$centre)
  })
  
  output$action_centre <- renderText({ 
    data <- filteredData()
    as.character(centres[centres$Code.U2A == data$centre,][["Action.menée"]])
  })
  
  observe({
    data <- filteredData()
    if(nrow(data) != 0)
    {
      
      #popup text
      pop_centre = paste("<b style='color:red'>",
                         htmlEscape(as.character(centres[centres$Code.U2A == data$centre,][["Libellé.U2A"]])),
                         "</b>")
      pop_s1 = paste("<b><a href = '",as.character(shop[as.numeric(data$ind_shop1),"SITE_INTERNET_LINK"]),  "' style='color:blue'>",
                         htmlEscape(as.character(shop[as.numeric(data$ind_shop1),"TEXT_1"])),
                         "</a></b>",
                         "<br/>",
                         data$d1,
                         "<br/>",
                         data$t1,
                         "<br/>",
                         "<div style = 'font-style: italic'>",
                         as.character(shop[as.numeric(data$ind_shop1),"TEXT_4"]), "</div>")
      
      pop_s2 = paste("<b><a href = '",as.character(shop[as.numeric(data$ind_shop2),"SITE_INTERNET_LINK"]),  "' style='color:blue'>",
                     htmlEscape(as.character(shop[as.numeric(data$ind_shop2),"TEXT_1"])),
                     "</a></b>",
                     "<br/>",
                     data$d2,
                     "<br/>",
                     data$t2,
                     "<br/>",
                     "<div style = 'font-style: italic'>",
                     as.character(shop[as.numeric(data$ind_shop2),"TEXT_4"]), "</div>")
      
      #first set view. fitBound doesn't pipe properly
      leafletProxy("map") %>%
      fitBounds(lat1 = min(data$lat_s1,data$lat_s2,data$lat_c), lng1 = min(data$lng_s1,data$lng_s2,data$lng_c),
                lat2 = max(data$lat_s1,data$lat_s2,data$lat_c), lng2 = max(data$lng_s1,data$lng_s2,data$lng_c))
      
      leafletProxy("map") %>%
        addCircleMarkers(lng = data$lng_s1, lat = data$lat_s1, radius = 6,col = "blue") %>%
        addCircleMarkers(lng = data$lng_s2, lat = data$lat_s2,radius = 6,col = "blue") %>%
        addPopups(lng = c(data$lng_c,data$lng_s1,data$lng_s2), lat = c(data$lat_c,data$lat_s1,data$lat_s2),
                        popup = c(pop_centre, pop_s1, pop_s2)
        )
    }
  })

  
  
}