-- =====================================================================
--  Кой има право върху кои таблици
--  ---------------------------------------------------------------------
--  ЗАЩО Е ТУК
--  От 30 октомври 2026 г. Supabase спира да дава автоматично права на
--  Data API върху НОВИ таблици в схема public. Старите таблици не се
--  пипат — те си остават достъпни. Но всяка таблица, създадена след
--  тази дата (нов проект, клон за преглед, „supabase db reset“), иска
--  изрично GRANT, инак страницата получава „permission denied“.
--
--  Този файл само ПОКАЗВА. Нищо не променя и може да се пуска по всяко
--  време върху живата база.
--
--  КАК СЕ ЧЕТЕ
--  · authenticated — влезлият потребител. Трябва да е ✅ навсякъде;
--    кой какво вижда се решава после от политиките (RLS).
--  · service_role — ключът на Edge функцията admin-users. Трябва да е
--    ✅ поне за profiles, enrollments, subjects и teaching — функцията
--    пише точно в тях. Ключът заобикаля RLS, но БЕЗ право върху
--    таблицата пак не минава.
--  · anon — нерегистриран посетител. Тук е редно да е ❌: в тази
--    платформа всичко е зад вход. Единственото изключение е
--    assignments, където има нарочно дадено право за четене.
--  · RLS — трябва да е ✅ за всяка таблица. Таблица без RLS, но с
--    права, е отворена за всеки влязъл потребител.
-- =====================================================================

select
  c.relname                                                    as таблица,
  case when c.relrowsecurity then '✅' else '❌ БЕЗ RLS' end   as rls,
  (select count(*) from pg_policy p where p.polrelid = c.oid)  as политики,
  case when has_table_privilege('authenticated', c.oid, 'select') then '✅' else '❌' end as чете_влязъл,
  case when has_table_privilege('authenticated', c.oid, 'insert') then '✅' else '❌' end as пише_влязъл,
  case when has_table_privilege('service_role',  c.oid, 'select') then '✅' else '❌' end as чете_функцията,
  case when has_table_privilege('service_role',  c.oid, 'insert') then '✅' else '❌' end as пише_функцията,
  case when has_table_privilege('anon',          c.oid, 'select') then '⚠️ да' else '—' end as чете_анонимен
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public'
  and c.relkind = 'r'
order by c.relname;
