$sdkLocal = Join-Path $env:LOCALAPPDATA "Android\Sdk"

function Resolve-ToolPath {
  param(
    [string]$CommandName,
    [string[]]$FallbackPaths
  )

  $cmd = Get-Command $CommandName -ErrorAction SilentlyContinue
  if ($cmd -and $cmd.Source) {
    return $cmd.Source
  }

  foreach ($path in $FallbackPaths) {
    if ($path -and (Test-Path $path)) {
      return $path
    }
  }

  return $null
}

# Resolve adb.exe from PATH or common SDK locations.
$adbCandidates = @(
  (Join-Path $sdkLocal "platform-tools\adb.exe"),
  (Join-Path $env:ANDROID_SDK_ROOT "platform-tools\adb.exe"),
  (Join-Path $env:ANDROID_HOME "platform-tools\adb.exe")
)
$adb = Resolve-ToolPath -CommandName "adb.exe" -FallbackPaths $adbCandidates

# Resolve emulator.exe from PATH or common SDK locations.
$emuCandidates = @(
  (Join-Path $sdkLocal "emulator\emulator.exe"),
  (Join-Path $env:ANDROID_SDK_ROOT "emulator\emulator.exe"),
  (Join-Path $env:ANDROID_HOME "emulator\emulator.exe")
)
$emu = Resolve-ToolPath -CommandName "emulator.exe" -FallbackPaths $emuCandidates

if (-not $adb) {
  $expected = Join-Path $sdkLocal "platform-tools\adb.exe"
  Write-Error "adb.exe not found. Install Android SDK Platform Tools, set ANDROID_SDK_ROOT/ANDROID_HOME, or add platform-tools to PATH. Expected: $expected"
  exit 1
}

if (-not $emu) {
  $expected = Join-Path $sdkLocal "emulator\emulator.exe"
  Write-Error "emulator.exe not found. Install Android Emulator, set ANDROID_SDK_ROOT/ANDROID_HOME, or add emulator to PATH. Expected: $expected"
  exit 1
}

Write-Host "Restarting adb server..."
& $adb kill-server 2>$null | Out-Null
Start-Sleep -Milliseconds 200
& $adb start-server | Out-Null

Write-Host "Stopping offline emulators if present..."
$deviceLines = & $adb devices 2>$null
foreach ($line in $deviceLines) {
  if ($line -match "^(emulator-\d+)\s+offline") {
    $serial = $matches[1]
    Write-Host "Stopping $serial..."
    & $adb -s $serial emu kill 2>$null | Out-Null
  }
}

function Start-AvdIfNeeded {
  param([string]$Serial)

  $lines = & $adb devices 2>$null
  foreach ($line in $lines) {
    if ($line -match "^$Serial\s+device$") {
      return
    }
    if ($line -match "^$Serial\s+offline$") {
      Write-Host "$Serial is offline, stopping..."
      & $adb -s $Serial emu kill 2>$null | Out-Null
      Start-Sleep -Milliseconds 500
      break
    }
  }

  Write-Host "Starting AVD Medium_Phone_API_36.1..."
  Start-Process -FilePath $emu -ArgumentList @("-avd", "Medium_Phone_API_36.1") -WindowStyle Minimized | Out-Null
}

$serial = "emulator-5554"
Start-AvdIfNeeded -Serial $serial

Write-Host "Waiting for emulator to be in device state..."
$deviceReady = $false
for ($i = 0; $i -lt 60; $i++) {
  $lines = & $adb devices 2>$null
  foreach ($line in $lines) {
    if ($line -match "^$serial\s+device$") {
      $deviceReady = $true
      break
    }
    if ($line -match "^$serial\s+offline$") {
      Write-Host "$serial is offline, restarting AVD..."
      & $adb -s $serial emu kill 2>$null | Out-Null
      Start-Sleep -Milliseconds 500
      Start-Process -FilePath $emu -ArgumentList @("-avd", "Medium_Phone_API_36.1") -WindowStyle Minimized | Out-Null
    }
  }
  if ($deviceReady) { break }
  Start-Sleep -Seconds 2
}

if (-not $deviceReady) {
  Write-Error "Emulator did not reach 'device' state within 120 seconds."
  exit 1
}

Write-Host "Waiting for Android boot to complete..."
$bootReady = $false
for ($i = 0; $i -lt 90; $i++) {
  $value = (& $adb -s $serial shell getprop sys.boot_completed 2>$null) -join ""
  if ($value.Trim() -eq "1") {
    $bootReady = $true
    break
  }
  Start-Sleep -Seconds 2
}

if (-not $bootReady) {
  Write-Error "Emulator did not finish booting within 180 seconds."
  exit 1
}

Write-Host "Bringing app to foreground..."
& $adb -s $serial shell am force-stop cz.terragramy.karta.dne 2>$null | Out-Null
& $adb -s $serial shell monkey -p cz.terragramy.karta.dne -c android.intent.category.LAUNCHER 1 2>$null | Out-Null

Write-Host "adb devices:"
& $adb devices
exit 0
