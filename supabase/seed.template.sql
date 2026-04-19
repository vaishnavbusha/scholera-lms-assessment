-- Scholera LMS demo seed template.
--
-- Usage:
-- 1. Create three auth users in Supabase Auth (admin, professor, student).
-- 2. Replace the three user id placeholders in the `declare` block below
--    with the real auth user ids.
-- 3. Run this script in the SQL editor after `schema.sql`.
--
-- Run this script exactly once. The department/course/section/module/item
-- ids are generated with gen_random_uuid() inside the DO block, so a second
-- run produces a second set of rows — not an in-place update.
--
-- To re-seed from scratch, first clear the demo tables without touching the
-- three profile rows that map to real auth users:
--
--   truncate
--     public.student_progress,
--     public.topics,
--     public.roadmap_nodes,
--     public.module_items,
--     public.modules,
--     public.announcements,
--     public.enrollments,
--     public.course_sections,
--     public.courses,
--     public.programs
--   restart identity cascade;
--
--   delete from public.departments;
--
-- Do NOT include `public.departments` in a truncate ... cascade — profiles
-- has a FK to departments, and truncate cascade wipes the three profile
-- rows you need for RLS checks. `delete from public.departments` respects
-- the on-delete-set-null behavior on profiles.department_id.
--
-- Storage path convention:
--   course-content/{section_id}/{filename}
--   avatars/{user_id}/{filename}
--
-- The storage policies in schema.sql rely on these prefixes, so seed rows
-- that reference uploaded files use the same layout.

do $$
declare
  admin_user_id uuid := 'ff41f145-938e-4c9f-b43c-587412c398bb';
  professor_user_id uuid := 'cf764365-64d7-440e-be2c-91c0edcfeb99';
  student_user_id uuid := 'f863f148-801d-41e3-b294-ba88a797138c';

  cs_department_id uuid := gen_random_uuid();
  math_department_id uuid := gen_random_uuid();

  ai_program_id uuid := gen_random_uuid();
  applied_math_program_id uuid := gen_random_uuid();

  ml_course_id uuid := gen_random_uuid();
  ds_course_id uuid := gen_random_uuid();
  linalg_course_id uuid := gen_random_uuid();

  ml_section_id uuid := gen_random_uuid();
  ds_section_id uuid := gen_random_uuid();
  linalg_section_id uuid := gen_random_uuid();

  -- Applied ML modules and items
  ml_mod_1 uuid := gen_random_uuid();
  ml_mod_2 uuid := gen_random_uuid();
  ml_mod_3 uuid := gen_random_uuid();
  ml_item_1_1 uuid := gen_random_uuid();
  ml_item_1_2 uuid := gen_random_uuid();
  ml_item_2_1 uuid := gen_random_uuid();
  ml_item_2_2 uuid := gen_random_uuid();
  ml_item_3_1 uuid := gen_random_uuid();

  -- Data Structures modules and items
  ds_mod_1 uuid := gen_random_uuid();
  ds_mod_2 uuid := gen_random_uuid();
  ds_item_1_1 uuid := gen_random_uuid();
  ds_item_1_2 uuid := gen_random_uuid();
  ds_item_2_1 uuid := gen_random_uuid();

  -- Linear Algebra modules and items
  linalg_mod_1 uuid := gen_random_uuid();
  linalg_item_1_1 uuid := gen_random_uuid();
  linalg_item_1_2 uuid := gen_random_uuid();
