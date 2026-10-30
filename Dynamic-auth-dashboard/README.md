# plumber2-and-shiny-example

> Disclaimer: Created initially by Claude

A minimal example of serving a Shiny app from a plumber2 API, deployed to Posit Connect with API-key authentication, plus a static HTML page, also on Connect, that displays the app. The API and Shiny app are confirmed working on Connect; the HTML page has only been tested locally.

Classic plumber can't serve Shiny because it has no WebSocket support, and Shiny needs WebSockets. plumber2 can: its `@shiny` tag (or `api_shiny()`) runs the app in a background process and reverse-proxies HTTP and WebSocket traffic to it.

## `plumber2/`

- `_server.yml` marks the folder as a plumber2 API and lists its route files. Connect needs this file to deploy it.
- `plumber.R` defines `/health`, serves the Shiny app at `/my_app/`, and redirects `/` to `my_app/`. Without the redirect, the root returns an empty 404, which Connect's content page shows as a blank page.
- `shiny/app.R` is the Shiny app.

Run locally from inside `plumber2/`, since the app path `shiny` is resolved from the working directory:

```bash
cd plumber2
Rscript -e 'install.packages(c("plumber2", "shiny", "callr"))'
Rscript -e 'plumber2::api_run(plumber2::api("_server.yml"))'
```

Then open <http://127.0.0.1:8080/my_app/> and <http://127.0.0.1:8080/health>. The Shiny process starts a few seconds after the API.

## `web/`

`index.html` displays the app in an iframe. Enter the API's URL (`http://127.0.0.1:8080` locally, or the Connect content URL) and click **Load app**; the page loads `<API URL>/my_app/`.

If you also enter an API key, the page first calls `/health` with `Authorization: Key ...` to check it. Leave the key blank to skip the check.

## Deploy to Connect

Requires Connect 2025.06.0 or later. Run from the repo root, with your Connect server already registered in rsconnect.

1. Deploy the API:

   ```r
   rsconnect::deployAPI("plumber2")
   ```

2. Open the API in Connect. Its content page should redirect to the Shiny app. Then open the API's **Info** panel and copy its **Content URL**, which looks like `https://connect.example.com/content/<guid>/`. Don't use the dashboard URL (`.../connect/#/apps/...`); the page can't load the app from that.
3. Deploy the page as static content:

   ```r
   rsconnect::deployApp("web")
   ```

4. Give both items the same access setting (for example, "All users - login required"), so anyone who can open the page can also load the app.
5. Open the page on Connect, paste the Content URL, and click **Load app**. To test the key check, create an API key from your Connect user menu and enter it too.

The page and the API are on the same Connect server, so the `/health` key check needs no CORS headers. The iframe is same-origin as well, which should get past Connect's default frame protection.

Connect can run several R processes for one API, and each one starts its own Shiny process. If Shiny sessions drop or reset, set the API's maximum processes to 1 in its **Runtime** settings.

## Authentication caveats

- **Connect checks the API key** before any content code runs, so the key protects every endpoint, including `/my_app/`.
- **An iframe cannot send an `Authorization` header.** The embedded app only loads if the viewer is also logged into Connect in that browser.
- **CORS:** if `index.html` is served from a different origin than the API (for example, opened locally against the Connect API), the browser blocks the `/health` key check. Deploying the page to the same Connect server avoids this.
- **Header-only access:** for a client that only has an API key, put a reverse proxy (nginx, Caddy, or similar) in front that injects the `Authorization` header and forwards WebSocket traffic.
