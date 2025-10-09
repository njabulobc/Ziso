# Ziso Mobile Architecture

This document describes the offline-first mobile reimplementation of the existing Ziso web platform. The mobile project lives under `mobile_app/` and is designed to run entirely on-device without any dependency on remote services.

## Overview

The application is written in Flutter and structured into layers that separate presentation, domain logic, and infrastructure. All persistent data is handled locally via SQLite, while exports, backups, and security features operate on the device file system or secure storage APIs.

```
mobile_app/
├── assets/schema.sql        # SQLite schema mirroring Django models
├── lib/
│   ├── core/
│   │   ├── database/        # Database provider, repositories, DAO helpers
│   │   ├── domain/          # Portable entity definitions
│   │   ├── services/        # Export, backup, PIN authentication services
│   │   └── utils/           # Shared utilities such as theming
│   ├── features/
│   │   └── entities/        # Configurations and UI for each business module
│   └── main.dart            # App bootstrap, theming, navigation, security shell
└── test/                    # Automated regression coverage for entity mapping
```

## Data Model

* `lib/core/domain/entities.dart` defines immutable Dart models for every Django entity (employees, companies, court cases, etc.) with helpers to convert to/from SQLite rows.
* `assets/schema.sql` mirrors the Django schema, including all many-to-many pivot tables to preserve relationships without a backend.

## Persistence Layer

* `DatabaseProvider` (lib/core/database/database_provider.dart) opens a singleton SQLite database in the app documents directory and runs the bundled schema.
* `EntityDao` encapsulates CRUD primitives for simple tables, while `PivotDao` manages many-to-many link tables.
* Repository classes (lib/core/database/repositories.dart) combine DAOs to expose higher-level operations that hydrate relation sets for complex entities such as employees, customers, and companies.

## Business Logic & Services

* `ExportService` generates PDF and Excel extracts using on-device libraries.
* `BackupService` exports and imports JSON snapshots of the full database to support file-based backups.
* `PinAuthService` stores a hashed PIN inside `flutter_secure_storage` for optional biometric/PIN protection (biometric integration can be added later).

All business rules are encapsulated locally so that future cloud-sync integrations can reuse these modules without large refactors.

## Presentation Layer

* `lib/main.dart` sets up theming (light/dark/system), the PIN lock flow, and the dashboard grid of modules.
* `EntityConfigurations` describes the form fields, search indices, and relationship metadata for each module.
* `EntityListPage` renders searchable lists with inline CRUD dialogs, chip-based multi-selectors for relations, and export/backup actions.

## Offline-First Considerations

* Every screen reads and writes directly to SQLite via repositories; no network calls are performed.
* Exported files (PDF, Excel, JSON backup) are stored in the application documents directory so they are available offline.
* The architecture is modular: adding synchronization later would only require plugging a sync orchestrator into the repositories without changing the UI.

## Testing

* `test/entities_test.dart` validates entity serialization to guard against schema drift.
* Additional Flutter widget and integration tests can build on this suite by mocking repositories.

## Future Extensions

* Hook biometric authentication into `PinAuthService` using `local_auth`.
* Add background jobs to schedule automatic exports or backups.
* Layer in conflict resolution and change tracking for eventual cloud synchronization.
