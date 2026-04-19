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
  - `file_picker`
  - `cached_network_image`
  - `intl`
  - `url_launcher`
  - `app_links` — receive `scholera://` deep links on iOS and Android
  - `shimmer` or a small custom skeleton implementation
- Add dev packages:
  - `flutter_lints`

Codegen decision: models are hand-written Dart classes with manual `fromJson` / `toJson`. `freezed`, `json_serializable`, and `build_runner` were evaluated and skipped — the data surface is small enough that codegen overhead is not justified.
- Set up `.env` loading or compile-time defines for Supabase URL and anon key.
- Add initial README sections early so setup stays documented as the app grows.

Current decision: read Supabase config through Dart defines in `lib/app/env.dart`; keep `.env` as a private local reference file only.

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

- Apply `supabase/schema.sql` to the Supabase project.
- Create `avatars` and `course-content` storage buckets.
- Initialize Supabase in `main.dart`. Done app-side.
- Add `AuthRepository`. Done app-side.
- Add `ProfileRepository`. Done app-side.
- Add `SessionController` or equivalent Riverpod notifier. Done app-side as `AuthController`.
- Implement sign-in, sign-out, session restore, and profile role fetch. App-side code exists; Supabase dashboard verification is still required.
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

## Phase 3: Shared UI System — COMPLETE (2026-04-19)

### Design thesis: "studio light"

Crisp modern product surface. Cool neutral canvas, saturated role accents, slate-family ink. Single-family sans typography. No warm cream, no editorial softness. Reads like a contemporary productivity app (Linear/Notion adjacent) rather than a scholarly journal.

An earlier iteration used warm cream + Fraunces serif ("academic workshop"). User feedback pushed it away from that direction because the cream canvas felt derivative — pivoted to the cooler, confident direction captured here.

### Typography

- Single family: **Plus Jakarta Sans** (weights 400/500/600/700/800).
- Delivered via `google_fonts` runtime loader (fine for prototype; bundle as assets later if cold start becomes an issue).

### Palette

- Canvas: paper `#F6F7F9`, surface `#FFFFFF`, surface muted `#F1F3F6`, outline `#E6E8EC`, outline-strong `#CBD1DA`.
- Ink: primary `#0F172A`, muted `#475569`, subtle `#94A3B8`.
- Role accents:
  - Admin — cobalt `#1D4ED8` (institutional, confident).
  - Professor — amber `#D97706` (warmth on a cool canvas, authorial).
  - Student — emerald `#059669` (progress, focused).
- Neutral (pre-auth): slate `#1E293B`.
- Status: not_started `#94A3B8`, in_progress `#F59E0B`, complete `#10B981`.
- Signals: error `#DC2626`, info `#2563EB`.

### Token + theme structure

```text
lib/app/theme/
  tokens.dart            Spacing, Radii, Elevation, Motion
  palette.dart           raw colors
  role_theme.dart        RoleTheme per AppRole + neutral
  app_theme.dart         buildAppTheme(RoleTheme) → ThemeData
  role_theme_scope.dart  inherited widget that applies a role's theme to a subtree
```

Each role shell wraps its subtree in `RoleThemeScope.forAppRole(...)`. Every primitive reads its accent from `Theme.of(context)` — **no widget takes a role parameter**. Adding a fourth role later means one new entry in `role_theme.dart`.

### Primitives

```text
lib/core/widgets/
  scholera_scaffold.dart  two factories: .list and .custom; optional RoleBadge in the app bar
  async_content.dart      wraps AsyncValue<T> into loading/data/error consistently
  empty_state.dart        serif title + sans body + optional action
  error_state.dart        calm phrasing, retry button
  loading_skeleton.dart   Bar, Card, List variants using shimmer
  status_pill.dart        dot + label, reads ProgressStatus enum
  topic_chip.dart         left-edge role-accent border, AI-extracted topic labels
  role_badge.dart         serif initial in role-tinted circle
```

### Definition of done (met)

- Loading, empty, and error states exist before feature screens multiply.
- Three role shells look distinct at a glance (app bar tint, primary buttons, badge).
- No widget couples itself to a role — every primitive stays reusable.
- `flutter analyze` passes clean across the theme + widgets layer.

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
- Surface only `link`, `note`, and `file` in the create-item UI. The `lecture` and `video` enum values stay in the schema but are not exposed as create options in this prototype.

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

- Use the `app_links` package to receive initial and runtime deep links.
- Register the URL scheme on each platform:
  - iOS: add `CFBundleURLTypes` entry with `CFBundleURLSchemes = ["scholera"]` in `ios/Runner/Info.plist`.
  - Android: add an `intent-filter` with `android:scheme="scholera"` in `android/app/src/main/AndroidManifest.xml`.
- Add a GoRouter route for `courses/:courseId/announcements/:announcementId`.
- Forward incoming links into GoRouter; if unauthenticated, stash the intended path and replay it after login succeeds.
- Validate the user actually has access to the target announcement after routing (teaches the section, enrolled in the section, or admin) and fall back to a friendly not-found state if not.

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
