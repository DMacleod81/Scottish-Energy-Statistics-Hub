require(readxl)
require(plotly)
require(dygraphs)
require(png)
require("DT")
###### UI Function ######



EnConsumptionOutput <- function(id) {
  ns <- NS(id)
  tagList(
    tabsetPanel(
      tabPanel("Sector Consumption",
    fluidRow(column(8,
                    h3("Total final energy consumption by sector", style = "color: #1A5D38;  font-weight:bold"),
                    h4(textOutput(ns('EnConsumptionSubtitle')), style = "color: #1A5D38;")
    ),
             column(
               4, style = 'padding:15px;',
               downloadButton(ns('EnConsumption.png'), 'Download Graph', style="float:right")
             )),
    
    tags$hr(style = "height:3px;border:none;color:#1A5D38;background-color:#1A5D38;"),
    #dygraphOutput(ns("EnConsumptionPlot")),
    plotlyOutput(ns("EnConsumptionPlot"), height = "450px")%>% withSpinner(color="#1A5D38"),
    tags$hr(style = "height:3px;border:none;color:#1A5D38;background-color:#1A5D38;")),
    tabPanel("Domestic & Non-domestic",
             fluidRow(column(8,
                             h3("Total final energy consumption domestic and non-domestic", style = "color: #1A5D38;  font-weight:bold"),
                             h4(textOutput(ns('EnConsumptionDomNonDomSubtitle')), style = "color: #1A5D38;")
             ),
             column(
               4, style = 'padding:15px;',
               downloadButton(ns('EnConsumptionDomNonDom.png'), 'Download Graph', style="float:right")
             )),
             
             tags$hr(style = "height:3px;border:none;color:#1A5D38;background-color:#1A5D38;"),
             #dygraphOutput(ns("EnConsumptionPlot")),
             plotlyOutput(ns("EnConsumptionDomNonDomPlot"))%>% withSpinner(color="#1A5D38"),
             tags$hr(style = "height:3px;border:none;color:#1A5D38;background-color:#1A5D38;"))),
    fluidRow(
    column(10,h3("Commentary", style = "color: #1A5D38;  font-weight:bold")),
    column(2,style = "padding:15px",actionButton(ns("ToggleText"), "Show/Hide Text", style = "float:right; "))),
    
    fluidRow(
    uiOutput(ns("Text"))
    ),
    tags$hr(style = "height:3px;border:none;color:#1A5D38;background-color:#1A5D38;"),
    tabsetPanel(
      tabPanel("Consumption by Sector",
               fluidRow(
    column(10, h3("Data - Sector Consumption (GWh)", style = "color: #1A5D38;  font-weight:bold")),
    column(2, style = "padding:15px",  actionButton(ns("ToggleTable"), "Show/Hide Table", style = "float:right; "))
    ),
    fluidRow(
      column(12, dataTableOutput(ns("EnConsumptionTable"))%>% withSpinner(color="#1A5D38"))),
    tags$hr(style = "height:3px;border:none;color:#1A5D38;background-color:#1A5D38;")),
    tabPanel("Domestic and Non-domestic",
             fluidRow(
               column(10, h3("Data - Domestic & Non Domestic (GWh)", style = "color: #1A5D38;  font-weight:bold")),
               column(2, style = "padding:15px",  actionButton(ns("ToggleTable2"), "Show/Hide Table", style = "float:right; "))
             ),
             fluidRow(
               column(12, dataTableOutput(ns("EnConsumptionDomNonDomTable"))%>% withSpinner(color="#1A5D38"))),
             column(12, HTML("<blockquote>
                          <p>* Electricity figures relate to electricity demand (i.e. after electricity own use and losses) rather than gross electricity consumption (generation minus net exports)</p>
                          </blockquote>")),
             tags$hr(style = "height:3px;border:none;color:#1A5D38;background-color:#1A5D38;"))),
    fluidRow(
      column(2, HTML("<p><strong>Last Updated:</strong></p>")),
      column(2,
             UpdatedLookup(c("BEISSubNatEnergy", "BEISUKConsump", "BEISElecGen"))),
      column(1, align = "right",
             HTML("<p><strong>Reason:</strong></p>")),
      column(7, align = "right", 
             p("Regular updates")
      )),
    fluidRow(p(" ")),
    fluidRow(
      column(2, HTML("<p><strong>Update Expected:</strong></p>")),
      column(2,
             DateLookup(c("BEISSubNatEnergy", "BEISUKConsump", "BEISElecGen"))),
      column(1, align = "right",
             HTML("<p><strong>Sources:</strong></p>")),
      column(7, align = "right",
        SourceLookup("BEISSubNatEnergy"),
        SourceLookup("BEISUKConsump"),
        SourceLookup("BEISElecGen")
        
      )
    )
  )
}




###### Server ######

###EXCLUDE MOST RECENT YEAR - Might be needed if some fuels are rolling over but not all.
ExcludeMostRecentYear <- 0

EnConsumption <- function(input, output, session) {

  if (exists("PackageHeader") == 0) {
    source("Structure/PackageHeader.R")
  }
  
  print("EnConsumption.R")
  
  output$EnConsumptionSubtitle <- renderText({
    
    EnConsumption <- read_csv("Processed Data/Output/Consumption/RenEnTgt.csv")
    
    if(ExcludeMostRecentYear == 1){
      EnConsumption <-  EnConsumption[which(EnConsumption$Year < max(EnConsumption$Year)),]
    }
    
    paste("Scotland,",max(as.numeric(EnConsumption$Year), na.rm = TRUE))
  })
 
  output$EnConsumptionPlot <- renderPlotly  ({
    
    EnConsumption <- read_csv("Processed Data/Output/Consumption/RenEnTgt.csv")
    
    if(ExcludeMostRecentYear == 1){
      EnConsumption <-  EnConsumption[which(EnConsumption$Year < max(EnConsumption$Year)),]
    }
    
    
    EnConsumption$Other <- EnConsumption$`Adjusted Consumption` - EnConsumption$`Gross Electricity Consumption` - EnConsumption$`Heat Consumption` - EnConsumption$`Consuming Sector - Transport`
    
    EnConsumption <- select(EnConsumption, Year, `Heat Consumption`, `Consuming Sector - Transport`, `Gross Electricity Consumption`, Other)
    
    names(EnConsumption) <- c("Year", "Heat", "Transport", "Electricity", "Other")
    
    ChartYear <- max(as.numeric(EnConsumption$Year), na.rm = TRUE)
    
    ChartColours <- c("#fc9272", "#2b8cbe", "#34d1a3", "#02818a")
    
    EnConsumption <- melt(EnConsumption, id = "Year")
    EnConsumption <- EnConsumption[which(EnConsumption$Year == ChartYear),]
    
    EnConsumption$variable <- paste0("<b>", EnConsumption$variable, "</b>")
    
    p <- plot_ly(
      data = EnConsumption,
      labels = ~variable,
      type = 'pie',
      values = ~value,
      text = paste0(
        EnConsumption$variable,
        ": ", format(round(EnConsumption$value, 0), big.mark = ","), " GWh" 
      ),
      textposition = 'outside',
      textinfo = 'label+percent',
      insidetextfont = list(color = '#FFFFFF'),
      hoverinfo = 'text',
      marker = list(colors = ChartColours,
                    line = list(color = '#FFFFFF', width = 1))
    )  %>% 
      layout(
        barmode = 'stack',
        legend = list(font = list(color = "#1A5D38"),
                      orientation = 'h'),
        hoverlabel = list(font = list(color = "white"),
                          hovername = 'text'),
        hovername = 'text',
        yaxis = list(title = "",
                     showgrid = FALSE),
        xaxis = list(
          title = "",
          tickformat = "%",
          showgrid = TRUE,
          zeroline = TRUE,
          zerolinecolor = ChartColours[1],
          zerolinewidth = 2,
          rangemode = "tozero"
        )
      ) %>% 
      config(displayModeBar = F)
    
    p
    
    #orca(p, "StaticCharts/EnConsumptionSectorPie.svg")
    
    
    
    
  })
  
  output$EnConsumptionTable = renderDataTable({
    
    EnConsumption <- read_csv("Processed Data/Output/Consumption/RenEnTgt.csv")
    
    if(ExcludeMostRecentYear == 1){
      EnConsumption <-  EnConsumption[which(EnConsumption$Year < max(EnConsumption$Year)),]
    }
    
    EnConsumption$Other <- EnConsumption$`Adjusted Consumption` - EnConsumption$`Gross Electricity Consumption` - EnConsumption$`Heat Consumption` - EnConsumption$`Consuming Sector - Transport`
    
    EnConsumption <- select(EnConsumption, Year, `Heat Consumption`, `Consuming Sector - Transport`, `Gross Electricity Consumption`, Other)
    
    names(EnConsumption) <- c("Year", "Heat", "Transport", "Gross electricity consumption", "Other")
    
    EnConsumption$Total <- EnConsumption$Heat + EnConsumption$Transport + EnConsumption$`Gross electricity consumption` + EnConsumption$Other
    

    
    datatable(
      EnConsumption,
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
        title = "Total final energy consumption by sector (GWh)",
        dom = 'ltBp',
        buttons = list(
          list(extend = 'copy'),
          list(
            extend = 'excel',
            title = 'Total final energy consumption by sector (GWh)',
            header = TRUE
          ),
          list(extend = 'csv',
               title = 'Total final energy consumption by sector (GWh)')
        ),
        
        # customize the length menu
        lengthMenu = list( c(10, 20, -1) # declare values
                           , c(10, 20, "All") # declare titles
        ), # end of lengthMenu customization
        pageLength = 10
      )
    ) %>%
      formatRound(2:ncol(EnConsumption), 0)
  })
  
  
  output$Text <- renderUI({
    tagList(column(12,
                   
                   HTML(
                     paste(readtext("Structure/1 - Whole System/EnConsumption.txt")[2])
                     
                   )))
  })
  
  observeEvent(input$ToggleTable, {
    toggle("EnConsumptionTable")
  })
  
  observeEvent(input$ToggleTable2, {
    toggle("EnConsumptionDomNonDomTable")
  })
  
  observeEvent(input$ToggleText, {
    toggle("Text")
  })
  
  
  output$EnConsumption.png <- downloadHandler(
    filename = "EnConsumption.png",
    content = function(file) {

writePNG(
  readPNG(
  "Structure/1 - Whole System/EnConsumptionSectorChart.png"
),
file)
    }
  )
  
  output$EnConsumptionDomNonDomPlot <- renderPlotly  ({
    
    EnConsumptionDomNonDom <- read_csv("Processed Data/Output/Consumption/TotalFinalConsumption.csv")
    
    if(ExcludeMostRecentYear == 0){
      EnConsumptionDomNonDom <-  EnConsumptionDomNonDom[which(EnConsumptionDomNonDom$Year < max(EnConsumptionDomNonDom$Year)),]
    }
    
    EnConsumptionDomNonDom <- EnConsumptionDomNonDom[which(EnConsumptionDomNonDom$`LA Code`== "S92000003"),]
    
    EnConsumptionDomNonDom <- select(EnConsumptionDomNonDom, Year, `Consuming Sector - Domestic`, `Consuming Sector - Industry & Commercial`)
    
    names(EnConsumptionDomNonDom) <- c("Year", "Domestic", "Non-domestic")
    
    ChartYear <- max(EnConsumptionDomNonDom$Year)
    
    ChartColours <- c("#34d1a3", "#2b8cbe")
    
    EnConsumptionDomNonDom <- melt(EnConsumptionDomNonDom, id = "Year")
    EnConsumptionDomNonDom <- EnConsumptionDomNonDom[which(EnConsumptionDomNonDom$Year == ChartYear),]
    
    EnConsumptionDomNonDom$variable <- paste0("<b>", EnConsumptionDomNonDom$variable, "</b>")
    
    p <- plot_ly(
      data = EnConsumptionDomNonDom,
      labels = ~variable,
      type = 'pie',
      values = ~value,
      text = paste0(
        EnConsumptionDomNonDom$variable,
        ": ", format(round(EnConsumptionDomNonDom$value,1), big.mark = ","), " GWh" 
      ),
      textposition = 'inside',
      textinfo = 'label+percent',
      insidetextfont = list(color = '#FFFFFF'),
      hoverinfo = 'text',
      marker = list(colors = ChartColours,
                    line = list(color = '#FFFFFF', width = 1))
    )  %>% 
      layout(
        barmode = 'stack',
        legend = list(font = list(color = "#1A5D38"),
                      orientation = 'h'),
        hoverlabel = list(font = list(color = "white"),
                          hovername = 'text'),
        hovername = 'text',
        yaxis = list(title = "",
                     showgrid = FALSE),
        xaxis = list(
          title = "",
          tickformat = "%",
          showgrid = TRUE,
          zeroline = TRUE,
          zerolinecolor = ChartColours[1],
          zerolinewidth = 2,
          rangemode = "tozero"
        )
      ) %>% 
      config(displayModeBar = F)
    
    p
    
    #orca(p, "StaticCharts/EnConsumptionPie.svg") # Run Manually from Code

  })
  
  output$EnConsumptionDomNonDom.png <- downloadHandler(
    filename = "EnConsumptionDomNonDom.png",
    content = function(file) {
      
      writePNG(
        readPNG(
          "Structure/1 - Whole System/EnConsumptionSectorDomNonDomChart.png"
        ),
        file)
    }
  )
  
  output$EnConsumptionDomNonDomSubtitle <- renderText({
    
    EnConsumptionDomNonDom <- read_csv("Processed Data/Output/Consumption/TotalFinalConsumption.csv")
    
    if(ExcludeMostRecentYear == 1){
      EnConsumptionDomNonDom <-  EnConsumptionDomNonDom[which(EnConsumptionDomNonDom$Year < max(EnConsumptionDomNonDom$Year)),]
    }
    
    EnConsumptionDomNonDom <- EnConsumptionDomNonDom[which(EnConsumptionDomNonDom$`LA Code`== "S92000003"),]
    
    EnConsumptionDomNonDom <- select(EnConsumptionDomNonDom, Year, `Consuming Sector - Domestic`, `Consuming Sector - Industry & Commercial`)
    
    names(EnConsumptionDomNonDom) <- c("Year", "Domestic", "Non-domestic")
    
    paste(max(as.numeric(EnConsumptionDomNonDom$Year), na.rm = TRUE))
  })
  
  output$EnConsumptionDomNonDomTable = renderDataTable({
    
    EnConsumptionDomNonDom <- read_csv("Processed Data/Output/Consumption/TotalFinalConsumption.csv")
    
    if(ExcludeMostRecentYear == 1){
      EnConsumptionDomNonDom <-  EnConsumptionDomNonDom[which(EnConsumptionDomNonDom$Year < max(EnConsumptionDomNonDom$Year)),]
    }
    
    EnConsumptionDomNonDom <- EnConsumptionDomNonDom[which(EnConsumptionDomNonDom$`LA Code`== "S92000003"),]
    
    EnConsumptionDomNonDom$NonDomElec <- EnConsumptionDomNonDom$`Electricity - Industrial` + EnConsumptionDomNonDom$`Electricity - Commercial`
    
    EnConsumptionDomNonDom <- select(EnConsumptionDomNonDom, Year,`Electricity - Domestic`, `Electricity - Industrial & Commercial`, `Consuming Sector - Domestic`, `Consuming Sector - Industry & Commercial`)
    
    HeatConsumptionbyLA <- read_csv("Processed Data/Output/Consumption/HeatConsumptionbyLA.csv")
    
    if(ExcludeMostRecentYear == 1){
      HeatConsumptionbyLA <-  HeatConsumptionbyLA[which(HeatConsumptionbyLA$Year < max(HeatConsumptionbyLA$Year)),]
    }
    
    HeatConsumptionbyLA <- HeatConsumptionbyLA[which(HeatConsumptionbyLA$`LA Code`== "S92000003"),]
    
    HeatConsumptionbyLA$Domestic <- HeatConsumptionbyLA$`Coal - Domestic` + HeatConsumptionbyLA$`Manufactured fuels - Domestic`+HeatConsumptionbyLA$`Petroleum products - Domestic` + HeatConsumptionbyLA$`Gas - Domestic` + HeatConsumptionbyLA$`Bioenergy & wastes - Domestic`
  
    HeatConsumptionbyLA$NonDomestic <- HeatConsumptionbyLA$Total - HeatConsumptionbyLA$Domestic
    
    HeatConsumptionbyLA <- select(HeatConsumptionbyLA, Year, `Domestic`, `NonDomestic`)
    
    EnConsumptionDomNonDom <- merge(HeatConsumptionbyLA, EnConsumptionDomNonDom)
    
    names(EnConsumptionDomNonDom) <- c("Year", "Heat - Domestic", "Heat - Non-Domestic ", "Electricity - Domestic", "Electricity - Non-Domestic ", "Total - Domestic", "Toal - Non-Domestic ")
    
    
   datatable(
      EnConsumptionDomNonDom,
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
        title = "Total final energy consumption by sector, domestic and non-domestic (GWh)",
        dom = 'ltBp',
        buttons = list(
          list(extend = 'copy'),
          list(
            extend = 'excel',
            title = 'Total final energy consumption by sector, domestic and non-domestic (GWh)',
            header = TRUE
          ),
          list(extend = 'csv',
               title = 'Total final energy consumption by sector, domestic and non-domestic (GWh)')
        ),
        
        # customize the length menu
        lengthMenu = list( c(10, 20, -1) # declare values
                           , c(10, 20, "All") # declare titles
        ), # end of lengthMenu customization
        pageLength = 10
      )
    ) %>%
      formatRound(2:ncol(EnConsumptionDomNonDom), 0)
  })
  

}

