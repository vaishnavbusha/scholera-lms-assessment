Using AI Assistants

A frank assessment of how AI coding tools assisted in developing this submission. This was written by the author as a draft to be further polished – each of the points below should be demonstrable from the repo and its commit history.

---

Tools Used

*   Claude Code (CLI) - Served as the main pair-programmer throughout the build. Operated from within the project's directory, with both file-editing and shell access.
*   Google Gemini 2.0 Flash - Used at runtime by the application itself, powering the lecture-insights feature; not used in the creation of the codebase.

No other AI coding assistants (Cursor, Copilot, ChatGPT) were utilized.

---

My Working Method

I treated Claude Code as an accelerated collaborator, rather than a hands-off autopilot. My workflow typically followed these steps:

1.  Markdown planning first, coding second. Before implementing any new feature, I would leverage Claude Code to help draft and update the various planning documents: PROJECTCONTEXT.md, IMPLEMENTATIONPLAN.md, SUPABASECONTRACT.md, PROJECTTRACKER.md, and a live HANDOFF.md. I began each coding session by reviewing the PROJECT_TRACKER.md, selecting the next item to address, and confirming the scope against the assessment-rubrics.md.
2.  Each feature implemented as a single, cohesive vertical slice. I worked in small, contained feature commits, grouping them by function (e.g., authentication, professor dashboard, student interactions). Planning documents were updated concurrently with the code, ensuring future coding sessions could pick up where the previous one left off without missing context.
3.  Rubric re-verification before concluding any task. I always re-checked the rubric for the specific feature before committing. This prevented scope creep-for example, I avoided building a full content editor for module items when the rubric clearly specified a "keep it simple" approach.
4.  Constant supervision of the AI. I rejected suggestions that introduced premature abstractions, and pushed back on speculative error handling that would never realistically occur.

---

Areas Where AI Provided the Most Assistance

*   Boilerplate-heavy code generation. Skeleton code for Riverpod controllers and repositories, GoRouter route trees, and Supabase JSON fromJson/toJson for manually defined models. It was far quicker to dictate the structural requirements than to type them out.
*   Initial drafts for schemas and RLS policies. I provided plain English descriptions of the intended role permissions, and Claude generated the initial schema.sql along with RLS policies and storage bucket rules. I meticulously reviewed each policy line by line, revising those that did not align with the rubric's intent (particularly regarding storage path conventions and the documented truncate cascade pitfall).
*   UI building blocks and theme concepts. The "studio light" design system – palette tokens, RoleThemeScope, and the eight reusable UI widgets (ScholeraScaffold, AsyncContent, EmptyState, ErrorState, LoadingSkeleton, StatusPill, TopicChip, RoleBadge) – were quickly iterated upon with AI assistance before I fine-tuned the final visual presentation.
*   Setting up stretch goal features. The integration of flutterlocalnotifications, localauth, applinks, and the Gemini SDK each involved platform-specific steps (e.g., adding entries to AndroidManifest.xml or Info.plist, or configuring FlutterFragmentActivity for biometrics). AI helped identify and provide these configuration details from documentation.
*   Drafting documentation. The README structure, the "Libraries and Their Purpose" table, the "Known Issues" section, and this document were all initially drafted by AI and then edited by me.

---

Where AI Made Mistakes (Requiring Human Correction)

These are actual issues that I had to correct while building. They are documented in the HANDOFF.md as they consumed significant time:

*   Router re-initialization on auth changes. An initial suggestion to use ref.watch(authControllerProvider) within the router provider resulted in the navigator being rebuilt on every auth state change, leading to screen state loss during sign-in/sign-out. I implemented _RouterRefreshNotifier to listen to auth and deep link changes, providing a stable refreshListenable for GoRouter, preserving screen state.
*   Inconsistency in PostgREST embedded object structure. The AI-generated model deserializers assumed 1-to-1 embedded fields would always be returned as an object, but they actually return either a list or an object based on unique constraint status. RoadmapItem.fromJson now correctly handles both using an _asRowList helper.
*   Layout error with Spacer() in SingleChildScrollView. An AI suggestion for the login screen footer layout caused a "non-zero flex but unbounded height" error. I resolved this by wrapping the content in IntrinsicHeight and making the spacer Expanded(child: SizedBox.shrink()).
*   API change in file_picker 11.x. The AI's code for picking files used an older API (FilePicker.platform.pickFiles(...)); the current API is simply FilePicker.pickFiles(...). This was caught by the analyzer.
*   Truncate-cascade behavior during seed script re-runs. The AI-suggested command truncate public.departments ... Cascade would have deleted all related tables through the foreign key chain. I replaced this with delete from public.departments to ensure on delete set null was correctly triggered.
*   Temptation towards over-engineering. At multiple points, the AI proposed complex solutions like freezed, jsonserializable, and buildrunner for the model layer, which were unnecessary given the limited data surface and code generation overhead. I rejected these as noted in IMPLEMENTATION_PLAN.md.
*   Lack of optimistic UI updates. The initial implementation of roadmap toggles caused a brief skeleton flash after every Supabase write, as it re-fetched data immediately. I guided the redesign to use an in-memory override map with background writes and failure rollbacks; AI assisted in implementing this new pattern once it was defined.

In each of these instances, the AI-generated code would compile but contained a critical flaw (in terms of UX, correctness, or scope). This highlighted the importance of reviewing AI-generated code against project requirements and platform behavior, rather than accepting it blindly.

---

Tasks Completed Without AI Assistance

*   Final design decisions. I rejected an initial "academic workshop" design system (warm cream and Fraunces serif) generated with AI collaboration, opting instead for the "studio light" direction (Plus Jakarta Sans, cool neutrals, and saturated role-specific accent colors) – a purely human design choice.
*   Project workflow and rubric prioritization. I determined which stretch goals to prioritize and the order of implementation, as well as which features to cut if time became a constraint.
*   Manual on-device testing. I tested every feature on both the Android emulator and a physical 120Hz device; the AI never ran the application.
*   RLS verification. I logged in as each of the three demo users to confirm they could only access the resources permitted by their role.

---

How to Replicate This Workflow

To understand how the AI was directed, the relevant artifacts are included in the repository:

*   PROJECT_TRACKER.md: A running list of completed tasks, updated in sync with each commit.
*   IMPLEMENTATION_PLAN.md: A phased breakdown of the project, outlining library choices and rationale.
*   SUPABASE_CONTRACT.md: The data model and RLS policies that guided the creation of schema.sql.
*   git log --oneline: Commits are scoped to specific feature slices (e.g., feat: admin experience) and each commit message clearly explains the work done.

---

Honest Self-Assessment

Using AI, I estimate I was approximately twice as fast on this project as I would have been working alone. This speed increase was primarily due to AI handling boilerplate code and surfacing platform-specific configuration details. However, AI did not make any architectural or design decisions; those were entirely mine. The errors identified above demonstrate the risks of relying solely on AI output, as blind acceptance could have led to shipping actual bugs.

Overall, AI is an invaluable tool for rapid development, but it requires careful supervision and critical review.