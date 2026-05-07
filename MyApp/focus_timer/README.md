# ApnaFlow Local Release v1

This package is the local-only, phone-ready version.

## What changed
- No Firebase imports
- Local profile storage in app documents
- Session storage in app documents
- Swipe-up intro screen
- Front/back camera toggle icon
- Start recording only; auto-stop at duration end
- Past dates hidden by calendar start date
- Estimate tab shows clean session cards with progress bars
- Update tab shows sessions, calendar, and session stats
- Session rename/delete restored

## Use inside your existing Flutter project
Replace the `lib/` folder with this package, merge `pubspec.yaml` dependencies and assets, then run:

```bash
flutter pub get
flutter run -d <your_android_device_id>
```

## Notes
- Videos and profile data are stored inside app-private storage.
- No Firebase setup is needed for this release.
- Camera permission must be enabled on Android.
