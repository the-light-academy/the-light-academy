-- =====================================================================
--  Изтриване на преподавател — само ако няма ученици
--  ---------------------------------------------------------------------
--  ПРОЧЕТИ ПРЕДИ ДА ПУСНЕШ. Този файл ТРИЕ. Няма връщане назад.
--
--  Преди него пусни supabase/queries/prepodavatel-ima-li-uchenici.sql —
--  той само гледа и казва дали може.
--
--  Файлът сам отказва да тръгне, ако:
--    · по името е намерен повече от един човек (или нито един);
--    · този човек не е преподавател;
--    · е администратор;
--    · има ученици — дори връзката да е спряна;
--    · има часове в календара (виж ключето по-долу).
--
--  Ако всички пазачи са минати, изтрива се профилът И входът към него,
--  за да не остане човек, който може да влезе без профил. Заедно с
--  профила си отиват и:
--    · записите кои предмети преподава;
--    · листовете, които е дал на свои ученици („Дай на моите“);
--    · обратните връзки, които е писал.
--  Чуждите резултати и самите домашни НЕ се пипат.
--
--  ПО-МЕКИЯТ ИЗХОД: ако просто не искаш човекът да се вижда и да влиза,
--  вместо да го триеш, спри го — тогава всичко остава записано:
--      update public.profiles set active = false
--       where full_name = 'Лили Иванова';
-- =====================================================================

do $$
declare
  --  ⬇⬇⬇  ТУК СЕ СМЕНЯТ ДВЕТЕ НЕЩА  ⬇⬇⬇
  ime           text    := 'Лили';   -- стига и част от името
  trii_chasovete boolean := false;   -- true само ако искаш и часовете ѝ

  koj      public.profiles;
  broi     int;
  deca     int;
  chasove  int;
  listove  int;
  vruzki   int;
  predmeti int;
begin
  --  1 · Кой точно
  select count(*) into broi
    from public.profiles p
   where p.full_name ilike '%' || ime || '%';

  if broi = 0 then
    raise exception 'Няма човек с име като „%“. Нищо не е изтрито.', ime
      using hint = 'Пусни queries/prepodavatel-ima-li-uchenici.sql — там са '
                   'изписани всички преподаватели.';
  end if;

  if broi > 1 then
    --  Името се търси сред ВСИЧКИ профили, не само сред преподавателите:
    --  ако по него излиза и едно дете, по-добре да откаже, отколкото да
    --  налучка. Затова ги изписваме кои са.
    raise exception 'По „%“ излизат % души: %. Нищо не е изтрито.',
      ime, broi,
      (select string_agg(p.full_name || ' (' ||
                case p.role when 'teacher' then 'преподавател'
                            when 'student' then 'ученик'
                            else coalesce(p.role, 'без роля') end || ')', ', '
                order by p.full_name)
         from public.profiles p
        where p.full_name ilike '%' || ime || '%')
      using hint = 'Напиши по-пълно име, за да остане само един.';
  end if;

  select p.* into koj
    from public.profiles p
   where p.full_name ilike '%' || ime || '%';

  --  2 · Това преподавател ли е изобщо
  if koj.role is distinct from 'teacher' then
    raise exception 'Профилът „%“ е с роля „%“, а не преподавател. '
                    'Нищо не е изтрито.', koj.full_name, koj.role;
  end if;

  if coalesce(koj.is_admin, false) then
    raise exception 'Профилът „%“ е администратор. Нищо не е изтрито.',
                    koj.full_name
      using hint = 'Свали администраторските права от таблото и пусни пак.';
  end if;

  --  3 · Има ли ученици — ТОВА Е ГЛАВНИЯТ ПАЗАЧ
  select count(*) into deca
    from public.teaching t where t.teacher_id = koj.id;

  if deca > 0 then
    raise exception '„%“ има % връзки с ученици. НИЩО НЕ Е ИЗТРИТО.',
                    koj.full_name, deca
      using hint = 'Първо прехвърли децата на друг преподавател от таблото '
                   '(Ученици → Преподавател), после пусни файла пак.';
  end if;

  --  4 · Часовете в календара пазят профила — базата няма да го пусне
  select count(*) into chasove
    from public.lessons l
   where l.teacher_id = koj.id or l.created_by = koj.id;

  if chasove > 0 and not trii_chasovete then
    raise exception '„%“ няма ученици, но има % часа в календара. '
                    'Нищо не е изтрито.', koj.full_name, chasove
      using hint = 'Ако часовете вече не трябват, смени trii_chasovete на '
                   'true най-горе във файла и пусни пак.';
  end if;

  --  5 · Какво си отива заедно с него
  select count(*) into listove
    from public.assignment_releases r where r.teacher_id = koj.id;
  select count(*) into vruzki
    from public.feedback_reports f where f.teacher_id = koj.id;
  select count(*) into predmeti
    from public.teacher_subjects ts where ts.teacher_id = koj.id;

  raise notice 'Изтривам „%“ (%).', koj.full_name, koj.id;
  raise notice '  · ученици: 0 — затова изобщо стигаме дотук';
  raise notice '  · предмети, които е преподавал: %', predmeti;
  raise notice '  · листове, които е дал: %', listove;
  raise notice '  · обратни връзки: %', vruzki;
  raise notice '  · часове в календара: % %', chasove,
               case when chasove > 0 then '(изтриват се и те)' else '' end;

  --  6 · Самото изтриване
  if chasove > 0 then
    delete from public.lessons l
     where l.teacher_id = koj.id or l.created_by = koj.id;
  end if;

  --  Входът влече профила след себе си (profiles.id → auth.users.id с
  --  „трие се с него“). Така не остава човек, който може да влезе, но
  --  няма профил. Ако входът липсва, трием самия профил.
  delete from auth.users u where u.id = koj.id;
  delete from public.profiles p where p.id = koj.id;

  if exists (select 1 from public.profiles p where p.id = koj.id) then
    raise exception 'Профилът не се изтри. Нищо не е променено.';
  end if;

  raise notice 'Готово. „%“ вече я няма.', koj.full_name;
end $$;


-- ---------------------------------------------------------------------
--  Какво остана: преподавателите след изтриването.
-- ---------------------------------------------------------------------
select p.full_name                                     as "преподавател",
       case when p.active then 'активен' else 'спрян' end as "състояние",
       (select count(*) from public.teaching t
         where t.teacher_id = p.id and t.active)       as "ученици сега"
  from public.profiles p
 where p.role = 'teacher'
 order by p.full_name;
