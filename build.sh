#!/bin/bash

swift build -c release

BIN_PATH=$(swift build -c release --show-bin-path)

APP_NAME="PunchyAudio"
APP_BUNDLE="$APP_NAME.app"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BIN_PATH/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/"
cp "Info.plist" "$APP_BUNDLE/Contents/Info.plist"
plutil -lint "$APP_BUNDLE/Contents/Info.plist"

ICON_SOURCE="Icon Exports/Icon-iOS-Default-1024x1024@1x.png"
if [ -f "$ICON_SOURCE" ]; then
    ICONSET="$APP_BUNDLE/Contents/Resources/AppIcon.iconset"
    mkdir -p "$ICONSET"
    
    sips -z 16 16     "$ICON_SOURCE" --out "$ICONSET/icon_16x16.png"      > /dev/null 2>&1
    sips -z 32 32     "$ICON_SOURCE" --out "$ICONSET/icon_16x16@2x.png"   > /dev/null 2>&1
    sips -z 32 32     "$ICON_SOURCE" --out "$ICONSET/icon_32x32.png"      > /dev/null 2>&1
    sips -z 64 64     "$ICON_SOURCE" --out "$ICONSET/icon_32x32@2x.png"   > /dev/null 2>&1
    sips -z 128 128   "$ICON_SOURCE" --out "$ICONSET/icon_128x128.png"    > /dev/null 2>&1
    sips -z 256 256   "$ICON_SOURCE" --out "$ICONSET/icon_128x128@2x.png" > /dev/null 2>&1
    sips -z 256 256   "$ICON_SOURCE" --out "$ICONSET/icon_256x256.png"    > /dev/null 2>&1
    sips -z 512 512   "$ICON_SOURCE" --out "$ICONSET/icon_256x256@2x.png" > /dev/null 2>&1
    sips -z 512 512   "$ICON_SOURCE" --out "$ICONSET/icon_512x512.png"    > /dev/null 2>&1
    sips -z 1024 1024 "$ICON_SOURCE" --out "$ICONSET/icon_512x512@2x.png" > /dev/null 2>&1
    
    iconutil -c icns "$ICONSET" -o "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
    rm -rf "$ICONSET"
    echo "App icon generated successfully"
else
    echo "Warning: Icon source not found at '$ICON_SOURCE'"
fi

echo "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"
xattr -cr "$APP_BUNDLE"
codesign --force --deep --sign - "$APP_BUNDLE"

echo "Build complete. Run with: open $APP_BUNDLE"
