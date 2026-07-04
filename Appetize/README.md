# Appetize Build

Appetize requires an iOS Simulator `.app` bundle compressed as `.zip` or `.tar.gz`.

This project includes a helper script that builds and packages the app:

```bash
cd TripProgress
chmod +x Scripts/build_appetize.sh
Scripts/build_appetize.sh
```

The output will be:

```text
Appetize/TripProgress-Appetize.zip
```

Upload that file at:

```text
https://appetize.io/upload
```

## Notes

- Run this on macOS with Xcode installed.
- Appetize needs a simulator build, not an App Store `.ipa`.
- If location does not move inside Appetize, use the app flow to verify destination search, route calculation, permissions, and UI. Real movement-based progress is best tested on a physical iPhone or Xcode simulator with a GPX route.
