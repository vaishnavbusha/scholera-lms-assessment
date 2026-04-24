# Scholera Handoff

Use this file when starting a new Codex conversation so the project context does not need to be re-explained.

## One-Line Summary

Build a Flutter mobile app for Scholera, an AI-native LMS, with Supabase auth/data, three role-specific experiences, MVC-inspired architecture, Riverpod controllers, and a polished native UI.

## Repository Status

- This is the submission repository.
- `assessment-rubrics.md` was copied here from the assessment repository as local context.
- The Flutter app is scaffolded for iOS and Android and runs on the Android emulator.
- Riverpod + GoRouter + Material 3 + MVC feature structure in place.
- Supabase project is live: schema, storage policies, buckets (`avatars` public, `course-content` private), three auth users (admin / professor / student), and the enriched demo seed are applied.
- **Auth is verified end-to-end.** All three roles sign in and land in the correct role shell on the Android emulator.
- **Phase 3 shared UI system is complete.** "Studio light" design: single-family Plus Jakarta Sans typography, cool neutral canvas, saturated role accents (admin cobalt, professor amber, student emerald). Tokens, `RoleThemeScope`, and eight reusable primitives live under `lib/app/theme/` and `lib/core/widgets/`.
- **Phase 4 admin experience is complete.** Dashboard stats (students/professors/courses/departments) + departments list on the admin home, `DepartmentDetailScreen` and `ProfessorDetailScreen` as drill-downs, all behind `AdminRepository` + Riverpod `FutureProvider` family. Pull-to-refresh on every admin screen.
- **Phase 5 professor experience is complete.** Professor course list, tabbed `ProfessorCourseScreen` (Announcements, Modules, Roadmap). Announcement create-sheet, module create-sheet, item create-sheet with type picker (link / note / file) including PDF/PPT upload to `course-content/{sectionId}/...`. Roadmap tab: timeline-tree layout with extracted topics and tappable coverage status picker updating `roadmap_nodes.professor_status`. All operations go through RLS-gated Supabase calls.
- **Phase 6 student experience is complete.** `StudentCoursesScreen` enrolled-sections list. `StudentCourseScreen` three-tab shell: read-only announcements (tap → `AnnouncementDetailScreen`), read-only modules (items still tappable for link/note/file), and a student roadmap reusing `RoadmapTimeline` with a tappable "You:" progress picker that upserts `student_progress`.
- **Phase 7 shared flows are complete.** `ProfileScreen` is shared across roles with avatar upload to `avatars/{userId}/...`, editable display name + bio, and sign-out; access via a tappable role badge in each role home's app bar (no separate icon button). Deep linking uses the `app_links` package + `scholera://` URL scheme registered in iOS `Info.plist` and Android `AndroidManifest.xml`; `DeepLinkController` holds the pending URI, and the router consumes it after auth, so links arriving pre-login are replayed after sign-in.
- Planning docs are kept current — treat `PROJECT_TRACKER.md` as the canonical status board.

## Launch

Use VS Code's **Run and Debug** panel → pick "Scholera (debug)" → F5.

The config at `.vscode/launch.json` passes `--dart-define-from-file=.env`. `.env` is gitignored and contains the Supabase URL + publishable key. `env.dart` accepts either `SUPABASE_ANON_KEY` or the newer `SUPABASE_PUBLISHABLE_KEY` name.

## Required Reading For Future Conversations

Read these files before making project decisions:

1. `assessment-rubrics.md`
2. `PROJECT_CONTEXT.md`
3. `IMPLEMENTATION_PLAN.md`
4. `SUPABASE_CONTRACT.md`
5. `PROJECT_TRACKER.md`
6. `HANDOFF.md`

Before closing any implementation task, re-check `assessment-rubrics.md` against the work completed in that task. Update `PROJECT_TRACKER.md` if the task changes feature status, risks, assumptions, or submission readiness.

## Current Technical Decisions

| Area | Decision |
| --- | --- |
| Framework | Flutter |
| Language | Dart |
| Architecture | MVC-inspired feature structure |
| State management | Riverpod |
| Navigation | GoRouter |
| Backend | Supabase Auth, Database, Storage, optional Realtime |
| UI direction | Native, polished, role-aware, practical product copy |

