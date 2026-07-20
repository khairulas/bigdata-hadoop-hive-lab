# setup-data.ps1
# Run this once after cloning to download the lab training datasets.
# Usage: .\setup-data.ps1

$releaseUrl = "https://github.com/khairulas/bigdata-hadoop-hive-lab/releases/download/v1.0/training-data.zip"
$zipPath    = "training-data.zip"
$extractTo  = "training/data"

Write-Host "Downloading training datasets..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $releaseUrl -OutFile $zipPath

Write-Host "Extracting to $extractTo ..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $extractTo | Out-Null
Expand-Archive -Path $zipPath -DestinationPath $extractTo -Force
Remove-Item $zipPath

$count = (Get-ChildItem -File $extractTo | Where-Object { $_.Name -ne ".gitkeep" }).Count
if ($count -gt 0) {
    Write-Host "Done. $count dataset files ready at $extractTo" -ForegroundColor Green
} else {
    Write-Host "WARNING: extraction finished but $extractTo is empty - please check manually." -ForegroundColor Yellow
}