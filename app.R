#######Load packages #######

library("shiny")
library("shinyFiles")
library("dplyr")
library("exifr")
library("leaflet")
library("tm")
library("rsconnect")

####### UI  #######

ui <- fluidPage(
  
  # Application title
  titlePanel("Check images from UAV flight"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      fileInput("dir", "Please select an input directory", multiple = TRUE, ),
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      leafletOutput("leafCoord", height = "100vh"), width = 8
    )
  )
)

####### Server  #######
server <- function(input, output) {
  
  # Get path of uploaded files
  list_of_files <- eventReactive(input$dir, {

    return(as.character(input$dir$datapath))
  })
  
  output$leafCoord <- renderLeaflet({
    
    # Read metadata of drone images
    exifr::read_exif(path = list_of_files()) %>%
      select(SourceFile,
             GPSLongitude, GPSLatitude) %>% 
      leaflet() %>% 
      addProviderTiles("Esri.WorldImagery") %>%
      addCircleMarkers(~ GPSLongitude, ~ GPSLatitude, radius = 5, color = "red", stroke = F)  

  })
}

####### RUN !!!  #######
shinyApp(ui = ui, server = server)
