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
8. Add profile editing.
9. Add deep links (`app_links`, iOS `Info.plist`, Android `AndroidManifest.xml`).
10. Polish states, write README (with demo credentials block), record demo.

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
