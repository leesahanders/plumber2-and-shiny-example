# Shinylive-dashboard

> Disclaimer: Created initially by Claude

The well dashboard from `Api-key-dashboard`, rebuilt as a Shinylive app. It runs entirely in the browser via WebAssembly (webR), with no R server, no API and no API key. It deploys to Connect as static content, which can be shared with "Anyone - no login required". Tested locally and on Connect with "Anyone - no login required" access.

## Layout

- `app/app.R` is a regular Shiny app:
  - A live flow-rate reading and sparkline that update every second.
  - A days slider driving three summary tiles and three plots, using the same simulated data as the API example.
- `site/` is created by the export step below, and holds the files you deploy. `.gitignore` excludes it.

## Export and preview locally

From this folder:

```bash
Rscript -e 'install.packages(c("shiny", "shinylive", "httpuv"))'
Rscript -e 'shinylive::export("app", "site")'
Rscript -e 'httpuv::runStaticServer("site")'
```

The first export downloads the Shinylive assets (about 670 MB unzipped) into a local cache. The exported `site/` folder is about 66 MB.

Open the URL `runStaticServer` prints. The first load takes several seconds while the browser downloads and starts R. Shinylive needs service workers, so it won't run from a `file://` path or in browsers that block them.

Preview on your own machine, not in Workbench. Workbench's proxy requires a login, so the app shows a spinner forever (see [Must be public](#must-be-public-no-login) below).

## Deploy to Connect

```r
rsconnect::deployApp("site")
```

rsconnect detects `site/` as static content with `index.html` as the primary document. Re-export before each deploy after changing `app/app.R`.

Then, in the content's Access settings, set "Anyone - no login required". With any login-required setting the page stays blank (see below).

## Must be public (no login)

Shinylive only works when nothing in front of it requires a login. It installs a service worker from `shinylive-sw.js`. Behind a login, such as Connect content restricted to logged-in users or a Workbench session proxy, the server answers that request with a 302 redirect. Browsers refuse to install a service worker from a redirect, so the app never starts. Connect shows a blank page, and Workbench shows the loading spinner forever. The browser console shows "Service Worker registration failed" followed by "ServiceWorker controller was not found!", and the Network tab shows `shinylive-sw.js` with status 302.

That suits the anonymous kiosk use case, but it means a Shinylive app on Connect can't be limited to logged-in users.

## Why this avoids the login and licensing issues

According to Connect's docs, Shinylive counts as static hosting: Connect serves the files and runs no code. "Anyone - no login required" is allowed for static content on all licenses, while the Public Access entitlement only applies to interactive content such as server-side Shiny and APIs. On a Basic license, anonymous static content shows a "Powered by Posit Connect" overlay. An admin can also disable anonymous access server-wide.

## Caveats

- **Everything ships to the browser.** Anyone who can open the app can download its code and data, so it can't hold secrets, database credentials, or data you wouldn't publish.
- **Data is a snapshot.** It's baked in at export time. Fresh data means re-exporting and redeploying, for example on a schedule.
- **Only webR-compatible packages work.** Most common CRAN packages do; packages that need system libraries or database drivers may not.
- **The first load is slow,** since the browser downloads the R runtime. The browser caches it afterwards, so a kiosk that stays open only pays this once.
- **The "live" reading is computed in the browser** from the clock. Real live data would mean the app fetching from somewhere, and webR's networking is limited. That's untested here.

## Sources

- [Shinylive: Shiny + WebAssembly](https://shiny.posit.co/py/get-started/shinylive.html)
- [Posit forum: using shinylive to host the shiny app](https://forum.posit.co/t/using-shinylive-to-host-the-shiny-app-on-github/196209)
- [r-shinylive issues](https://issues.ecosyste.ms/hosts/GitHub/repositories/posit-dev%2Fr-shinylive/issues)
- [Datanovia: Run a Shiny App in the Browser With Shinylive](https://www.datanovia.com/learn/programming/shiny/deployment/shinylive)
