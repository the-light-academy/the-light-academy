/* =====================================================================
   The Light Academy — готовите пробни теми по състезания (4. клас,
   състезателна математика).
   ---------------------------------------------------------------------
   ЗАЩО СТОИ ТУК, А НЕ В БАЗАТА

   Темите са страници в самия сайт (probni_testove/*.html). Те вече
   съществуват — отварят се, мерят време и се проверяват сами, дори
   базата да е празна. Досега порталът ги показваше само ако същият
   тест е въведен в assignments, пуснат в библиотеката И даден на
   ученика. Дотогава под състезанието пишеше „Още няма пробна тема“,
   въпреки че темата си стои на сървъра.

   Затова този списък: раздел „Пробни изпити“ показва всяка готова тема
   под състезанието, за което върши работа — без да чака нищо.

   КАК СЕ ВРЪЗВА С БАЗАТА

   `slug` е същият, който стои в scripts/probni/test*.js и в
   supabase/assignments.sql. Ако същата тема дойде и от базата (пусната
   и дадена на ученика), побеждава редът от базата: той носи опитите,
   процента и „Направи отново“. Тукашната се показва само когато от
   базата няма нищо — иначе щяха да се виждат две еднакви карти.

   `rounds` казва под кои състезания да излезе темата. Темите от
   общинския кръг стоят и под областния: кръговете са с еднакъв формат и
   организаторът дава същия тип задачи — същото пише и календарът.

   КОГАТО ДОБАВИШ НОВА ТЕМА

   Сглоби я с scripts/build_probni.py и допиши един ред тук. Ако искаш
   резултатът ѝ да се записва в профила, добави я и в
   supabase/assignments.sql (или в supabase/probni-v-razdel.sql) и я
   пусни с supabase/probni-otvoreni.sql.
   ===================================================================== */
(function (global) {
  'use strict';

  var TLA = global.TLA = global.TLA || {};

  var LIST = [
    { slug: 'sal-2025-4',
      title: 'Пробен „Иван Салабашев“ — 2025',
      href: 'probni_testove/probna_salabashev_2025_4klas.html',
      year: 2025, minutes: 120, maxPoints: 60,
      rounds: [{ track: 'salabashev', section: 'minali' }] },

    { slug: 'sal-2024-4',
      title: 'Пробен „Иван Салабашев“ — 2024',
      href: 'probni_testove/probna_salabashev_2024_4klas.html',
      year: 2024, minutes: 120, maxPoints: 60,
      rounds: [{ track: 'salabashev', section: 'minali' }] },

    { slug: 'probna-obshtinski-2020-4',
      title: 'Пробен общински кръг — 2020',
      href: 'probni_testove/probna_obshtinski_2020_4klas.html',
      year: 2020, minutes: 240, maxPoints: 21,
      rounds: [
        { track: 'olimpiada', section: 'obshtinski' },
        { track: 'olimpiada', section: 'oblasten', note: 'тема от общинския кръг — върши работа и тук' }
      ] },

    { slug: 'probna-obshtinski-2018-4',
      title: 'Пробен общински кръг — 2018',
      href: 'probni_testove/probna_obshtinski_2018_4klas.html',
      year: 2018, minutes: 240, maxPoints: 21,
      rounds: [
        { track: 'olimpiada', section: 'obshtinski' },
        { track: 'olimpiada', section: 'oblasten', note: 'тема от общинския кръг — върши работа и тук' }
      ] }
  ];

  /* Темите за едно състезание, най-новата година отгоре. `c` е ред от
     календара (assets/sastezaniya.js). Състезание без раздел приема
     всички теми на своя track. */
  function forCompetition(c) {
    if (!c || !c.track) return [];
    var out = [];
    LIST.forEach(function (t) {
      t.rounds.forEach(function (r) {
        if (r.track !== c.track) return;
        if (c.section && r.section && r.section !== c.section) return;
        if (out.some(function (x) { return x.slug === t.slug; })) return;
        out.push({
          slug: t.slug, title: t.title, href: t.href, year: t.year,
          minutes: t.minutes, maxPoints: t.maxPoints, note: r.note || ''
        });
      });
    });
    return out.sort(function (a, b) { return b.year - a.year; });
  }

  TLA.Probni = {
    grade: 4,
    subject: 'sastezatelna-matematika',
    list: LIST,
    forCompetition: forCompetition
  };
})(window);
