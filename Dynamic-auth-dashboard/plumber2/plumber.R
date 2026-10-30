library(plumber2)
library(shiny)

# Send the root URL to the app, so Connect's content page shows it. The target is
# relative because on Connect the API lives under /content/<guid>/, not at /.
#* @redirect get / my_app/
NULL

#* Health check
#* @get /health
function() {
  list(status = "ok")
}

# Everything under /my_app/ is reverse-proxied to a Shiny app that plumber2 runs
# in a background process (requires the shiny and callr packages).
# "shiny" is resolved from the working directory, so start the API from this folder.
#* @shiny /my_app/
shiny::shinyAppDir("shiny")
