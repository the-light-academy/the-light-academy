/* =====================================================================
   admin-users — create and delete accounts (students and teachers)
   ---------------------------------------------------------------------
   The only server-side code in this project, and it exists for one
   reason: creating or deleting an auth user needs the service_role key,
   which bypasses every Row Level Security policy. That key must never be
   sent to a browser, so this function holds it instead.

   Every request is checked twice before anything happens:
     1. the caller's access token must be a valid session, and
     2. that user's profile row must be is_admin AND active.

   The check used to be role='teacher'. With several teachers that is far
   too wide: it would let any teacher create accounts and delete other
   people's students. Making accounts is an admin job, and the database
   agrees -- the policies added in schema-v3.sql give a plain teacher no
   write access to profiles at all.

   role is never taken from the request for students: handle_new_user()
   hard-codes 'student', and a teacher is promoted here, by the service
   key, only after the caller has been proven to be the admin.

   Supabase injects SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY into the
   function environment at deploy time -- you do not set them by hand.

   Deploy:
     supabase login
     supabase link --project-ref <your-project-ref>
     supabase functions deploy admin-users
   ===================================================================== */

/* npm:, а не https://esm.sh/… — esm.sh е чужд сайт, който трябва да
   отговори, докато Supabase сглобява функцията, и когато не отговори за
   10 секунди, деплоят пада с „Fetch … timed out“. Причината не е в кода:
   същият файл минава или пада според това как се чувства esm.sh в онзи
   момент. С npm: пакетът се тегли от регистъра, който Deno ползва сам, и
   един посредник отпада. Ако някога и това откаже, работи и
   'jsr:@supabase/supabase-js@2'. */
import { createClient } from 'npm:@supabase/supabase-js@2';

const ALLOWED_ORIGINS = [
  'https://the-light-academy.github.io',
  'http://127.0.0.1:9301',
  'http://localhost:9301',
];

function corsHeaders(origin: string | null) {
  // Echo the origin only when we recognise it, so this function cannot be
  // driven from an arbitrary site using a logged-in teacher's browser.
  const allow = origin && ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0];
  return {
    'Access-Control-Allow-Origin': allow,
    'Access-Control-Allow-Headers': 'authorization, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, DELETE, OPTIONS',
    'Vary': 'Origin',
  };
}

/* The school year turns over on 1 September; 2026 means 2026/27. The same
   rule as school_year_of() in supabase/schema-v2.sql. Deno runs in UTC, and
   the first hours of 1 September in Sofia are still 31 August in UTC, so the
   date is read in Sofia time rather than the server's. */
function schoolYearOf(d: Date): number {
  const sofia = new Date(d.toLocaleString('en-US', { timeZone: 'Europe/Sofia' }));
  return sofia.getMonth() >= 8 ? sofia.getFullYear() : sofia.getFullYear() - 1;
}

function json(body: unknown, status: number, origin: string | null) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
  });
}

