#!/usr/bin/env bash
# Builds Orbyt.app from the SwiftPM products.
#   scripts/bundle.sh [debug|release]   → build/Orbyt.app
set -euo pipefail

config="${1:-debug}"
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

swift build -c "$config" --product Orbyt
swift build -c "$config" --product obt
bin="$(swift build -c "$config" --show-bin-path)"

app="build/Orbyt.app"
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp "$bin/Orbyt" "$app/Contents/MacOS/Orbyt"
cp "$bin/obt" "$app/Contents/MacOS/obt"
# SwiftPM resource bundles: its generated Bundle.module looks at the app
# root, which code signing forbids, then at the absolute .build path. Dev
# bundles rely on the latter so they can be signed; scripts/release.sh
# builds a distributable app with xcodebuild instead.
for bundle in "$bin"/*.bundle; do
    cp -R "$bundle" "$app/Contents/Resources/"
done
cp Resources/AppIcon.icns "$app/Contents/Resources/AppIcon.icns"

# Its own bundle id, so a dev build runs next to the installed app (which
# lets only one copy of dev.orbyt.orbyt run) and keeps its own settings
# and notification permission.
bundle_id="dev.orbyt.dev"

cat > "$app/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key><string>${bundle_id}</string>
    <key>CFBundleName</key><string>Orbyt</string>
    <key>CFBundleExecutable</key><string>Orbyt</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>dev</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
    <key>NSHighResolutionCapable</key><true/>
    <key>NSPrincipalClass</key><string>NSApplication</string>
</dict>
</plist>
PLIST

# Ad-hoc signing gives the app a stable identity, which notifications need.
codesign --force --sign - --identifier "$bundle_id" "$app/Contents/MacOS/obt"
codesign --force --sign - --identifier "$bundle_id" "$app"

echo "$app"
