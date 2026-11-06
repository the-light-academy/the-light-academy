-- =====================================================================
--  Какво вече е пуснато в базата и какво още чака
--  ---------------------------------------------------------------------
--  Пусни ЦЕЛИЯ файл в SQL редактора на Supabase. Нищо не променя — само
--  гледа. Всеки ред казва едно нещо: „има го“ или „пусни този файл“.
-- =====================================================================
with proverki(подредба, какво, готово, файл) as (
  values
    (1, 'Интерактивни уроци в календара',
        (select count(*) > 0 from pg_constraint
          where conrelid = 'public.assignments'::regclass
            and pg_get_constraintdef(oid) ilike '%lesson%'),
        'supabase/schema-v9.sql'),
    (2, 'Часовете на преподавателите',
        (select to_regclass('public.lessons') is not null),
        'supabase/schema-v10.sql'),
    (3, 'Редактиране и триене на записан час',
        (select count(*) = 2 from pg_policies
          where schemaname = 'public' and tablename = 'lessons'
            and policyname in ('lessons: edit own', 'lessons: drop own')),
        'supabase/schema-v11.sql'),
    (4, 'Рожден ден в паспорта',
        (select count(*) > 0 from information_schema.columns
          where table_schema = 'public' and table_name = 'profiles'
            and column_name = 'birthday'),
        'supabase/schema-v12.sql'),
    (5, 'Английски като предмет',
        (select count(*) > 0 from public.subjects where slug = 'angliiski' and active),
        'supabase/schema-v13.sql'),
    (6, '…и кой преподавател по какво преподава',
        (select to_regclass('public.teacher_subjects') is not null),
        'supabase/schema-v13.sql'),
    (7, '…и общият календар на часовете',
        (select count(*) > 0 from pg_policies
          where schemaname = 'public' and tablename = 'lessons'
            and policyname = 'lessons: read all'),
        'supabase/schema-v13.sql'),
    (8, 'Описание под заглавието на заданието',
        (select count(*) > 0 from information_schema.columns
          where table_schema = 'public' and table_name = 'assignments'
            and column_name = 'description'),
        'supabase/schema-v14.sql'),
    (9, 'Обратна връзка за родителя',
        (select to_regclass('public.feedback_reports') is not null),
        'supabase/schema-v15.sql'),
    (10, 'Деветте интерактивни урока',
        (select count(*) >= 9 from public.assignments where kind = 'lesson'),
        'supabase/uroci.sql'),
    (11, 'Трите листа от Барселона (7. клас)',
        (select count(*) = 3 from public.assignments
          where slug in ('hw7-w03b','hw7-w04b','hw7-w05b')),
        'supabase/assignments.sql'),
    (12, '6. клас: рационалните числа преди степенуването',
        (select count(*) > 0 from public.assignments
          where slug = 'hw6-w07' and week = 4),
        'supabase/assignments.sql'),
    (13, 'Час с група деца (няколко имена в един час)',
        (select coalesce(
          (select substring(pg_get_constraintdef(oid) from '<= ([0-9]+)')::int >= 200
             from pg_constraint
            where conrelid = 'public.lessons'::regclass
              and conname = 'lessons_child_name_ok'), false)),
        'supabase/schema-v16.sql'),
    (14, 'Трите нови листа (НОД/НОК, рационални ниво 2, многочлени)',
        (select count(*) = 3 from public.assignments
          where slug in ('hw5-w09b','hw6-w10b','hw7-w06b')),
        'supabase/assignments.sql'),
    (15, 'Домашното по английски за 4. клас (to be)',
        (select exists (select 1 from public.assignments
                         where slug = 'hw4-en-tobe')),
        'supabase/domashno-angliyski-4.sql'),
    --  Разделите вътре в предмета: кръговете на олимпиадата и юнитите
    --  по английски. Самите раздели са в assets/tracks.js; базата пази
    --  само кой лист в кой раздел е — за това трябват двете колони.
    (16, 'Раздели вътре в предмета (кръгове и юнити)',
        (select count(*) = 2 from information_schema.columns
          where table_schema = 'public' and table_name = 'assignments'
            and column_name in ('track', 'section')),
        'supabase/schema-v8.sql'),
    --  Английският няма седмици: ако някой лист по него още носи
    --  седмица, порталът ще го подреди на погрешно място.
    (17, 'Английският е без седмици (върви по юнити)',
        (select not exists (
           select 1 from public.assignments a
             join public.subjects s on s.id = a.subject_id
            where s.slug = 'angliiski' and a.week is not null)),
        'supabase/domashno-angliyski-4.sql'),
    --  Домашното на Кали за 12 ноември, разделено на пет листа в Unit 1.
    (18, 'Петте листа за 5. клас, Unit 1 (English Plus 1)',
        (select count(*) = 5 from public.assignments
          where slug like 'en5-u1-%' and track = 'ep1_unit1'),
        'supabase/domashni-angliyski-5-u1.sql')
)
select подредба                                   as "№",
       какво,
       case when готово then '✅ има го' else '❌ липсва' end as състояние,
       case when готово then '' else 'пусни ' || файл end    as какво_да_направя
  from proverki
 order by подредба;
