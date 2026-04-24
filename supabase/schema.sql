-- Scholera LMS mobile prototype schema plan.
--
-- This file is intentionally explicit so the Flutter app can be implemented
-- against a stable contract. Apply it to a fresh Supabase project, then create
-- one auth user for each role and update the generated profile rows.

create extension if not exists "pgcrypto";

do $$
begin
  create type public.app_role as enum ('admin', 'professor', 'student');
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.module_item_type as enum (
    'link',
    'note',
    'file',
    'lecture',
    'video'
  );
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.progress_status as enum (
    'not_started',
    'in_progress',
    'complete'
  );
exception
  when duplicate_object then null;
end $$;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.departments (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  created_at timestamptz not null default now()
);

create table if not exists public.programs (
  id uuid primary key default gen_random_uuid(),
  department_id uuid not null references public.departments(id) on delete cascade,
  name text not null,
  description text,
  created_at timestamptz not null default now()
);

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role public.app_role not null default 'student',
  display_name text not null default '',
  bio text not null default '',
  avatar_url text,
  department_id uuid references public.departments(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'display_name', ''),
    coalesce((new.raw_user_meta_data ->> 'role')::public.app_role, 'student')
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create table if not exists public.courses (
  id uuid primary key default gen_random_uuid(),
  department_id uuid not null references public.departments(id) on delete restrict,
  code text not null,
  title text not null,
  description text,
  created_at timestamptz not null default now(),
  unique (department_id, code)
);

