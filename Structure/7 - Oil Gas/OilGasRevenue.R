require(readxl)
require(plotly)
require(dygraphs)
require(png)
require("DT")
###### UI Function ######



OilGasRevenueOutput <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(column(8,
                    h3("Oil and gas revenue", style = "color: #126992;  font-weight:bold"),
                    h4(textOutput(ns('OilGasRevenueSubtitle')), style = "color: #126992;")
    ),
             column(
               4, style = 'padding:15px;',
               downloadButton(ns('OilGasRevenue.png'), 'Download Graph', style="float:right")
             )),
    
    tags$hr(style = "height:3px;border:none;color:#126992;background-color:#126992;"),
    #dygraphOutput(ns("OilGasRevenuePlot")),
    plotlyOutput(ns("OilGasRevenuePlot"))%>% withSpinner(color="#126992"),
    tags$hr(style = "height:3px;border:none;color:#126992;background-color:#126992;"),
    fluidRow(
    column(10,h3("Commentary", style = "color: #126992;  font-weight:bold")),
    column(2,style = "padding:15px",actionButton(ns("ToggleText"), "Show/Hide Text", style = "float:right; "))),
    
    fluidRow(
    uiOutput(ns("Text"))
    ),
    tags$hr(style = "height:3px;border:none;color:#126992;background-color:#126992;"),
               fluidRow(
    column(10, h3("Data", style = "color: #126992;  font-weight:bold")),
    column(2, style = "padding:15px",  actionButton(ns("ToggleTable"), "Show/Hide Table", style = "float:right; "))
    ),
    fluidRow(
      column(12, dataTableOutput(ns("OilGasRevenueTable"))%>% withSpinner(color="#126992"))),
    tags$hr(style = "height:3px;border:none;color:#126992;background-color:#126992;"),
    fluidRow(
      column(2, HTML("<p><strong>Last Updated:</strong></p>")),
      column(2,
             UpdatedLookup(c("SGOilGasProd"))),
      column(1, align = "right",
             HTML("<p><strong>Reason:</strong></p>")),
      column(7, align = "right", 
             p("Regular updates")
      )),
    fluidRow(p(" ")),
    fluidRow(
      column(2, HTML("<p><strong>Update Expected:</strong></p>")),
      column(2,
             DateLookup(c("SGOilGasProd"))),
      column(1, align = "right",
             HTML("<p><strong>Sources:</strong></p>")),
      column(7, align = "right",
        SourceLookup("SGOilGasProd")
        
      )
    )
  )
}