begin
  ---------------------------------------------------------------------------
  -- Departments
  ---------------------------------------------------------------------------
  insert into public.departments (id, name, description)
  values
    (cs_department_id, 'Computer Science', 'Computing, AI, and systems coursework.'),
    (math_department_id, 'Mathematics', 'Pure and applied mathematics.')
  on conflict (id) do nothing;

  ---------------------------------------------------------------------------
  -- Profile role and display data
  --
  -- Upsert so the seed also works when profile rows were wiped (for example
  -- by a truncate ... cascade that reached profiles through its FK to
  -- departments). The handle_new_user trigger only fires on auth.users
  -- insert, so rebuilding profile rows by hand is sometimes necessary.
  ---------------------------------------------------------------------------
  insert into public.profiles (id, role, display_name, bio, department_id)
  values
    (admin_user_id,     'admin',     'Avery Admin',      'Institution administrator for Scholera Mobile.',   null),
    (professor_user_id, 'professor', 'Priya Professor',  'Teaches applied machine learning and core algorithms.', cs_department_id),
    (student_user_id,   'student',   'Sam Student',      'Graduate student in AI systems.',                   cs_department_id)
  on conflict (id) do update set
    role          = excluded.role,
    display_name  = excluded.display_name,
    bio           = excluded.bio,
    department_id = excluded.department_id;

  ---------------------------------------------------------------------------
  -- Programs
  ---------------------------------------------------------------------------
  insert into public.programs (id, department_id, name, description)
  values
    (
      ai_program_id,
      cs_department_id,
      'Artificial Intelligence',
      'Graduate program focused on machine learning and intelligent systems.'
    ),
    (
      applied_math_program_id,
      math_department_id,
      'Applied Mathematics',
      'Mathematical foundations for engineering and science.'
    )
  on conflict (id) do nothing;

  ---------------------------------------------------------------------------
  -- Courses
  ---------------------------------------------------------------------------
  insert into public.courses (id, department_id, code, title, description)
  values
    (
      ml_course_id,
      cs_department_id,
      'CS 541',
      'Applied Machine Learning',
      'Production-minded machine learning systems and model foundations.'
    ),
    (
      ds_course_id,
      cs_department_id,
      'CS 344',
      'Data Structures',
      'Core data structures and algorithmic thinking.'
    ),
    (
      linalg_course_id,
      math_department_id,
      'MATH 214',
      'Linear Algebra',
      'Vector spaces, linear maps, and applications.'
    )
  on conflict (id) do nothing;

  ---------------------------------------------------------------------------
  -- Sections (single professor teaches all three sections in this demo)
  ---------------------------------------------------------------------------
  insert into public.course_sections (id, course_id, professor_id, term, section_code)
  values
    (ml_section_id, ml_course_id, professor_user_id, 'Fall 2026', 'A'),
    (ds_section_id, ds_course_id, professor_user_id, 'Fall 2026', 'A'),
    (linalg_section_id, linalg_course_id, professor_user_id, 'Fall 2026', 'A')
  on conflict (id) do nothing;

  ---------------------------------------------------------------------------
  -- Enrollments
  ---------------------------------------------------------------------------
  insert into public.enrollments (section_id, student_id)
  values
    (ml_section_id, student_user_id),
    (ds_section_id, student_user_id),
    (linalg_section_id, student_user_id)
  on conflict (section_id, student_id) do nothing;

  ---------------------------------------------------------------------------
  -- Announcements
  ---------------------------------------------------------------------------
  insert into public.announcements (section_id, professor_id, title, body)
  values
    (
      ml_section_id,
      professor_user_id,
      'Welcome to Applied Machine Learning',
      'Review the Week 1 materials before our first session and bring one production ML example to discuss.'
    ),
    (
      ml_section_id,
      professor_user_id,
      'Week 2 office hours moved',
      'Office hours this Thursday are moved to Friday 2-4pm in room 317.'
    ),
    (
      ds_section_id,
      professor_user_id,
      'Welcome to Data Structures',
      'We will cover arrays, lists, and hash tables before the first quiz in week 3.'
    ),
    (
      linalg_section_id,
      professor_user_id,
      'Welcome to Linear Algebra',
      'Linear algebra is the language of modern machine learning — practice matrix operations daily.'
    )
  on conflict do nothing;

  ---------------------------------------------------------------------------
  -- Applied ML modules and items
  ---------------------------------------------------------------------------
  insert into public.modules (id, section_id, title, position)
  values
    (ml_mod_1, ml_section_id, 'Week 1 - Foundations', 0),
    (ml_mod_2, ml_section_id, 'Week 2 - Neural Networks', 1),
    (ml_mod_3, ml_section_id, 'Week 3 - Model Evaluation', 2)
  on conflict (id) do nothing;

  insert into public.module_items (
    id, module_id, section_id, title, item_type, url, body, storage_path, position
  )
  values
    (ml_item_1_1, ml_mod_1, ml_section_id, 'Course orientation link',
      'link', 'https://example.com/ml-orientation', null, null, 0),
    (ml_item_1_2, ml_mod_1, ml_section_id, 'Lecture notes: model lifecycle',
      'note', null,
      'Topics include problem framing, data quality, evaluation metrics, and deployment constraints.',
      null, 1),
    (ml_item_2_1, ml_mod_2, ml_section_id, 'Neural networks lecture deck',
      'file', null, null,
      'course-content/' || ml_section_id::text || '/neural-networks-week-2.pdf', 0),
    (ml_item_2_2, ml_mod_2, ml_section_id, 'Backprop walkthrough',
      'link', 'https://example.com/backprop', null, null, 1),
    (ml_item_3_1, ml_mod_3, ml_section_id, 'Evaluation metrics cheat sheet',
      'note', null,
      'Precision, recall, F1, AUC, calibration, and when each is appropriate.',
      null, 0)
  on conflict (id) do nothing;

  ---------------------------------------------------------------------------
  -- Data Structures modules and items
  ---------------------------------------------------------------------------
  insert into public.modules (id, section_id, title, position)
  values
    (ds_mod_1, ds_section_id, 'Arrays and Lists', 0),
    (ds_mod_2, ds_section_id, 'Hash Tables', 1)
  on conflict (id) do nothing;

  insert into public.module_items (
    id, module_id, section_id, title, item_type, url, body, storage_path, position
  )
  values
    (ds_item_1_1, ds_mod_1, ds_section_id, 'Array fundamentals',
      'note', null,
      'Contiguous memory, O(1) random access, resize semantics.',
      null, 0),
    (ds_item_1_2, ds_mod_1, ds_section_id, 'Linked list lecture deck',
      'file', null, null,
      'course-content/' || ds_section_id::text || '/linked-lists.pdf', 1),
    (ds_item_2_1, ds_mod_2, ds_section_id, 'Hash table visualizer',
      'link', 'https://example.com/hash-table-viz', null, null, 0)
  on conflict (id) do nothing;

  ---------------------------------------------------------------------------
  -- Linear Algebra modules and items
  ---------------------------------------------------------------------------
  insert into public.modules (id, section_id, title, position)
  values
    (linalg_mod_1, linalg_section_id, 'Vectors and Matrices', 0)
  on conflict (id) do nothing;

  insert into public.module_items (
    id, module_id, section_id, title, item_type, url, body, storage_path, position
  )
  values
    (linalg_item_1_1, linalg_mod_1, linalg_section_id, 'Course welcome note',
      'note', null,
      'Linear algebra in one paragraph — everything is a vector space.',
      null, 0),
    (linalg_item_1_2, linalg_mod_1, linalg_section_id, 'Matrix operations intro',
      'file', null, null,
      'course-content/' || linalg_section_id::text || '/matrix-operations.pdf', 1)
  on conflict (id) do nothing;

  ---------------------------------------------------------------------------
  -- Professor roadmap coverage
  ---------------------------------------------------------------------------
  update public.roadmap_nodes set professor_status = 'complete'    where module_item_id = ml_item_1_1;
  update public.roadmap_nodes set professor_status = 'complete'    where module_item_id = ml_item_1_2;
  update public.roadmap_nodes set professor_status = 'in_progress' where module_item_id = ml_item_2_1;
  update public.roadmap_nodes set professor_status = 'in_progress' where module_item_id = ml_item_2_2;
  update public.roadmap_nodes set professor_status = 'not_started' where module_item_id = ml_item_3_1;
  update public.roadmap_nodes set professor_status = 'complete'    where module_item_id = ds_item_1_1;
  update public.roadmap_nodes set professor_status = 'in_progress' where module_item_id = ds_item_1_2;
  update public.roadmap_nodes set professor_status = 'not_started' where module_item_id = ds_item_2_1;
  update public.roadmap_nodes set professor_status = 'in_progress' where module_item_id = linalg_item_1_1;
  update public.roadmap_nodes set professor_status = 'not_started' where module_item_id = linalg_item_1_2;

  ---------------------------------------------------------------------------
  -- Extracted topics per item
  ---------------------------------------------------------------------------
  insert into public.topics (module_item_id, title, confidence)
  values
    (ml_item_1_1, 'Course expectations', 0.95),
    (ml_item_1_1, 'Assessment cadence', 0.91),
    (ml_item_1_2, 'Problem framing', 0.97),
    (ml_item_1_2, 'Evaluation metrics', 0.92),
    (ml_item_1_2, 'Deployment constraints', 0.88),
    (ml_item_2_1, 'Gradient descent', 0.98),
    (ml_item_2_1, 'Backpropagation', 0.96),
    (ml_item_2_1, 'Activation functions', 0.94),
    (ml_item_2_2, 'Chain rule intuition', 0.93),
    (ml_item_2_2, 'Automatic differentiation', 0.87),
    (ml_item_3_1, 'Precision vs recall', 0.95),
    (ml_item_3_1, 'ROC and AUC', 0.91),
    (ml_item_3_1, 'Calibration', 0.84),
    (ds_item_1_1, 'Dynamic arrays', 0.96),
    (ds_item_1_1, 'Amortized analysis', 0.90),
    (ds_item_1_2, 'Singly linked lists', 0.97),
    (ds_item_1_2, 'Doubly linked lists', 0.92),
    (ds_item_2_1, 'Open addressing', 0.93),
    (ds_item_2_1, 'Separate chaining', 0.92),
    (linalg_item_1_1, 'Vector spaces', 0.97),
    (linalg_item_1_1, 'Linear independence', 0.92),
    (linalg_item_1_2, 'Matrix multiplication', 0.98),
    (linalg_item_1_2, 'Transpose and inverse', 0.93)
  on conflict do nothing;

  ---------------------------------------------------------------------------
  -- Student progress (intentionally diverges from professor coverage)
  ---------------------------------------------------------------------------
  insert into public.student_progress (student_id, module_item_id, status)
  values
    (student_user_id, ml_item_1_1, 'complete'),
    (student_user_id, ml_item_1_2, 'in_progress'),
    (student_user_id, ml_item_2_1, 'not_started'),
    (student_user_id, ml_item_2_2, 'not_started'),
    (student_user_id, ml_item_3_1, 'not_started'),
    (student_user_id, ds_item_1_1, 'complete'),
    (student_user_id, ds_item_1_2, 'in_progress'),
    (student_user_id, ds_item_2_1, 'not_started'),
    (student_user_id, linalg_item_1_1, 'complete'),
    (student_user_id, linalg_item_1_2, 'in_progress')
  on conflict (student_id, module_item_id) do update
    set status = excluded.status;
end $$;
