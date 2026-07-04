# Build for Appetize from Windows

You cannot create the Appetize iOS file directly on Windows because iOS Simulator `.app` builds require Xcode on macOS.

Use GitHub Actions instead:

1. Create a GitHub repository.
2. Upload the entire `TripProgress` folder contents to that repository.
3. Open the repository on GitHub.
4. Go to `Actions`.
5. Select `Build Appetize iOS Simulator Zip`.
6. Click `Run workflow`.
7. Wait until the workflow finishes.
8. Open the finished workflow run.
9. Download the artifact named `TripProgress-Appetize`.
10. Extract it if GitHub downloads it as an artifact zip.
11. Upload `TripProgress-Appetize.zip` to:

```text
https://appetize.io/upload
```

Important: Appetize wants the inner file named `TripProgress-Appetize.zip`, which contains `TripProgress.app`.
