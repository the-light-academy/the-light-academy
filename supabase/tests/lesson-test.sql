-- Уроците в assignments: третият вид, нулевите точки и забраната за
-- опит върху урок. Всичко в транзакция с rollback — базата остава както
-- е била.
\set ON_ERROR_STOP on
create or replace function pg_temp.must_fail(name text, sql text, want text)
returns void language plpgsql as $$
declare code text;
begin
  begin execute sql;
  exception when others then
    code := sqlstate;
    /* Тези кодове значат, че самият тест е написан накриво — липсваща
       колона, объркан тип, сбъркан синтаксис. Да ги броим за „базата
       спря нередното“ е най-лесният начин тестът да лъже. */
    if code in ('42601','42703','42804','42883','42P01','22P02') then
      raise exception '   ✗ % · тестът е сбъркан, не базата: % (%)', name, sqlerrm, code;
    end if;
    if code <> want then
      raise exception '   ✗ % · спря с %, а трябваше с %: %', name, code, want, sqlerrm;
    end if;
    raise notice '   ✓ % (%)', name, code; return;
  end;
  raise exception '   ✗ % · МИНА, а не трябваше', name;
end $$;

begin;

-- ── 1. Трите вида минават, четвърти няма ──────────────────────────────
do $$ begin
  insert into public.assignments (slug,title,kind,url,published,sort_order)
    values ('v9-hw','Домашно проба','homework','hw.html',false,900);
  insert into public.assignments (slug,title,kind,url,published,sort_order)
    values ('v9-ex','Изпит проба','exam','ex.html',false,901);
  insert into public.assignments (slug,title,kind,url,published,sort_order)
    values ('v9-ur','Урок проба','lesson','uroci/u.html',false,902);
  raise notice '   ✓ домашно, изпит и урок влизат';
end $$;

select pg_temp.must_fail('измислен вид',
  $$insert into public.assignments (slug,title,kind,url,sort_order)
    values ('v9-x','Проба','video','x.html',903)$$, '23514');

select pg_temp.must_fail('празен вид',
  $$insert into public.assignments (slug,title,kind,url,sort_order)
    values ('v9-y','Проба','','y.html',904)$$, '23514');

-- ── 2. Урокът няма точки, дори да му се напишат ───────────────────────
do $$
declare p numeric;
begin
  select max_points into p from public.assignments where slug = 'v9-ur';
  if p <> 0 then
    raise exception '   ✗ новият урок влезе с % точки, а трябва 0', p;
  end if;
  raise notice '   ✓ нов урок влиза с 0 точки, без да се пише';

  update public.assignments set max_points = 50 where slug = 'v9-ur';
  select max_points into p from public.assignments where slug = 'v9-ur';
  if p <> 0 then
    raise exception '   ✗ урокът прие % точки при редакция', p;
  end if;
  raise notice '   ✓ и 50 точки, писани на ръка, пак стават 0';

  select max_points into p from public.assignments where slug = 'v9-hw';
  if p <> 100 then
    raise exception '   ✗ домашното изгуби точките си: %', p;
  end if;
  raise notice '   ✓ домашното си остава със 100 точки — тригерът не го пипа';
end $$;

-- ── 3. Върху урок не се пише опит ─────────────────────────────────────
-- Нужен е ученик с истински id в auth.users, иначе ще спре външният ключ
-- и тестът ще отчете чужда забрана за своя.
do $$
declare uid uuid;
begin
  select id into uid from public.profiles where role = 'student' limit 1;
  if uid is null then
    raise notice '   ⊘ няма нито един ученик — проверката за опит се пропуска';
    return;
  end if;

  /* първо: опит върху домашно — трябва да мине */
  insert into public.attempts (user_id, assignment_id, status)
    select uid, id, 'submitted' from public.assignments where slug = 'v9-hw';
  raise notice '   ✓ опит върху домашно минава';

  /* после: същото върху урок — трябва да спре */
  begin
    insert into public.attempts (user_id, assignment_id, status)
      select uid, id, 'submitted' from public.assignments where slug = 'v9-ur';
    raise exception '   ✗ опит върху урок МИНА, а не трябваше';
  exception when check_violation then
    raise notice '   ✓ опит върху урок е спрян';
  end;

  /* и прехвърляне на вече записан опит върху урок */
  begin
    update public.attempts set assignment_id = (select id from public.assignments where slug='v9-ur')
      where user_id = uid
        and assignment_id = (select id from public.assignments where slug='v9-hw');
    raise exception '   ✗ опитът беше преместен върху урок, а не трябваше';
  exception when check_violation then
    raise notice '   ✓ и преместване на опит върху урок е спряно';
  end;
