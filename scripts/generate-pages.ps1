$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$postsPath = Join-Path $repoRoot "posts.json"
$outDir = Join-Path $repoRoot "dist"

if (-not (Test-Path $postsPath)) {
  throw "posts.json not found at $postsPath"
}

if (Test-Path $outDir) {
  Remove-Item -Recurse -Force $outDir
}
New-Item -ItemType Directory -Path $outDir | Out-Null

$posts = Get-Content -Raw $postsPath | ConvertFrom-Json
if ($null -eq $posts) { $posts = @() }

$posts = $posts | Sort-Object -Property date -Descending

$pageSize = 20
$totalPages = [Math]::Max(1, [int][Math]::Ceiling($posts.Count / $pageSize))

function EscapeHtml([string]$text) {
  if ($null -eq $text) { return "" }
  return $text.Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;")
}

function PageTemplate([int]$pageIndex, [int]$totalPages, $pagePosts) {
  $nav = ""
  for ($i = 1; $i -le $totalPages; $i += 1) {
    $href = if ($i -eq 1) { "index.html" } else { "page-$i.html" }
    $active = if ($i -eq $pageIndex) { "active" } else { "" }
    $nav += "<a href=`"$href`" class=`"$active`">Page $i</a>"
  }

  function FormatPostedAt([string]$dateStr) {
    if ([string]::IsNullOrWhiteSpace($dateStr)) { return "" }
    try {
      $d = [datetime]::Parse($dateStr)
      return "posted at {0}年{1}月{2}日" -f $d.Year, $d.Month, $d.Day
    } catch {
      return ""
    }
  }

  function StripPostedAt([string]$text) {
    if ($null -eq $text) { return "" }
    $lines = $text -split "(`r`n|`n|`r)"
    $kept = @()
    foreach ($line in $lines) {
      if ($line.Trim() -match '^posted at\s+') { continue }
      $kept += $line
    }
    return ($kept -join "`n")
  }

  $entries = @()
  foreach ($post in $pagePosts) {
    $title = EscapeHtml $post.title
    if ([string]::IsNullOrWhiteSpace($title)) { $title = "Untitled" }
    $body = StripPostedAt $post.body
    $body = EscapeHtml $body
    $body = $body -replace "`r`n", "`n"
    $body = $body -replace "`r", "`n"
    $body = $body -replace "(`n){2,}", "`n`n"
    $body = $body -replace "`n`n", "__P__"
    $body = $body -replace "`n", " "
    $body = $body -replace "__P__", "<br><br>"
    $postedAt = EscapeHtml (FormatPostedAt $post.date)
    $postedAtHtml = if ($postedAt) { "<br><div>$postedAt</div>" } else { "" }
    $entries += @"
<div class="entry">
  <h2>$title</h2>
  <br>
  <div>$body</div>
  $postedAtHtml
</div>
"@
  }

  $separator = "<br><hr><br>"
  $topRule = "<hr><br>"
  $content = if ($entries.Count -gt 0) { $topRule + ($entries -join $separator) } else { "<div class=`"empty`">No posts yet.</div>" }

  return @"
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Dream Log - Page $pageIndex</title>
    <style>
      :root { --bg:#f6f2ea; --ink:#1f1c16; --muted:#6b6258; --accent:#2b6cb0; }
      * { box-sizing: border-box; }
      body { margin:0; font-family: "Georgia","Times New Roman",serif; color:var(--ink); background: radial-gradient(circle at 20% 10%, #fff7e6, var(--bg)); }
      header { padding: 28px 16px 6px; text-align:center; }
      header h1 { margin:0; }
      main { max-width: 860px; margin: 28px auto 0; padding: 16px; }
      .entry h2 { margin:0 0 6px; font-size:22px; }
      hr { border:none; border-top:1px solid #dccfb9; }
      .nav { display:flex; gap:8px; flex-wrap:wrap; justify-content:center; margin:18px 0 28px; }
      .nav a { text-decoration:none; color:var(--ink); border:1px solid #dccfb9; padding:6px 12px; border-radius:999px; background:#fffefb; }
      .nav a.active { background:var(--accent); color:white; border-color:var(--accent); }
      .empty { text-align:center; color:var(--muted); padding: 48px 12px; }
      @media (max-width: 680px) {
        body { font-size: 16px; line-height: 1.7; }
        header { padding: 20px 12px 4px; }
        header h1 { font-size: 24px; }
        main { margin-top: 20px; padding: 12px; }
        .entry h2 { font-size: 19px; }
        .nav { margin: 12px 0 20px; }
        .nav a { padding: 6px 10px; font-size: 13px; }
      }
    </style>
  </head>
  <body>
    <header>
      <h1>Dream Log</h1>
    </header>
    <main>
      $content
    </main>
    <div class="nav">$nav</div>
  </body>
</html>
"@
}

for ($i = 0; $i -lt $totalPages; $i += 1) {
  $pageIndex = $i + 1
  $slice = $posts | Select-Object -Skip ($i * $pageSize) -First $pageSize
  $html = PageTemplate $pageIndex $totalPages $slice
  $fileName = if ($pageIndex -eq 1) { "index.html" } else { "page-$pageIndex.html" }
  $outPath = Join-Path $outDir $fileName
  Set-Content -Path $outPath -Value $html -Encoding UTF8
}

Write-Output "Generated $totalPages page(s) into $outDir"
