-- =====================================================================
--  Английски, 5. клас, Unit 1 — четирите листа за празните части
--  ---------------------------------------------------------------------
--  Unit 1 има седем части, но домашните дотук покриваха само четири:
--  Reading, Language focus, Review и Vocabulary. Speaking, Writing и
--  English Plus options стояха празни. Тези четири листа ги запълват и
--  вървят по САМИЯ УЧЕБНИК, а не по домашното на хартия:
--
--    Around Town          Vocabulary  p12 местата в града, a/an/some/any
--                                     p16 прилагателните за сравняване
--    Where’s the museum?  Speaking    p18 как се пита къде е нещо
--    My Town              Writing     p19 описание на град
--    English Plus: Extra  options     p92, p100, p106, p116
--
--  Листът „Around Town“ нарочно не пита нито една от думите, които вече
--  ги има в „Guess the Word“ — речникът се разширява, не се повтаря.
--
--  БЕЗ седмица: английският върви по юнити, не по седмици.
--
--  Страниците се сглобяват от scripts/build_english5_u1b.py, задачите
--  стоят в scripts/english5/u1_*.py, а scripts/check_english5_u1b.py ги
--  извежда наново по свои правила.
--
--  ПУСКА СЕ ТОЛКОВА ПЪТИ, КОЛКОТО ТРЯБВА — нищо не се трие и не се
--  дублира. published нарочно не се пипа при повторно пускане: кога
--  един лист отива при учениците се решава от таблото („Сложи в
--  библиотеката“, после „Дай на моите“).
--
--  Файлът е написан от scripts/gen_english5_u1b_sql.py — не го
--  редактирай на ръка.
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

  raise notice 'Четирите листа се закачат за предмет „%“, Unit 1.', imeto;

  --  Домашно — Unit 1 · Around Town
  --  Местата в града, a/an/some/any и прилагателните за сравняване на места (p12 и p16)
  insert into public.assignments
    (slug, title, kind, url, description, max_points, published,
     sort_order, week, subject_id, grades, track, section)
  values
    ('en5-u1-places',
     'Домашно — Unit 1 · Around Town',
     'homework',
     'homework_5_en_u1_places.html',
     'Местата в града, a/an/some/any и прилагателните за сравняване на места (p12 и p16)',
     49,
     false,
     5115,
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

  --  Домашно — Unit 1 · Where’s the museum?
  --  Предлозите за място, учтивият въпрос за посока и ключовите фрази (p18)
  insert into public.assignments
    (slug, title, kind, url, description, max_points, published,
     sort_order, week, subject_id, grades, track, section)
  values
    ('en5-u1-speaking',
     'Домашно — Unit 1 · Where’s the museum?',
     'homework',
     'homework_5_en_u1_speaking.html',
     'Предлозите за място, учтивият въпрос за посока и ключовите фрази (p18)',
     38,
     false,
     5116,
     null,          --  английският не върви по седмици, а по юнити
     predmet,
     '{5}',
     'ep1_unit1',
     'speaking')
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

  --  Домашно — Unit 1 · My Town
  --  Описание на град: мястото на прилагателното, ключовите фрази и образец с празни места (p19)
  insert into public.assignments
    (slug, title, kind, url, description, max_points, published,
     sort_order, week, subject_id, grades, track, section)
  values
    ('en5-u1-writing',
     'Домашно — Unit 1 · My Town',
     'homework',
     'homework_5_en_u1_writing.html',
     'Описание на град: мястото на прилагателното, ключовите фрази и образец с празни места (p19)',
     34,
     false,
     5117,
     null,          --  английският не върви по седмици, а по юнити
     predmet,
     '{5}',
     'ep1_unit1',
     'writing')
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

  --  Домашно — Unit 1 · English Plus: Extra
  --  Лични данни, четене на карта, Обединеното кралство и песента (p92, p100, p106, p116)
  insert into public.assignments
    (slug, title, kind, url, description, max_points, published,
     sort_order, week, subject_id, grades, track, section)
  values
    ('en5-u1-extra',
     'Домашно — Unit 1 · English Plus: Extra',
     'homework',
     'homework_5_en_u1_extra.html',
     'Лични данни, четене на карта, Обединеното кралство и песента (p92, p100, p106, p116)',
     31,
     false,
     5118,
     null,          --  английският не върви по седмици, а по юнити
     predmet,
     '{5}',
     'ep1_unit1',
     'options')
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
--  Справка: ВСИЧКИ листове за Unit 1 — кой в коя част е и вижда ли се.
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
