# Scholera LMS Mobile

Flutter mobile prototype for Scholera, an AI-native Learning Management System.

The app is being built for three role-specific experiences:

- Admin: institution overview, departments, professors, and assigned courses.
- Professor: course sections, announcements, modules, uploads, and roadmap coverage.
- Student: enrolled courses, read-only course content, and personal roadmap progress.

## Tech Stack

- Flutter and Dart for native mobile development.
- Riverpod for dependency injection, async state, and MVC-style controllers.
- GoRouter for role-aware navigation and deep links.
- Supabase for auth, database, storage, and optional realtime.

## Current Status

The Flutter app scaffold is in place with:

- iOS and Android targets.
- Material 3 app theme.
- GoRouter route shell.
- Riverpod `ProviderScope`.
- MVC-inspired feature folders.
- Supabase initialization through Dart defines.
- Auth/profile repositories and controller.
- Real email/password login form.
- Role redirects for admin, professor, and student profiles.
- Setup-needed sign-in state when Supabase config is missing.

The Supabase dashboard project, storage buckets, test users, and seed data still need to be created before auth can be verified end to end.

## Setup

```sh
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-public-anon-key
```

Copy `.env.example` to `.env` for local reference if useful. The app reads config through Dart defines so secrets do not need to be committed.

## Supabase

The draft schema lives in `supabase/schema.sql`. It includes the planned tables, enums, indexes, roadmap creation trigger, and draft RLS policies for the three role model.

Use `supabase/WEB_SETUP.md` to configure the Supabase dashboard.

Storage buckets still need to be created in Supabase:

- `avatars`
- `course-content`

## Assignment Context

See `assessment-rubrics.md` for the full take-home assignment requirements and `PROJECT_TRACKER.md` for implementation progress.
