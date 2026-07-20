# Patient Mobile App Architecture

This Flutter app is the patient-facing client for the Intelligent Patient Flow and Appointment Scheduling System.

## Structure

- `lib/app`: app entry, router, top-level providers, theme bridge.
- `lib/core`: constants, networking, storage, errors, and framework-agnostic utilities.
- `lib/shared`: reusable widgets and patient mobile design system.
- `lib/features`: feature-first modules using data, domain, and presentation layers.

## Architecture Rules

- Widgets do not call APIs directly.
- API services only perform Dio calls.
- Repositories map API responses and errors into domain-friendly results.
- Riverpod controllers own screen state when workflows are implemented.
- Sensitive auth values must not be stored in `SharedPreferences`.
- Use `flutter_secure_storage` only if backend later returns mobile tokens.
- Cookie/session support is prepared through Dio cookie management.

## API Configuration

The default API base URL is Android-emulator friendly:

```bash
http://10.0.2.2:8000/api/v1
```

Override it at run time:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

Use your machine LAN IP for physical devices.

## Adding A Feature

1. Read backend Swagger/OpenAPI first.
2. Add DTO models under `feature/data/models`.
3. Add API calls in `feature/data/*_api_service.dart`.
4. Add repository mapping in `feature/data/*_repository_impl.dart`.
5. Add domain contracts under `feature/domain/repositories`.
6. Add Riverpod controllers under `feature/presentation/controllers`.
7. Keep screens thin and composed from shared widgets.

## Commands

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```
