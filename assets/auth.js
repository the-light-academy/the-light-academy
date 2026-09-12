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
        .select('id, full_name, role, active, grade_at_entry, entry_school_year')
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
      return { session: session, profile: profile };
    },

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

    /* ---- small shared helpers ------------------------------------- */

    escapeHtml: function (value) {
      return String(value == null ? '' : value)
        .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
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
})(window);
