-- =====================================================================
--  Домашно по АНГЛИЙСКИ за 4. клас — „Cat Family Album“ (to be)
--  ---------------------------------------------------------------------
--  Листът е homework_4_english_to_be.html: десет упражнения върху
--  глагола to be (am · is · are) — спрежението на „съм“. 49 отговора,
--  по 1 точка всеки, всичко се проверява от самата страница.
--
--  Мястото му в платформата: раздел „Домашни“, предмет „Английски“,
--  4. клас. БЕЗ седмица: английският не върви по седмици, а по юнитите
--  на учебника (виж assets/tracks.js). Листовете за 5. клас стоят под
--  своя юнит; този за 4. клас още няма юнит и затова се подрежда по
--  sort_order, най-отзад в списъка.
--
--  Предметът е „Английски“ (slug angliiski) — същият, който влиза с
--  supabase/schema-v13.sql и се вижда в падащото меню на таблото. Ако
--  някой го е преименувал от таблото, slug-ът пак е същият; ако пък е
--  сменен и slug-ът, редът долу го намира по име. Няма ли го изобщо,
--  файлът спира с ясно съобщение, вместо да закачи домашното за нищо.
--
--  ПУСКА СЕ ТОЛКОВА ПЪТИ, КОЛКОТО ТРЯБВА — нищо не се трие и не се
--  дублира. published нарочно не се пипа при повторно пускане: кога
--  листът отива при учениците се решава от таблото („Сложи в
--  библиотеката“, после „Дай на моите“).
--
--  ПРЕДИ ТОВА трябва веднъж да са минали:
--    · supabase/schema.sql и надстройките след него
--    · supabase/schema-v13.sql  (оттам идва предметът „Английски“)
-- =====================================================================

do $do$
declare
  predmet uuid;
  imeto   text;
begin
  --  Първо по slug — така се казва предметът в хранилището.
  select id, name into predmet, imeto
    from public.subjects
   where slug = 'angliiski';

  --  Ако таблото му е сменило и slug-а, остава името.
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

  raise notice 'Домашното се закача за предмет „%“.', imeto;

  insert into public.assignments
    (slug, title, kind, url, description, max_points, published,
     sort_order, week, subject_id, grades)
  values
    ('hw4-en-tobe',
     'Домашно — To be: am, is, are (Cat Family Album)',
     'homework',
     'homework_4_english_to_be.html',
     'Десет упражнения върху глагола to be: избор, попълване, кратки форми, '
       || 'отрицание, въпроси, кратки отговори, грешки, свързване и подреждане',
     49,
     false,
     408,
     null,          --  английският не върви по седмици, а по юнити
     predmet,
     '{4}')
  on conflict (slug) do update set
    title       = excluded.title,
    kind        = excluded.kind,
    url         = excluded.url,
    description = excluded.description,
    max_points  = excluded.max_points,
    sort_order  = excluded.sort_order,
    week        = excluded.week,
    subject_id  = excluded.subject_id,
    grades      = excluded.grades;
    -- published нарочно липсва тук: то се управлява от таблото.
end
$do$;


-- ---------------------------------------------------------------------
--  Справка: какво стана. Един ред — домашното и предметът му.
-- ---------------------------------------------------------------------
select
  a.slug,
  a.title,
  s.name                                   as predmet,
  a.grades                                 as klasove,
  a.week                                   as sedmica,
  a.max_points                             as tochki,
  a.published                              as publikuvano,
  case when a.published then 'вижда се от учениците'
       else 'още не се вижда — пусни го от таблото' end as sustoqnie
from public.assignments a
left join public.subjects s on s.id = a.subject_id
where a.slug = 'hw4-en-tobe';
