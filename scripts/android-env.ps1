[CmdletBinding()]
param(
  [switch]$Release,
  [string]$DevHost = "192.168.0.205",
  [string]$Port = "5173"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not $Release) {
  $env:TAURI_DEV_HOST = $DevHost
  $env:TAURI_DEV_PORT = $Port
} else {
  Remove-Item Env:\TAURI_DEV_HOST -ErrorAction SilentlyContinue
  Remove-Item Env:\TAURI_DEV_PORT -ErrorAction SilentlyContinue
}

if ([string]::IsNullOrWhiteSpace($env:ANDROID_KEYSTORE_PASSWORD)) {
  $secureStore = Read-Host "Enter ANDROID_KEYSTORE_PASSWORD" -AsSecureString
  $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureStore)
  try {
    $storePlain = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
  } finally {
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
  }
  if ([string]::IsNullOrWhiteSpace($storePlain)) {
    throw "ANDROID_KEYSTORE_PASSWORD cannot be empty."
  }
  $env:ANDROID_KEYSTORE_PASSWORD = $storePlain
}

if ([string]::IsNullOrWhiteSpace($env:ANDROID_KEY_PASSWORD)) {
  $secureKey = Read-Host "Enter ANDROID_KEY_PASSWORD" -AsSecureString
  $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
  try {
    $keyPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
  } finally {
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
  }
  if ([string]::IsNullOrWhiteSpace($keyPlain)) {
    throw "ANDROID_KEY_PASSWORD cannot be empty."
  }
  $env:ANDROID_KEY_PASSWORD = $keyPlain
}

$storeStatus = if ([string]::IsNullOrWhiteSpace($env:ANDROID_KEYSTORE_PASSWORD)) { "missing" } else { "set" }
$keyStatus = if ([string]::IsNullOrWhiteSpace($env:ANDROID_KEY_PASSWORD)) { "missing" } else { "set" }

if ($Release) {
  Write-Host "Release env: ANDROID_KEYSTORE_PASSWORD $storeStatus, ANDROID_KEY_PASSWORD $keyStatus"
} else {
  Write-Host "TAURI_DEV_HOST=$env:TAURI_DEV_HOST TAURI_DEV_PORT=$env:TAURI_DEV_PORT"
  Write-Host "ANDROID_KEYSTORE_PASSWORD: $storeStatus"
  Write-Host "ANDROID_KEY_PASSWORD: $keyStatus"
}
