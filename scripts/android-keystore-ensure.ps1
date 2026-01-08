$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$root = Split-Path -Parent $PSScriptRoot
$keysDir = Join-Path $root "src-tauri\keys"
$keystorePath = Join-Path $keysDir "release.keystore"

if (Test-Path $keystorePath) {
  Write-Host "Keystore already exists"
  exit 0
}

$storePass = $env:ANDROID_KEYSTORE_PASSWORD
$keyPass = $env:ANDROID_KEY_PASSWORD
if ([string]::IsNullOrWhiteSpace($storePass) -or [string]::IsNullOrWhiteSpace($keyPass)) {
  $example = '$env:ANDROID_KEYSTORE_PASSWORD="YOUR_PASSWORD"; $env:ANDROID_KEY_PASSWORD="YOUR_PASSWORD"'
  throw "Set ANDROID_KEYSTORE_PASSWORD and ANDROID_KEY_PASSWORD for this terminal session. Example: $example"
}

New-Item -ItemType Directory -Force -Path $keysDir | Out-Null

$keytoolPath = $null
if ($env:JAVA_HOME) {
  $candidate = Join-Path $env:JAVA_HOME "bin\keytool.exe"
  if (Test-Path $candidate) {
    $keytoolPath = $candidate
  }
}

if (-not $keytoolPath) {
  $keytoolCmd = Get-Command keytool -ErrorAction SilentlyContinue
  if ($keytoolCmd) {
    $keytoolPath = $keytoolCmd.Source
  }
}

if (-not $keytoolPath) {
  throw "keytool not found. Install a JDK or set JAVA_HOME to a valid JDK."
}

& $keytoolPath `
  -genkeypair -v `
  -keystore $keystorePath `
  -alias release `
  -storepass $storePass `
  -keypass $keyPass `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -dname "CN=Release, OU=Android, O=Terragramy, L=Unknown, ST=Unknown, C=US"

Write-Host "Keystore created at $(Resolve-Path $keystorePath)"
