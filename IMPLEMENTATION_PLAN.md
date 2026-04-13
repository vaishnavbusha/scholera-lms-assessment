# Scholera Flutter Implementation Plan

## Working Rule

Complete the required assignment first, then add stretch goals only when the core demo path is reliable.

After every implementation task, re-check `assessment-rubrics.md` and confirm the work still satisfies the assignment rather than drifting into nice-but-unrequired scope.

The app should always have a demoable vertical path for all three roles:

1. Sign in.
2. Land in the correct role experience.
3. Navigate to role-specific course or institution data.
4. Show modules and roadmap topics.
5. Update the writeable state for that role.
6. Sign out.

## Phase 0: Repository Setup

- Use this repository as the final submission repository.
- Scaffold Flutter app in this repository.
- Add Flutter SDK constraints.
- Add baseline packages:
  - `flutter_riverpod`
  - `supabase_flutter`
  - `go_router`
  - `freezed_annotation`
  - `json_annotation`
  - `file_picker`
  - `cached_network_image`
  - `intl`
  - `url_launcher`
  - `flutter_secure_storage` if needed beyond Supabase defaults
  - `shimmer` or a small custom skeleton implementation
- Add dev packages:
  - `build_runner`
  - `freezed`
  - `json_serializable`
  - `flutter_lints`
- Set up `.env` loading or compile-time defines for Supabase URL and anon key.
- Add initial README sections early so setup stays documented as the app grows.

## Phase 1: App Architecture

Target folder layout:

```text
lib/
  main.dart
  app/
    scholera_app.dart
    router.dart
    theme.dart
    env.dart
  core/
    errors/
    loading/
    widgets/
    utils/
  features/
    auth/
      models/
      views/
      controllers/
    profile/
      models/
      views/
      controllers/
    admin/
      models/
      views/
      controllers/
    professor/
      models/
      views/
      controllers/
    student/
      models/
      views/
      controllers/
    courses/
      models/
      views/
      controllers/
    announcements/
      models/
      views/
      controllers/
    modules/
      models/
      views/
      controllers/
    roadmap/
      models/
      views/
      controllers/
  data/
    supabase/
    repositories/
```

Architecture choices:

- Use MVC-inspired boundaries inside each feature.
- Models represent typed domain data and JSON conversion.
- Views are Flutter widgets and screens only.
- Controllers own user actions, screen state, form submission, optimistic updates, and coordination between repositories and views.
- Repositories are the only place that talks directly to Supabase tables/storage.
- Use Riverpod providers to create repositories, expose controllers, and model async state.
- Keep UI role-specific, but reuse lower-level course/module/roadmap views where behavior is truly shared.
- Prefer `AsyncValue` for loading/error/data surfaces.
- Keep route guards centralized in `go_router`.

MVC mapping:

| MVC Part | Flutter Implementation |
| --- | --- |
| Model | Dart data classes, enums, JSON serializers, simple domain helpers |
| View | Screens, widgets, forms, bottom sheets, tab views |
| Controller | Riverpod `Notifier`, `AsyncNotifier`, or plain controller class exposed by providers |
| Data boundary | Repository classes wrapping Supabase queries and storage calls |

## Phase 2: Supabase Foundation

- Initialize Supabase in `main.dart`.
- Add `AuthRepository`.
- Add `ProfileRepository`.
- Add `SessionController` or equivalent Riverpod notifier.
- Implement sign-in, sign-out, session restore, and profile role fetch.
- Define typed role enum:
  - `admin`
  - `professor`
  - `student`
- Define route guard behavior:
  - No session -> login.
  - Session without profile loaded -> loading shell.
  - Session with role -> role root.
  - Deep link target -> preserve requested path and complete after login.

Definition of done:

- Three test users can sign in and land in three different role shells.
- Session survives hot restart/app restart.
- Sign-out returns to login.

## Phase 3: Shared UI System

- Build app theme with a clean Material 3 base.
- Define spacing, text styles, semantic colors, status colors, and role accents.
- Build shared widgets:
  - `ScholeraScaffold`
  - `AsyncContent`
  - `EmptyState`
  - `ErrorState`
  - `LoadingSkeleton`
  - `StatusPill`
  - `TopicChip`
  - `AvatarPicker`
  - `RoleSwitcherDebugBanner` only for development if useful
- Keep product copy practical and user-facing.

Definition of done:

- Loading, empty, and error states exist before feature screens multiply.
- App has a consistent visual rhythm.

