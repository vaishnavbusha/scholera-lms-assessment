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
- Placeholder role shells for admin, professor, and student.

Supabase auth and real data integration are the next implementation milestone.

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

Storage buckets still need to be created in Supabase:

- `avatars`
- `course-content`

## Assignment Context

See `assessment-rubrics.md` for the full take-home assignment requirements and `PROJECT_TRACKER.md` for implementation progress.
