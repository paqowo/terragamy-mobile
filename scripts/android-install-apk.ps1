$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$apkPath = Join-Path $root "src-tauri\\gen\\android\\app\\build\\outputs\\apk\\release\\app-release.apk"

if (!(Test-Path $apkPath)) {
  Write-Error "Release APK not found at $apkPath. Run npm run android:build:apk first."
  exit 1
}

$null = Get-Command adb -ErrorAction Stop
& adb install -r $apkPath
