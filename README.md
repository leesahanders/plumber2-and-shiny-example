# Api-key-dashboard

> Disclaimer: Created initially by Claude

These two projects are different approaches for trying to build and serve a dashboard with content hosted on Connect. 

Both projects1 and 2 have: 

- A dashboard, a simple html page under the /web sub folder. 
- A plumber2 API endpoint serving various analytics. 

Project 3 has: 

- HTML assets for a site generated through shinylive. 

TLDR is that while it is now possible to serve a shiny app from a plumber2 api endpoint, because of the active server component it requires the active authentication to make happen (you can't just rely on an API key). From best I could tell. If others do find a way to do this I'd be very interested! 

Where the docs are for the plumber2 deployed content: open <Content URL>/__docs__/. Click Standalone, then add __docs__/ to the end of the URL. Similarly for the shiny app it's at <Content URL>/my_app/ . 

**Project 1: Dynamic-auth-dashboard**

This project is only serving the shiny webpage inside the html page. In  order to see it the user must log in to the Connect server. 

**Project 2: Api-key-dashboard**

This project is serving just components from the plumber2 API endpoint and anything dynamic is being handled in the html page. So images, etc, are served from the plumber endpoint on Connect and then displayed inside the html page. There is a shiny app on the bottom, in order to see it the user must log in to the Connect server. 

It includes a widget that updates every second and draws a graph (without requiring the page to update). This is a good option for dashboards that would be available in offices or manufacturing floors! 

Now, while the portions at the top are accessed via API key and therefore theoretically able to be accessed on a dashboard visible on an office floor or the like, the API key is embedded in the html and therefore  visible to anyone that views the page which is a security liability and not recommended. for the case of this example it asks for an API key and URL to help prevent secrets from leaking. 

**Project 3: Shinylive dashboard as static content**

Shiny running entirely in the browser via WebAssembly, with no R server at all. It requires setting the site’s access to “Anyone - no login required”. If it is behind a login then the service worker's redirect for auth is broken. 