Deno.serve(async (req: Request) => {
  const origin = req.headers.get('origin');

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders(origin) });
  }

  const url = Deno.env.get('SUPABASE_URL')!;
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  const admin = createClient(url, serviceKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  // ---- 1. who is calling? -------------------------------------------
  const authHeader = req.headers.get('Authorization') || '';
  const token = authHeader.replace(/^Bearer\s+/i, '');
  if (!token) return json({ error: 'Липсва токен.' }, 401, origin);

  const { data: userData, error: userErr } = await admin.auth.getUser(token);
  if (userErr || !userData?.user) {
    return json({ error: 'Невалидна сесия.' }, 401, origin);
  }

  // ---- 2. are they the admin? ---------------------------------------
  const { data: profile, error: profErr } = await admin
    .from('profiles')
    .select('role, active, is_admin')
    .eq('id', userData.user.id)
    .maybeSingle();

  if (profErr) return json({ error: profErr.message }, 500, origin);
  if (!profile || profile.is_admin !== true || profile.active !== true) {
    return json({ error: 'Само администраторът може да управлява профили.' }, 403, origin);
  }

  let body: Record<string, unknown> = {};
  try { body = await req.json(); } catch { /* empty body is fine for some calls */ }

  // ---- create -------------------------------------------------------
  if (req.method === 'POST') {
    const email = String(body.email || '').trim().toLowerCase();
    const password = String(body.password || '');
    const fullName = String(body.full_name || '').trim();

    // 'student' (the default) or 'teacher'. Anything else is refused
    // rather than quietly treated as a student.
    const kind = String(body.kind || 'student');
    if (kind !== 'student' && kind !== 'teacher') {
      return json({ error: 'Непознат вид профил.' }, 400, origin);
    }

    // The class the student is entered in. -1 and 0 are the two preschool
    // years. The database stores this together with the school year it was
    // set in, and works out the current class from the pair, so this value
    // never has to be migrated in September.
    const rawGrade = body.grade;
    const grade =
      rawGrade === null || rawGrade === undefined || rawGrade === ''
        ? null
        : Number(rawGrade);

    if (!email || !email.includes('@')) {
      return json({ error: 'Невалиден имейл.' }, 400, origin);
    }
    if (password.length < 8) {
      return json({ error: 'Паролата трябва да е поне 8 знака.' }, 400, origin);
    }
    if (kind === 'student') {
      if (grade === null) {
        return json({ error: 'Изберете клас.' }, 400, origin);
      }
      if (!Number.isInteger(grade) || grade < -1 || grade > 12) {
        return json({ error: 'Класът трябва да е между предучилищна и 12.' }, 400, origin);
      }
    }

    // Which teacher takes this student, and for which subjects. A student
    // with no teaching row sees nothing at all -- that is the deliberate
    // rule in schema-v3.sql -- so the dashboard always sends one, and this
    // refuses to make a student who would land nowhere.
    const teacherId = body.teacher_id ? String(body.teacher_id) : null;
    const subjectIds: string[] = Array.isArray(body.subject_ids)
      ? body.subject_ids.map((x: unknown) => String(x)).filter(Boolean)
      : [];

    if (kind === 'student') {
      if (!teacherId) {
        return json({ error: 'Изберете преподавател за ученика.' }, 400, origin);
      }
      if (!subjectIds.length) {
        return json({ error: 'Изберете поне един предмет.' }, 400, origin);
      }
      const { data: t } = await admin
        .from('profiles').select('id, role, active').eq('id', teacherId).maybeSingle();
      if (!t || t.role !== 'teacher' || t.active !== true) {
        return json({ error: 'Избраният преподавател не съществува.' }, 400, origin);
      }
    }

    const { data: created, error: createErr } = await admin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,                     // teacher-issued, no confirmation mail
      // handle_new_user() reads full_name and grade out of this and makes
      // the profile row, then enrols the student in every subject marked
      // auto_enroll. role is hard-coded to 'student' in the trigger and is
      // passed here only so the metadata says what it is.
      user_metadata: {
        full_name: fullName,
        // handle_new_user() ignores this and always writes 'student'; a
        // teacher is promoted below, with the service key, only because
        // the caller has already been proven to be the admin.
        role: kind,
        grade: kind === 'student' ? String(grade) : '',
      },
    });

    if (createErr) {
      const msg = /already registered|already been registered/i.test(createErr.message)
        ? 'Вече има профил с този имейл.'
        : createErr.message;
      return json({ error: msg }, 400, origin);
    }

    const newId = created.user!.id;

    // ---- a teacher ---------------------------------------------------
    // The trigger wrote role='student'; only the service key can change
    // that, and only here, after the admin check at the top.
    if (kind === 'teacher') {
      const { error: promErr } = await admin.from('profiles')
        .update({ full_name: fullName, role: 'teacher', active: true, is_admin: false })
        .eq('id', newId);
      if (promErr) return json({ error: promErr.message }, 500, origin);

      // A teacher is not a pupil of the academy: drop the automatic
      // enrolments the trigger made, so they never show up as a student.
      await admin.from('enrollments').delete().eq('profile_id', newId);

      return json({ ok: true, id: newId, kind: 'teacher' }, 200, origin);
    }

    // ---- a student ---------------------------------------------------
    // The on_auth_user_created trigger has already made the profile row;
    // this just makes sure the name and the class landed even if the
    // metadata did not survive.
    const schoolYear = schoolYearOf(new Date());
    await admin.from('profiles')
      .update({
        full_name: fullName,
        role: 'student',
        active: true,
        grade_at_entry: grade,
        entry_school_year: schoolYear,
        grade_set_at: new Date().toISOString(),
      })
      .eq('id', newId);

    // Enrol in exactly the subjects chosen, plus anything marked
    // auto_enroll, so the trigger's work is kept rather than fought.
    const { data: autoSubjects } = await admin
      .from('subjects').select('id').eq('active', true).eq('auto_enroll', true);
    const allSubjects = Array.from(new Set([
      ...subjectIds,
      ...(autoSubjects || []).map((s: { id: string }) => s.id),
    ]));

    await admin.from('enrollments').upsert(
      allSubjects.map((sid) => ({ profile_id: newId, subject_id: sid })),
      { onConflict: 'profile_id,subject_id', ignoreDuplicates: true },
    );

    // The teaching rows. Without these the student sees an empty portal,
    // so a failure here is reported rather than swallowed.
    const { error: teachErr } = await admin.from('teaching').upsert(
      subjectIds.map((sid) => ({
        teacher_id: teacherId, student_id: newId, subject_id: sid,
      })),
      { onConflict: 'teacher_id,student_id,subject_id', ignoreDuplicates: true },
    );
    if (teachErr) {
      return json({
        error: 'Профилът е създаден, но не се закачи за преподавател: ' + teachErr.message,
      }, 500, origin);
    }

    return json({ ok: true, id: newId, kind: 'student', grade }, 200, origin);
  }

  // ---- delete -------------------------------------------------------
  if (req.method === 'DELETE') {
    const userId = String(body.user_id || '');
    if (!userId) return json({ error: 'Липсва user_id.' }, 400, origin);

    if (userId === userData.user.id) {
      return json({ error: 'Не можете да изтриете собствения си профил.' }, 400, origin);
    }

    const { data: target } = await admin
      .from('profiles').select('role, is_admin, full_name').eq('id', userId).maybeSingle();
    if (!target) return json({ error: 'Няма такъв профил.' }, 404, origin);
    if (target.is_admin) {
      return json({ error: 'Профил на администратор не се изтрива оттук.' }, 400, origin);
    }

    // Deleting a teacher would cascade their teaching rows away and leave
    // their students seeing an empty portal without anybody noticing. So
    // it is refused while they still have students -- the admin moves the
    // students first, and the error says how many there are.
    if (target.role === 'teacher') {
      const { count } = await admin
        .from('teaching')
        .select('student_id', { count: 'exact', head: true })
        .eq('teacher_id', userId)
        .eq('active', true);
      if (count && count > 0) {
        return json({
          error: 'Този преподавател още води ' + count + ' ученици. ' +
                 'Прехвърлете ги на друг преподавател и опитайте пак.',
        }, 400, origin);
      }
    }

    // attempts.user_id and profiles.id both cascade from auth.users.
    const { error: delErr } = await admin.auth.admin.deleteUser(userId);
    if (delErr) return json({ error: delErr.message }, 400, origin);

    return json({ ok: true }, 200, origin);
  }

  return json({ error: 'Неподдържан метод.' }, 405, origin);
});
