$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$keystorePath = Join-Path $root "src-tauri\\keys\\release.keystore"
$keystoreDir = Split-Path -Parent $keystorePath

$storePass = $env:ANDROID_KEYSTORE_PASSWORD
$keyPass = $env:ANDROID_KEY_PASSWORD
if ([string]::IsNullOrWhiteSpace($storePass) -or [string]::IsNullOrWhiteSpace($keyPass)) {
  Write-Error "Set ANDROID_KEYSTORE_PASSWORD and ANDROID_KEY_PASSWORD before creating the keystore."
  exit 1
}

if (Test-Path $keystorePath) {
  Write-Host "Keystore already exists at $keystorePath"
  exit 0
}

New-Item -ItemType Directory -Force -Path $keystoreDir | Out-Null

$keytool = "keytool"
if ($env:JAVA_HOME) {
  $candidate = Join-Path $env:JAVA_HOME "bin\\keytool.exe"
  if (Test-Path $candidate) {
    $keytool = $candidate
  }
}

$null = Get-Command $keytool -ErrorAction Stop

& $keytool `
  -genkeypair -v `
  -keystore $keystorePath `
  -alias release `
  -storepass $storePass `
  -keypass $keyPass `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -dname "CN=Release, OU=Android, O=Terragramy, L=Unknown, S=Unknown, C=US"

Write-Host "Keystore created at $keystorePath"
