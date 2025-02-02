library("shiny")                # For the app iteslf.
library("shinythemes")          # For the "cerulean" theme.
library("shinyhelper")          # Used for help modal boxes.
library("shinyEffects")         # Used for home page effects.
library("shinyanimate")         # Used for home page effects.
library("shinycssloaders")      # For loaders.
library("shinyjs")              # Various UI effects
library("magrittr")             # Dependency of other packages. Lets use the pipe operator (%>%").
library("data.table")           # Needed for function na.omit(").
library("DT")                   # For the interactive tables.
library("dygraphs")             # For the interactive graphs.
library("leaflet")              # For interactive maps.
library("RColorBrewer")         # Used to create a colour palette for the map.
library("rgdal")                # Needed to load shapfile for the map.
library("plyr")                 # Needed for function revalue("), for editing country names.
library("rmarkdown")            # Used for reports, especially important is function render(").
library("knitr")                # Takes Rmd. file and turns it into .md document which includes the R code and its output.
library("networkD3")            # Used to create the sankey diagram.
library("treemap")              # Used to create the static treemap.
library("dplyr")                # Used for data manipulation.
library("ggplot2")              # Used for plots in country and sector profiles.
library("leaflet.minicharts")   # Used to superimpose piecharts on a leaflet map.
library("plotly")               # Used for the streamgraph.
library("ggsci")                # Used for colour palettes.
library("ggflags")              # Expands ggplot with new geom for adding flags.
library("countrycode")          # Enables conversion from Common country names to ISO codes.
library("knitr")                # Used for sector definitions table
library("kableExtra")           # Used for styling the sector definitions table
library("extrafont")            # Extra fonts
library("readtext")
library("htmlwidgets")
library("readxl")
library("gganimate")
library("gifski")
library("readr")
library("maptools")
library("tmaptools")
library("tmap")
library("sf")
library("leaflet")
library("rgeos")
library("shinyWidgets")
library("readxl")
library("lubridate")
library("ggrepel")
library("coda")
library("reshape2")
library("sp")
library("readxl")
library("data.table")
library("plyr")
library("plotly")
library("dygraphs")
library("reshape2")
library("lubridate")
library("xts")
library("RColorBrewer")
library("readr")
library("ggplot2")
library("extrafont")
library("ggflags")
library("png")
library("grid")
library("scales")
library("stringr")
library("dplyr")
library("RColorBrewer")
library("ggrepel")
library("magrittr")
library("tidyr")
library("visNetwork")
library("readr")
library("maptools")
library("tmaptools")
library("tmap")
library("sf")
library("leaflet")
library("rgeos")
library("readxl")
library("ggplot2")
library("foreach")
library("doSNOW")
library("ggthemes")
library(ggrepel)
library(gganimate)
library(LearnBayes)
library(deldir)
library(expm)
library(gdata)
library(gmodels)
library(goftest)
library(gtools)
library(polyclip)
library(spData)
library(spatialEco)
library(spatstat)



js_code <- "
shinyjs.browseURL = function(url) {
  window.open(url,'_blank');
}
"

dir.create('~/.fonts')
file.copy("www/GOTHIC.TTF", "~/.fonts")
system('fc-cache -f ~/.fonts')





