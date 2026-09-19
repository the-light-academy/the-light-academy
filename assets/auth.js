/* =====================================================================
   The Light Academy — shared auth + data helpers
   ---------------------------------------------------------------------
   The first shared script in this repository. Everything else here is
   inlined per page, but auth code must exist exactly once: a bug in one
   of seventeen copies would be a security bug.

   Load order on any page that uses this:

     <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
     <script src="assets/supabase-config.js"></script>
     <script src="assets/auth.js"></script>

   What this file is and is not:
   - It is the single place that talks to Supabase.
   - It is NOT what keeps students out of each other's results. That is
     Row Level Security, in the database. Every guard here is a
     convenience so people land on the right page -- a determined visitor
     can skip any of it, and the database will still refuse them.
   ===================================================================== */

(function (global) {
  'use strict';

  var cfg = global.TLA_SUPABASE || {};
  var configured =
    cfg.url && cfg.anonKey &&
    cfg.url.indexOf('PASTE_') === -1 &&
    cfg.anonKey.indexOf('PASTE_') === -1;

  var client = null;
  if (configured && global.supabase && global.supabase.createClient) {
    client = global.supabase.createClient(cfg.url, cfg.anonKey);
  }

  /* Shown instead of a silent blank page when the keys have not been
     filled in yet, or the CDN script failed to load. */
  function notConfiguredMessage() {
    return configured
      ? 'Няма връзка с базата данни. Проверете дали Supabase скриптът се е заредил.'
      : 'Порталът още не е свързан с база данни. Попълнете assets/supabase-config.js.';
  }

  /* ---- преглед на лист от преподавател -----------------------------
     „Отвори“ в таблото праща ?preview=1. Листът се показва точно както го
     вижда ученикът — същите задачи, същият ред — но без бутон за предаване
     и без да пише в базата.

     Стои тук, а не в осемнайсетте листа, защото всички минават през този
     файл. Така и следващият нов лист го получава, без да се пипа.

     Само за преподавател: ученик с ?preview=1 в адреса вижда обикновения
     лист. Иначе едно поставено от някого в чата URL-че би му дало начин да
     реши домашното, без да го предаде. */
  var previewOn = false;

  /* Бутоните за предаване из листовете. Изброени, а не отгатнати по клас,
     защото всеки лист си има собствен стил и няма общ клас. */
  var SUBMIT_IDS = [
    'checkBtn',        /* домашните листове */
    'submitBtn',       /* входно ниво 2 и 6 */
    'finish-btn',      /* входният тест отвътре */
    'hwSubmit',        /* общият рендер homework.html */
    'p1-finish-btn',   /* матурите — първа част */
    'p2-finish-btn'    /* матурите — втора част */
  ];

  var previewAsked = /[?&]preview=1(&|$)/.test(global.location.search);

  /* Спирачката се вдига ВЕДНАГА, щом адресът иска преглед, и пада едва ако
     се окаже, че гледа ученик. Така посоката на грешката е безобидната: в
     най-лошия случай за част от секундата не се записва нещо, вместо
     преподавател да остави опит на свое име в чужд профил. */
  previewOn = previewAsked;

  function enterPreviewIfAsked(profile) {
    if (!previewAsked) return;
    if (!profile || profile.role !== 'teacher') { previewOn = false; return; }
    previewOn = true;

    var doc = global.document;
    if (doc.documentElement.getAttribute('data-tla-preview')) return;   /* вече е включен */
    doc.documentElement.setAttribute('data-tla-preview', '1');

    var css = doc.createElement('style');
    css.textContent =
      '[data-tla-preview] #' + SUBMIT_IDS.join(',[data-tla-preview] #') + '{display:none !important;}' +
      '.tla-prev{position:sticky;top:0;z-index:9999;display:flex;gap:10px;' +
        'align-items:center;justify-content:center;flex-wrap:wrap;' +
        'padding:10px 16px;background:#16233F;color:#fff;' +
        'font:700 14px/1.45 Nunito,system-ui,sans-serif;text-align:center;}' +
      '.tla-prev b{color:#FFD98A;}' +
      '.tla-prev a{color:#fff;text-decoration:underline;white-space:nowrap;}' +
      /* Зеленото е рамка и лек фон, а не запълване: надписът вътре си остава
         както е написан в листа и се чете със същия контраст. */
      /* Отстъпът вдясно е запазена лента за надписа „ВЕРЕН“. Без него
         дълъг отговор минава под него — „правоъгълен и равнобедрен“ го
         прави на 430px. По-добре текстът да се пренесе, отколкото да се
         застъпят. */
      '[data-tla-preview] .tla-key{border:2px solid #16603A !important;' +
        'background:#E9F7EF !important;box-shadow:none !important;position:relative;' +
        'padding-right:72px !important;}' +
      '[data-tla-preview] .tla-key::after{content:"верен";position:absolute;' +
        'top:50%;right:12px;transform:translateY(-50%);' +
        'font:800 11px/1 Nunito,system-ui,sans-serif;letter-spacing:.06em;' +
        'text-transform:uppercase;color:#16603A;pointer-events:none;}' +
      '[data-tla-preview] .tla-keytag{display:inline-block;margin-left:10px;' +
        'padding:3px 10px;border-radius:999px;background:#E9F7EF;color:#16603A;' +
        'font:800 12px/1.4 Nunito,system-ui,sans-serif;white-space:nowrap;}';
    doc.head.appendChild(css);

    function banner() {
      if (doc.querySelector('.tla-prev')) return;
      var bar = doc.createElement('div');
      bar.className = 'tla-prev';
      bar.innerHTML =
        '<span><b>Преглед.</b> Това е листът, както го вижда ученикът. ' +
        'Няма бутон за предаване и нищо не се записва.</span>' +
        '<a href="teacher.html">Обратно към таблото</a>';
      doc.body.insertBefore(bar, doc.body.firstChild);
    }
    if (doc.body) banner();
    else doc.addEventListener('DOMContentLoaded', banner);

    /* Листът рисува задачите си след requireAuth(), тоест бутонът може да
       се появи след този момент. Наблюдаваме го и го махаме, ако се върне. */
    function hideSubmits() {
      for (var i = 0; i < SUBMIT_IDS.length; i++) {
        var el = doc.getElementById(SUBMIT_IDS[i]);
        if (el) el.style.display = 'none';
      }
    }
    hideSubmits();
    markAnswers();
    if (global.MutationObserver) {
      new global.MutationObserver(function () { hideSubmits(); markAnswers(); })
        .observe(doc.documentElement, { childList: true, subtree: true });
    }
  }

  /* ---- верният отговор, в зелено --------------------------------------
     За да се провери един лист, трябва да се види ключът, а не да се решава
     наум. В преглед верният отговор се огражда в зелено, а при задачите с
     писан отговор той се изписва до полето.

     Ключът се чете от самия лист. auth.js е обикновен <script>, значи стои
     в същия глобален обхват като скрипта на листа — затова `QUESTIONS` и
     `part1Steps` се виждат по име, макар да са `const` и да ги няма в
     window. Оттам и двата вида листове се покриват, без да се пипа нито
     един от осемнайсетте. */
  function answerKey() {
    /* домашните листове и входните нива */
    try { if (typeof QUESTIONS !== 'undefined' && QUESTIONS.length) return QUESTIONS; }
    catch (e) {}
    return null;
  }

  function maturaKey() {
    /* матурите показват по една задача; трябва и коя е тя в момента */
    try {
      if (typeof part1Steps !== 'undefined' && typeof p1Index !== 'undefined') {
        return { steps: part1Steps, at: p1Index };
      }
    } catch (e) {}
    return null;
  }

  function markAnswers() {
    var doc = global.document;

    var qs = answerKey();
    if (qs) {
      for (var i = 0; i < qs.length; i++) {
        var q = qs[i];

        /* избор от няколко: огражда се верният бутон */
        if (typeof q.correct === 'number') {
          var btn = doc.querySelector('.choice[data-q="' + i + '"][data-c="' + q.correct + '"]');
          if (btn && !btn.classList.contains('tla-key')) btn.classList.add('tla-key');
        }

        /* писан отговор: изписва се до полето, веднъж */
        var fields = q.fields || (q.answer != null ? [{ answer: q.answer }] : null);
        if (!fields) continue;
        for (var f = 0; f < fields.length; f++) {
          var want = fields[f].answer;
          if (want == null || want === '') continue;
          var inp = q.fields
            ? doc.querySelector('input[data-q="' + i + '"][data-f="' + f + '"]')
            : doc.querySelector('input[data-q="' + i + '"]');
          if (!inp || inp.getAttribute('data-tla-key')) continue;
          inp.setAttribute('data-tla-key', '1');
          var tag = doc.createElement('span');
          tag.className = 'tla-keytag';
          tag.textContent = 'верен отговор: ' + want;
          inp.parentNode.insertBefore(tag, inp.nextSibling);
        }
      }
    }

    var m = maturaKey();
    if (m && m.steps[m.at] && typeof m.steps[m.at].correct === 'number') {
      var opts = doc.querySelectorAll('.options-list .option');
      for (var k = 0; k < opts.length; k++) {
        opts[k].classList.toggle('tla-key', k === m.steps[m.at].correct);
      }
    }
  }

  /* Листовете пазят входа по два начина: повечето с requireAuth(), а трите
     матури с getSession() направо. Затова прегледът не виси на нито един от
     тях — включва се сам при зареждане. */
  function bootPreview() {
    if (!previewAsked) return;
    TLA.getProfile().then(enterPreviewIfAsked).catch(function () { previewOn = false; });
  }

  var TLA = {
    client: client,
    isConfigured: function () { return !!client; },
    notConfiguredMessage: notConfiguredMessage,

    /* ---- session -------------------------------------------------- */

    getSession: async function () {
      if (!client) return null;
      var res = await client.auth.getSession();
      return (res && res.data && res.data.session) || null;
    },

    signIn: async function (email, password) {
      if (!client) throw new Error(notConfiguredMessage());
      var res = await client.auth.signInWithPassword({
        email: String(email || '').trim(),
        password: String(password || '')
      });
      if (res.error) throw res.error;
      return res.data;
    },

    signOut: async function () {
      if (client) { try { await client.auth.signOut(); } catch (e) {} }
      global.location.href = 'login.html';
    },

    /* ---- profile -------------------------------------------------- */

    /* Returns { id, full_name, role, active, grade_at_entry,
       entry_school_year } or null. RLS means a student can only ever read
       their own row here. */
    getProfile: async function () {
      if (!client) return null;
      var session = await TLA.getSession();
      if (!session) return null;
      var res = await client
        .from('profiles')
        .select('id, full_name, role, active, is_admin, grade_at_entry, entry_school_year')
        .eq('id', session.user.id)
        .maybeSingle();
      if (res.error) return null;
      return res.data;
    },

    /* ---- page guards ---------------------------------------------- */

    /* Send anyone without a session to the login page, remembering where
       they were headed so login can bounce them back. A deactivated
       account is signed out immediately -- their rows stay, but
       is_teacher() and every teacher policy already ignore them. */
    requireAuth: async function (opts) {
      opts = opts || {};
      var session = await TLA.getSession();
      if (!session) {
        var back = global.location.pathname.split('/').pop() + global.location.search;
        global.location.replace('login.html?next=' + encodeURIComponent(back));
        return null;
      }
      var profile = await TLA.getProfile();
      if (profile && profile.active === false) {
        await TLA.signOut();
        return null;
      }
      if (opts.role && (!profile || profile.role !== opts.role)) {
        global.location.replace(profile && profile.role === 'teacher'
          ? 'teacher.html' : 'portal.html');
        return null;
      }
      /* Преподавател, отворил лист с ?preview=1, го вижда както го вижда
         ученикът, но без бутон за предаване и без да се записва нищо. */
      enterPreviewIfAsked(profile);
      return { session: session, profile: profile };
    },

    /* Вярно е само когато преподавател гледа лист с ?preview=1. Листовете
       не го викат — auth.js се оправя сам — но е тук, ако някой лист
       поиска да покаже нещо различно в преглед. */
    isPreview: function () { return previewOn; },

    /* ---- school year and grade -------------------------------------
       The same arithmetic as school_year_of() / current_grade() in
       supabase/schema-v2.sql, repeated here only so a page can print a
       class without a round trip. The database is the one that decides
       what a student may actually see; this is for labels. */

    /* The school year turns over on 1 September. 2026 means 2026/27. */
    schoolYearOf: function (d) {
      d = d || new Date();
      return d.getMonth() >= 8 ? d.getFullYear() : d.getFullYear() - 1;
    },

    currentSchoolYear: function () { return TLA.schoolYearOf(new Date()); },

    /* A profile stores the class it was entered in and the year that was;
       the current class follows from those two. null when no class is set. */
    currentGrade: function (profile) {
      if (!profile) return null;
      var g = profile.grade_at_entry, y = profile.entry_school_year;
      if (g === null || g === undefined || y === null || y === undefined) return null;
      return g + (TLA.currentSchoolYear() - y);
    },

    /* -1 and 0 are preschool and must never reach the screen as numbers. */
    gradeLabel: function (g) {
      if (g === null || g === undefined || g === '') return 'Без клас';
      g = Number(g);
      if (g === -1) return 'Предучилищна (5 г.)';
      if (g === 0) return 'Предучилищна (6 г.)';
      if (g >= 1 && g <= 12) return g + '. клас';
      return 'Завършил';
    },

    /* Every class, in the order they belong in a dropdown. */
    GRADES: [-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],

    /* Which classes an assignment is for, as text. null means all. */
    gradesLabel: function (grades) {
      if (!grades || !grades.length) return 'всички класове';
      return grades.slice().sort(function (a, b) { return a - b; })
        .map(TLA.gradeLabel).join(', ');
    },

    /* ---- data ----------------------------------------------------- */

    listAssignments: async function () {
      if (!client) return [];
      var res = await client
        .from('assignments')
        .select('id, slug, title, kind, url, max_points, published, due_at, sort_order, week, subject_id, grades')
        .order('sort_order', { ascending: true })
        .order('title', { ascending: true });
      if (res.error) throw res.error;
      return res.data || [];
    },

    listSubjects: async function () {
      if (!client) return [];
      var res = await client
        .from('subjects')
        .select('id, slug, name, active, sort_order')
        .order('sort_order', { ascending: true })
        .order('name', { ascending: true });
      if (res.error) throw res.error;
      return res.data || [];
    },

    getAssignmentBySlug: async function (slug) {
      if (!client) return null;
      var res = await client
        .from('assignments')
        .select('id, slug, title, kind, url, max_points, published, content')
        .eq('slug', slug)
        .maybeSingle();
      if (res.error) throw res.error;
      return res.data;
    },

    /* Every attempt this student has filed, newest first. */
    myAttempts: async function () {
      if (!client) return [];
      var session = await TLA.getSession();
      if (!session) return [];
      var res = await client
        .from('attempts')
        .select('id, assignment_id, status, auto_score, auto_max, manual_score, manual_max, total_score, submitted_at, ai_graded_at, teacher_note')
        .eq('user_id', session.user.id)
        .order('submitted_at', { ascending: false });
      if (res.error) throw res.error;
      return res.data || [];
    },

    /* Called by matura2026.html and homework.html when a student finishes.
       `records` / `part2` are stored exactly as the exam page builds them,
       so nothing about the existing result format changes.

       user_id is set from the session rather than passed in -- and the
       insert policy checks it again server-side, so a forged id is
       rejected by the database, not by this line. */
    saveAttempt: async function (slug, payload) {
      /* Скритият бутон е подредбата; това е същинската спирачка. Дори лист,
         който извика записването по друг път — часовник, който предава сам,
         стар код — в преглед не оставя нищо в базата. */
      if (previewOn) return { preview: true };
      if (!client) throw new Error(notConfiguredMessage());
      var session = await TLA.getSession();
      if (!session) throw new Error('Няма активна сесия.');

      var assignment = await TLA.getAssignmentBySlug(slug);
      if (!assignment) throw new Error('Липсва задание "' + slug + '" в базата.');

      var row = {
        user_id: session.user.id,
        assignment_id: assignment.id,
        status: payload.status || 'submitted',
        auto_score: payload.autoScore != null ? payload.autoScore : null,
        auto_max: payload.autoMax != null ? payload.autoMax : null,
        manual_max: payload.manualMax != null ? payload.manualMax : null,
        records: payload.records || null,
        part2: payload.part2 || null,
        started_at: payload.startedAt || null
      };

      var res = await client.from('attempts').insert(row).select('id').maybeSingle();
      if (res.error) throw res.error;
      return res.data;
    },

    /* ---- who teaches whom ------------------------------------------
       The database is what actually decides any of this -- see the
       policies in supabase/schema-v3.sql. These are here so a page can
       show the right controls, not so it can enforce anything. */

    isAdmin: function (profile) {
      return !!(profile && profile.is_admin === true && profile.active !== false);
    },

    /* Every (teacher, student, subject) row the caller is allowed to see.
       For the admin that is all of them; for a teacher, their own. */
    listTeaching: async function () {
      if (!client) return [];
      var res = await client
        .from('teaching')
        .select('id, teacher_id, student_id, subject_id, active')
        .eq('active', true);
      if (res.error) throw res.error;
      return res.data || [];
    },

    /* Which sheets the signed-in teacher has given to their students.
       A row with hidden = true was given and then taken back. */
    listReleases: async function () {
      if (!client) return [];
      var res = await client
        .from('assignment_releases')
        .select('id, assignment_id, teacher_id, hidden, released_at');
      if (res.error) throw res.error;
      return res.data || [];
    },

    /* Give a sheet to my students, or take it back. Upsert rather than
       insert, so pressing it twice is harmless and un-hiding is the same
       call with hidden = false. */
    setRelease: async function (assignmentId, hidden) {
      if (!client) throw new Error(notConfiguredMessage());
      var session = await TLA.getSession();
      if (!session) throw new Error('Няма активна сесия.');
      var res = await client
        .from('assignment_releases')
        .upsert({
          assignment_id: assignmentId,
          teacher_id: session.user.id,
          hidden: !!hidden
        }, { onConflict: 'assignment_id,teacher_id' })
        .select('id, assignment_id, teacher_id, hidden')
        .maybeSingle();
      if (res.error) throw res.error;
      return res.data;
    },

    /* For the portal: my teachers, by name and subject. Comes from a
       SECURITY DEFINER function, so a student learns who teaches them
       without being able to read anybody's profile row. */
    myTeachers: async function () {
      if (!client) return [];
      var res = await client.rpc('my_teachers');
      if (res.error) return [];
      return res.data || [];
    },

    /* ---- small shared helpers ------------------------------------- */

    escapeHtml: function (value) {
      return String(value == null ? '' : value)
        .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
    },

    /* Текстът на задача може да съдържа малко HTML — дробите се пишат
       като <span class="frac"><span class="num">5</span>… Ако мине през
       escapeHtml, учителят вижда самите тагове; ако мине суров, отваря се
       дупка: записът идва от attempts, а attempts ги пише браузърът на
       ученика, тоест чужда ръка може да сложи там каквото си поиска, а
       страницата, която го чете, е админската.

       Затова: първо се екранира ВСИЧКО, после се връщат обратно само
       <span> с клас от списъка тук и затварящите им тагове. Нов таг или
       атрибут не може да се появи — шаблонът не го допуска — а броячът
       пази затварящите тагове да не излязат извън своите отварящи. */
    richText: function (value) {
      var s = TLA.escapeHtml(value), depth = 0;
      s = s.replace(/&lt;(\/?)span(?: class=&quot;(frac|num|den|mixed)&quot;)?&gt;/g,
        function (whole, slash, cls) {
          if (slash) { if (!depth) return ''; depth--; return '</span>'; }
          if (!cls) return whole;
          depth++;
          return '<span class="' + cls + '">';
        });
      while (depth-- > 0) s += '</span>';
      return s;
    },

    formatDate: function (iso) {
      if (!iso) return '—';
      try {
        return new Date(iso).toLocaleString('bg-BG', {
          day: '2-digit', month: '2-digit', year: 'numeric',
          hour: '2-digit', minute: '2-digit'
        });
      } catch (e) { return iso; }
    },

    percent: function (score, max) {
      if (score == null || !max) return null;
      return Math.round((Number(score) / Number(max)) * 100);
    }
  };

  global.TLA = TLA;
  bootPreview();
})(window);