## Phase 4: Admin Experience

Screens:

- `AdminHomeScreen`
- `DepartmentsScreen`
- `DepartmentDetailScreen`
- `ProfessorDetailScreen`
- `AdminProfileScreen`

Data:

- Counts for students, professors, courses, departments.
- Departments with assigned professors.
- Professor profile and assigned courses.

Implementation notes:

- Keep admin dashboard compact and operational.
- Use lists and metrics with minimal chrome.
- Surface data freshness and empty states.

Definition of done:

- Admin can sign in, see stats, open department, open professor, and return predictably.

## Phase 5: Professor Experience

Screens:

- `ProfessorCoursesScreen`
- `ProfessorCourseScreen` with tabs:
  - Announcements
  - Modules
  - Roadmap
- `CreateAnnouncementSheet`
- `CreateModuleSheet`
- `CreateModuleItemSheet`
- `ProfessorProfileScreen`

Data operations:

- Fetch professor course sections.
- Fetch/create announcements.
- Fetch/create modules.
- Fetch/create module items.
- Upload PDF/PPT files to Supabase Storage.
- Fetch roadmap tree with topics.
- Update professor coverage status.

Implementation notes:

- Module management is the most important professor feature.
- Use optimistic UI for simple creates and status changes when safe.
- Make item type visually obvious through label and icon.

Definition of done:

- Professor can create an announcement.
- Professor can create a module.
- Professor can add a link, note, and file item.
- Professor can view roadmap topics.
- Professor can update coverage status.

## Phase 6: Student Experience

Screens:

- `StudentCoursesScreen`
- `StudentCourseScreen` with tabs:
  - Announcements
  - Modules
  - Roadmap
- `AnnouncementDetailScreen`
- `StudentProfileScreen`

Data operations:

- Fetch enrolled courses.
- Fetch announcements read-only.
- Fetch modules/items read-only.
- Fetch roadmap with professor coverage and student progress.
- Update student personal progress.

Implementation notes:

- Make professor coverage and student progress visually distinct.
- Student should never see professor create/edit controls.
- Student progress updates should be easy and immediate.

Definition of done:

- Student can sign in, open a course, read announcement detail, view modules, and mark roadmap progress.

## Phase 7: Profile And Deep Links

Profile:

- Fetch profile for current user.
- Edit display name and bio.
- Upload/change avatar if storage policies allow it.
- Show save, loading, success, and error states.

Deep linking:

- Configure URL scheme `scholera://`.
- Add route for course announcement detail.
- Preserve intended route through login.
- Validate authorization after route opens.

Definition of done:

- All roles can edit profile.
- A direct announcement link opens the right announcement after auth.

## Phase 8: Data Hardening And Edge Cases

- Add friendly messages for empty courses, no modules, no announcements, no roadmap topics.
- Add retry actions for failed loads.
- Handle missing profile role.
- Handle forbidden/unauthorized records.
- Handle file upload failures.
- Add pull-to-refresh on primary list screens.
- Avoid duplicate submissions on create forms.

Definition of done:

- The app fails softly and tells the user what happened.

## Phase 9: Polish And Stretch Goals

Only after required scope is demoable:

- Realtime announcements with Supabase Realtime.
- Local notification for new announcement.
- Biometric auth.
- Animated transitions for role shell and course detail.
- Lecture insights with Gemini.

Recommended stretch order:

1. Realtime announcements.
2. Animated transitions.
3. Biometric auth.
4. Gemini lecture insights.

## Phase 10: Submission Package

- Write README with:
  - Setup under 5 minutes.
  - Environment variables.
  - Framework and library choices.
  - Test credentials.
  - Screenshots/GIFs for admin, professor, student.
  - Known issues.
- User writes `AI_ASSISTANT_USAGE.md`.
- Record 5 to 10 minute demo:
  - Admin login and department/professor view.
  - Professor login, module creation, item creation, roadmap status.
  - Student login, course view, roadmap progress.
  - Any stretch goals.
- Push final code to the new public repo.

## Suggested Build Order

1. Scaffold Flutter app and routing.
2. Wire Supabase auth and profile role fetch.
3. Build typed models and repositories.
4. Build admin read-only flow.
5. Build professor course, announcement, module, and roadmap write flows.
6. Build student course, announcement, module, and roadmap progress flows.
7. Build profile editing.
8. Add deep links.
9. Polish empty/loading/error states.
10. Prepare README, screenshots, and demo.
