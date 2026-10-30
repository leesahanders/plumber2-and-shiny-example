# Simulated daily well data. The seed is fixed so every endpoint sees the same data.
well_data <- function(days) {
  set.seed(1)
  data.frame(
    day = seq_len(days),
    output = 1000 + cumsum(rnorm(days, sd = 15)),
    pressure = rnorm(days, mean = 3000, sd = 120)
  )
}

#* Summary numbers for the dashboard tiles
#* @get /summary
#* @query days:integer|10,365|(90)
#* @serializer json{auto_unbox = TRUE}
function(query) {
  d <- well_data(query$days)
  list(
    days = query$days,
    avg_output = round(mean(d$output)),
    latest_output = round(tail(d$output, 1)),
    avg_pressure = round(mean(d$pressure))
  )
}

#* Daily output over time
#* @get /plot/trend
#* @query days:integer|10,365|(90)
#* @serializer png{width = 480, height = 320}
function(query) {
  d <- well_data(query$days)
  plot(d$day, d$output, type = "l", xlab = "Day", ylab = "Output (bbl)", main = "Daily output")
}

#* Distribution of wellhead pressure
#* @get /plot/pressure
#* @query days:integer|10,365|(90)
#* @serializer png{width = 480, height = 320}
function(query) {
  d <- well_data(query$days)
  hist(d$pressure, xlab = "Pressure (psi)", main = "Pressure distribution", col = "grey80")
}

#* Output against pressure
#* @get /plot/scatter
#* @query days:integer|10,365|(90)
#* @serializer png{width = 480, height = 320}
function(query) {
  d <- well_data(query$days)
  plot(d$pressure, d$output, xlab = "Pressure (psi)", ylab = "Output (bbl)", main = "Output vs pressure")
}

# Everything under /my_app/ is reverse-proxied to a Shiny app that plumber2 runs
# in a background process. "shiny" is resolved from the working directory, so
# start the API from this folder.
#* @shiny /my_app/
shiny::shinyAppDir("shiny")
