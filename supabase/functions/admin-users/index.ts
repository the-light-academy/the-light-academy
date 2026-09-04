/* =====================================================================
   admin-users — create and delete student accounts
   ---------------------------------------------------------------------
   The only server-side code in this project, and it exists for one
   reason: creating or deleting an auth user needs the service_role key,
   which bypasses every Row Level Security policy. That key must never be
   sent to a browser, so this function holds it instead.

   Every request is checked twice before anything happens:
     1. the caller's access token must be a valid session, and
     2. that user's profile row must be role='teacher' AND active.

   Supabase injects SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY into the
   function environment at deploy time -- you do not set them by hand.

   Deploy:
     supabase login
     supabase link --project-ref <your-project-ref>
     supabase functions deploy admin-users
   ===================================================================== */

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

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

  // ---- 2. are they actually a teacher? ------------------------------
  const { data: profile, error: profErr } = await admin
    .from('profiles')
    .select('role, active')
    .eq('id', userData.user.id)
    .maybeSingle();

  if (profErr) return json({ error: profErr.message }, 500, origin);
  if (!profile || profile.role !== 'teacher' || profile.active !== true) {
    return json({ error: 'Само преподавател може да управлява профили.' }, 403, origin);
  }

  let body: Record<string, unknown> = {};
  try { body = await req.json(); } catch { /* empty body is fine for some calls */ }

  // ---- create -------------------------------------------------------
  if (req.method === 'POST') {
    const email = String(body.email || '').trim().toLowerCase();
    const password = String(body.password || '');
    const fullName = String(body.full_name || '').trim();

    if (!email || !email.includes('@')) {
      return json({ error: 'Невалиден имейл.' }, 400, origin);
    }
    if (password.length < 8) {
      return json({ error: 'Паролата трябва да е поне 8 знака.' }, 400, origin);
    }

    const { data: created, error: createErr } = await admin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,                     // teacher-issued, no confirmation mail
      user_metadata: { full_name: fullName, role: 'student' },
    });

    if (createErr) {
      const msg = /already registered|already been registered/i.test(createErr.message)
        ? 'Вече има профил с този имейл.'
        : createErr.message;
      return json({ error: msg }, 400, origin);
    }

    // The on_auth_user_created trigger has already made the profile row;
    // this just makes sure the name landed even if metadata was empty.
    await admin.from('profiles')
      .update({ full_name: fullName, role: 'student', active: true })
      .eq('id', created.user!.id);

    return json({ ok: true, id: created.user!.id }, 200, origin);
  }

  // ---- delete -------------------------------------------------------
  if (req.method === 'DELETE') {
    const userId = String(body.user_id || '');
    if (!userId) return json({ error: 'Липсва user_id.' }, 400, origin);

    // Guard against a teacher deleting themselves, and against deleting
    // another teacher through this endpoint.
    if (userId === userData.user.id) {
      return json({ error: 'Не можете да изтриете собствения си профил.' }, 400, origin);
    }
    const { data: target } = await admin
      .from('profiles').select('role').eq('id', userId).maybeSingle();
    if (target?.role === 'teacher') {
      return json({ error: 'Профил на преподавател не се изтрива оттук.' }, 400, origin);
    }

    // attempts.user_id and profiles.id both cascade from auth.users.
    const { error: delErr } = await admin.auth.admin.deleteUser(userId);
    if (delErr) return json({ error: delErr.message }, 400, origin);

    return json({ ok: true }, 200, origin);
  }

  return json({ error: 'Неподдържан метод.' }, 405, origin);
});
