#!/bin/bash
# Builds HabitMon as a proper double-clickable .app bundle (not just `swift run`).
# Usage: Scripts/build-app.sh [install]
#   With "install", also copies the result to /Applications/HabitMon.app.
set -euo pipefail

cd "$(dirname "$0")/.."
APP_NAME="HabitMon"
BUNDLE_ID="com.ryanleejiho.HabitMon"
BUILD_DIR=".build/app"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

echo "Building release binary..."
swift build -c release

echo "Assembling $APP_NAME.app..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp ".build/release/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

cat > "$APP_BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.games</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
PLIST

echo "Ad-hoc code signing (so Gatekeeper allows it to launch without a paid Apple Developer cert)..."
codesign --force --deep --sign - "$APP_BUNDLE"

echo "Built: $APP_BUNDLE"

if [ "${1:-}" = "install" ]; then
    echo "Installing to /Applications/$APP_NAME.app..."
    rm -rf "/Applications/$APP_NAME.app"
    cp -R "$APP_BUNDLE" "/Applications/$APP_NAME.app"

    # Force LaunchServices to pick up Info.plist changes (e.g. LSUIElement) immediately —
    # without this, macOS can keep serving a stale cached registration for the same bundle
    # ID/path and the app launches with its OLD activation policy (e.g. still shows a Dock
    # icon) until something else happens to trigger a re-scan.
    /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -f "/Applications/$APP_NAME.app"

    echo "Installed: /Applications/$APP_NAME.app"
fi
