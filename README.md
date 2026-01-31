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
