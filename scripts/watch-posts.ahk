; AutoHotkey v2 script to watch posts.json and push to GitHub Pages
; Put this script in scripts\ and it auto-resolves repo path.

repoPath := A_ScriptDir "\.."
postsFile := repoPath "\posts.json"
pollMs := 60000

if !FileExist(postsFile) {
  MsgBox "posts.json not found.`n" postsFile, "Error", 16
  ExitApp
}

lastTime := FileGetTime(postsFile, "M")

A_TrayMenu.Delete()
A_TrayMenu.Add("Run Git Now", RunGitNow)
A_TrayMenu.Add()
A_TrayMenu.Add("Exit", (*) => ExitApp())
A_TrayMenu.Default := "Run Git Now"

SetTimer(CheckFile, pollMs)

CheckFile(*) {
  global postsFile, lastTime
  newTime := FileGetTime(postsFile, "M")
  if (newTime != lastTime) {
    lastTime := newTime
    RunGitNow()
  }
}

RunGitNow(*) {
  global repoPath
  RunWait A_ComSpec ' /c "cd /d "' repoPath '" && git add posts.json && git commit -m "auto update posts" && git push"', , "Hide"
}
