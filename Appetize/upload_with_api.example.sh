#!/bin/bash
set -euo pipefail

# Optional Appetize API upload example.
# Usage:
#   export APPETIZE_API_TOKEN="your_token"
#   ./Appetize/upload_with_api.example.sh

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ZIP_PATH="$ROOT_DIR/Appetize/TripProgress-Appetize.zip"

if [ -z "${APPETIZE_API_TOKEN:-}" ]; then
  echo "Set APPETIZE_API_TOKEN first."
  exit 1
fi

if [ ! -f "$ZIP_PATH" ]; then
  echo "Build zip not found: $ZIP_PATH"
  echo "Run Scripts/build_appetize.sh first."
  exit 1
fi

curl "https://api.appetize.io/v1/apps" \
  -u "$APPETIZE_API_TOKEN:" \
  -F "file=@$ZIP_PATH" \
  -F "platform=ios"
