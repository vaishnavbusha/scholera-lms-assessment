# Supabase Setup

This folder contains the planned database contract for the Scholera mobile prototype.

## Files

| File | Purpose |
| --- | --- |
| `schema.sql` | Tables, enums, helper functions, roadmap trigger, indexes, and draft RLS policies |
| `WEB_SETUP.md` | Dashboard checklist for creating the Supabase project, buckets, users, and seed data |
| `seed.template.sql` | Demo data template for one admin, one professor, one student, one course section, modules, topics, and progress |

## Setup Order

1. Create a Supabase project.
2. Open the SQL editor.
3. Run `schema.sql`.
4. Create auth users for admin, professor, and student.
5. Replace the placeholder UUIDs in `seed.template.sql`.
6. Run `seed.template.sql`.
7. Create storage buckets:
   - `avatars`
   - `course-content`

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

Use `WEB_SETUP.md` as the practical checklist while configuring the dashboard.
