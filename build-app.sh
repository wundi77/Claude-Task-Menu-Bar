#!/bin/bash
set -e

APP_NAME="ClaudeTaskMenuBar"
BUNDLE_ID="com.claude.taskmenbar"

echo "🔨 Kompiliere $APP_NAME (Release) ..."
swift build -c release

EXECUTABLE=".build/release/$APP_NAME"
if [ ! -f "$EXECUTABLE" ]; then
    echo "❌ Executable nicht gefunden: $EXECUTABLE"
    exit 1
fi

APP_BUNDLE="$APP_NAME.app"
echo "📦 Erstelle App-Bundle ..."

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$EXECUTABLE" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

cat > "$APP_BUNDLE/Contents/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>Claude Task Menu Bar</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
</dict>
</plist>
PLIST

printf "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"

echo "🔏 Signiere App (ad-hoc) ..."
codesign --force --deep --sign - "$APP_BUNDLE"

echo ""
echo "✅ $APP_BUNDLE wurde erstellt!"
echo ""
echo "Nächste Schritte:"
echo "  1. Alten Eintrag entfernen: Systemeinstellungen → Allgemein → Startobjekte"
echo "  2. App verschieben:  cp -r \"$APP_BUNDLE\" /Applications/"
echo "  3. App starten:      open /Applications/$APP_NAME.app"
echo "  4. Checkbox 'Beim Login automatisch starten' aktivieren"