create table if not exists public.course_sections (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  professor_id uuid not null references public.profiles(id) on delete restrict,
  term text not null,
  section_code text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.enrollments (
  id uuid primary key default gen_random_uuid(),
  section_id uuid not null references public.course_sections(id) on delete cascade,
  student_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (section_id, student_id)
);

create table if not exists public.announcements (
  id uuid primary key default gen_random_uuid(),
  section_id uuid not null references public.course_sections(id) on delete cascade,
  professor_id uuid not null references public.profiles(id) on delete restrict,
  title text not null,
  body text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists announcements_set_updated_at on public.announcements;
create trigger announcements_set_updated_at
before update on public.announcements
for each row execute function public.set_updated_at();

create table if not exists public.modules (
  id uuid primary key default gen_random_uuid(),
  section_id uuid not null references public.course_sections(id) on delete cascade,
  title text not null,
  position int not null default 0,
  created_at timestamptz not null default now(),
  unique (section_id, position)
);

create table if not exists public.module_items (
  id uuid primary key default gen_random_uuid(),
  module_id uuid not null references public.modules(id) on delete cascade,
  section_id uuid not null references public.course_sections(id) on delete cascade,
  title text not null,
  item_type public.module_item_type not null,
  url text,
  body text,
  storage_path text,
  position int not null default 0,
  created_at timestamptz not null default now(),
  unique (module_id, position)
);

create table if not exists public.roadmap_nodes (
  id uuid primary key default gen_random_uuid(),
  section_id uuid not null references public.course_sections(id) on delete cascade,
  module_id uuid not null references public.modules(id) on delete cascade,
  module_item_id uuid not null references public.module_items(id) on delete cascade,
  professor_status public.progress_status not null default 'not_started',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (module_item_id)
);

drop trigger if exists roadmap_nodes_set_updated_at on public.roadmap_nodes;
create trigger roadmap_nodes_set_updated_at
before update on public.roadmap_nodes
for each row execute function public.set_updated_at();

create table if not exists public.topics (
  id uuid primary key default gen_random_uuid(),
  module_item_id uuid not null references public.module_items(id) on delete cascade,
  title text not null,
  confidence numeric,
  created_at timestamptz not null default now()
);

create table if not exists public.student_progress (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  module_item_id uuid not null references public.module_items(id) on delete cascade,
  status public.progress_status not null default 'not_started',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (student_id, module_item_id)
);

drop trigger if exists student_progress_set_updated_at on public.student_progress;
create trigger student_progress_set_updated_at
before update on public.student_progress
for each row execute function public.set_updated_at();

create index if not exists profiles_role_idx on public.profiles(role);
create index if not exists course_sections_professor_idx on public.course_sections(professor_id);
create index if not exists enrollments_student_idx on public.enrollments(student_id);
create index if not exists announcements_section_idx on public.announcements(section_id);
create index if not exists modules_section_idx on public.modules(section_id);
create index if not exists module_items_module_idx on public.module_items(module_id);
create index if not exists roadmap_nodes_section_idx on public.roadmap_nodes(section_id);
create index if not exists topics_module_item_idx on public.topics(module_item_id);
create index if not exists student_progress_student_idx on public.student_progress(student_id);

create or replace function public.current_user_role()
returns public.app_role
language sql
stable
security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid()
$$;

create or replace function public.is_admin()
returns boolean
language sql
stable
as $$
  select public.current_user_role() = 'admin'
$$;

create or replace function public.teaches_section(target_section_id uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.course_sections
    where id = target_section_id
      and professor_id = auth.uid()
  )
$$;

create or replace function public.enrolled_in_section(target_section_id uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.enrollments
    where enrollments.section_id = target_section_id
      and student_id = auth.uid()
  )
$$;

create or replace function public.create_roadmap_node_for_item()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.roadmap_nodes (section_id, module_id, module_item_id)
  values (new.section_id, new.module_id, new.id)
  on conflict (module_item_id) do nothing;

  return new;
end;
$$;

drop trigger if exists module_items_create_roadmap_node on public.module_items;
create trigger module_items_create_roadmap_node
after insert on public.module_items
for each row execute function public.create_roadmap_node_for_item();

alter table public.profiles enable row level security;
alter table public.departments enable row level security;
alter table public.programs enable row level security;
alter table public.courses enable row level security;
alter table public.course_sections enable row level security;
alter table public.enrollments enable row level security;
alter table public.announcements enable row level security;
alter table public.modules enable row level security;
alter table public.module_items enable row level security;
alter table public.roadmap_nodes enable row level security;
alter table public.topics enable row level security;
alter table public.student_progress enable row level security;

drop policy if exists "profiles readable by owner and admins" on public.profiles;
create policy "profiles readable by owner and admins"
on public.profiles
for select
to authenticated
using (id = auth.uid() or public.is_admin());

drop policy if exists "profiles editable by owner" on public.profiles;
create policy "profiles editable by owner"
on public.profiles
for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

drop policy if exists "admins read departments" on public.departments;
create policy "admins read departments"
on public.departments
for select
to authenticated
using (public.is_admin());

drop policy if exists "admins read programs" on public.programs;
create policy "admins read programs"
on public.programs
for select
to authenticated
using (public.is_admin());

drop policy if exists "course visibility by role" on public.courses;
create policy "course visibility by role"
on public.courses
for select
to authenticated
using (
  public.is_admin()
  or exists (
    select 1
    from public.course_sections
    where course_sections.course_id = courses.id
      and course_sections.professor_id = auth.uid()
  )
  or exists (
    select 1
    from public.course_sections
    join public.enrollments on enrollments.section_id = course_sections.id
    where course_sections.course_id = courses.id
      and enrollments.student_id = auth.uid()
  )
);

drop policy if exists "section visibility by role" on public.course_sections;
create policy "section visibility by role"
on public.course_sections
for select
to authenticated
using (
  public.is_admin()
  or professor_id = auth.uid()
  or public.enrolled_in_section(id)
);

drop policy if exists "enrollment visibility by role" on public.enrollments;
create policy "enrollment visibility by role"
on public.enrollments
for select
to authenticated
using (
  public.is_admin()
  or student_id = auth.uid()
  or public.teaches_section(section_id)
);

drop policy if exists "announcement visibility by role" on public.announcements;
create policy "announcement visibility by role"
on public.announcements
for select
to authenticated
using (
  public.is_admin()
  or public.teaches_section(section_id)
  or public.enrolled_in_section(section_id)
);

drop policy if exists "professors create announcements" on public.announcements;
create policy "professors create announcements"
on public.announcements
for insert
to authenticated
with check (
  professor_id = auth.uid()
  and public.teaches_section(section_id)
);

drop policy if exists "professors update own announcements" on public.announcements;
create policy "professors update own announcements"
on public.announcements
for update
to authenticated
using (professor_id = auth.uid() and public.teaches_section(section_id))
with check (professor_id = auth.uid() and public.teaches_section(section_id));

drop policy if exists "module visibility by role" on public.modules;
create policy "module visibility by role"
on public.modules
for select
to authenticated
using (
  public.is_admin()
  or public.teaches_section(section_id)
  or public.enrolled_in_section(section_id)
);

drop policy if exists "professors create modules" on public.modules;
create policy "professors create modules"
on public.modules
for insert
to authenticated
with check (public.teaches_section(section_id));

drop policy if exists "professors update modules" on public.modules;
create policy "professors update modules"
on public.modules
for update
to authenticated
using (public.teaches_section(section_id))
with check (public.teaches_section(section_id));

drop policy if exists "module item visibility by role" on public.module_items;
create policy "module item visibility by role"
on public.module_items
for select
to authenticated
using (
  public.is_admin()
  or public.teaches_section(section_id)
  or public.enrolled_in_section(section_id)
);

drop policy if exists "professors create module items" on public.module_items;
create policy "professors create module items"
on public.module_items
for insert
to authenticated
with check (public.teaches_section(section_id));

drop policy if exists "professors update module items" on public.module_items;
create policy "professors update module items"
on public.module_items
for update
to authenticated
using (public.teaches_section(section_id))
with check (public.teaches_section(section_id));

drop policy if exists "roadmap visibility by role" on public.roadmap_nodes;
create policy "roadmap visibility by role"
on public.roadmap_nodes
for select
to authenticated
using (
  public.is_admin()
  or public.teaches_section(section_id)
  or public.enrolled_in_section(section_id)
);

drop policy if exists "professors update roadmap coverage" on public.roadmap_nodes;
create policy "professors update roadmap coverage"
on public.roadmap_nodes
for update
to authenticated
using (public.teaches_section(section_id))
with check (public.teaches_section(section_id));

drop policy if exists "topic visibility by role" on public.topics;
create policy "topic visibility by role"
on public.topics
for select
to authenticated
using (
  public.is_admin()
  or exists (
    select 1
    from public.module_items
    where module_items.id = topics.module_item_id
      and (
        public.teaches_section(module_items.section_id)
        or public.enrolled_in_section(module_items.section_id)
      )
  )
);

drop policy if exists "students read own progress" on public.student_progress;
create policy "students read own progress"
on public.student_progress
for select
to authenticated
using (
  public.is_admin()
  or student_id = auth.uid()
  or exists (
    select 1
    from public.module_items
    where module_items.id = student_progress.module_item_id
      and public.teaches_section(module_items.section_id)
  )
);

drop policy if exists "students create own progress" on public.student_progress;
create policy "students create own progress"
on public.student_progress
for insert
to authenticated
with check (student_id = auth.uid());

drop policy if exists "students update own progress" on public.student_progress;
create policy "students update own progress"
on public.student_progress
for update
to authenticated
using (student_id = auth.uid())
with check (student_id = auth.uid());

-- Storage policies.
--
-- Required bucket setup in Supabase Storage (create these before running the
-- policy block, otherwise the policies reference buckets that do not yet
-- exist):
--   - avatars: public bucket, for profile images.
--   - course-content: private bucket, for professor-uploaded lecture files.
--
-- Path conventions enforced by the app (the policies depend on these):
--   - avatars/{user_id}/...
--   - course-content/{section_id}/...

drop policy if exists "avatars public read" on storage.objects;
create policy "avatars public read"
on storage.objects
for select
to public
using (bucket_id = 'avatars');

drop policy if exists "avatars owner insert" on storage.objects;
create policy "avatars owner insert"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "avatars owner update" on storage.objects;
create policy "avatars owner update"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "avatars owner delete" on storage.objects;
create policy "avatars owner delete"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "course content role read" on storage.objects;
create policy "course content role read"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'course-content'
  and (
    public.is_admin()
    or public.teaches_section(((storage.foldername(name))[1])::uuid)
    or public.enrolled_in_section(((storage.foldername(name))[1])::uuid)
  )
);

drop policy if exists "course content professor insert" on storage.objects;
create policy "course content professor insert"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'course-content'
  and public.teaches_section(((storage.foldername(name))[1])::uuid)
);

