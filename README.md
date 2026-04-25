# Scholera LMS — Mobile

A Flutter mobile companion for Scholera, an AI-native Learning Management System used by universities. Three distinct role experiences — admin, professor, student — wired to a live Supabase backend with auth, RLS-gated data, storage, and realtime.

Built for the take-home assignment described in [`assessment-rubrics.md`](assessment-rubrics.md).

---

## Demo Video

The following is the demo video explaining the purpose, app and the way it works: https://drive.google.com/drive/folders/1S0skwGoiJ4BNrp2gLMRqQZc1jwzNjwkb?usp=sharing

## Screenshots

The screenshots can be accessed using the below drive link:
https://drive.google.com/drive/folders/1ojH3kM_yKw4NKP-aYMn19WlLehtn_-b0?usp=sharing

---

## Quick Start (under 5 minutes)

### 0. Prerequisites

- **Flutter 3.32.0** (stable channel) — Dart 3.8.0. Later 3.x versions should work, but this is the version the app was built and tested on. Check yours with `flutter --version`.
- An iOS simulator / physical iPhone, or an Android emulator / physical device.
- A Supabase project (free tier is fine). See `supabase/WEB_SETUP.md` for the one-time dashboard setup.

### 1. Clone and install

```sh
git clone https://github.com/vaishnavbusha/scholera-lms-assessment.git
cd scholera-lms-assessment
flutter pub get
```

### 2. Supabase setup

Follow `supabase/WEB_SETUP.md` end-to-end. It's a checklist — apply the schema, create the two storage buckets, create three test users, seed demo data, and enable the `announcements` realtime publication. ~10 minutes the first time.

### 3. Environment variables

Copy `.env.example` to `.env` (the file is gitignored) and fill in:

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-supabase-publishable-key
GEMINI_API_KEY=optional-for-lecture-insights
```

- `SUPABASE_ANON_KEY` or `SUPABASE_PUBLISHABLE_KEY` — the app accepts either name.
- `GEMINI_API_KEY` — optional. When unset, the "Lecture Insights" sheet falls back to file metadata + pre-extracted topics instead of AI-generated summaries. Free keys: <https://aistudio.google.com>.

### 4. Run

**VS Code** (easiest): open the repo → Run and Debug → pick **"Scholera (debug)"** → F5. Reads `.env` automatically via `--dart-define-from-file=.env`.

**Command line**:

```sh
flutter run --dart-define-from-file=.env -d <device-id>
```

List available devices with `flutter devices`.

**iOS first-time only**: `cd ios && pod install && cd ..` before the first iOS build, and any time you add native plugins.

### 5. Sign in

Use the demo credentials below.

---

## Demo Credentials

All three users live in the same Supabase project. Shared throwaway password — these exist only for demo review.

| Role | Email | Password |
| --- | --- | --- |
| Admin | admin@scholera.test | admin |
| Professor | professor@scholera.test | professor |
| Student | student@scholera.test | student |


---

## Framework & Key Libraries

| Library | Why |
| --- | --- |
| **Flutter 3.32** | Best cross-platform velocity; compiles to native for both iOS and Android with one codebase. |
| **Riverpod 3** | Explicit DI + async-aware state with `AsyncValue`. Family providers give per-section / per-user scoping cleanly. No globals, no rebuild surprises. |
| **GoRouter 17** | Declarative role-aware routing, auth redirects, and deep link handling in one tree. `refreshListenable` lets the navigator re-evaluate redirects without tearing itself down. |
| **supabase_flutter 2.12** | Auth, Postgres, Storage, and Realtime in one SDK. RLS is the authorization model; no app-level permission logic needed. |
| **app_links 6** | Cross-platform `scholera://` deep link delivery (initial + runtime URIs). |
| **flutter_local_notifications 19** | Simulated push (rubric allows this). Fires when the app receives a realtime insert, with a `scholera://` payload that routes through the same deep-link pipe. |
| **local_auth 2.3** | Face ID / fingerprint gate for returning users. Opt-in via profile toggle, enforced by `UnlockScreen` on next cold start. |
| **google_generative_ai 0.4** | Gemini 2.0 Flash for lecture insights — sends the uploaded file bytes, returns JSON summary + topics. Graceful fallback when no API key is set. |
| **refresh_rate 1.0** | Unlocks 120Hz on supported panels. Uses the modern Android `SurfaceControl.setFrameRate` API (not the deprecated `preferredDisplayModeId`), so OEM ROMs honor the vote. |
| **app_links, cached_network_image, shimmer, google_fonts, intl, url_launcher, file_picker** | Supporting libraries for deep links, avatar caching, skeleton loaders, typography (Plus Jakarta Sans), date formatting, external URLs, and PDF/PPT picking. |

---

## Architecture

MVC-inspired feature structure, Riverpod controllers wrapping Supabase repositories, views that never query Supabase directly.

```
lib/
├── app/                     theme, router, env, page transitions
├── core/                    shared primitives (widgets, errors, biometric, notifications)
├── data/
│   ├── supabase/           Supabase client provider
│   └── repositories/       one repo per domain (auth, profile, admin, course,
│                           module, announcement, roadmap)
└── features/
    ├── auth/               login, splash, unlock, auth controller
    ├── admin/              dashboard, departments, professor detail
    ├── professor/          courses, course shell, announcements,
    │                       modules, roadmap (write)
    ├── student/            enrolled courses, course shell, announcements,
    │                       modules, roadmap (read + own progress)
    ├── profile/            shared profile editor + settings toggles
    ├── lecture_insights/   Gemini integration
    ├── announcements/      shared announcement model + realtime listener
    ├── modules/            shared module model + item actions
    ├── roadmap/            shared roadmap model + timeline widget
    └── deep_links/         scholera:// URI handling
```

