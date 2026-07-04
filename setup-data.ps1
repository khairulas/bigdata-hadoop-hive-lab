# setup-data.ps1
# Run this once after cloning to download the lab training datasets.
# Usage: .\setup-data.ps1

$releaseUrl = "https://github.com/khairulas/bigdata-hadoop-hive-lab/releases/download/v1.0/training-data.zip"
$zipPath    = "training-data.zip"
$extractTo  = "."

Write-Host "Downloading training datasets..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $releaseUrl -OutFile $zipPath

Write-Host "Extracting..." -ForegroundColor Cyan
Expand-Archive -Path $zipPath -DestinationPath $extractTo -Force
Remove-Item $zipPath

Write-Host "Done. Training data is ready at training/data/" -ForegroundColor Green
