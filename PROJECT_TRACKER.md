# Scholera Project Tracker

## Current State

- Assignment context has been read from `assessment-rubrics.md`.
- This repository is the submission repository and currently contains the assignment brief, planning docs, and Flutter scaffold.
- Flutter app has been scaffolded for iOS and Android.
- Planned stack: Flutter, Riverpod, Supabase, GoRouter.
- Planned architecture: MVC-inspired features with Riverpod controllers and Supabase repositories.
- Supabase schema plan and Dart define environment foundation have been added.

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
- [ ] Initialize Supabase.
- [x] Configure app theme.
- [x] Configure GoRouter.
- [ ] Add shared loading, empty, and error widgets.

### Supabase Backend

- [x] Draft schema SQL.
- [x] Document storage buckets.
- [ ] Create Supabase project.
- [ ] Apply schema SQL.
- [ ] Create storage buckets.
- [ ] Configure storage policies.
- [ ] Create test users.
- [ ] Seed required demo data.
- [ ] Verify RLS with admin, professor, and student users.

### Auth

- [ ] Email/password sign-in.
- [ ] Session restore.
- [ ] Profile role fetch.
- [ ] Role-based route redirect.
- [ ] Expired session handling.
- [ ] Sign-out from each role.

### Admin

- [ ] Dashboard stats.
- [ ] Departments list.
- [ ] Department detail.
- [ ] Professor detail.

### Professor

- [ ] Professor course list.
- [ ] Course management tabs.
- [ ] Announcements list.
- [ ] Create announcement.
- [ ] Modules list.
- [ ] Create module.
- [ ] Add link item.
- [ ] Add note item.
- [ ] Upload PDF/PPT item.
- [ ] Professor roadmap with topics.
- [ ] Update professor coverage status.

### Student

- [ ] Student course list.
- [ ] Course detail tabs.
- [ ] Announcements read-only list.
- [ ] Announcement detail.
- [ ] Modules read-only list.
- [ ] Student roadmap with topics.
- [ ] Show professor coverage status.
- [ ] Update student personal progress.

### Shared

- [ ] View profile.
- [ ] Edit display name.
- [ ] Edit bio.
- [ ] Upload/edit avatar.
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
- File upload policies may need bucket setup.
- Deep linking can take longer than expected on simulator if bundle scheme config is late.
- Final app cannot rely on mocked data, so Supabase seed data is critical.
- `AI_ASSISTANT_USAGE.md` must be written by the user, not generated.

## Next Best Action

Initialize Supabase in Flutter using `AppEnv`, then wire email/password auth, profile role lookup, and role-based route redirects.

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