Three invariants the architecture relies on:

1. **Repositories throw; controllers catch.** Supabase errors propagate as `AsyncError` into Riverpod state, then surface via `AsyncContent` with retry.
2. **Primitives are role-agnostic.** Every role shell wraps itself in `RoleThemeScope.forAppRole(role: ...)`; shared widgets read the accent from `Theme.of(context)`. Adding a fourth role = one entry in `role_theme.dart`, zero widget changes.
3. **The router is created once per app lifetime.** Auth state changes fire `refreshListenable`; GoRouter re-runs `redirect` without rebuilding the navigator. Screens keep their state across auth transitions (login form doesn't clear mid-sign-in).

---

## Features

### Required (rubric)

- Email/password sign-in via Supabase Auth, session persistence across restarts, expired-session handling
- Role-based routing — each role lands in a visually distinct shell (cobalt admin, amber professor, emerald student)
- **Admin**: institution stats dashboard, departments list, department detail with professors, professor detail with assigned courses
- **Professor**: courses list, tabbed course management (Announcements / Modules / Roadmap), announcement creation, module creation, link/note/file items with PDF/PPT upload to `course-content/{sectionId}/…`, roadmap coverage toggle
- **Student**: enrolled courses list, read-only announcements + modules, own roadmap progress toggle (independent of professor coverage)
- **Shared**: profile edit with avatar upload, sign-out
- **Deep linking**: `scholera://courses/{sectionId}/announcements/{announcementId}` with auth replay

### Stretch goals (all five)

- **Realtime announcements** — Supabase postgres_changes; list updates without pull-to-refresh
- **Local notifications** — fire on new announcements; tap routes through the deep-link controller to the announcement detail
- **Biometric auth** — FaceID/fingerprint unlock for returning users; opt-in dialog after first sign-in, toggle in Profile
- **Animated transitions** — shared-axis page transitions, spring-physics list entrance, roadmap timeline draw-in, uniform fade-through on every loader→data swap
- **Lecture insights via Gemini** — file upload → Gemini 2.0 Flash → summary + topics rendered in a sheet from the roadmap tab

---

## Known Issues / Limitations

- **Notifications only fire while the app is alive.** Force-killed or fully backgrounded apps cannot receive local notifications — the Supabase realtime socket dies with the isolate. True killed-app push would require FCM/APNS plumbing, which is out of scope for this prototype (the rubric explicitly permits simulated push).
- **Lecture insights are in-memory cached.** Closing and reopening the app re-calls Gemini on the same file. A persistent `lecture_insights` table would be a small follow-up.
- **Small demo dataset.** Admin dashboard counts will show single-digit numbers because there are only three seeded users. Expected for the prototype.
- **Biometric opt-in is per-device.** Enabling it on one phone doesn't carry to a second. `shared_preferences` is scoped to device storage by design.
- **Gemini API rate limits.** Free tier allows ~15 requests/minute. Don't spam the "Insights" button during the demo.
- **Lecture file size.** The Gemini call holds the full file bytes in the Dart heap. Stay under ~10MB per lecture file; larger uploads would need chunked streaming.
- **iOS build requires one extra step.** After `flutter pub get`, run `cd ios && pod install && cd ..` to link native plugin code. Flutter doesn't do this automatically.
- **OEM-specific 120Hz behavior.** Some Android ROMs (notably older Samsung/Xiaomi builds) hard-cap apps to 60Hz unless the device's "Smooth Display / Adaptive" system setting is enabled. The app requests the highest available rate via `refresh_rate`'s tiered API, but the OS has final say.

---

## Development

```sh
# Analyzer
flutter analyze

# Format
dart format lib test

# Run tests (none currently — prototype scope)
flutter test

# Clean rebuild (after adding native plugins)
flutter clean && flutter pub get
cd ios && pod install && cd ..   # iOS only

# Cold-launch (required after native-plugin changes)
flutter run --dart-define-from-file=.env -d <device-id>
```

---

## Tested Against

| Platform | Device | Version |
| --- | --- | --- |
| Android | Physical device | Android 14, 120Hz panel |
| Android | Emulator | API 34 |
| iOS | _TBD — add when verified_ | _TBD_ |

Built and tested primarily on Android during development. iOS builds cleanly via Flutter; run `pod install` once before the first iOS build.

---

## AI Assistant Usage

See [`AI_ASSISTANT_USAGE.md`](AI_ASSISTANT_USAGE.md) for how AI coding tools were used during development. Written by the author, not generated.

---

## Project Docs

- [`assessment-rubrics.md`](assessment-rubrics.md) — the original take-home brief
- [`PROJECT_TRACKER.md`](PROJECT_TRACKER.md) — implementation status board
- [`supabase/WEB_SETUP.md`](supabase/WEB_SETUP.md) — Supabase dashboard checklist
- [`supabase/schema.sql`](supabase/schema.sql) — DDL, RLS policies, realtime publication
- [`supabase/seed.template.sql`](supabase/seed.template.sql) — demo data template

---

## DOWNLOAD APK

Use the link to download and test the android version of the app: https://drive.google.com/drive/folders/1qeDJgGpy53jSwUHLg1tXIoIbJ-bKTNzm?usp=sharing

---

## License

See [`LICENSE`](LICENSE).
