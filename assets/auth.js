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

    /* Returns { id, full_name, role, active } or null.
       RLS means a student can only ever read their own row here. */
    getProfile: async function () {
      if (!client) return null;
      var session = await TLA.getSession();
      if (!session) return null;
      var res = await client
        .from('profiles')
        .select('id, full_name, role, active')
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

    /* ---- data ----------------------------------------------------- */

    listAssignments: async function () {
      if (!client) return [];
      var res = await client
        .from('assignments')
        .select('id, slug, title, kind, url, max_points, published, due_at, sort_order')
        .order('sort_order', { ascending: true })
        .order('title', { ascending: true });
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
        .select('id, assignment_id, status, auto_score, auto_max, manual_score, manual_max, total_score, submitted_at, ai_graded_at')
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

    /* Ask the grade-free-text Edge Function to pre-mark the free-text
       answers of an attempt that was just filed.

       Everything about this is best effort. The function may not be
       deployed, may have no ANTHROPIC_API_KEY, or may be having a bad
       day; in every one of those cases the answers simply stay unmarked
       and the teacher marks them by hand, which is how the site worked
       before. So this never throws -- it returns a small report and the
       caller decides what, if anything, to say on screen.

       The function is also the only thing that can write these marks:
       it checks the caller's session server-side and clamps every number
       to the task's points budget. */
    requestAiGrading: async function (attemptId) {
      if (!client || !attemptId) return { ok: false, reason: 'not-configured' };
      var session = await TLA.getSession();
      if (!session) return { ok: false, reason: 'no-session' };

      try {
        var res = await fetch(cfg.url + '/functions/v1/grade-free-text', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + session.access_token,
            'apikey': cfg.anonKey
          },
          body: JSON.stringify({ attempt_id: attemptId })
        });
        var data = null;
        try { data = await res.json(); } catch (e) {}
        if (!res.ok) {
          return { ok: false, reason: 'error', status: res.status,
                   message: (data && data.error) || ('HTTP ' + res.status) };
        }
        return {
          ok: true,
          graded: (data && data.graded) || 0,
          score: data ? data.score : null,
          max: data ? data.max : null,
          reason: data ? data.reason : null
        };
      } catch (err) {
        return { ok: false, reason: 'network', message: err.message || String(err) };
      }
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
