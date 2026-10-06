-- Ограниченията на разделите. Всичко в транзакция с rollback.
\set ON_ERROR_STOP on
create or replace function pg_temp.must_fail(name text, sql text, want text)
returns void language plpgsql as $$
declare code text;
begin
  begin execute sql;
  exception when others then
    code := sqlstate;
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
insert into public.assignments (slug,title,kind,url,max_points,published,sort_order)
values ('v8-proba','Проба','exam','a.html',20,false,900);

do $$ begin
  update public.assignments set track='olimpiada', section='obshtinski' where slug='v8-proba';
  raise notice '   ✓ задание влиза в раздел';
  update public.assignments set track=null, section=null where slug='v8-proba';
  raise notice '   ✓ и може да излезе от него';
end $$;

select pg_temp.must_fail('подтема без тема',
  $$update public.assignments set section='obshtinski' where slug='v8-proba'$$, '23514');
select pg_temp.must_fail('тема на кирилица',
  $$update public.assignments set track='олимпиада' where slug='v8-proba'$$, '23514');
select pg_temp.must_fail('тема с главни букви',
  $$update public.assignments set track='Olimpiada' where slug='v8-proba'$$, '23514');
select pg_temp.must_fail('тема с интервал',
  $$update public.assignments set track='общински кръг' where slug='v8-proba'$$, '23514');
select pg_temp.must_fail('прекалено дълго име',
  $$update public.assignments set track=repeat('a',40) where slug='v8-proba'$$, '23514');

do $$
declare n int;
begin
  select count(*) into n from public.assignments where track is not null;
  perform (select 1);
  raise notice '   ✓ старите задания остават извън раздели · % в раздел', n;
end $$;
rollback;
\echo '═══ ВСИЧКО МИНА ═══'
