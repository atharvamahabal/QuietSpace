$ErrorActionPreference = "Stop"

$url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.38.6-stable.zip"
$zipPath = "d:\Android Projects\QuietSpace\flutter.zip"
$destPath = "d:\Android Projects\QuietSpace\sdk"

Write-Host "Creating destination directory..."
New-Item -ItemType Directory -Force -Path $destPath | Out-Null

Write-Host "Downloading Flutter SDK from $url..."
# Using .NET WebClient for better compatibility/performance sometimes, or Invoke-WebRequest
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $zipPath)
Write-Host "Download complete."

Write-Host "Extracting..."
Expand-Archive -LiteralPath $zipPath -DestinationPath $destPath -Force
Write-Host "Extraction complete."

Write-Host "Cleaning up zip file..."
Remove-Item -Path $zipPath -Force

Write-Host "Setup complete. Flutter is in $destPath\flutter"
