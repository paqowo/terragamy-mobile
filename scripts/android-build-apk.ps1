$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$androidDir = Join-Path $root "src-tauri\\gen\\android"
$gradlew = Join-Path $androidDir "gradlew.bat"

if (!(Test-Path $gradlew)) {
  Write-Error "Missing gradlew.bat at $gradlew"
  exit 1
}

Push-Location $androidDir
try {
  & $gradlew assembleRelease
} finally {
  Pop-Location
}
