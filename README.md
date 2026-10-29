# plumber2-and-shiny-example

A minimal example of serving a Shiny app from a plumber2 API, deployed to Posit Connect with API-key authentication, plus an HTML page that displays the app. Tested locally; not yet deployed to Connect.

Classic plumber can't serve Shiny because it has no WebSocket support, and Shiny needs WebSockets. plumber2 can: its `@shiny` tag (or `api_shiny()`) runs the app in a background process and reverse-proxies HTTP and WebSocket traffic to it.

## `plumber2/`

- `_server.yml` marks the folder as a plumber2 API and lists its route files. Connect needs this file to deploy it.
- `plumber.R` defines `/health` and serves the Shiny app at `/my_app/`.
- `shiny/app.R` is the Shiny app.

Run locally from inside `plumber2/`, since the app path `shiny` is resolved from the working directory:

```bash
cd plumber2
Rscript -e 'install.packages(c("plumber2", "shiny", "callr"))'
Rscript -e 'plumber2::api_run(plumber2::api("_server.yml"))'
```

Then open <http://127.0.0.1:8080/my_app/> and <http://127.0.0.1:8080/health>. The Shiny process starts a few seconds after the API.

Deploy to Connect 2025.06.0 or later from the repo root:

```r
rsconnect::deployAPI("plumber2")
```

Connect can run several R processes for one API, and each one starts its own Shiny process. If Shiny sessions drop or reset, set the content item's maximum processes to 1.

## `web/`

`index.html` displays the app in an iframe. Enter the API's URL (`http://127.0.0.1:8080` locally, or the Connect content URL) and click **Load app**; the page loads `<API URL>/my_app/`.

If you also enter an API key, the page first calls `/health` with `Authorization: Key ...` to check it. Leave the key blank to skip the check.

## Authentication caveats

- **Connect checks the API key** before any content code runs, so the key protects every endpoint, including `/my_app/`.
- **An iframe cannot send an `Authorization` header.** The embedded app only loads if the viewer also has a Connect session cookie in that browser, and an admin may need to allow embedding (Connect's frame-options setting; check your server's config).
- **CORS:** if `index.html` is served from a different origin than the API, the browser blocks the `/health` key check unless the API sends CORS headers. On Connect, the preflight request carries no key, so Connect will likely reject it. Serving the page from the same Connect server avoids this.
- **Header-only access:** for a client that only has an API key, put a reverse proxy (nginx, Caddy, or similar) in front that injects the `Authorization` header and forwards WebSocket traffic.
