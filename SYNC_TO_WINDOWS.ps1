# Run this on THRONE / your PC AFTER the sandbox package is available
# (download artifacts folder, or copy from wherever the sandbox files land)
#
# Target: C:\Users\KING\projects\lumming

$ErrorActionPreference = "Stop"
$Project = "C:\Users\KING\projects\lumming"

# If you downloaded a zip of the sandbox lumming folder, set $Source to the extracted path:
# $Source = "C:\Users\KING\Downloads\lumming"
# Then: Copy-Item -Path "$Source\*" -Destination $Project -Recurse -Force

# Or if you already have the new folders elsewhere, copy only the new brand subfolders:
$NewFolders = @(
  "brand\branding-guide",
  "brand\app-mockups",
  "brand\trailers",
  "brand\character-lineup",
  "brand\character-masters",
  "brand\locked-style-references"
)

Write-Host "Lummings project: $Project"
if (-not (Test-Path $Project)) {
  Write-Error "Project not found at $Project"
  exit 1
}

# Create folders if missing
foreach ($rel in $NewFolders) {
  $dest = Join-Path $Project $rel
  if (-not (Test-Path $dest)) {
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    Write-Host "Created $dest"
  }
}

Write-Host ""
Write-Host "Folders ready. Copy the staged files into:"
$NewFolders | ForEach-Object { Write-Host "  $Project\$_" }
Write-Host ""
Write-Host "Then verify:"
Write-Host "  Get-ChildItem $Project\brand -Directory | Select Name"
Write-Host "  (Get-ChildItem $Project\brand\branding-guide).Count  # should be 8"
Write-Host "  (Get-ChildItem $Project\brand\app-mockups).Count     # should be 5"
Write-Host "  (Get-ChildItem $Project\brand\trailers).Count        # should be 4+"
