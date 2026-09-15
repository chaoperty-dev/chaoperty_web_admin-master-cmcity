# setup_git_standard.ps1
# ตั้งมาตรฐาน git สำหรับ chaoperty (repo-local เท่านั้น)
# รัน: powershell -ExecutionPolicy Bypass -File setup_git_standard.ps1

Set-Location $PSScriptRoot

Write-Host "==> Applying repo-local git config" -ForegroundColor Cyan

# --- Line endings -----------------------------------------------------------
git config --local core.autocrlf false
git config --local core.safecrlf warn

# --- Display ----------------------------------------------------------------
git config --local core.quotepath false      # ชื่อไฟล์ไทยไม่ escape
git config --local log.date iso-strict

# --- Fetch / Push / Pull ----------------------------------------------------
git config --local fetch.prune true
git config --local fetch.pruneTags true
git config --local push.default simple
git config --local push.autoSetupRemote true
git config --local pull.rebase false

# --- Diff / Merge -----------------------------------------------------------
git config --local diff.algorithm histogram
git config --local diff.colorMoved zebra
git config --local merge.conflictstyle zdiff3
git config --local rebase.autostash true
git config --local rerere.enabled true

# --- Encoding ---------------------------------------------------------------
git config --local i18n.commitEncoding utf-8
git config --local i18n.logOutputEncoding utf-8

# --- Commit template --------------------------------------------------------
git config --local commit.template .gitmessage

# --- Tag sorting (version-aware) --------------------------------------------
git config --local tag.sort -version:refname

# --- Reuse https creds for ssh-style URLs -----------------------------------
git config --local url."https://github.com/".insteadOf "git@github.com:"

Write-Host "==> Normalizing line endings to LF (this rewrites the index)" -ForegroundColor Cyan
git add --renormalize .
git status --short

Write-Host ""
Write-Host "==> Done. Review the staged renormalization, then commit:" -ForegroundColor Green
Write-Host '   git commit -m "chore: add .gitattributes + normalize line endings to LF"'
