#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

renv::load("./")
library("shiny")
library("shinyFiles")
library("tidyverse")
library("exifr")
library("leaflet")

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Check images from UAV flight"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      shinyDirButton("dir", "Please select an input directory", "Upload"),
      textInput("extension", "Extension", "*1.tif"), width = 4
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      leafletOutput("leafCoord", height = "100vh"), width = 8
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  volumes = getVolumes()()
  shinyDirChoose(
    input,
    'dir',
    roots = volumes 
  )
  
  #path <- reactive({
  #  return(file.path(paste((input$dir$path), collapse = .Platform$file.sep)))
  #})
  
  path <- renderText({parseDirPath(roots = volumes, input$dir)})
  
  ext <- renderText({ input$extension })
  
  output$leafCoord <- renderLeaflet({
    
    # Find files in folder - with certain extension
    droneImages <- list.files(path = path(), pattern = ext(), recursive = TRUE,  full.names = T)

    # Read metadata of drone images
    exifr::read_exif(path = droneImages) %>%
      select(SourceFile,
             GPSLongitude, GPSLatitude) %>% 
      leaflet() %>% 
      addProviderTiles("Esri.WorldImagery") %>%
      addCircleMarkers(~ GPSLongitude, ~ GPSLatitude, radius = 5, color = "red", stroke = F)  

  })
}

# Run the application 
shinyApp(ui = ui, server = server)
