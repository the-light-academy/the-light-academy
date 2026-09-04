/* =====================================================================
   The Light Academy — Supabase connection settings
   ---------------------------------------------------------------------
   The ONLY place these two values live. Change them here and every page
   picks it up.

   Find them in your Supabase dashboard under
       Project Settings -> API

   Both values are meant to be public. The anon key grants nothing on its
   own: what any request may actually read or write is decided by the Row
   Level Security policies in supabase/schema.sql, inside the database.

   NEVER put the `service_role` key in this file, or anywhere else in this
   repository. It bypasses every policy. It belongs only inside the
   Edge Function, where Supabase injects it automatically.
   ===================================================================== */

window.TLA_SUPABASE = {
  url: 'https://zlimdhrdddlfdgskjidg.supabase.co',

  // Either key format works here:
  //   sb_publishable_...  (current name)
  //   eyJ...              (the older "anon / public" key, still valid)
  // Both are safe in the browser. The `sb_secret_` / `service_role` key
  // is NOT -- it bypasses every policy and must never appear in this repo.
  anonKey: 'PASTE_YOUR_PUBLISHABLE_KEY_HERE'
};