###### Server ######
OilGasRevenue <- function(input, output, session) {
  
  
  if (exists("PackageHeader") == 0) {
    source("Structure/PackageHeader.R")
  }
  
  print("OilGasRevenue.R")

  
  output$OilGasRevenueSubtitle <- renderText({
    
    Data <- read_excel("Structure/CurrentWorking.xlsx", 
                       sheet = "Oil and gas sales revenue", skip = 13, col_names = TRUE)[1:2]
    
    
    names(Data) <- c("Year", "Revenue")
    
    OilGasRevenue <- Data
    
    OilGasRevenue$Year <- as.numeric(substr(OilGasRevenue$Year, 1,4))

    paste0("Scotland, ", min(OilGasRevenue$Year),"/",substr(min(OilGasRevenue$Year)+1,3,4)," - ",  max(OilGasRevenue$Year),"/",substr(max(OilGasRevenue$Year)+1,3,4))
  })
  
  output$OilGasRevenuePlot <- renderPlotly  ({
    
    
    Data <- read_excel("Structure/CurrentWorking.xlsx", 
                       sheet = "Oil and gas sales revenue", skip = 13, col_names = TRUE)[1:2]
    
    
    names(Data) <- c("Year", "Revenue")
    
    Data$Year <- factor(Data$Year, ordered = TRUE)
    
    OilGasRevenue <- Data
    
    
    ### variables
    ChartColours <- c("#126992", "#1d91c0", "#7fcdbb", "#8da0cb")
    sourcecaption = "Source: Scottish Government"
    plottitle = "International sales from oil and gas supply chain"
    
    
    p <-  plot_ly(OilGasRevenue,x = ~ Year ) %>% 
      add_trace(data = OilGasRevenue,
                x = ~ Year,
                y = ~ Revenue,
                name = "Revenue",
                type = 'scatter',
                mode = 'lines',
                legendgroup = "1",
                text = paste0(
                  "Revenue: \u00A3",
                  round(OilGasRevenue$Revenue, digits = 3),
                  " billion\nYear: ",
                  paste(OilGasRevenue$Year)
                ),
                hoverinfo = 'text',
                line = list(width = 6, color = ChartColours[1], dash = "none")
      )  %>% 
      add_trace(
        data = tail(OilGasRevenue[which(OilGasRevenue$Revenue > 0 | OilGasRevenue$Revenue < 0),], 1),
        x = ~ Year,
        y = ~ Revenue,
        legendgroup = "1",
        name = "Total",
        text = paste0(
          "Revenue: \u00A3",
          round(OilGasRevenue[which(OilGasRevenue$Revenue > 0 | OilGasRevenue$Revenue < 0),][-1,]$Revenue, digits = 3),
          " billion\nYear: ",
          paste(OilGasRevenue[which(OilGasRevenue$Revenue > 0 | OilGasRevenue$Revenue < 0),][-1,]$Year)
        ),
        hoverinfo = 'text',
        showlegend = FALSE ,
        type = "scatter",
        mode = 'markers',
        marker = list(size = 18, 
                      color = ChartColours[1])
      )  %>%  
      layout(
        barmode = 'stack',
        bargap = 0.66,
        legend = list(font = list(color = "#126992"),
                      orientation = 'h'),
        hoverlabel = list(font = list(color = "white"),
                          hovername = 'text'),
        hovername = 'text',

        xaxis = list(title = "Financial Year",
                     showgrid = FALSE),
        yaxis = list(
          title = "\u00A3 Billion",
          tickformat = "",
          showgrid = TRUE,
          zeroline = TRUE,
          zerolinecolor = ChartColours[1],
          zerolinewidth = 2,
          rangemode = "tozero"
        )
      ) %>% 
      config(displayModeBar = F)
    p
    
    
    
  })
  
  
  output$OilGasRevenueTable = renderDataTable({
    
    Data <- read_excel("Structure/CurrentWorking.xlsx", 
                       sheet = "Oil and gas sales revenue", skip = 13, col_names = TRUE)[1:15]
    
    
    names(Data) <- c("Financial Year", "Sales Revenue (\u00A3 Billion)", "Proportion of UK Total",
                     "of which: crude oil & NGL sales",	"Proportion of UK total", 	
                     "of which: natural gas sales",	"Proportion of UK total", 	
                     "Other Income",	"Proportion of UK total", 	
                     "Operating Expenditure", 	"Proportion of UK total", 	
                     "Capital Expenditure inc decommissioning", 	"Proportion of UK total", 
                     "Of which: Decommissioning Expenditure",	"Proportion of UK total" 
)
    
    Data$`Financial Year` <- factor(Data$`Financial Year`, ordered = TRUE)
    
    OilGasRevenue <- Data
    
    datatable(
      OilGasRevenue,
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
        title = "Oil and gas revenue (\u00A3 billion)",
        dom = 'ltBp',
        buttons = list(
          list(extend = 'copy'),
          list(
            extend = 'excel',
            title = 'Oil and gas revenue (\u00A3 billion)',
            header = TRUE
          ),
          list(extend = 'csv',
               title = 'Oil and gas revenue (\u00A3 billion)')
        ),
        
        # customize the length menu
        lengthMenu = list( c(10, 20, -1) # declare values
                           , c(10, 20, "All") # declare titles
        ), # end of lengthMenu customization
        pageLength = 10
      )
    ) %>%
      formatRound(c(2,4,6,8,10,12,14), 3) %>% 
      formatPercentage(c(3,5,7,9,11,13,15),0)
  })
  

 output$Text <- renderUI({
   tagList(column(12,
                                   
                                     HTML(
                                       paste(readtext("Structure/7 - Oil Gas/OilGasRevenue.txt")[2])
                                     
                                   )))
 })
 
 
  observeEvent(input$ToggleTable, {
    toggle("OilGasRevenueTable")
  })
  
  
  observeEvent(input$ToggleText, {
    toggle("Text")
  })
  
  
  output$OilGasRevenue.png <- downloadHandler(
    filename = "OilGasRevenue.png",
    content = function(file) {


      Data <- read_excel("Structure/CurrentWorking.xlsx", 
                         sheet = "Oil and gas sales revenue", skip = 13, col_names = TRUE)[1:2]
      
      
      names(Data) <- c("Year", "Revenue")
      
      OilGasRevenue <- Data
      
      OilGasRevenue$Year <- as.numeric(substr(OilGasRevenue$Year, 1,4))
      
      ### variables
      ChartColours <- c("#126992", "#66c2a5", "#fc8d62", "#8da0cb")
      sourcecaption = "Source: Scottish Government"
      plottitle = "Oil and gas sales revenue"
      
      #OilGasRevenue$OilPercentage <- PercentLabel(OilGasRevenue$Oil)
      
      
      OilGasRevenueChart <- OilGasRevenue %>%
        ggplot(aes(x = Year), family = "Century Gothic") +
        
        geom_line(
          aes(
            y = Revenue,
            colour = ChartColours[2],
            label = percent(Revenue, 0.1)
          ),
          size = 1.5,
          family = "Century Gothic"
        ) +
        geom_text(
          aes(
            x = Year,
            y = Revenue,
            label = ifelse(Year == min(Year), paste0("\u00A3", format(round(Revenue, digits = 1),nsmall = 1, trim = TRUE), " billion"), ""),
            hjust = 0.5,
            vjust = 2.2,
            colour = ChartColours[2],
            fontface = 2
          ),
          family = "Century Gothic"
        ) +
        geom_text(
          aes(
            x = Year,
            y = Revenue,
            label = ifelse(Year == max(Year), paste0("\u00A3", format(round(Revenue, digits = 1),nsmall = 1, trim = TRUE), " billion"), ""),
            hjust = 0.5,
            vjust = -1,
            colour = ChartColours[2],
            fontface = 2
          ),
          family = "Century Gothic"
        ) +
        geom_point(
          data = tail(OilGasRevenue, 1),
          aes(
            x = Year,
            y = Revenue,
            colour = ChartColours[2],
            show_guide = FALSE
          ),
          size = 4,
          family = "Century Gothic"
        ) +
        geom_text(
          aes(
            x = mean(Year),
            y = mean(Revenue),
            label = "Revenue",
            hjust = 0.5,
            vjust = -.5,
            colour = ChartColours[2],
            fontface = 2
          ),
          family = "Century Gothic"
        ) +
        geom_text(
          aes(
            x = Year,
            y = 0,
            label = ifelse(Year == max(Year) |
                             Year == min(Year), paste0(Year,"/",substr(Year+1, 3,4)), ""),
            hjust = 0.5,
            vjust = 1.5,
            fontface = 2
          ),
          colour = ChartColours[1],
          family = "Century Gothic"
        )
      
      
      OilGasRevenueChart <-
        LinePercentChart(OilGasRevenueChart,
                         OilGasRevenue,
                         plottitle,
                         sourcecaption,
                         ChartColours)
      
      OilGasRevenueChart <- OilGasRevenueChart +
        xlim(min(OilGasRevenue$Year) -1 , max(OilGasRevenue$Year) +1)+
        ylim(-1,max(OilGasRevenue$Revenue))+
        labs(subtitle = paste0("Scotland, ",min(OilGasRevenue$Year),"/",substr(min(OilGasRevenue$Year)+1,3,4), " - ", max(OilGasRevenue$Year), "/",substr(max(OilGasRevenue$Year)+1,3,4), " (Financial Years)"))
      
      OilGasRevenueChart
      
      ggsave(
        file,
        plot =  OilGasRevenueChart,
        width = 26,
        height = 12,
        units = "cm",
        dpi = 300
      )
      
      
    }
  )
}
