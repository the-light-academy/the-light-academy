-- =====================================================================
--  Английски, 5. клас, Unit 1 — петте листа от домашното за 12 ноември
--  ---------------------------------------------------------------------
--  Домашното е едно, но е голямо: 138 задачи за автоматична проверка и
--  7 въпроса с цели изречения. Разделено е на пет листа по теми, всеки
--  с най-много десет упражнения, за да не е безкрайно на един екран.
--
--  Мястото им в платформата: предмет „Английски“, 5. клас, Unit 1 от
--  English Plus 1 — всеки лист в своята част на юнита (Reading,
--  Language focus, Review, Vocabulary). БЕЗ седмица: английският върви
--  по юнити, не по седмици.
--
--  Страниците се сглобяват от scripts/build_english5.py, задачите стоят
--  в scripts/english5/, а scripts/check_english5.py ги сверява наново с
--  правилата на юнита.
--
--  ПУСКА СЕ ТОЛКОВА ПЪТИ, КОЛКОТО ТРЯБВА — нищо не се трие и не се
--  дублира. published нарочно не се пипа при повторно пускане: кога
--  един лист отива при учениците се решава от таблото („Сложи в
--  библиотеката“, после „Дай на моите“).
--
--  Файлът е написан от scripts/gen_english5_sql.py — не го редактирай
--  на ръка.
--
--  ПРЕДИ ТОВА трябва веднъж да са минали:
--    · supabase/schema.sql и надстройките след него
--    · supabase/schema-v8.sql   (колоните track и section)
--    · supabase/schema-v13.sql  (оттам идва предметът „Английски“)
-- =====================================================================

do $do$
declare
  predmet uuid;
  imeto   text;
