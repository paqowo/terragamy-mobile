# Terragramy â€“ Karta dne

## Requirements
- Node.js
- npm

## Scripts
- `npm install`
- `npm run dev`
- `npm run android:dev` (use this exact command)
- `npm run android:logcat:hmr`
- `npm run android:logcat:hmr:all`
- `npm run build`

## VS Code quickstart
1) `npm run android:restart`
2) `npm run android:dev`

Good output looks like:
```
adb devices:
emulator-5554    device
```

`npm run android:dev` now auto-restarts the emulator if it is offline or missing.

## Android HMR logcat
Krok 1: `npm run android:dev` (v jednom terminalu)
Krok 2: `npm run android:logcat:hmr` (v druhĂ©m terminalu)

Co oÄŤekĂˇvat v logu:
- `[HMR DEBUG] WebSocket connect -> ws://<host>:5173/@vite/ws`
- `[HMR DEBUG] WebSocket OPEN`

KdyĹľ se objevĂ­ `ws://tauri.localhost/@vite/ws`, znamenĂˇ to, Ĺľe HMR jde na ĹˇpatnĂ˝ host a Android WebView se k Vite serveru nepĹ™ipojĂ­.
KdyĹľ vidĂ­Ĺˇ `CLOSE 1006`, WebSocket spadl bez sprĂˇvnĂ©ho ukonÄŤenĂ­ (obvykle ĹˇpatnĂ˝ host/port nebo sĂ­ĹĄovĂ© spojenĂ­).

## Android HMR host
If you have multiple network adapters (VPN, virtual adapters), set `TAURI_DEV_HOST` to the LAN IP your Android device can reach.
Example (PowerShell): `$env:TAURI_DEV_HOST="192.168.0.205"; $env:TAURI_DEV_PORT="5173"; npm run android:dev`

Verify in logcat:
- `[HMR DEBUG] WebSocket connect -> ws://192.168.0.205:5173/@vite/ws`
- `[HMR DEBUG] WebSocket OPEN`
- `[vite] server connection lost` should stop appearing

## Assets
- `public/logo.webp`
- `public/favicon.ico`
- `public/symbols/<slug>.webp` (one file per card slug)

## Android release APK
### Generate launcher icons
- `npm run android:icons`

### Keystore passwords (PowerShell)
```
$env:ANDROID_KEYSTORE_PASSWORD="your-store-password"
$env:ANDROID_KEY_PASSWORD="your-key-password"
```

### Create keystore + build + install
```
npm run android:keystore:create
npm run android:build:apk
npm run android:install:apk
```

Final APK path:
`src-tauri/gen/android/app/build/outputs/apk/release/app-release.apk`

### Verification checklist
- Logo click does not open external browser
- Icons present in `src-tauri/gen/android/app/src/main/res/mipmap-*`
- Release APK exists and installs

## Build signed release APK (no Play Store)
1) `npm install`
2) In the same terminal session (PowerShell):
```
$env:ANDROID_KEYSTORE_PASSWORD="YOUR_PASSWORD"
$env:ANDROID_KEY_PASSWORD="YOUR_PASSWORD"
```
3) `npm run android:apk:release`

The release build does NOT require the dev server running.

APK output path will be printed and is typically under:
`src-tauri/gen/android/app/build/outputs/apk/universal/release/`

Back up `src-tauri/keys/release.keystore` and keep the passwords safe. Losing them prevents updates signed with the same key.


