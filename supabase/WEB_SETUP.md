# Supabase Web Setup Checklist

Use this checklist in the Supabase dashboard before expecting the Flutter auth flow to work.

## 1. Create Project

1. Go to the Supabase dashboard.
2. Create a new project.
3. Save the project URL and anon public key.
4. Add them locally using Dart defines when running Flutter:

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-public-anon-key
```

Do not commit real keys to the repository.

## 2. Apply Database Schema

1. Open the SQL editor.
2. Paste the contents of `supabase/schema.sql`.
3. Run the script.
4. Confirm these tables exist:
   - `profiles`
   - `departments`
   - `programs`
   - `courses`
   - `course_sections`
   - `enrollments`
   - `announcements`
   - `modules`
   - `module_items`
   - `roadmap_nodes`
   - `topics`
   - `student_progress`

## 3. Create Storage Buckets And Apply Policies

### 3a. Create buckets

Create these buckets in Supabase Storage:

| Bucket | Visibility | Purpose |
| --- | --- | --- |
| `avatars` | Public | Profile images |
| `course-content` | Private | Professor-uploaded PDF/PPT course files |

### 3b. Path conventions the policies rely on

The app writes uploaded files to paths prefixed by the owning entity:

- `avatars/{user_id}/...`
- `course-content/{section_id}/...`

The `storage.objects` policies in `schema.sql` parse the first folder from the object path and gate access by that id. Uploads that do not follow the convention will be rejected.

### 3c. Apply storage policies

The policies at the bottom of `schema.sql` reference the bucket ids `avatars` and `course-content`. Make sure the buckets exist first, then re-run the storage policy block (or the full script) so the policies bind against real buckets.

Sanity checks after applying:

- Anonymous read of an `avatars` object returns the file.
- A signed-in student cannot upload into `avatars/{another_user_id}/...`.
- A signed-in professor can upload into `course-content/{their_section_id}/...` but not into another professor's section.
- A signed-in student enrolled in a section can read files under `course-content/{that_section_id}/...`.

## 4. Create Test Users

Create one user for each role:

| Role | Needed For Demo |
| --- | --- |
| Admin | Dashboard, departments, professor assignments |
| Professor | Course management, announcements, modules, roadmap coverage |
| Student | Enrolled courses, read-only content, personal progress |

After each auth user is created, the trigger from `schema.sql` creates a matching row in `public.profiles`.

You do not need to update `profiles.role` manually if you run `seed.template.sql` afterward, because the seed script updates the role and profile fields for the three user ids you provide.

Expected values:

```text
admin
professor
student
```

## 5. Seed Demo Data

1. Open `supabase/seed.template.sql`.
2. Replace the three placeholder UUIDs with the real auth user ids.
3. Run the script in the SQL editor.

Important:

- The script inserts the department before assigning `department_id` on professor/student profiles.
- If you ran an older copy of the seed file, use the updated version from the repo and rerun it.

The template creates:

- one department
- one program
- one course
- one course section
- one admin, one professor, and one student profile mapping
- one enrollment
- one announcement
- two modules
- one link item, one note item, and one file item
- roadmap statuses
- extracted topics
- student progress

## 6. Verify Role Access

Before building the full feature screens, test these assumptions:

- Admin can read institution data.
- Professor can read and write only their course content.
- Student can read enrolled course content.
- Student can update only their own progress.
- All roles can read and edit their own profile.

## 7. Demo Credentials

Because this is a take-home submission, the reviewer needs to sign in as each role. Once the three test users are created and seeded, record their emails and passwords in the repository `README.md` under a "Demo Credentials" section so the reviewer can sign in in under 5 minutes.

These credentials exist only in the throwaway demo Supabase project. Do not reuse passwords from any real account.

## 8. Current App Behavior

If `SUPABASE_URL` or `SUPABASE_ANON_KEY` is missing, the app shows a setup-needed message on the sign-in screen and disables sign-in.

Once the project URL and anon key are passed in, the app initializes Supabase and sign-in can call the real Supabase Auth API.
