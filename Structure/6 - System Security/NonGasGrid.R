require(readxl)
require(plotly)
require(dygraphs)
require(png)
require("DT")
###### UI Function ######



NonGasGridOutput <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(column(8,
                    h3("Proportion of households not on the gas grid by local authority (estimates)", style = "color: #5d8be1;  font-weight:bold"),
                    h4(textOutput(ns('NonGasGridSubtitle')), style = "color: #5d8be1;")
    ),
             column(
               4, style = 'padding:15px;',
               downloadButton(ns('NonGasGrid.png'), 'Download Graph', style="float:right")
             )),
    
    tags$hr(style = "height:3px;border:none;color:#5d8be1;background-color:#5d8be1;"),
    #dygraphOutput(ns("NonGasGridPlot")),
    leafletOutput(ns("GasGridMap"), height = "800px")%>% withSpinner(color="#5d8be1"),
    tags$hr(style = "height:3px;border:none;color:#5d8be1;background-color:#5d8be1;"),
    fluidRow(
    column(10,h3("Commentary", style = "color: #5d8be1;  font-weight:bold")),
    column(2,style = "padding:15px",actionButton(ns("ToggleText"), "Show/Hide Text", style = "float:right; "))),
    
    fluidRow(
    uiOutput(ns("Text"))
    ),
    tags$hr(style = "height:3px;border:none;color:#5d8be1;background-color:#5d8be1;"),
    fluidRow(
    column(10, h3("Data", style = "color: #5d8be1;  font-weight:bold")),
    column(2, style = "padding:15px",  actionButton(ns("ToggleTable"), "Show/Hide Table", style = "float:right; "))
    ),
    fluidRow(
      column(12, dataTableOutput(ns("NonGasGridTable"))%>% withSpinner(color="#5d8be1"))),
    tags$hr(style = "height:3px;border:none;color:#5d8be1;background-color:#5d8be1;"),
    fluidRow(
      column(2, HTML("<p><strong>Last Updated:</strong></p>")),
      column(2,
             UpdatedLookup(c("BEISNonGasGrid"))),
      column(1, align = "right",
             HTML("<p><strong>Reason:</strong></p>")),
      column(7, align = "right", 
             p("Regular updates")
      )),
    fluidRow(p(" ")),
    fluidRow(
      column(2, HTML("<p><strong>Update Expected:</strong></p>")),
      column(2,
             DateLookup(c("BEISNonGasGrid"))),
      column(1, align = "right",
             HTML("<p><strong>Sources:</strong></p>")),
      column(7, align = "right",
        SourceLookup("BEISNonGasGrid")
        
      )
    )
  )
}




