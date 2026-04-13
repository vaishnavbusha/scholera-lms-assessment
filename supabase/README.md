# Supabase Setup

This folder contains the planned database contract for the Scholera mobile prototype.

## Files

| File | Purpose |
| --- | --- |
| `schema.sql` | Tables, enums, helper functions, roadmap trigger, indexes, and draft RLS policies |

## Setup Order

1. Create a Supabase project.
2. Open the SQL editor.
3. Run `schema.sql`.
4. Create storage buckets:
   - `avatars`
   - `course-content`
5. Create one test auth user for each role:
   - admin
   - professor
   - student
6. Update the generated `profiles.role` values.
7. Insert seed departments, courses, sections, enrollments, modules, module items, roadmap statuses, topics, and student progress.

## App Environment

The Flutter app reads Supabase config through Dart defines:

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-public-anon-key
```

Copy `.env.example` to `.env` for local reference if useful, but do not commit real credentials.

## Verification

Before wiring feature repositories, confirm this schema against the actual Supabase project and update `SUPABASE_CONTRACT.md` if anything differs.
