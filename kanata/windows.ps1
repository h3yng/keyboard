$ErrorActionPreference = "stop"

$ConfigUrl = "https://raw.githubusercontent.com/h3yng/keyboard/refs/heads/main/kanata/kanata.kbd"
$KanataUrl = "https://github.com/jtroo/kanata/releases/download/v1.12.1-prerelease-1/windows-binaries-x64.zip"

$InstallDir = Join-Path $env:LOCALAPPDATA "Kanata"
$ZipPath = Join-Path $env:TEMP "kanata-windows-x64.zip"
$ConfigPath = Join-Path $InstallDir "kanata.kbd"

Write-Host "preparing installation directory..."
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

Write-Host "Downloading Kanata..."
Invoke-WebRequest -Uri $KanataUrl -OutFile $ZipPath

Write-Host "Extracting Kanata..."
Expand-Archive `
    -Path $ZipPath `
    -DestinationPath $InstallDir `
    -Force

Write-Host "pulling config..."
Invoke-WebRequest `
    -Uri $ConfigUrl `
    -OutFile $ConfigPath

$Kanata = Get-ChildItem `
    -Path $InstallDir `
    -Recurse `
    -File `
    -Filter "kanata_windows_gui_winIOv2_x64.exe" |
    Select-Object -First 1

if (-not $Kanata) {
    Write-Host "Extracted executables:"

    Get-ChildItem `
        -Path $InstallDir `
        -Recurse `
        -File `
        -Filter "*.exe" |
        ForEach-Object {
            Write-Host "  $($_.FullName)"
        }

    throw "The Kanata GUI WinIOv2 executable was not found."
}

Write-Host "Starting Kanata from:"
Write-Host $Kanata.FullName

Start-Process `
    -FilePath $Kanata.FullName `
    -ArgumentList @("--cfg", "`"$ConfigPath`"")

Remove-Item $ZipPath -Force -ErrorAction SilentlyContinue

Write-Host "Kanata is running with your Graphite configuration."
