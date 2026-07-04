#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/TripProgress.xcodeproj"
SCHEME="TripProgress"
CONFIGURATION="Debug"
DERIVED_DATA="$ROOT_DIR/build/AppetizeDerivedData"
OUTPUT_DIR="$ROOT_DIR/Appetize"
APP_PATH="$DERIVED_DATA/Build/Products/${CONFIGURATION}-iphonesimulator/TripProgress.app"
ZIP_PATH="$OUTPUT_DIR/TripProgress-Appetize.zip"

echo "Building TripProgress for iOS Simulator..."
xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -sdk iphonesimulator \
  -configuration "$CONFIGURATION" \
  -derivedDataPath "$DERIVED_DATA" \
  -destination 'generic/platform=iOS Simulator' \
  clean build

if [ ! -d "$APP_PATH" ]; then
  echo "Could not find simulator app at: $APP_PATH"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
rm -f "$ZIP_PATH"

echo "Packaging Appetize zip..."
(
  cd "$(dirname "$APP_PATH")"
  zip -qry "$ZIP_PATH" "$(basename "$APP_PATH")"
)

echo "Done: $ZIP_PATH"
echo "Upload this file to https://appetize.io/upload"