###### Server ######
NonGasGrid <- function(input, output, session) {

  if (exists("PackageHeader") == 0) {
    source("Structure/PackageHeader.R")
  }
  
  print("NonGasGrid.R")
  ###### Renewable Energy ###### ######
  
  ### From ESD ###
  
  output$NonGasGridSubtitle <- renderText({
    
    paste("Scotland, 2021")
  
    })
  
  output$NonGasGridPlot <- renderImage({
    
    # A temp file to save the output. It will be deleted after renderImage
    # sends it, because deleteFile=TRUE.
    outfile <- tempfile(fileext='.png')
   
     writePNG(readPNG("Structure/6 - System Security/NonGasGridOutput.png"),outfile) 
    
    # Generate a png
    
    
    # Return a list
    list(src = outfile,
         alt = "This is alternate text")
  }, deleteFile = TRUE)
  
  
  output$NonGasGridTable = renderDataTable({
    
    NonGasGrid <- read_excel(
      "Structure/CurrentWorking.xlsx",
      sheet = "Non-gas grid by LA",
      skip = 13
    )[c(6,2,5)]
    
    NonGasGrid[33,1] <- "S92000003"
    NonGasGrid[33,2] <- "Scotland"
    
    NonGasGrid <- rbind(NonGasGrid[33,], NonGasGrid[1:32,])

    datatable(
      NonGasGrid,
      extensions = 'Buttons',
      
      rownames = FALSE,
      options = list(
        paging = TRUE,
        pageLength = -1,
        searching = TRUE,
        fixedColumns = FALSE,
        autoWidth = TRUE,
        ordering = TRUE,
        title = "Proportion of households not on the gas grid by local authority (estimates)",
        dom = 'ltBp',
        buttons = list(
          list(extend = 'copy'),
          list(
            extend = 'excel',
            title = 'Proportion of households not on the gas grid by local authority (estimates)',
            header = TRUE
          ),
          list(extend = 'csv',
               title = 'Proportion of households not on the gas grid by local authority (estimates)')
        ),
        
        # customize the length menu
        lengthMenu = list( c(10, 20, -1) # declare values
                           , c(10, 20, "All") # declare titles
        ), # end of lengthMenu customization
        pageLength = 10
      )
    ) %>%
      formatPercentage(3, 1)
  })
  
  output$NonGasGridTimeSeriesTable = renderDataTable({
    
    NonGasGrid <- read_excel(
      "Structure/CurrentWorking.xlsx",
      sheet = "Non-home supplier elec",
      skip = 13
    )
    
    names(NonGasGrid)[1] <- "Quarter"#
    
    NonGasGrid <- NonGasGrid[complete.cases(NonGasGrid),]
    
    NonGasGrid$Quarter <- as.Date(as.numeric(NonGasGrid$Quarter), origin = "1899-12-30")
    
    NonGasGrid$Quarter <- as.character(as.yearqtr(NonGasGrid$Quarter))
    
    
    datatable(
      NonGasGrid,
      extensions = 'Buttons',
      
      rownames = FALSE,
      options = list(
        paging = TRUE,
        pageLength = -1,
        searching = TRUE,
        fixedColumns = FALSE,
        autoWidth = TRUE,
        ordering = TRUE,
        order = list(list(0, 'desc')),
        title = "Proportion of households not on the gas grid by local authority (estimates), Scotland, 2017",
        dom = 'ltBp',
        buttons = list(
          list(extend = 'copy'),
          list(
            extend = 'excel',
            title = 'Proportion of households not on the gas grid by local authority (estimates), Scotland, 2017',
            header = TRUE
          ),
          list(extend = 'csv',
               title = 'Proportion of households not on the gas grid by local authority (estimates), Scotland, 2017')
        ),
        
        # customize the length menu
        lengthMenu = list( c(10, 20, -1) # declare values
                           , c(10, 20, "All") # declare titles
        ), # end of lengthMenu customization
        pageLength = 10
      )
    ) %>%
      formatPercentage(2:9, 1)
  })
  
  
  
  output$Text <- renderUI({
    tagList(column(12,
                   HTML(
                     paste(readtext("Structure/6 - System Security/NonGasGrid.txt")[2])
                     
                   )))
  })
  
  
  observeEvent(input$ToggleTable, {
    toggle("NonGasGridTable")
  })
  
  observeEvent(input$ToggleTable2, {
    toggle("NonGasGridTimeSeriesTable")
  })
  

  
  observeEvent(input$ToggleText, {
    toggle("Text")
  })
  
  
  output$NonGasGrid.png <- downloadHandler(
    filename = "NonGasGrid.png",
    content = function(file) {
      writePNG(readPNG("Structure/6 - System Security/NonGasGridChart.png"), file) 
    }
  )
  
  output$GasGridMap <- renderLeaflet({
    
    ### Load Packages
    library(readr)
    library("maptools")
    library(tmaptools)
    library(tmap)
    library("sf")
    library("leaflet")
    library("rgeos")
    library(readxl)
    library(ggplot2)
    
    print("MapsandGasGrid")
    
    # This is unlikely to change from 2012
    yearstart <- 2012
    
    ### Set the final year for the loop as the current year ###
    yearend <- format(Sys.Date(), "%Y")
    
    
    ### Add Simplified shape back to the Shapefile
    LA <- readOGR("Pre-Upload Scripts/Maps/Shapefile/LocalAuthority2.shp")
    
    LA <- spTransform(LA, CRS("+proj=longlat +datum=WGS84"))
    ############ RENEWABLE ELECTRICITY ################################################
    
    GasGridMap <- read_excel(
      "Structure/CurrentWorking.xlsx",
      sheet = "Non-gas grid by LA",
      skip = 13
    )
    
    GasGridMap <- GasGridMap[c(2,ncol(GasGridMap),5)]
    
    names(GasGridMap) <- c("LocalAuthority", "CODE", "Meters")
    
    GasGridMap <- GasGridMap[which(substr(GasGridMap$CODE, 1,3)== "S12"),]
    
    GasGridMap$Content <- paste0("<b>",GasGridMap$LocalAuthority, "</b><br/>Proportion of households<br/>not on the gas grid:<br/><em>", percent(GasGridMap$Meters, 0.1),"</em>" )
    
    GasGridMap$Hover <- paste0(GasGridMap$LocalAuthority, " - ", percent(GasGridMap$Meters, 0.1))
    
    GasGridMap$Meters <- GasGridMap$Meters*100
    
    
    
    ### Change LA$CODE to string
    LA$CODE <- as.character(LA$CODE)
    
    ### Order LAs in Shapefile
    LA <- LA[order(LA$CODE),]
    
    ### Order LAs in Data
    GasGridMap <- GasGridMap[order(GasGridMap$CODE),]
    
    ### Combine Data with Map data
    LAMap <-
      merge(LA, GasGridMap)
    
    
    pal <- colorNumeric(
      palette = "Reds",
      domain = c(0,100))
    
    leaflet(LAMap) %>% 
      addProviderTiles("Esri.WorldGrayCanvas", ) %>% 
      addPolygons(stroke = TRUE, 
                  weight = 0.1,
                  smoothFactor = 0.2,
                  popup = ~Content,
                  label = ~Hover,
                  fillOpacity = 1,
                  color = ~pal(Meters),
                  highlightOptions = list(color = "white", weight = 2,
                                          bringToFront = TRUE)) %>%
      leaflet::addLegend("bottomright", pal = pal, values = c(0,50,100),
                         title = "Proportion of households<br/>not on the gas grid",
                         labFormat = labelFormat(suffix = "%"),
                         opacity = 1
      ) 
    
  }) 
}
