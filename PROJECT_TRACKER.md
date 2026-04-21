# Scholera Project Tracker

## Current State

- Assignment context has been read from `assessment-rubrics.md`.
- This repository is the submission repository and currently contains the assignment brief, planning docs, and Flutter scaffold.
- Flutter app has been scaffolded for iOS and Android.
- Planned stack: Flutter, Riverpod, Supabase, GoRouter.
- Planned architecture: MVC-inspired features with Riverpod controllers and Supabase repositories.
- Supabase schema plan and Dart define environment foundation have been added.
- Flutter-side Supabase initialization, auth repository, profile repository, auth controller, login form, role redirect, and sign-out hooks have been added.
- Supabase dashboard setup is still pending, so auth is not end-to-end verified yet.
- Plan tweaks (2026-04-19): dropped `freezed` / `json_serializable` / `build_runner` / `flutter_secure_storage` from the dependency plan; added `app_links` for deep linking; scoped the create-item UI to `link` / `note` / `file` only; added explicit `storage.objects` policies to `schema.sql`; enriched `seed.template.sql` to 2 departments, 3 courses, multi-module content; committed to carrying demo credentials in README.
- Auth verified end-to-end (2026-04-19): all three roles sign in on the Android emulator and land on the correct role shell. VS Code launch configs are in `.vscode/launch.json` using `--dart-define-from-file=.env`.
- Phase 3 shared UI system complete (2026-04-19): "studio light" design thesis — single-family **Plus Jakarta Sans** typography, cool neutral canvas (#F6F7F9), saturated role accents (admin cobalt #1D4ED8, professor amber #D97706, student emerald #059669), slate-family ink. Tokens, role theme, and eight reusable primitives (`ScholeraScaffold`, `AsyncContent`, `EmptyState`, `ErrorState`, `LoadingSkeleton`, `StatusPill`, `TopicChip`, `RoleBadge`) live under `lib/app/theme/` and `lib/core/widgets/`. Each role shell wraps itself in `RoleThemeScope` — primitives take no role parameter. Earlier "academic workshop" palette (warm cream + Fraunces serif) was discarded because the cream canvas felt derivative.
- Phase 4 admin experience complete (2026-04-19): stats dashboard + departments list merged on `AdminHomeScreen`, `DepartmentDetailScreen` and `ProfessorDetailScreen` as drill-downs. `AdminRepository` + Riverpod `FutureProvider` family handle the four queries. Pull-to-refresh on every admin screen. All data live from Supabase — no fixtures.
- Phase 5a-5c professor experience (partial) complete (2026-04-19): `ProfessorCoursesScreen` lists sections the professor teaches; `ProfessorCourseScreen` is a tabbed shell (Announcements / Modules / Roadmap); Announcements tab is fully functional with list + `CreateAnnouncementSheet` (modal bottom sheet). Remaining: modules + roadmap.
- Phase 5d-5e professor modules complete (2026-04-20): `ModulesTab` lists modules with nested items (type-iconed rows); `CreateModuleSheet` creates a module with auto-incrementing position; `CreateModuleItemSheet` adds a link / note / file item. File uploads use `file_picker` 11 and store to `course-content/{sectionId}/{timestamp}_{filename}` per the storage path convention. Cleanup on row-insert failure.
- Phase 5f professor roadmap complete (2026-04-20): `ProfessorRoadmapTab` groups modules with items underneath; each item shows extracted topics as `TopicChip`s and a tappable coverage-status picker that updates `roadmap_nodes.professor_status` through `RoadmapRepository`. Shared `RoadmapItemCard` and `RoadmapStatusPicker` widgets so the student roadmap reuses them. Later rebuilt the section layout into a timeline-tree (`RoadmapTimeline`): continuous vertical spine, module nodes, item nodes hanging below.
- Phase 6 student experience complete (2026-04-20): `StudentCoursesScreen` lists enrolled sections; `StudentCourseScreen` is a tabbed shell matching the professor's three-tab layout with emerald accent. `StudentAnnouncementsTab` is read-only with tap-to-open `AnnouncementDetailScreen` (also positioned as the deep-link target). `StudentModulesTab` is read-only. `StudentRoadmapTab` reuses `RoadmapTimeline` with a tappable "You:" picker that upserts `student_progress`, professor coverage shown as a read-only pill next to it.

## Active Decisions

| Decision | Choice | Reason |
| --- | --- | --- |
| Mobile framework | Flutter | User preference and strong native-feeling prototype velocity |
| App architecture | MVC-inspired feature structure | User preference, clear separation between models, views, and controllers |
| State management | Riverpod | Explicit user preference, dependency injection and async controller modeling |
| Backend | Supabase | Required by assignment |
| Navigation | GoRouter | Role guards and deep links are central requirements |
| UI style | Native, restrained, role-aware | Matches rubric emphasis on polish and distinct role experiences |

## Progress Checklist

### Planning

- [x] Read assignment.
- [x] Capture project context.
- [x] Capture implementation plan.
- [x] Capture Supabase assumptions.
- [ ] Confirm actual Supabase schema.
- [x] Confirm this is the final submission repository.

### Foundation

- [x] Scaffold Flutter app.
- [x] Add dependencies.
- [x] Configure environment variables.
- [x] Initialize Supabase.
- [x] Configure app theme (Material 3 + Fraunces/Manrope + role accents).
- [x] Configure GoRouter.
- [x] Add design token system (`lib/app/theme/tokens.dart`, `palette.dart`).
- [x] Add role theme + RoleThemeScope.
- [x] Add shared loading, empty, and error widgets.
- [x] Add StatusPill, TopicChip, RoleBadge primitives.
- [x] Add VS Code launch configs using `--dart-define-from-file=.env`.

### Supabase Backend

- [x] Draft schema SQL.
- [x] Document storage buckets.
- [x] Document Supabase web setup checklist.
- [x] Draft seed data template.
- [x] Add storage.objects policies for `avatars` and `course-content` to schema.
- [x] Enrich seed template (2 departments, 3 courses, multi-module content).
- [ ] Create Supabase project.
- [ ] Apply schema SQL.
- [ ] Create storage buckets.
- [ ] Verify storage policies bound correctly after buckets exist.
- [ ] Create test users.
- [ ] Seed required demo data.
- [ ] Verify RLS with admin, professor, and student users.

### Auth

- [x] Email/password sign-in.
- [x] Session restore.
- [x] Profile role fetch.
- [x] Role-based route redirect.
- [ ] Expired session handling.
- [x] Sign-out from each role.

### Admin

- [x] Dashboard stats (students / professors / courses / departments counts).
- [x] Departments list (merged into the admin home; tapping opens detail).
- [x] Department detail (name, description, assigned professors).
- [x] Professor detail (profile + course sections with joined course info).
- [x] Pull-to-refresh on admin home and detail screens.

### Professor

- [x] Professor course list.
- [x] Course management tabs (Announcements / Modules / Roadmap).
- [x] Announcements list (newest first, with timestamps).
- [x] Create announcement (modal bottom sheet; auto-refresh on success).
- [x] Modules list.
- [x] Create module.
- [x] Add link item.
- [x] Add note item.
- [x] Upload PDF/PPT item.
- [x] Professor roadmap with topics.
- [x] Update professor coverage status.

### Student

- [x] Student course list.
- [x] Course detail tabs (Announcements / Modules / Roadmap, emerald accent).
- [x] Announcements read-only list.
- [x] Announcement detail screen.
- [x] Modules read-only list (items still tappable for link/note/file).
- [x] Student roadmap with topics (reuses `RoadmapTimeline`).
- [x] Show professor coverage status (read-only pill).
- [x] Update student personal progress (tappable "You:" picker upserting `student_progress`).

### Shared

- [ ] View profile.
- [ ] Edit display name.
- [ ] Edit bio.
- [ ] Upload/edit avatar.
- [ ] Add `app_links` dependency.
- [ ] Register `scholera://` URL scheme in iOS `Info.plist`.
- [ ] Register `scholera://` intent-filter in Android `AndroidManifest.xml`.
- [ ] Deep link to announcement.
- [ ] Preserve deep link through login.

### Polish

- [ ] Empty states.
- [ ] Loading skeletons.
- [ ] Friendly error states.
- [ ] Pull-to-refresh on key lists.
- [ ] Optimistic updates where appropriate.
- [ ] Accessibility labels for controls.
- [ ] Performance pass on large lists.

### Submission

- [ ] README setup instructions.
- [ ] README library choices.
- [ ] README demo credentials block (admin/professor/student).
- [ ] README screenshots/GIFs.
- [ ] README known issues.
- [ ] User-authored `AI_ASSISTANT_USAGE.md`.
- [ ] Demo video.
- [ ] Final public GitHub repo link.

## Demo Script Draft

1. Sign in as admin.
2. Show dashboard stats.
3. Open department list.
4. Open department detail.
5. Open professor profile and assigned courses.
6. Sign out.
7. Sign in as professor.
8. Open a course section.
9. Create an announcement.
10. Create a module.
11. Add a link, note, and file item.
12. Open roadmap and update professor coverage status.
13. Sign out.
14. Sign in as student.
15. Open enrolled course.
16. Read announcement detail.
17. View modules.
18. Open roadmap, compare professor coverage with student progress, and mark progress.
19. Show profile edit.
20. Show deep link behavior if available in the demo environment.

## Risks To Watch

- Backend schema may not match assignment terminology.
- RLS may block expected demo queries.
- File upload policies rely on the `{bucket}/{id}/...` path convention — uploads that skip the id prefix will be rejected.
- Deep linking can take longer than expected on simulator if bundle scheme config is late.
- Final app cannot rely on mocked data, so Supabase seed data is critical.
- `AI_ASSISTANT_USAGE.md` must be written by the user, not generated.
- Admin dashboard counts will look small with only 3 demo auth users (1 admin, 1 professor, 1 student). This is acceptable for the prototype rubric but worth noting in the README known-issues section.

## Next Best Action

Phases 4, 5, and 6 are complete — all three role experiences are live end-to-end against Supabase. Next is Phase 7: shared flows. Profile view + edit (any role), avatar upload to the `avatars` bucket, deep linking for `scholera://courses/{id}/announcements/{id}` via `app_links`, iOS `Info.plist` URL scheme, and Android `AndroidManifest.xml` intent-filter. Then Phase 8: polish (expired-session handling, pull-to-refresh audit) and the README + demo credentials + screenshots pass.

## Commit Checkpoints

Commit when a checkpoint is coherent, builds if code exists, and the tracker reflects the current state.

Before any commit:

- Re-check `assessment-rubrics.md` against the completed task.
- Run the relevant formatter/analyzer/tests for the changed area when available.
- Check `git status`.
- Include only changes that belong to the task unless the user says otherwise.
- Use the user's existing git author identity.

Suggested commits:

1. `docs: capture scholera project plan`
   - Include `PROJECT_CONTEXT.md`, `IMPLEMENTATION_PLAN.md`, `SUPABASE_CONTRACT.md`, `PROJECT_TRACKER.md`, and `HANDOFF.md`.
   - Good to commit now if you want the planning baseline saved.
2. `chore: scaffold flutter app`
   - Flutter project created.
   - Dependencies added.
   - App launches to a placeholder screen.
3. `feat: add auth and role routing`
   - Supabase initialized.
   - Sign-in/sign-out works.
   - Profile role routes to admin, professor, or student shell.
4. `feat: add admin experience`
   - Admin dashboard, departments, department detail, professor detail.
5. `feat: add professor course management`
   - Professor courses, announcements, modules, item creation, file upload.
6. `feat: add roadmap flows`
   - Professor coverage and student progress are separate and functional.
7. `feat: add student course experience`
   - Student courses, read-only announcements/modules, roadmap progress.
8. `feat: add profile and deep links`
   - Profile editing and announcement deep links.
9. `polish: improve states and submission docs`
   - Empty/loading/error states, README, screenshots, known issues.
