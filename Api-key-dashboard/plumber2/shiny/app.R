library(shiny)

set.seed(1)
daily_output <- 1000 + cumsum(rnorm(365, sd = 15))

ui <- fluidPage(
  sliderInput("bins", "Histogram bins", min = 5, max = 50, value = 20),
  plotOutput("hist", height = "300px")
)

server <- function(input, output, session) {
  output$hist <- renderPlot(
    hist(daily_output, breaks = input$bins, xlab = "Output (bbl)", main = "A year of daily output")
  )
}

shinyApp(ui, server)
