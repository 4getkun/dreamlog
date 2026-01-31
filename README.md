# Dream_Log

Static dream memo site for GitHub Pages.

## Files
- `index.html`: Public list view (loads `posts.json` and paginates 20 per page).
- `admin.html`: Local editor (adds posts, exports JSON, generates static pages).
- `posts.json`: Data file used by `index.html`.

## Basic flow
1) Open `admin.html` in your browser.
2) Add posts.
3) Click "Export posts.json" and overwrite the repo `posts.json`.
4) Push to GitHub, enable Pages.

## Static page generation (20 posts per page)
1) Open `admin.html`.
2) Click "Generate static pages".
3) Downloaded files: `index.html`, `page-2.html`, ...
4) Replace files in the repo and push to GitHub.

## Electron admin (local only)
1) Install Node.js.
2) In this folder, run: `npm install`
3) Start: `npm run start`
4) Use "Export posts.json" to save + auto git add/commit/push.

Notes:
- `admin.html` is ignored by git (local only).
- Auto git requires `git` in PATH and already-authenticated remote.
- App starts with Windows login and lives in the tray when closed.
- If installed EXE can't find the repo, set env `DREAMLOG_REPO` to the repo folder.

## Build Windows EXE (tray resident)
1) Install Node.js.
2) Run: `npm install`
3) Build installer: `npm run dist`
4) EXE is in `dist-app/`
5) Install and launch. Closing the window keeps it in the tray.
