-- =====================================================================
--  Кои точно задачи е сгрешило едно дете
--  ---------------------------------------------------------------------
--  Пуска се в Supabase: SQL Editor → New query → Run. САМО ЧЕТЕ: нищо
--  не се записва и нищо не се променя.
--
--  Смени само първия ред — имената в кавичките. Търси се по част от
--  името, затова „Андрей“ намира и „Андрей Петров“. Ако в академията
--  има двама Андреевци, ще излязат и двамата с пълните си имена и ще
--  се вижда кой кой е.
--
--  Другарят на greshki-po-temi.sql. Онзи брои, този показва: всяка
--  сгрешена задача с условието ѝ, какво е отговорило детето и кое е
--  вярното. Оттук се вижда ДАЛИ грешките в една тема си приличат —
--  три пъти една и съща грешка е друго нещо от три различни.
--
--  Броят се само предадените работи. Незавършените не казват нищо за
--  знание — казват, че детето е спряло по средата.
-- =====================================================================

with deca as (
  select id, full_name
    from public.profiles
   where role = 'student'
     and (full_name ilike '%Андрей%' or full_name ilike '%Боян%')   -- ← смени тук
),

-- Последните домашни на всяко дете. Числото в последния ред казва колко.
posledni as (
  select at.*,
         row_number() over (partition by at.user_id order by at.submitted_at desc) as nomer
    from public.attempts at
    join deca d on d.id = at.user_id
    join public.assignments a on a.id = at.assignment_id
   where at.status <> 'in_progress'
     and a.kind = 'homework'
),

zadachi as (
  select d.full_name,
         a.title,
         p.submitted_at,
         coalesce((r->>'correct')::boolean, false) as vyarno,
         -- условието идва с html (дробите са таблички) — тук пада
         btrim(regexp_replace(replace(r->>'text', E'\n', ' '), '<[^>]+>', '', 'g')) as uslovie,
         case
           when r->>'kind' = 'free'       then r->>'chosenAnswer'
           when r->>'chosenIndex' is null  then '(без отговор)'
           -- вариантите се пазят в самия запис; ако по някаква причина
           -- ги няма, се показва кой по ред е избран, а не празно —
           -- празното се чете като „не е отговорил“, което е друго нещо
           when r->'options' is null       then 'вариант № ' || ((r->>'chosenIndex')::int + 1)
           else r->'options'->>((r->>'chosenIndex')::int)
         end as dal,
         case
           when r->>'kind' = 'free' then r->>'correctAnswer'
           else r->'options'->>((r->>'correctIndex')::int)
         end as vyarnoto
    from posledni p
    join deca d on d.id = p.user_id
    join public.assignments a on a.id = p.assignment_id
    cross join lateral jsonb_array_elements(coalesce(p.records, '[]'::jsonb)) r
   where p.nomer <= 6                                               -- ← последните 6 домашни
)

-- ── Всяка сгрешена задача, с отговора на детето ────────────────────
select full_name                   as ученик,
       title                       as домашно,
       left(uslovie, 90)           as условие,
       coalesce(dal, '(без отговор)') as дал,
       vyarnoto                    as вярното
  from zadachi
 where not vyarno
 order by 1, submitted_at desc, 3;
