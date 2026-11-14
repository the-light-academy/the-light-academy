-- =====================================================================
--  6. клас — трите нива по седмици: кое го има и кое не
--  ---------------------------------------------------------------------
--  Пусни ЦЕЛИЯ файл в SQL редактора на Supabase. Нищо не променя — само
--  гледа. За всяка седмица показва трите листа един до друг:
--
--      основен   ·   ниво 2   ·   ниво В група
--
--  и за всеки от тях в какво състояние е:
--
--      ❌ няма го в базата   — редът не е пускан. Пусни файла, който
--                              пише най-долу в колоната „какво липсва“.
--      ⬜ чернова            — редът е в базата, но не е в библиотеката.
--                              Таблото → „Сложи в библиотеката“.
--      📚 в библиотеката     — публикуван е, но още не е даден на деца.
--                              Таблото → „Дай на моите“.
--      ✅ даден              — стигнал е до учениците.
--
--  Седмиците 3, 18 и 33 ги няма нарочно: тогава се пише входно ниво,
--  класна работа и изходно ниво — няма домашно, значи няма и нива.
-- =====================================================================

with listove as (
  --  Само истинските домашни за 6. клас по математика. Старите тестови
  --  редове (draft.html, hw6.html) нямат „homework_6_“ в адреса и
  --  отпадат тук.
  select a.*
    from public.assignments a
    join public.subjects s on s.id = a.subject_id
   where a.kind = 'homework'
     and a.grades = array[6]
     and s.slug = 'matematika'
     and a.url like 'homework\_6\_%'
),
osnovni as (
  select * from listove
   where title not like '%· ниво 2' and title not like '%· ниво В%'
),
sustoyanie as (
  --  Едно и също изречение за всеки от трите листа.
  select o.id as osnoven_id,
         v.vid,
         case
           when x.id is null                    then '❌ няма го в базата'
           when not x.published                 then '⬜ чернова'
           when not exists (select 1 from public.assignment_releases r
                             where r.assignment_id = x.id and not r.hidden)
                                                then '📚 в библиотеката'
           else '✅ даден'
         end as text
    from osnovni o
    cross join lateral (values
        ('1 основен',     o.url),
        ('2 ниво 2',      replace(o.url, '.html', 'b.html')),
        ('3 ниво В група', replace(o.url, '.html', 'v.html'))
      ) as v(vid, adres)
    left join listove x on x.url = v.adres
)
select
  o.week                                               as "седмица",
  replace(o.title, 'Домашно — ', '')                   as "тема",
  max(s.text) filter (where s.vid = '1 основен')       as "основен",
  max(s.text) filter (where s.vid = '2 ниво 2')        as "ниво 2",
  max(s.text) filter (where s.vid = '3 ниво В група')  as "ниво В група",
  case
    when max(s.text) filter (where s.vid = '2 ниво 2') = '❌ няма го в базата'
     and max(s.text) filter (where s.vid = '3 ниво В група') = '❌ няма го в базата'
      then 'пусни domashni-nivo2.sql и domashni-nivo-v.sql'
    when max(s.text) filter (where s.vid = '2 ниво 2') = '❌ няма го в базата'
      then 'пусни supabase/domashni-nivo2.sql'
    when max(s.text) filter (where s.vid = '3 ниво В група') = '❌ няма го в базата'
      then 'пусни supabase/domashni-nivo-v.sql'
    when max(s.text) filter (where s.vid = '1 основен') = '❌ няма го в базата'
      then 'пусни supabase/assignments.sql'
    else ''
  end                                                  as "какво липсва"
  from osnovni o
  join sustoyanie s on s.osnoven_id = o.id
 group by o.id, o.week, o.title, o.sort_order
 order by o.week, o.sort_order, o.title;


-- ---------------------------------------------------------------------
--  Един ред накрая: колко от всяко ниво има и докъде са стигнали.
-- ---------------------------------------------------------------------
with listove as (
  select a.*,
         case when a.title like '%· ниво 2'  then 'ниво 2'
              when a.title like '%· ниво В%' then 'ниво В група'
              else 'основен' end as nivo
    from public.assignments a
    join public.subjects s on s.id = a.subject_id
   where a.kind = 'homework'
     and a.grades = array[6]
     and s.slug = 'matematika'
     and a.url like 'homework\_6\_%'
)
select nivo                                              as "ниво",
       count(*)                                          as "в базата",
       count(*) filter (where published)                 as "в библиотеката",
       count(*) filter (where exists (
         select 1 from public.assignment_releases r
          where r.assignment_id = listove.id and not r.hidden))
                                                         as "дадени",
       case when count(*) = 32 then '✅ пълен комплект'
            else '❌ липсват ' || (32 - count(*))::text end as "комплект"
  from listove
 group by nivo
 order by nivo;
