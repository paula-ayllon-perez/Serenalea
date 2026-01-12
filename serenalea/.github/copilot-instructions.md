# Copilot / AI agent instructions for serenalea

Purpose: short, actionable rules for code changes, tests & common patterns. Use these to produce PRs that are small, well-tested and respect project conventions.

1. Quick context
- Flutter app (lib/main.dart) using Firebase: Auth, Firestore and Storage (see `lib/firebase_options.dart` and `firebase.json`).
- Layered structure: `data/services` (talk to Firebase), `data/repositories` (app API), `data/models` (DTOs), `presentation/pages` (UI), `core` (theme, utils).
- Routes are declared in `lib/presentation/routes/routes.dart`; protected routes use `AuthGuard` (`lib/presentation/widgets/auth_guard.dart`).

2. Important files to consult (first things to open)
- `lib/main.dart` (app bootstrap, Firebase init, `DatabaseInitializer.initializeIfEmpty()`)
- `lib/presentation/routes/routes.dart` and `activity_routes.dart`
- `lib/core/utils/database_initializer.dart` (seeds collections: `activity_categories`, activities)
- `lib/data/services/*_firestore.dart` (Firestore + Storage interaction)
- `lib/data/repositories/*` (higher-level API used by UI)
- `lib/data/models/*.dart` (schemas: users, PhotoMemory, activities)
- `ALBUM_FOTOS_README.md` (feature-level design & data shape for the photo album)
- `pubspec.yaml`, `analysis_options.yaml` (deps & linting rules)

3. Key conventions & gotchas
- Firestore collections use plural names: `users`, `photo_memories`, `activity_categories`. If you change a name, update all usages and DB seeders.
- Registration flow: create user in Firebase Auth, upload profile image to `profile_images/$uid.jpg` (Storage), then save user doc under `users/$uid` (see `UserFirestoreService.registerUser`).
- `PhotoMemory.imagePath` can be a local path **or** a Firebase Storage download URL. If you change upload behavior, ensure both storage and DB are updated.
- The app seeds example data on startup via `DatabaseInitializer.initializeIfEmpty()` — useful for local dev. To re-seed, clear Firestore or edit the initializer.
- Date formatting is set to Spanish in `main.dart` (`initializeDateFormatting('es', null)`) — keep locale formatting consistent.
- Many Firestore reads fetch `userId` and then sort locally to avoid needing composite indexes. If you alter queries, update indexes in Firebase console or adapt code accordingly.
- Error handling patterns: services often `rethrow` errors; UI maps Firebase errors with text matching (e.g., `login` error messages). Avoid changing exception text without corresponding UI updates.
- Tests: unit and widget tests exist (`test/`); some whitebox tests replicate private logic (see `register_assessment_whitebox_test.dart`). Renaming internal symbols or thresholds will break tests.

4. Dev workflows & commands
- Install deps: `flutter pub get`
- Static analysis: `flutter analyze`
- Format: `dart format .` (or use IDE auto-format)
- Run tests: `flutter test` (unit + widget)
- Run app: `flutter run -d <device>` or use IDE run/debug
- Build release: `flutter build apk` / `flutter build ios` as usual

5. When changing storage/DB logic
- Update service (`*_firestore.dart`) and repository (`*_repository.dart`) together.
- Add or update tests that assert DB shape and behavior.
- Update `DatabaseInitializer` if test/example data needs change.

6. PR guidance
- Make small, focused PRs; include tests and run `flutter analyze` and `flutter test` locally.
- If changing public APIs (repositories/services/models), add migration notes in PR description and update related references (routes, UI, tests).

7. Example concise prompts for tasks (use as templates)
- "Add uploading of activity images to Firebase Storage: update `PhotoFirestoreService.savePhoto` to upload the file to `photo_memories/<userId>/<timestamp>.jpg`, substitute `imagePath` with the download URL, add tests, and run `flutter test` and `flutter analyze` before creating the PR." 
- "Refactor auth flow to show a friendly snackbar on token expiry: find `AuthGuard` and the login flow, add error mapping in UI and tests."

8. Where to ask questions
- If unclear domain intent (e.g., score thresholds, category names), check `ALBUM_FOTOS_README.md` first and then open a short PR or issue requesting clarification.

---
If any of these sections are unclear or you want more examples (for example, a checklist for PRs or a template for database migrations), say which area and I’ll expand the file.