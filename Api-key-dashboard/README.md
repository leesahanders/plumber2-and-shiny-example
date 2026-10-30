# Api-key-dashboard

> Disclaimer: Created initially by Claude

A mock-up dashboard where an HTML page gets all its data and plots from a plumber2 API using an API key, the same way as `curl -H "Authorization: Key $CONNECT_API_KEY" <url>`. A Shiny app, also served by the API, sits at the bottom of the page and needs a Connect login instead. Tested locally; not yet deployed to Connect.

## Layout

- `plumber2/_server.yml` marks the folder as a plumber2 API. Connect needs this file to deploy it.
- `plumber2/plumber.R` serves simulated well data:
  - `GET /summary?days=90` returns JSON for the summary tiles.
  - `GET /plot/trend`, `/plot/pressure` and `/plot/scatter`, each with `?days=90`, return PNG plots.
  - `days` must be between 10 and 365; other values get a 400 error.
  - `GET /live` returns the current simulated flow rate, which changes every second.
  - `/my_app/` serves the Shiny app.
- `plumber2/shiny/app.R` is the Shiny app.
- `web/index.html` is the dashboard page:
  - A live widget calls `/live` every second and updates the reading and a one-minute sparkline in place, without reloading the page.
  - The slider re-fetches the tiles and plots when you release it.
  - It remembers the connection, so a reload reconnects without asking again. The API URL is kept in `localStorage`, which survives browser restarts. The key is kept in `sessionStorage`, which lasts until the tab closes, so a kiosk that restarts its browser needs the key re-entered.

## Why the Shiny part needs a login

The page's own JavaScript makes the summary and plot requests, so it can add the `Authorization: Key ...` header to each one. Plots are fetched as data and then displayed, because a plain `<img src>` can't send headers.

The Shiny app is different: the browser loads it in an iframe and then opens a WebSocket, and browsers don't let a page add headers to either. The only credential those requests carry is the Connect login cookie, so the app only appears for viewers who are logged into Connect in that browser.

## Run locally

From inside `plumber2/`, since the app path `shiny` is resolved from the working directory:

```bash
cd plumber2
Rscript -e 'install.packages(c("plumber2", "shiny", "callr", "ragg"))'
Rscript -e 'plumber2::api_run(plumber2::api("_server.yml"))'
```

Try <http://127.0.0.1:8080/summary?days=120> and <http://127.0.0.1:8080/plot/trend?days=120>.

To use the page locally, it has to be served from the same origin as the API. Otherwise the browser blocks the requests, since the API sends no CORS headers. Opening `index.html` from disk and pointing it at port 8080 won't work for the tiles and plots. The Shiny iframe does work that way.

If you stop the API by killing its process, the background Shiny process can keep running. A later run may then proxy to that stale process and show errors such as "cannot change working directory". Find and stop leftover processes with `ps aux | grep callr`.

## Deploy to Connect

Requires Connect 2025.06.0 or later. Run from this folder, with your Connect server registered in rsconnect.

1. Deploy the API with `rsconnect::deployAPI("plumber2")`.
2. Copy the API's **Content URL** from its **Info** panel. It looks like `https://connect.example.com/content/<guid>/`. The API's own content page will be blank, because nothing is served at `/`.
3. Deploy the page with `rsconnect::deployApp("web")`. rsconnect detects it as static content.
4. Open the page on Connect, enter the Content URL and an API key, and click **Load dashboard**. The page and API share an origin on Connect, so no CORS setup is needed.

## Caveats

- **Browser storage is shared across the Connect server.** Any page on the same Connect server can read `localStorage`, which is why only the URL goes there. `sessionStorage` is limited to this tab, but another Connect page opened in the same tab could still read the key.
- **The live widget makes one API request per second per open page.** That's fine for a kiosk or two; for many viewers, slow it down or switch to a push mechanism.
- **The key is visible to anyone who can open the page.** The user types it in this mock-up; if you embed it in the HTML instead, anyone who can view the page can read it. Use a key from a low-privilege account.
- **Licensing:** before using this pattern to give people without Connect accounts access to interactive content, check it against Connect's licensing. Anonymous access to interactive content normally requires the Public Access entitlement.
- **plumber2's Shiny proxy is young.** In local testing the Shiny slider once failed to load its JavaScript, and a reload fixed it. It didn't happen again in four more reloads.
