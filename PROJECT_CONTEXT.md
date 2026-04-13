# Scholera Mobile Project Context

## Source Of Truth

This project is based on `assessment-rubrics.md`, a take-home assignment for building a native mobile companion app for Scholera, an AI-native Learning Management System used by universities.

This repository is the submission repository. The original assessment repository was read-only, and `assessment-rubrics.md` was copied here as local context.

## Product Goal

Build a polished mobile prototype that authenticates users with Supabase, detects their role, and routes them into a distinct experience for their role.

The app must support three roles:

| Role | Primary Job |
| --- | --- |
| Admin | Manage institution-level departments, professors, students, courses, and programs |
| Professor | Manage course sections, announcements, modules, roadmap coverage, and content |
| Student | View enrolled courses, consume course content, and track personal learning progress |

## Core Evaluation Criteria

| Area | What Must Be Demonstrated |
| --- | --- |
| Role-based routing | Auth reads profile role and sends each user to the right role shell |
| UI quality | Native-feeling, polished, distinct experiences for admin, professor, and student |
| API integration | Data comes from Supabase, with loading, empty, error, and auth-expiry states |
| Code organization | Clean role separation, maintainable data/repository structure |
| Module hierarchy | Clear module to item relationship and professor-side CRUD |
| Roadmap and topics | Extracted topics shown per item, with separate professor and student progress |
| Navigation | Logical stack/tab structure plus deep linking to announcements |
| Performance | Smooth loading and low jank |

## Required Features

### Authentication

- Email/password sign-in using Supabase Auth.
- Session persistence across app restarts.
- Expired-session handling.
- Sign-out from all role experiences.
- Profile lookup after login to read `role`.

### Admin Experience

- Dashboard with total students, professors, courses, and departments.
- Department list with assigned professors.
- Department detail.
- Professor detail with profile and assigned courses.

### Professor Experience

- Course list for sections taught by the professor.
- Course management screen with tabs.
- Announcements tab: view and create announcements.
- Modules tab: view ordered modules and nested items.
- Create module by title.
- Add module items:
  - Link with URL and title.
  - Note with plain text.
  - File upload for PDF or PPT.
- Roadmap tab:
  - Structure generated from modules and items.
  - Extracted topics displayed next to each item.
  - Professor coverage status: `not_started`, `in_progress`, `complete`.

### Student Experience

- Enrolled course list.
- Course detail with tabs.
- Announcements tab: read-only list and detail.
- Modules tab: read-only module content.
- Roadmap tab:
  - Same module and item structure as professor.
  - Extracted topics displayed.
  - Professor coverage status displayed.
  - Student personal progress tracked separately.

### Shared Experience

- Profile view and edit for display name, bio, and avatar.
- Deep link handling:
  - `scholera://courses/{courseId}/announcements/{announcementId}`
  - If unauthenticated, login first, then route to the announcement.

## Chosen Stack

- Flutter for mobile app development.
- Dart as the implementation language.
- MVC-inspired architecture for feature organization.
- Riverpod for dependency injection, async state, and controller exposure.
- Supabase for auth, database, storage, and optional realtime.

## Design Direction

Visual thesis: a calm, native academic workspace with crisp hierarchy, fast scanning, and role-specific color accents that make each user mode feel purposeful.

Interaction thesis:

- Role shells should transition cleanly after login so the app feels aware of the user's job.
- Course detail tabs should preserve scroll position and loading state.
- Roadmap status updates should feel immediate with optimistic UI and clear rollback on failure.

Role identity:

| Role | Visual Feel | Primary Surfaces |
| --- | --- | --- |
| Admin | Operational, broad, institution-level | Stats, departments, professor rosters |
| Professor | Authoring and course control | Course management, content hierarchy, coverage controls |
| Student | Focus and progress | Enrolled courses, readable content, personal progress |

## Non-Goals For First Complete Pass

- No custom AI topic extraction is required.
- No full content editor is required.
- No gradebook implementation is required unless the backend already makes it trivial.
- No web admin panel.
- No hardcoded final data. Temporary local fixtures are acceptable only before Supabase integration is wired.

## Stretch Goals To Consider After Required Scope

- Supabase Realtime for announcements.
- Local notifications when announcements arrive.
- Biometric auth for returning users.
- Animated route transitions.
- Lecture insights using Gemini if there is enough time and clean file text extraction.
