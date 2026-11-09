-- =====================================================================
--  Английски, 5. клас, Unit 2 — трите листа „Days“
--  ---------------------------------------------------------------------
--  Втората тема от учебника: всекидневие, present simple и празници.
--  Три листа, всеки с най-много седем упражнения:
--
--    1  A Day in the Life  at/on/in, наречия за честота, цял понеделник
--    2  Present Simple     -s, don’t/doesn’t, въпроси, кратки отговори
--    3  Special Days       празници, предложения, also, Баба Марта
--
--  Мястото им: предмет „Английски“, 5. клас, Unit 2 от English Plus 1,
--  всеки в своята част на юнита. БЕЗ седмица: английският върви по юнити.
--
--  Третият лист има и четири въпроса с цели изречения — те се записват
--  в part2 с manual_max и излизат в таблото за ръчна оценка.
--
--  ПУСКА СЕ ТОЛКОВА ПЪТИ, КОЛКОТО ТРЯБВА — нищо не се трие и не се
--  дублира. published нарочно не се пипа при повторно пускане.
--
--  Файлът е написан от scripts/gen_english5_u2_sql.py — не го
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

  raise notice 'Трите листа се закачат за предмет „%“, Unit 2.', imeto;

  --  Домашно — Unit 2 · A Day in the Life
  --  Всекидневието, предлозите at / on / in и наречията за честота — с цял един понеделник накрая
  insert into public.assignments
    (slug, title, kind, url, description, max_points, published,
     sort_order, week, subject_id, grades, track, section)
  values
    ('en5-u2-day',
     'Домашно — Unit 2 · A Day in the Life',
     'homework',
     'homework_5_en_u2_day.html',
     'Всекидневието, предлозите at / on / in и наречията за честота — с цял един понеделник накрая',
     37,
     false,
     5120,
     null,          --  английският не върви по седмици, а по юнити
     predmet,
     '{5}',
     'ep1_unit2',
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

  --  Домашно — Unit 2 · Present Simple
  --  Present simple: третото лице с -s, don’t и doesn’t, въпроси с Do и Does, кратки отговори и хващане на грешка
  insert into public.assignments
    (slug, title, kind, url, description, max_points, published,
     sort_order, week, subject_id, grades, track, section)
  values
    ('en5-u2-present',
     'Домашно — Unit 2 · Present Simple',
     'homework',
     'homework_5_en_u2_present.html',
     'Present simple: третото лице с -s, don’t и doesn’t, въпроси с Do и Does, кратки отговори и хващане на грешка',
     44,
     false,
     5121,
     null,          --  английският не върви по седмици, а по юнити
     predmet,
     '{5}',
     'ep1_unit2',
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

  --  Домашно — Unit 2 · Special Days
  --  Празниците, изразите за предложение, мястото на also и текст за Баба Марта
  insert into public.assignments
    (slug, title, kind, url, description, max_points, published,
     sort_order, week, subject_id, grades, track, section)
  values
    ('en5-u2-special',
     'Домашно — Unit 2 · Special Days',
     'homework',
     'homework_5_en_u2_special.html',
     'Празниците, изразите за предложение, мястото на also и текст за Баба Марта',
     42,
     false,
     5122,
     null,          --  английският не върви по седмици, а по юнити
     predmet,
     '{5}',
     'ep1_unit2',
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
end
$do$;


-- ---------------------------------------------------------------------
--  Справка: трите листа, в коя част на юнита са и вижда ли ги някой.
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
where a.slug like 'en5-u2-%'
order by a.sort_order;