end $$;

-- ── 4. Старите задания са недокоснати ─────────────────────────────────
do $$
declare n int;
begin
  select count(*) into n from public.assignments
   where kind not in ('exam','homework','lesson');
  if n > 0 then
    raise exception '   ✗ % стари задания не минават новото ограничение', n;
  end if;
  select count(*) into n from public.assignments where kind = 'lesson';
  raise notice '   ✓ всички стари задания минават новото ограничение · уроци: %', n;
end $$;

-- ── 5. Същото, но през очите на ученик (под RLS) ──────────────────────
-- Предишната проверка мина като суперпотребител. Тя доказва, че тригерът
-- се задейства, но не и че ученикът опира до него: политиката върху
-- attempts иска заданието да МУ Е ДАДЕНО. Затова тук се сглобява цялата
-- верига — преподавател, записване по предмета, публикуван лист, даден
-- на класа — и чак тогава се пробва. Без нея „insert ... select“ не
-- вмъква нито ред и тишината лесно минава за забрана.
do $$
declare st uuid; tc uuid; sb uuid; g int; hw uuid; ur uuid; n int;
begin
  select t.student_id, t.teacher_id, t.subject_id, public.current_grade(t.student_id)
    into st, tc, sb, g
    from public.teaching t
    join public.enrollments e
      on e.profile_id = t.student_id and e.subject_id = t.subject_id and e.active
    join public.profiles p
      on p.id = t.student_id and p.role = 'student' and p.active
   where t.active and public.current_grade(t.student_id) between -1 and 12
   limit 1;

  if st is null then
    raise notice '   ⊘ няма ученик с преподавател по записан предмет — проверката под RLS се пропуска';
    return;
  end if;

  insert into public.assignments (slug,title,kind,url,published,sort_order,subject_id,grades)
    values ('v9-rls-hw','Домашно за RLS','homework','hw3.html',true,960,sb,array[g])
    returning id into hw;
  insert into public.assignments (slug,title,kind,url,published,sort_order,subject_id,grades)
    values ('v9-rls-ur','Урок за RLS','lesson','uroci/u3.html',true,961,sb,array[g])
    returning id into ur;
  insert into public.assignment_releases (assignment_id, teacher_id, hidden)
    values (hw, tc, false), (ur, tc, false);

  if not public.can_see_assignment(st, ur) then
    raise exception '   ✗ урокът не стигна до ученика — веригата в теста е сбъркана';
  end if;

  perform set_config('tla.uid', st::text, true);
  set local role authenticated;

  begin
    insert into public.attempts (user_id, assignment_id, status) values (st, hw, 'submitted');
    get diagnostics n = row_count;
    if n <> 1 then raise exception '   ✗ домашното не се предаде (% реда)', n; end if;
    raise notice '   ✓ ученикът още предава домашно — тригерът не му пречи';
  exception when check_violation or insufficient_privilege then
    raise exception '   ✗ предаването на домашно се счупи: % (%)', sqlerrm, sqlstate;
  end;

  begin
    insert into public.attempts (user_id, assignment_id, status) values (st, ur, 'submitted');
    raise exception '   ✗ ученик записа опит върху урок';
  exception
    when check_violation then
      raise notice '   ✓ и като ученик опитът върху урок е спрян от тригера';
    when insufficient_privilege then
      raise exception '   ✗ спря го политиката, не тригерът — проверката не доказва нищо';
  end;

  reset role;
end $$;

rollback;
\echo '═══ ВСИЧКО МИНА ═══'