begin
  select id, name into predmet, imeto
    from public.subjects
   where slug = 'angliiski';

  if predmet is null then
    select id, name into predmet, imeto
      from public.subjects
     where coalesce(active, true)
       and (name ilike '%нглийск%' or name ilike '%english%')
     order by length(name), name
     limit 1;
  end if;

  if predmet is null then
    raise exception using
      message = 'Няма предмет „Английски“ в public.subjects.',
      hint    = 'Пусни първо supabase/schema-v13.sql или създай предмета от таблото.';
  end if;

  raise notice 'Петте листа се закачат за предмет „%“, Unit 1.', imeto;

  --  Домашно — Unit 1 · The Lost Backpack
  --  Разказът „The Lost Backpack“ с двайсет празни места и седем въпроса с цели изречения
  insert into public.assignments
    (slug, title, kind, url, description, max_points, published,
     sort_order, week, subject_id, grades, track, section)
  values
    ('en5-u1-story',
     'Домашно — Unit 1 · The Lost Backpack',
     'homework',
     'homework_5_en_u1_story.html',
     'Разказът „The Lost Backpack“ с двайсет празни места и седем въпроса с цели изречения',
     27,
     false,
     5110,
     null,          --  английският не върви по седмици, а по юнити
     predmet,
     '{5}',
     'ep1_unit1',
     'reading')
  on conflict (slug) do update set
    title       = excluded.title,
    kind        = excluded.kind,
    url         = excluded.url,
    description = excluded.description,
    max_points  = excluded.max_points,
    sort_order  = excluded.sort_order,
    week        = excluded.week,
    subject_id  = excluded.subject_id,
    grades      = excluded.grades,
    track       = excluded.track,
    section     = excluded.section;
    -- published нарочно липсва тук: то се управлява от таблото.

  --  Домашно — Unit 1 · Word Order Workshop
  --  Подреждане на разбъркани думи: have got, this/that/these/those, there is/are, въпросителни думи
  insert into public.assignments
    (slug, title, kind, url, description, max_points, published,
     sort_order, week, subject_id, grades, track, section)
  values
    ('en5-u1-order',
     'Домашно — Unit 1 · Word Order Workshop',
     'homework',
     'homework_5_en_u1_order.html',
     'Подреждане на разбъркани думи: have got, this/that/these/those, there is/are, въпросителни думи',
     24,
     false,
     5111,
     null,          --  английският не върви по седмици, а по юнити
     predmet,
     '{5}',
     'ep1_unit1',
     'language_focus')
  on conflict (slug) do update set
    title       = excluded.title,
    kind        = excluded.kind,
    url         = excluded.url,
    description = excluded.description,
    max_points  = excluded.max_points,
    sort_order  = excluded.sort_order,
    week        = excluded.week,
    subject_id  = excluded.subject_id,
    grades      = excluded.grades,
    track       = excluded.track,
    section     = excluded.section;
    -- published нарочно липсва тук: то се управлява от таблото.

  --  Домашно — Unit 1 · Grammar Detective
  --  Намери сгрешената дума — трийсет изречения от лесни към коварни
  insert into public.assignments
    (slug, title, kind, url, description, max_points, published,
     sort_order, week, subject_id, grades, track, section)
  values
    ('en5-u1-detective',
     'Домашно — Unit 1 · Grammar Detective',
     'homework',
     'homework_5_en_u1_detective.html',
     'Намери сгрешената дума — трийсет изречения от лесни към коварни',
     30,
     false,
     5112,
     null,          --  английският не върви по седмици, а по юнити
     predmet,
     '{5}',
     'ep1_unit1',
     'review')
  on conflict (slug) do update set
    title       = excluded.title,
    kind        = excluded.kind,
    url         = excluded.url,
    description = excluded.description,
    max_points  = excluded.max_points,
    sort_order  = excluded.sort_order,
    week        = excluded.week,
    subject_id  = excluded.subject_id,
    grades      = excluded.grades,
    track       = excluded.track,
    section     = excluded.section;
    -- published нарочно липсва тук: то се управлява от таблото.

  --  Домашно — Unit 1 · Grammar Mix
  --  Въпросителни думи, and/or/but, there is/there are, отрицания и some/any
  insert into public.assignments
    (slug, title, kind, url, description, max_points, published,
     sort_order, week, subject_id, grades, track, section)
  values
    ('en5-u1-grammar',
     'Домашно — Unit 1 · Grammar Mix',
     'homework',
     'homework_5_en_u1_grammar.html',
     'Въпросителни думи, and/or/but, there is/there are, отрицания и some/any',
     30,
     false,
     5113,
     null,          --  английският не върви по седмици, а по юнити
     predmet,
     '{5}',
     'ep1_unit1',
     'language_focus')
  on conflict (slug) do update set
    title       = excluded.title,
    kind        = excluded.kind,
    url         = excluded.url,
    description = excluded.description,
    max_points  = excluded.max_points,
    sort_order  = excluded.sort_order,
    week        = excluded.week,
    subject_id  = excluded.subject_id,
    grades      = excluded.grades,
    track       = excluded.track,
    section     = excluded.section;
    -- published нарочно липсва тук: то се управлява от таблото.

  --  Домашно — Unit 1 · Guess the Word
  --  Познай думата по описанието: места в града, предмети, държави и прилагателни
  insert into public.assignments
    (slug, title, kind, url, description, max_points, published,
     sort_order, week, subject_id, grades, track, section)
  values
    ('en5-u1-words',
     'Домашно — Unit 1 · Guess the Word',
     'homework',
     'homework_5_en_u1_words.html',
     'Познай думата по описанието: места в града, предмети, държави и прилагателни',
     34,
     false,
     5114,
     null,          --  английският не върви по седмици, а по юнити
     predmet,
     '{5}',
     'ep1_unit1',
     'vocabulary')
  on conflict (slug) do update set
    title       = excluded.title,
    kind        = excluded.kind,
    url         = excluded.url,
    description = excluded.description,
    max_points  = excluded.max_points,
    sort_order  = excluded.sort_order,
    week        = excluded.week,
    subject_id  = excluded.subject_id,
    grades      = excluded.grades,
    track       = excluded.track,
    section     = excluded.section;
    -- published нарочно липсва тук: то се управлява от таблото.
end
$do$;


-- ---------------------------------------------------------------------
--  Справка: петте листа, в коя част на юнита са и вижда ли ги някой.
-- ---------------------------------------------------------------------
select
  a.sort_order                             as red,
  a.slug,
  a.title,
  s.name                                   as predmet,
  a.grades                                 as klasove,
  a.track || ' / ' || a.section            as chast,
  a.max_points                             as tochki,
  case when a.published then 'вижда се от учениците'
       else 'още не се вижда — пусни го от таблото' end as sustoqnie
from public.assignments a
left join public.subjects s on s.id = a.subject_id
where a.slug like 'en5-u1-%'
order by a.sort_order;