drop policy if exists "course content professor update" on storage.objects;
create policy "course content professor update"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'course-content'
  and public.teaches_section(((storage.foldername(name))[1])::uuid)
)
with check (
  bucket_id = 'course-content'
  and public.teaches_section(((storage.foldername(name))[1])::uuid)
);

drop policy if exists "course content professor delete" on storage.objects;
create policy "course content professor delete"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'course-content'
  and public.teaches_section(((storage.foldername(name))[1])::uuid)
);

-- ---------------------------------------------------------------------------
-- Realtime: enable change broadcasts on announcements so the mobile client
-- can subscribe to inserts via supabase_flutter's postgres_changes channel,
-- refresh the list without pull-to-refresh, and fire local notifications
-- on new posts.
--
-- Idempotent via exception handling: running this block multiple times is
-- safe. If Realtime isn't firing, re-run just this block and then verify
-- with:
--   select pubname, tablename from pg_publication_tables
--   where tablename = 'announcements';
-- A row with pubname = 'supabase_realtime' means the mobile app will
-- receive insert/update/delete events scoped by RLS.
-- ---------------------------------------------------------------------------

do $$
begin
  alter publication supabase_realtime add table public.announcements;
  raise notice 'Added public.announcements to supabase_realtime publication.';
exception
  when duplicate_object then
    raise notice 'public.announcements is already in supabase_realtime — no change.';
  when undefined_object then
    raise warning 'Publication supabase_realtime not found. Realtime features will not work until it is created.';
end$$;
