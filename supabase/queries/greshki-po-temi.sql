-- =====================================================================
--  Кои теми затрудняват едно дете — по сгрешените задачи
--  ---------------------------------------------------------------------
--  Пуска се в Supabase: SQL Editor → New query → Run. САМО ЧЕТЕ: нищо
--  не се записва и нищо не се променя.
--
--  Смени само първия ред — имената в кавичките. Търси се по част от
--  името, затова „Андрей“ намира и „Андрей Петров“. Ако в академията
--  има двама Андреевци, ще излязат и двамата с пълните си имена и ще
--  се вижда кой кой е.
--
--  КАКВО ПОКАЗВА И КАКВО НЕ
--
--  Темата се чете от ЗАГЛАВИЕТО на домашното („Домашно 9 — Обикновени
--  дроби“), защото всяка задача пази условието си, но не и темата си.
--  Тоест: „коя седмица куца“ — да; „коя точно подтема вътре“ — не
--  направо, но условията на сгрешените задачи са отпечатани отдолу и
--  там се вижда.
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
         -- Условието идва с html: дробите в листовете са числител над
         -- знаменател. Ако html-ът просто се махне, „4/5 · 3/7“ става
         -- „45 · 37“ — две безсмислени числа, а задачата става
         -- неразпознаваема. Затова дробите ПЪРВО стават „n/d“ и чак
         -- после падат останалите етикети.
         btrim(regexp_replace(
           regexp_replace(
             replace(r->>'text', E'\n', ' '),
             '<span class="frac"><span class="num">(.*?)</span><span class="den">(.*?)</span></span>',
             '\1/\2', 'g'),
           '<[^>]+>', '', 'g')) as uslovie,
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

-- ── 1. Обобщението: къде са грешките ───────────────────────────────
select full_name                                   as ученик,
       title                                       as домашно,
       count(*) filter (where not vyarno)          as сгрешени,
       count(*)                                    as задачи,
       round(100.0 * count(*) filter (where vyarno) / nullif(count(*), 0))
                                                   as процент_верни,
       max(submitted_at)::date                     as предадено
  from zadachi
 group by 1, 2
 order by 1, 3 desc, 5;
