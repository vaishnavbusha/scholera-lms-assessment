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

## 3. Create Storage Buckets

Create these buckets in Supabase Storage:

| Bucket | Purpose |
| --- | --- |
| `avatars` | Profile images |
| `course-content` | Professor-uploaded PDF/PPT course files |

Storage policies still need to be verified before file upload work begins.

## 4. Create Test Users

Create one user for each role:

| Role | Needed For Demo |
| --- | --- |
| Admin | Dashboard, departments, professor assignments |
| Professor | Course management, announcements, modules, roadmap coverage |
| Student | Enrolled courses, read-only content, personal progress |

After each auth user is created, update the matching row in `profiles.role`.

Expected values:

```text
admin
professor
student
```

## 5. Seed Demo Data

Create enough data to support the assignment demo:

- At least one department.
- At least one professor profile assigned to that department.
- At least one student profile.
- At least one course.
- At least one course section taught by the professor.
- At least one enrollment connecting the student to the section.
- At least one announcement.
- At least two modules.
- At least one link item, note item, and file item.
- Topics for module items.
- Student progress rows for at least part of the roadmap.

## 6. Verify Role Access

Before building the full feature screens, test these assumptions:

- Admin can read institution data.
- Professor can read and write only their course content.
- Student can read enrolled course content.
- Student can update only their own progress.
- All roles can read and edit their own profile.

## 7. Current App Behavior

If `SUPABASE_URL` or `SUPABASE_ANON_KEY` is missing, the app shows a setup-needed message on the sign-in screen and disables sign-in.

Once the project URL and anon key are passed in, the app initializes Supabase and sign-in can call the real Supabase Auth API.