## Architecture Reminder

Feature folders should follow MVC-style organization:

```text
features/
  feature_name/
    models/
    views/
    controllers/
```

Supabase calls should stay in repositories:

```text
data/
  supabase/
  repositories/
```

Riverpod should expose repositories and controllers. Views should not directly query Supabase.

## Build Priority

Steps 1–4 are **done**. Next active step is 5.

1. ~~Create/configure Supabase project using `supabase/schema.sql`.~~
2. ~~Create buckets, test users, and seed data.~~
3. ~~Verify auth and role-based routing end to end.~~
4. ~~Build shared UI states (tokens, role theme, primitives).~~
5. ~~Build admin read flow (dashboard stats, departments, department detail, professor detail).~~
6. ~~Build professor course/module/announcement/roadmap write flow.~~
7. ~~Build student course/module/announcement/roadmap progress flow.~~
8. ~~Add profile editing.~~
9. ~~Add deep links (`app_links`, iOS `Info.plist`, Android `AndroidManifest.xml`).~~
10. Polish states, write README (with demo credentials block), record demo.

## Critical Gotchas (learned the hard way — don't repeat)

- **Router is created once per app lifetime.** The `appRouterProvider` must NOT `ref.watch(authControllerProvider)` — that tears down the navigator on every auth transition and wipes screen state (login text fields clear mid-sign-in). Instead, a `_RouterRefreshNotifier` subscribes to auth + deep-link changes and fires `notifyListeners()`; GoRouter's `refreshListenable` re-runs `redirect` without recreating the router. Adding or renaming routes requires **hot restart**, not hot reload.
- **Flutter page transitions**: Android's default `ZoomPageTransitionsBuilder` felt janky against screens that load skeletons mid-animation. Theme overrides it to `CupertinoPageTransitionsBuilder` on both platforms for a clean slide.
- **PostgREST embedded 1-to-1 fields** can come back as **either a list or a single object** depending on unique-constraint detection. `RoadmapItem.fromJson` uses an `_asRowList` helper that normalizes both shapes. Any future model that embeds a unique-related row should do the same.
- **`DecoratedBox` forbids per-side border colors** when a `borderRadius` is set. Use a uniform border + an inline element (e.g. a dot, a left-column bar) for accent effects. `TopicChip` was rebuilt around a leading colored dot for this reason.
- **`Spacer()` inside a `SingleChildScrollView`** crashes with "non-zero flex but unbounded height." Wrap the Column in `IntrinsicHeight` and use `Expanded(child: SizedBox.shrink())` instead. Login screen footer-push uses this pattern.
- **Login `isConfigured` is derived from env**, not from auth state. If you read `authState.value?.isSupabaseConfigured`, it becomes `null` during the `AsyncLoading` transition, the "setup needed" banner flickers, the Column children shift, and TextFormFields remount with their content appearing blank for a frame. `env.hasSupabaseConfig` stays stable.
- **`file_picker` 11.x API changed**: call `FilePicker.pickFiles(...)` directly — not `FilePicker.platform.pickFiles(...)`.
- **Avatar upload URL caching**: Supabase's CDN caches public URLs aggressively. Use timestamped filenames (`{userId}/{timestamp}_{name}`) so re-uploads produce new URLs and update immediately in the UI.
- **Only link items launch the external browser.** Notes and files surface in-app modal sheets. Link items use `LaunchMode.externalApplication`. Files render metadata in a sheet (no preview, no download launch) — the `createSignedUrlFor` helper was intentionally removed.
- **Module item creation writes roadmap nodes via trigger.** `schema.sql` has a trigger on `module_items` insert that creates the matching `roadmap_nodes` row with default `professor_status = 'not_started'`. Client doesn't need to create these manually.
- **Storage path conventions are RLS-gated:**
  - `avatars/{auth.uid()}/...` — owner write, public read.
  - `course-content/{section_id}/...` — section professor writes, admin + enrolled students + teaching professor read.
  - Uploads that skip the prefix get rejected by storage.objects policies.
