/* =====================================================================
   grade-free-text — pre-marks the free-text answers with Claude
   ---------------------------------------------------------------------
   Part 2 of the matura, and any homework question without an exact
   answer, can only be judged by reading what the student wrote. Until
   now those simply said "чака оценка" until the teacher got to them.
   This function gives them a provisional mark straight away, based on
   how much of the student's answer matches the reference solution that
   is already stored with the attempt.

   It is a *pre*-mark, never the last word:
     - the attempt stays status='submitted', so the teacher's list still
       shows it as waiting;
     - `ai_graded_at` records that the manual_score on the row came from
       the model, not from a person;
     - the moment the teacher saves their own marks, status becomes
       'graded' and their numbers replace these.

   Two secrets, neither of which ever reaches a browser:
     SUPABASE_SERVICE_ROLE_KEY  injected by Supabase at deploy time
     ANTHROPIC_API_KEY          you set once, by hand:
         supabase secrets set ANTHROPIC_API_KEY=sk-ant-...

   Deploy:
     supabase functions deploy grade-free-text

   Without the API key the function answers 501 and the exam page simply
   leaves the answers unmarked -- exactly how the site behaved before.
   ===================================================================== */

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const ALLOWED_ORIGINS = [
  'https://the-light-academy.github.io',
  'http://127.0.0.1:9301',
  'http://localhost:9301',
];

const MODEL = 'claude-opus-5';

function corsHeaders(origin: string | null) {
  const allow = origin && ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0];
  return {
    'Access-Control-Allow-Origin': allow,
    'Access-Control-Allow-Headers': 'authorization, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Vary': 'Origin',
  };
}

function json(body: unknown, status: number, origin: string | null) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders(origin), 'Content-Type': 'application/json' },
  });
}

type Part2 = Record<string, unknown>;

/* Sub-questions belong to a task with a shared points budget (the matura's
   Part 2 is three tasks worth 12 / 11 / 12). Homework questions carry their
   own `points` and stand alone. Both shapes end up as one group here. */
function group(part2: Part2[]) {
  const groups: { task: string; budget: number | null; items: { idx: number; r: Part2 }[] }[] = [];
  const byTask: Record<string, number> = {};

  part2.forEach((r, idx) => {
    const task = String(r.taskId != null ? r.taskId : (r.id != null ? r.id : idx));
    if (byTask[task] == null) {
      byTask[task] = groups.length;
      const budget = r.taskPoints != null ? Number(r.taskPoints)
                   : r.points != null ? Number(r.points)
                   : null;
      groups.push({ task, budget: Number.isFinite(budget as number) ? budget : null, items: [] });
    }
    groups[byTask[task]].items.push({ idx, r });
  });

  return groups;
}

const SYSTEM = [
  'Ти си опитен учител по математика, който проверява отговорите с',
  'свободен текст от изпитна работа на ученик от 7. клас в България.',
  '',
  'За всяка подточка получаваш: условието, отговора на ученика и ключа с',
  'верния отговор (примерно решение). Дай точки според това КОЛКО ОТ',
  'ключа се съдържа в отговора на ученика:',
  '  • пълно съвпадение по същество (същият резултат и същият ход на',
  '    разсъждение) — целият брой точки за подточката;',
  '  • верен краен резултат без обосновка, или вярна обосновка с',
  '    аритметична грешка накрая — частични точки;',
  '  • само отделни верни стъпки — малка част от точките;',
  '  • празен отговор, "не знам", преписано условие или изцяло грешно —',
  '    0 точки.',
  '',
  'Гледай смисъла, не буквите: друга формулировка, друг ред на действията',
  'или друг верен път до същия отговор се признават напълно. Не',
  'наказвай правописа и записа (0,5 и 0.5 са едно и също).',
  '',
  'Всяка задача има общ бюджет точки. Сборът на точките, които даваш на',
  'подточките на една задача, НЕ може да го надхвърля. Точките са цели',
  'или на половинки.',
  '',
  'За всяка подточка напиши и кратък коментар на български (едно',
  'изречение) — какво е признато и какво липсва. Пиши на ученика, на',
  '"ти", спокойно и по същество.',
].join('\n');

const SCHEMA = {
  type: 'object',
  additionalProperties: false,
  properties: {
    marks: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        properties: {
          id: { type: 'string', description: 'Идентификаторът на подточката, точно както е подаден.' },
          points: { type: 'number', description: 'Присъдените точки.' },
          comment: { type: 'string', description: 'Кратко обяснение на български.' },
        },
        required: ['id', 'points', 'comment'],
      },
    },
  },
  required: ['marks'],
};

