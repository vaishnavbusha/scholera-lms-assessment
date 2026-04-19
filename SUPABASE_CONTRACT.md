# Supabase Contract And Data Assumptions

## Purpose

This file tracks expected Supabase tables, fields, relationships, storage buckets, and policy assumptions so implementation stays grounded. Update it whenever the actual backend schema differs.

## Environment

Expected app configuration:

```text
SUPABASE_URL=
SUPABASE_ANON_KEY=
```

Do not commit secret keys. The anon key is acceptable for client use when Row Level Security is configured correctly, but keep environment files out of public commits unless intentionally using sample values.

Current app config foundation:

- `.env.example` documents the required values.
- `.env` is ignored for private local use.
- `lib/app/env.dart` reads config through Dart defines:
- `lib/main.dart` initializes Supabase only when both values are present.
- The login screen shows a setup-needed state when either value is missing.

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-public-anon-key
```

The app does not read `.env` directly yet.

## Auth

Supabase Auth handles email/password login.

The authenticated user's app role is expected to be stored in a profile table, not in hardcoded app logic.

## Expected Tables

These names are assumptions until confirmed against the real Supabase schema.

A draft implementation plan exists in `supabase/schema.sql`. Treat it as the local contract until the Supabase project is created and verified.

### profiles

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid | Matches `auth.users.id` |
| role | text | `admin`, `professor`, or `student` |
| display_name | text | Editable by owner |
| bio | text | Editable by owner |
| avatar_url | text | Editable by owner |
| department_id | uuid | Optional for professor/student |
| created_at | timestamptz | Read-only |
| updated_at | timestamptz | Updated on profile edit |

### departments

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid | Primary key |
| name | text | Department name |
| description | text | Optional |
| created_at | timestamptz | Read-only |

### programs

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid | Primary key |
| department_id | uuid | Parent department |
| name | text | Program name |
| description | text | Optional |

### courses

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid | Primary key |
| department_id | uuid | Parent department |
| code | text | Example: CS 201 |
| title | text | Course title |
| description | text | Optional |

### course_sections

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid | Primary key |
| course_id | uuid | Parent course |
| professor_id | uuid | Profile id for professor |
| term | text | Example: Spring 2026 |
| section_code | text | Example: A |

### enrollments

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid | Primary key |
| section_id | uuid | Course section |
| student_id | uuid | Profile id for student |
| created_at | timestamptz | Read-only |

### announcements

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid | Primary key |
| section_id | uuid | Course section |
| professor_id | uuid | Author |
| title | text | Required |
| body | text | Required |
| created_at | timestamptz | Sort descending |
| updated_at | timestamptz | Optional |

### modules

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid | Primary key |
| section_id | uuid | Course section |
| title | text | Required |
| position | int | Order inside course |
| created_at | timestamptz | Read-only |

### module_items

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid | Primary key |
| module_id | uuid | Parent module |
| section_id | uuid | Denormalized for easier querying if available |
| title | text | Required |
| item_type | text | `link`, `note`, `file`, `lecture`, `video` |
| url | text | For links/files/videos |
| body | text | For notes |
| storage_path | text | For uploaded files |
| position | int | Order inside module |
| created_at | timestamptz | Read-only |

### roadmap_nodes

If roadmap is generated from modules/items, this may be a view rather than a table.

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid | Primary key |
| section_id | uuid | Course section |
| module_id | uuid | Related module |
| module_item_id | uuid | Related item |
| professor_status | text | `not_started`, `in_progress`, `complete` |
| updated_at | timestamptz | Read-only |

### topics

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid | Primary key |
| module_item_id | uuid | Related item |
| title | text | Extracted topic label |
| confidence | numeric | Optional |
| created_at | timestamptz | Read-only |

### student_progress

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid | Primary key |
| student_id | uuid | Profile id |
| module_item_id | uuid | Related item |
| status | text | `not_started`, `in_progress`, `complete` |
| updated_at | timestamptz | For display/sync |

## Storage Buckets

Expected buckets:

| Bucket | Purpose |
| --- | --- |
| avatars | Profile images |
| course-content | Professor uploaded PDF/PPT files |

These buckets must be created in Supabase Storage separately from `schema.sql`. The bucket rows themselves are created via the dashboard; the access policies live on `storage.objects` and are applied by `schema.sql` once the buckets exist.

### Storage Policies

| Bucket | Read | Write | Notes |
| --- | --- | --- | --- |
| avatars | Public | Authenticated user may insert/update/delete rows under a path prefixed with their own `auth.uid()` | Public read matches the "avatar on profile card" use case. Path convention: `avatars/{user_id}/...` |
| course-content | Admin, section professor, and enrolled students in that section | Section professor only | The bucket is private. Path convention: `course-content/{section_id}/...` so RLS can gate by `section_id` using `teaches_section` / `enrolled_in_section` helpers. |

The `storage.objects` policies must be able to infer `section_id` from the object path. The app is responsible for writing uploads to a path that begins with the owning `section_id`.

## Repository Responsibilities

| Repository | Responsibilities |
| --- | --- |
| AuthRepository | Sign in, sign out, session stream |
| ProfileRepository | Current profile, update profile, avatar upload |
| AdminRepository | Stats, departments, professor detail |
| CourseRepository | Professor courses, student courses, course detail |
| AnnouncementRepository | List, detail, create, realtime optional |
| ModuleRepository | List modules/items, create module, create item, upload file |
| RoadmapRepository | Fetch roadmap tree, update professor coverage, update student progress |

## RLS Expectations

These are behavior expectations from the assignment:

- Admin can read institution-level department, professor, student, course, and program data.
- Professor can read and manage course sections they teach.
- Professor can create announcements/modules/items for their own sections.
- Student can read enrolled course content.
- Student can update only their own progress.
- Any user can read and update their own profile.
- Students can see profiles of students who are part of the same class if the backend supports it.

## Schema Verification Checklist

When Supabase access is available:

- [x] Draft local schema plan.
- [x] Add local app config keys.
- [x] Add Supabase web setup checklist.
- [ ] Apply `supabase/schema.sql` to Supabase.
- [ ] Confirm table names.
- [ ] Confirm profile role column.
- [ ] Confirm course/section relationship.
- [ ] Confirm professor-course assignment relationship.
- [ ] Confirm student enrollment relationship.
- [ ] Confirm announcement columns.
- [ ] Confirm module and module item columns.
- [ ] Create and confirm file storage buckets and upload policies.
- [ ] Confirm roadmap trigger creates nodes from module items.
- [ ] Confirm extracted topics relationship.
- [ ] Confirm student progress table and allowed statuses.
- [ ] Confirm RLS behavior for all three roles.
- [ ] Add seed/test credentials to private notes, not committed public docs.

## Open Questions

- Are course sections modeled separately from courses in the actual backend?
- Is roadmap stored as its own table/view, or should the app compose it from modules and module items?
- Are professor coverage statuses stored on `roadmap_nodes`, `module_items`, or another table?
- Are topics linked to roadmap nodes or directly to module items?
- Does the backend expose RPCs for admin counts, or should counts be queried directly?
- Are avatar and course file uploads already configured in storage buckets?
- Is there a required URL scheme or app bundle identifier for deep links?
