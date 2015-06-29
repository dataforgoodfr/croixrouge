server <- function(input, output, session) {
  
  
  basic_map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      addCircleMarkers(lng = centres$longitude,
                       lat = centres$latitude,
                       radius = 2,
                       layerId = centres$Code.U2A,
                       col = "red")
  })
  
  output$map <- basic_map
  
  ### refreshing map and global variables
  observe({
    input$refresh
    current_center_ID <<- NA
    output$map <- basic_map
  })
  
  
  filteredData <- reactive({
    if(length(input$map_marker_click$id) != 0)
    {
      if(input$map_marker_click$id %in% centres$Code.U2A)
      {
        current_center_ID <<- input$map_marker_click$id
        data_u2a_viz[data_u2a_viz$centre == as.character(input$map_marker_click$id), ]
      }
      else
        NA
    }
    else
      NA
  })
  
  ### TEXT OUTPUT
  output$nm_centre <- renderText({ 
    input$refresh
    data <- filteredData()
    if(is.na(current_center_ID))
      paste("Choix du centre")
    else
      paste(htmlEscape(as.character(centres[centres$Code.U2A == current_center_ID,][["Libellé.U2A"]])))
  })
  
  output$id_centre <- renderText({ 
    input$refresh
    data <- filteredData()
    if(is.na(current_center_ID))
      ""
    else
      as.character(current_center_ID)
  })
  
  output$action_centre <- renderText({ 
    input$refresh
    data <- filteredData()
    if(is.na(current_center_ID))
      ""
    else
      as.character(centres[centres$Code.U2A == current_center_ID,][["Action.menée"]])
  })
  
  observe({
    data <- filteredData()
    if(is.data.frame(data))
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
      
      pop_autre = paste("<b style='color:violet'>",
                        as.character(data$type_autre),
                        "</b>",
                        "</br>",
                        data$d_a,
                        "</br>",
                        data$t_a)
      #first set view. fitBound doesn't pipe properly
      leafletProxy("map") %>%
      fitBounds(lat1 = min(data$lat_s1,data$lat_s2,data$lat_c, data$lat_a), lng1 = min(data$lng_s1,data$lng_s2,data$lng_c, data$lng_a),
                lat2 = max(data$lat_s1,data$lat_s2,data$lat_c, data$lat_a), lng2 = max(data$lng_s1,data$lng_s2,data$lng_c, data$lng_a))
      
      leafletProxy("map") %>%
        addCircleMarkers(lng = c(data$lng_s1, data$lng_s2),
                         lat = c(data$lat_s1, data$lat_s2),
                         col = "blue",
                         radius = 7,
                         opacity = 0.9,
                         popup = c(pop_s1, pop_s2)) %>%
        addCircleMarkers(lng = data$lng_a, lat = data$lat_a,
                         col = "yellow",radius = 7,
                         opacity = 0.9,
                         popup = pop_autre) %>%
        addPopups(lng = c(data$lng_c, data$lng_s1, data$lng_s2,data$lng_a),
                  lat = c(data$lat_c,data$lat_s1, data$lat_s2, data$lat_a),
                        popup = c(pop_centre, pop_s1, pop_s2, pop_autre))
    }
  })

  
  
}