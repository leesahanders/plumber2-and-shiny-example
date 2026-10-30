library(shiny)

# Simulated daily well data, the same as the API example. The seed is fixed so
# every output sees the same data.
well_data <- function(days) {
  set.seed(1)
  data.frame(
    day = seq_len(days),
    output = 1000 + cumsum(rnorm(days, sd = 15)),
    pressure = rnorm(days, mean = 3000, sd = 120)
  )
}

# Simulated flow rate, computed from the clock so it changes smoothly.
flow_rate <- function(t = as.numeric(Sys.time())) {
  round(500 + 25 * sin(t / 5) + 8 * sin(t / 1.3), 1)
}

tile <- function(label, id, unit) {
  column(4, wellPanel(label, h2(textOutput(id, inline = TRUE)), unit))
}

ui <- fluidPage(
  titlePanel("Well dashboard (Shinylive)"),
  p("This app runs entirely in your browser via WebAssembly. There is no R server behind it."),

  h3("Live flow rate (updates every second)"),
  h2(textOutput("live", inline = TRUE)),
  plotOutput("spark", height = "80px"),

  h3("Production"),
  sliderInput("days", "Days of data", min = 10, max = 365, value = 90),
  fluidRow(
    tile("Average output", "avg_output", "bbl/day"),
    tile("Latest output", "latest_output", "bbl/day"),
    tile("Average pressure", "avg_pressure", "psi")
  ),
  fluidRow(
    column(4, plotOutput("trend", height = "280px")),
    column(4, plotOutput("pressure", height = "280px")),
    column(4, plotOutput("scatter", height = "280px"))
  )
)

server <- function(input, output, session) {
  d <- reactive(well_data(input$days))
  fmt <- function(x) format(round(x), big.mark = ",")

  output$avg_output <- renderText(fmt(mean(d()$output)))
  output$latest_output <- renderText(fmt(tail(d()$output, 1)))
  output$avg_pressure <- renderText(fmt(mean(d()$pressure)))

  output$trend <- renderPlot(
    plot(d()$day, d()$output, type = "l", xlab = "Day", ylab = "Output (bbl)", main = "Daily output")
  )
  output$pressure <- renderPlot(
    hist(d()$pressure, xlab = "Pressure (psi)", main = "Pressure distribution", col = "grey80")
  )
  output$scatter <- renderPlot(
    plot(d()$pressure, d()$output, xlab = "Pressure (psi)", ylab = "Output (bbl)", main = "Output vs pressure")
  )

  # Live widget: take a reading every second and keep the last minute.
  readings <- reactiveVal(numeric())
  observe({
    invalidateLater(1000)
    readings(tail(c(isolate(readings()), flow_rate()), 60))
  })

  output$live <- renderText(paste(tail(readings(), 1), "bbl/h at", format(Sys.time(), "%H:%M:%S")))
  output$spark <- renderPlot({
    par(mar = c(0.5, 0.5, 0.5, 0.5))
    plot(readings(), type = "l", col = "#2a6ebb", lwd = 2, axes = FALSE, xlab = "", ylab = "")
  })
}

shinyApp(ui, server)
