$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

& "$PSScriptRoot\android-env.ps1" -Release

$storePass = $env:ANDROID_KEYSTORE_PASSWORD
$keyPass = $env:ANDROID_KEY_PASSWORD
if ([string]::IsNullOrWhiteSpace($storePass) -or [string]::IsNullOrWhiteSpace($keyPass)) {
  throw "Set ANDROID_KEYSTORE_PASSWORD and ANDROID_KEY_PASSWORD before building a release APK."
}

& "$PSScriptRoot\android-keystore-ensure.ps1"

$root = Split-Path -Parent $PSScriptRoot
$androidGenRoot = Join-Path $root "src-tauri\gen\android"
$gradlePropsPath = Join-Path $androidGenRoot "gradle.properties"

function Ensure-GradleProps {
  param([string]$Path)

  if (-not (Test-Path $Path)) {
    throw "gradle.properties not found at $Path"
  }

  $content = Get-Content -Path $Path -Raw
  $linesToAdd = @()
  if ($content -notmatch '(?m)^\s*kotlin\.compiler\.execution\.strategy=in-process\s*$') {
    $linesToAdd += "kotlin.compiler.execution.strategy=in-process"
  }
  if ($content -notmatch '(?m)^\s*kotlin\.incremental=false\s*$') {
    $linesToAdd += "kotlin.incremental=false"
  }
  if ($linesToAdd.Count -gt 0) {
    Add-Content -Path $Path -Value $linesToAdd
  }
  Write-Host "Patched gradle.properties: $Path"
}

if (-not (Test-Path $androidGenRoot)) {
  & npm run tauri -- android init
  $initExit = $LASTEXITCODE
  if ($initExit -ne 0) {
    throw "Android init failed with exit code $initExit."
  }
}

Ensure-GradleProps -Path $gradlePropsPath

if ($env:ANDROID_GRADLE_STOP -eq "1") {
  $gradlew = Join-Path $androidGenRoot "gradlew.bat"
  if (Test-Path $gradlew) {
    Write-Host "Stopping Gradle daemon..."
    Push-Location $androidGenRoot
    try {
      & $gradlew --stop
    } finally {
      Pop-Location
    }
  } else {
    Write-Warning "ANDROID_GRADLE_STOP=1 but gradlew.bat was not found at $gradlew"
  }
} else {
  Write-Host "Gradle daemon stop skipped (ANDROID_GRADLE_STOP not set)."
}

& npm run tauri -- android build --apk=true --target aarch64
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
  throw "Release build failed with exit code $exitCode."
}

$apkRoot = Join-Path $root "src-tauri\gen\android\app\build\outputs\apk"
if (-not (Test-Path $apkRoot)) {
  throw "APK output directory not found: $apkRoot"
}

$latestApk = Get-ChildItem -Path $apkRoot -Recurse -Filter *.apk |
  Where-Object { $_.FullName -match '\\release\\' -or $_.Name -match 'release' } |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if (-not $latestApk) {
  throw "No release APK found under $apkRoot. Check Gradle output for errors."
}

$sdkRoot = $env:ANDROID_HOME
if ([string]::IsNullOrWhiteSpace($sdkRoot)) {
  throw "ANDROID_HOME is not set. It is required to locate apksigner."
}

$apksigner = Get-ChildItem -Path (Join-Path $sdkRoot "build-tools") -Recurse -Filter apksigner.bat |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if (-not $apksigner) {
  throw "apksigner.bat not found under $sdkRoot\build-tools"
}

$distDir = Join-Path $root "dist\android"
New-Item -ItemType Directory -Force -Path $distDir | Out-Null

$inputName = $latestApk.BaseName
$signedName = $inputName -replace "-unsigned$", ""
$signedApk = Join-Path $distDir ($signedName + "-signed.apk")

& $apksigner.FullName sign `
  --ks "$root\src-tauri\keys\release.keystore" `
  --ks-key-alias release `
  --ks-pass "env:ANDROID_KEYSTORE_PASSWORD" `
  --key-pass "env:ANDROID_KEY_PASSWORD" `
  --out $signedApk `
  $latestApk.FullName

& $apksigner.FullName verify --verbose $signedApk

Write-Host "✅ Release APK built: $($latestApk.FullName)"
Write-Host "✅ Signed APK: $signedApk"

if ($env:ANDROID_INSTALL_AFTER_BUILD -eq "1") {
  $adbCmd = Get-Command adb -ErrorAction SilentlyContinue
  if (-not $adbCmd) {
    throw "ANDROID_INSTALL_AFTER_BUILD=1 but adb was not found on PATH."
  }
  & $adbCmd.Source install -r $signedApk
}

exit $exitCode
