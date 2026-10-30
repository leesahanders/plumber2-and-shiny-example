library(shiny)

ui <- fluidPage(
  titlePanel("Mock Shiny app"),
  sliderInput("n", "Number of points", min = 10, max = 500, value = 100),
  plotOutput("plot")
)

server <- function(input, output, session) {
  output$plot <- renderPlot(plot(rnorm(input$n), rnorm(input$n)))
}

shinyApp(ui, server)