Deno.serve(async (req: Request) => {
  const origin = req.headers.get('origin');

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders(origin) });
  }
  if (req.method !== 'POST') {
    return json({ error: 'Неподдържан метод.' }, 405, origin);
  }

  const apiKey = Deno.env.get('ANTHROPIC_API_KEY');
  if (!apiKey) {
    return json({ error: 'AI оценяването не е настроено (липсва ANTHROPIC_API_KEY).' }, 501, origin);
  }

  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { autoRefreshToken: false, persistSession: false } },
  );

  // ---- 1. who is calling? -------------------------------------------
  const token = (req.headers.get('Authorization') || '').replace(/^Bearer\s+/i, '');
  if (!token) return json({ error: 'Липсва токен.' }, 401, origin);

  const { data: userData, error: userErr } = await admin.auth.getUser(token);
  if (userErr || !userData?.user) return json({ error: 'Невалидна сесия.' }, 401, origin);
  const callerId = userData.user.id;

  let body: Record<string, unknown> = {};
  try { body = await req.json(); } catch { /* handled below */ }
  const attemptId = String(body.attempt_id || '');
  if (!attemptId) return json({ error: 'Липсва attempt_id.' }, 400, origin);

  // ---- 2. may they ask for this attempt to be graded? ---------------
  const { data: attempt, error: attErr } = await admin
    .from('attempts')
    .select('id, user_id, status, part2, manual_max, ai_graded_at')
    .eq('id', attemptId)
    .maybeSingle();

  if (attErr) return json({ error: attErr.message }, 500, origin);
  if (!attempt) return json({ error: 'Няма такъв резултат.' }, 404, origin);

  if (attempt.user_id !== callerId) {
    const { data: profile } = await admin
      .from('profiles').select('role, active').eq('id', callerId).maybeSingle();
    if (!profile || profile.role !== 'teacher' || profile.active !== true) {
      return json({ error: 'Нямате достъп до този резултат.' }, 403, origin);
    }
  }

  // ---- 3. nothing to do? --------------------------------------------
  const part2: Part2[] = Array.isArray(attempt.part2) ? attempt.part2 as Part2[] : [];
  if (!part2.length) return json({ ok: true, graded: 0, reason: 'no-free-text' }, 200, origin);

  // A teacher's marking always wins, and one attempt is graded once --
  // both so a mark never silently changes under the student, and so a
  // page reload cannot run up a bill.
  if (attempt.status === 'graded') {
    return json({ ok: true, graded: 0, reason: 'already-graded' }, 200, origin);
  }
  if (attempt.ai_graded_at) {
    return json({ ok: true, graded: 0, reason: 'already-ai-graded' }, 200, origin);
  }

  const groups = group(part2);

  // ---- 4. ask Claude -------------------------------------------------
  const tasks = groups.map((g) => ({
    task: g.task,
    budget_points: g.budget,
    subquestions: g.items.map((it) => ({
      id: String(it.r.id != null ? it.r.id : it.idx),
      question: String(it.r.prompt || ''),
      student_answer: String(it.r.studentAnswer || '').trim() || '(няма отговор)',
      answer_key: String(it.r.solution || '').trim() || '(няма подаден ключ)',
    })),
  }));

  const userMessage = [
    'Оцени отговорите по-долу. Върни по един запис за всяка подточка,',
    'с точно същото "id".',
    '',
    'Ако за някоя подточка липсва ключ с верен отговор, прецени сам дали',
    'написаното е математически вярно.',
    '',
    '```json',
    JSON.stringify({ tasks }, null, 2),
    '```',
  ].join('\n');

  let apiRes: Response;
  try {
    apiRes = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: MODEL,
        max_tokens: 8000,
        thinking: { type: 'adaptive' },
        output_config: {
          effort: 'medium',
          format: { type: 'json_schema', schema: SCHEMA },
        },
        system: SYSTEM,
        messages: [{ role: 'user', content: userMessage }],
      }),
    });
  } catch (e) {
    return json({ error: 'Няма връзка с Claude: ' + String(e) }, 502, origin);
  }

  if (!apiRes.ok) {
    const text = await apiRes.text();
    return json({ error: 'Claude отговори с ' + apiRes.status + ': ' + text.slice(0, 400) },
                502, origin);
  }

  const payload = await apiRes.json();

  // A refusal or a cut-off response is not a zero -- leave the answers for
  // the teacher rather than writing marks nobody stands behind.
  if (payload.stop_reason === 'refusal') {
    return json({ error: 'Моделът отказа да оцени тези отговори.' }, 502, origin);
  }
  if (payload.stop_reason === 'max_tokens') {
    return json({ error: 'Отговорът на модела беше отрязан.' }, 502, origin);
  }

  const text = (payload.content || [])
    .filter((b: { type: string }) => b.type === 'text')
    .map((b: { text: string }) => b.text)
    .join('');

  let parsed: { marks?: { id?: string; points?: number; comment?: string }[] };
  try {
    parsed = JSON.parse(text);
  } catch {
    return json({ error: 'Отговорът на модела не беше валиден JSON.' }, 502, origin);
  }

  const byId: Record<string, { points: number; comment: string }> = {};
  (parsed.marks || []).forEach((m) => {
    if (!m || m.id == null) return;
    const pts = Number(m.points);
    byId[String(m.id)] = {
      points: Number.isFinite(pts) ? pts : 0,
      comment: String(m.comment || ''),
    };
  });

  // ---- 5. write the marks back --------------------------------------
  // Every number is clamped here rather than trusted: no sub-question may
  // go negative or exceed its task's budget, and no task may exceed it in
  // total. The model is a marker, not the authority on the point scale.
  const out = part2.map((r) => ({ ...r }));
  let total = 0, max = 0, marked = 0;

  groups.forEach((g) => {
    const budget = g.budget;
    let used = 0;
    if (budget != null) max += budget;

    g.items.forEach((it) => {
      const key = String(it.r.id != null ? it.r.id : it.idx);
      const m = byId[key];
      if (!m) return;

      let pts = Math.max(0, Math.round(m.points * 2) / 2);
      if (budget != null) pts = Math.min(pts, Math.max(0, budget - used));
      used += pts;

      out[it.idx].mark = pts;
      out[it.idx].markSource = 'ai';
      out[it.idx].aiComment = m.comment;
      marked++;
    });

    total += used;
  });

  if (!marked) return json({ error: 'Моделът не върна оценки.' }, 502, origin);

  const manualMax = attempt.manual_max != null ? Number(attempt.manual_max) : (max || null);

  const { error: updErr } = await admin.from('attempts').update({
    part2: out,
    manual_score: total,
    manual_max: manualMax,
    ai_graded_at: new Date().toISOString(),
  }).eq('id', attemptId);

  if (updErr) return json({ error: updErr.message }, 500, origin);

  return json({ ok: true, graded: marked, score: total, max: manualMax }, 200, origin);
});
