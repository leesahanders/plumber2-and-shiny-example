# Api-key-dashboard

> Disclaimer: Created initially by Claude

These two projects are different approaches for trying to build and serve a dashboard with content hosted on Connect. 

Both projects have: 

- A dashboard, a simple html page under the /web sub folder. 
- A plumber2 API endpoint serving various analytics 

TLDR is that while it is now possible to serve a shiny app from a plumber2 api endpoint, because of the active server component it requires the active authentication to make happen (you can't just rely on an API key). From best I could tell. If others do find a way to do this I'd be very interested! 

**Project 1: Api-key-dashboard**

This project is serving just components from the plumber2 API endpoint and anything dynamic is being handled in the html page. So images, etc, are served from the plumber endpoint on Connect and then displayed inside the html page. There is a shiny app on the bottom, in order to see it the user must log in to the Connect server. 

**Project 2: Dynamic-auth-dashboard**

This project is only serving the shiny webpage inside the html page. In  order to see it the user must log in to the Connect server. 

