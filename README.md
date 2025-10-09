# Ziso Mobile

This repository now includes an offline-first Flutter application that recreates the data model and workflows from the original Ziso Django web app. The mobile client runs entirely on-device with no network calls or external backend dependencies.

## Project Structure

| Path | Description |
| ---- | ----------- |
| `ZisoDB/` | Existing Django web project (kept for reference). |
| `mobile_app/` | New Flutter application with local database, business logic, and UI. |
| `ARCHITECTURE.md` | Detailed architecture notes for the mobile app. |

## Prerequisites

* Flutter 3.13 or newer (Dart SDK >= 3.0)
* Android Studio / Xcode toolchains for building native binaries

Install Flutter following the [official instructions](https://docs.flutter.dev/get-started/install) and run `flutter doctor` to confirm your environment.

## Getting Started

```bash
cd mobile_app
flutter pub get
flutter run
```

By default the app launches with light theme enabled. Use the dashboard menu to toggle dark mode, configure a PIN lock, or navigate into entity modules.

### Local Database

* The schema is defined in `assets/schema.sql` and initialized automatically on first launch.
* Data is stored in `ziso_mobile.db` within the application documents directory.

### CRUD, Search, and Relationships

* Each module exposes a searchable list view with inline create/edit dialogs.
* Many-to-many relationships are managed with chip selectors that write into pivot tables.
* The repositories hydrate relation sets so the UI stays consistent offline.

### Exports & Backups

* Use the toolbar actions in each module to export the current dataset to PDF, Excel, or a JSON backup file.
* Files are written to `Documents/exports` or `Documents/backups` on the device/emulator.

### Optional PIN Protection

* Open the dashboard menu → “Set PIN” to configure an on-device PIN stored with `flutter_secure_storage`.
* The “Lock App” action immediately requires the PIN; clearing the PIN disables the lock screen.

### Dark Mode

* Accessible from the dashboard palette icon with light/dark/system modes.

## Testing

The project includes a starter test suite that validates entity serialization.

```bash
cd mobile_app
flutter test
```

> **Note:** Running tests requires the Flutter SDK. In CI or lightweight environments without Flutter, skip this step.

## Packaging

* Android: `flutter build apk`
* iOS: `flutter build ipa`

Both commands produce fully offline binaries ready for sideloading. Integrate distribution signing as needed.

## Data Backup

JSON backups are created via the module toolbar and can be re-imported by placing the file in the app documents directory and wiring a future “Restore” UI flow. The backup format mirrors the SQLite tables for portability.

## Extending the App

1. Add new entities by extending `EntityConfigurations` with additional metadata and repository wiring.
2. Implement advanced analytics by composing queries in repository classes.
3. Introduce cloud sync later by wrapping repositories with a synchronization layer—no UI changes required.

Refer to `ARCHITECTURE.md` for deeper design rationale.