- **Supabase API key naming**: accept either `SUPABASE_ANON_KEY` or `SUPABASE_PUBLISHABLE_KEY` in `env.dart` — Supabase renamed "anon" to "publishable" in recent dashboard UIs.
- **Role coupling rule**: primitives in `lib/core/widgets/` and `lib/features/roadmap/views/widgets/` must not take a `role` parameter. Each role shell wraps itself in `RoleThemeScope.forAppRole(role: ...)`; primitives read accent from `Theme.of(context)`. Adding a fourth role = one entry in `role_theme.dart`, zero widget changes.
- **Truncate cascade surprise**: when re-seeding, don't `truncate public.departments ... cascade`. The `profiles.department_id` FK causes the cascade to wipe `profiles`, breaking FKs from everything else. Use `delete from public.departments` (respects `on delete set null`) or exclude it from the truncate list.

## Deep Link Surface

Supported URL: `scholera://courses/{sectionId}/announcements/{announcementId}`
Maps to: `/student/courses/{sectionId}/announcements/{announcementId}`
Unauthenticated taps are held in `DeepLinkController` state and replayed by the router redirect once auth completes. Test via:

```sh
# Android emulator:
adb shell am start -W -a android.intent.action.VIEW \
  -d "scholera://courses/<SECTION>/announcements/<ID>" \
  com.example.scholera_lms_assessment

# iOS simulator:
xcrun simctl openurl booted "scholera://courses/<SECTION>/announcements/<ID>"
```

## Recent Commits (newest first)

```text
40da34f feat: deep linking and tappable role badge for profile access
19d25ee feat: shared profile screen with avatar upload and name/bio edit
dfc15e1 feat: keep non-link module items in-app instead of launching externally
7c16803 feat: timeline-tree roadmap plus roadmap and module polish
a13497d feat: student experience — courses, tabs, announcement detail, progress
c863b9d feat: professor roadmap tab with topics and coverage toggle
3eed425 feat: professor modules tab with create module and add item
88d3e7d feat: professor courses, tabbed course shell, announcements tab
2ce900c feat: admin experience and stable router across auth transitions
bd348ee feat: phase 3 shared UI system with studio light palette
f844cb7 chore: refine plan and harden supabase foundation
9345a62 feat: add Supabase auth foundation
9509365 chore: scaffold Flutter app and Supabase project foundation
```

## What's Left

1. **README.md** — setup instructions (under 5 min), library + "why" for each major choice, demo credentials (admin / professor / student), screenshots or GIFs across all three roles, known issues.
2. **AI_ASSISTANT_USAGE.md** — **written by the user**, not generated.
3. **Demo video** — 5 to 10 minutes covering all three roles, including module creation, item upload, roadmap coverage toggle, student progress, deep link behavior.
4. **Smoke tests worth running before submission:**
   - Sign in as each of the three roles and walk the main path
   - Upload a PDF as professor, verify it lands in `course-content/{section}/`
   - Toggle coverage → check `roadmap_nodes.professor_status` in Supabase
   - Upload an avatar → check it lands in `avatars/{user}/`
   - Fire a deep link while signed out — confirm it replays after sign-in
   - Delete all announcements in a section in Supabase → refresh tab → confirm the empty state renders
5. **Optional stretch** (rubric says these strengthen the profile): push notifications, biometric, animated transitions (beyond what's already there), Supabase Realtime announcements, Gemini lecture insights.

## Important Assignment Constraints

- Final data must come from Supabase, not hardcoded fixtures.
- The professor and student roadmap statuses are separate:
  - Professor status means the lecture has been taught.
  - Student status means the student has studied it.
- Module management is the foundation of the professor experience and should be prioritized.
- `AI_ASSISTANT_USAGE.md` must be written by the user, not generated by Codex.
- README needs setup instructions, library choices, screenshots/GIFs, known issues, and demo link.
- Demo video should be 5 to 10 minutes and cover all three roles.

## Commit Guidance

Use `PROJECT_TRACKER.md` as the commit checkpoint list. A good first commit is:

```text
docs: capture scholera project plan
```

Include the planning docs and assessment rubric in that commit.

When the user asks Codex to commit:

- Use the user's existing local git identity.
- Do not change git `user.name` or `user.email`.
- Propose a meaningful commit message based on the actual diff.
- If the user provides a commit message, use the user's message exactly unless it is clearly unsafe or impossible.
- Before committing, check `git status` and avoid including unrelated user changes unless the user explicitly wants them included.
