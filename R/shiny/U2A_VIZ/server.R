require(htmltools)

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
    table[table$centre == as.character(input$map_marker_click$id), ]
  })
  
  output$nm_centre <- renderText({ 
    data <- filteredData()
    paste(htmlEscape(as.character(centres[centres$Code.U2A == data$centre,][["Libellé.U2A"]])))
  })
  
  output$id_centre <- renderText({ 
    data <- filteredData()
    as.character(data$centre)
  })
  
  observe({
    data <- filteredData()
    if(nrow(data) != 0)
    {
      clat = unlist(strsplit(as.character(data$coord_c),","))[1]
      clong = unlist(strsplit(as.character(data$coord_c),","))[2]
      l1 = unlist(strsplit(as.character(data$coord_s1),","))[1]
      lg1 = unlist(strsplit(as.character(data$coord_s1),","))[2]
      l2 = unlist(strsplit(as.character(data$coord_s2),","))[1]
      lg2 = unlist(strsplit(as.character(data$coord_s2),","))[2]
      
      #popup text
      pop_centre = paste("<b style='color:red'>",
                         htmlEscape(as.character(centres[centres$Code.U2A == data$centre,][["Libellé.U2A"]])),
                         "</b>")
      pop_s1 = paste("<b style='color:blue'>",
                         htmlEscape(as.character(shop[as.numeric(data$ind_shop1),"TEXT_1"])),
                         "</b>",
                         "<br/>",
                         data$d1,
                         "<br/>",
                         data$t1)
      pop_s2 = paste("<b style='color:blue'>",
                         htmlEscape(as.character(shop[as.numeric(data$ind_shop2),"TEXT_1"])),
                         "</b>",
                         "<br/>",
                         data$d2,
                         "<br/>",
                         data$t2)
      
      #first set view. fitBound doesn't pipe properly
      leafletProxy("map") %>%
      fitBounds(lat1 = min(l1,l2,clat), lng1 = min(lg1,lg2,clong),
                lat2 = max(l1,l2,clat), lng2 = max(lg1,lg2,clong))
      
      leafletProxy("map") %>%
        addCircleMarkers(lng = lg1, lat = l1, radius = 6,col = "blue") %>%
        addCircleMarkers(lng = lg2, lat = l2,radius = 6,col = "blue") %>%
        addPopups(lng = c(clong,lg1,lg2), lat = c(clat,l1,l2),
                        popup = c(pop_centre, pop_s1, pop_s2)
        )
    }
  })

  
  
}