/* =====================================================================
   Юнитите по английски за 5. клас — проверка на каталога
   ---------------------------------------------------------------------
   assets/tracks.js държи структурата на English Plus 1: Starter unit и
   осем юнита, всеки с темите и страниците си. Преписано е от „Map of
   the book“ и затова е проверимо: учебникът е построен по строг модел
   и всяко отклонение от него значи сбъркана цифра.

   Какво се проверява, без да се вярва на написаното:

     · Юнит n заема страници 12+10(n-1) … 21+10(n-1). Всяка страница,
       спомената в юнита, трябва да е вътре в този обхват.
     · Колоните на картата са на фиксирани места в юнита:
         Vocabulary        start и start+4
         Reading           start+2
         Language focus    start+3 и start+5
         Speaking          start+6
         Writing           start+7
         Review            start+8 и start+9
       Сбъркана цифра излиза веднага оттук.
     · Допълненията отзад: Extra listening and speaking е 91+n, а
       Curriculum Extra, Culture, Project и Song вървят възходящо по
       юнити, всяко в своя блок страници.
     · Имената (id) са по формата, която базата приема, и не се
       повтарят; подразделите са едни и същи и в същия ред навсякъде.

   Пуска се така:
       /opt/node22/bin/node scripts/check_units.js
   ===================================================================== */
'use strict';
const fs = require('fs');
const path = require('path');

const KOREN = path.resolve(__dirname, '..');
let proverki = 0;
const greshki = [];
function tvurdi(uslovie, kakvo) {
  proverki++;
  if (!uslovie) greshki.push(kakvo);
}

/* tracks.js се изпълнява наистина, в празен „прозорец“ — така се чете
   точно това, което ще прочете и браузърът. */
const global_ = {};
new Function('window', fs.readFileSync(path.join(KOREN, 'assets/tracks.js'), 'utf8'))
  .call(null, global_);
const T = global_.TLA.Tracks;

const UNITS = T.forSubject('angliiski', 5);
tvurdi(UNITS.length === 9, 'юнитите не са девет, а ' + UNITS.length);

const REDNI = ['vocabulary', 'reading', 'language_focus', 'speaking', 'writing',
               'review', 'options'];
const FORMA = /^[a-z][a-z0-9_]{0,31}$/;

/* Всички страници, споменати в един текст. */
function stranici(txt) {
  return (txt.match(/\bp(\d{1,3})\b/g) || []).map(x => Number(x.slice(1)));
}

/* ── Starter unit ─────────────────────────────────────────────────── */
const st = UNITS[0];
tvurdi(st.id === 'ep1_starter', 'първият раздел не е Starter unit');
tvurdi(st.title === 'Starter unit', 'заглавието на стартовия юнит е друго');
tvurdi(st.sections.map(s => s.id).join(',') === 'vocabulary,language_focus',
       'стартовият юнит няма точно двете си части');
st.sections.forEach(s => {
  stranici(s.note).forEach(n =>
    tvurdi(n >= 4 && n <= 11, 'Starter unit: страница p' + n + ' е извън 4–11'));
});
tvurdi(stranici(st.sections[0].note).join(',') === '4,6,8,10',
       'Starter unit · Vocabulary: страниците не са 4, 6, 8, 10');
tvurdi(stranici(st.sections[1].note).join(',') === '5,7,9,11',
       'Starter unit · Language focus: страниците не са 5, 7, 9, 11');

/* ── Осемте юнита ─────────────────────────────────────────────────── */
const OCHAKVANI = {            /* колона → отместване от първата страница */
  vocabulary: [0, 4],
  reading: [2],
  language_focus: [3, 5],
  speaking: [6],
  writing: [7],
  review: [8, 9]
};
const dop = { extra: [], curriculum: [], culture: [], project: [], song: [] };

for (let n = 1; n <= 8; n++) {
  const u = UNITS[n];
  const start = 12 + 10 * (n - 1);
  const kraj = start + 9;
  const kade = 'Unit ' + n;

  tvurdi(u.id === 'ep1_unit' + n, kade + ': името не е ep1_unit' + n);
  tvurdi(u.subject === 'angliiski' && u.grade === 5, kade + ': не е английски, 5. клас');
  tvurdi(u.title.indexOf('Unit ' + n + ' ') === 0, kade + ': заглавието не започва с номера');
  tvurdi(/^[\x20-\x7E·’é]+$/.test(u.title),
         kade + ': заглавието не е на английски: ' + u.title);
  tvurdi(u.note.indexOf('Pages ' + start + '–' + kraj) !== -1,
         kade + ': описанието не казва страници ' + start + '–' + kraj);
  tvurdi(u.sections.map(s => s.id).join(',') === REDNI.join(','),
         kade + ': частите не са седемте в реда им');

  u.sections.forEach(function (sec) {
    tvurdi(FORMA.test(sec.id), kade + ' · ' + sec.id + ': името не е по формата');
    tvurdi(sec.note && sec.note.length >= 20, kade + ' · ' + sec.id + ': празно описание');

    const pp = stranici(sec.note);
    tvurdi(pp.length > 0, kade + ' · ' + sec.id + ': няма нито една страница');

    if (sec.id === 'options') {
      pp.forEach(x => tvurdi(x >= 92 && x <= 119,
        kade + ' · options: p' + x + ' е извън блока 92–119'));
      const red = sec.note.split('p').slice(1);
      red.forEach(function (parche) {
        const br = Number((parche.match(/^(\d{1,3})/) || [])[1]);
        if (!br) return;
        if (/^\d+\s+Extra listening/.test(parche)) dop.extra.push([n, br]);
        else if (/^\d+\s+Curriculum Extra/.test(parche)) dop.curriculum.push([n, br]);
        else if (/^\d+\s+Culture/.test(parche)) dop.culture.push([n, br]);
        else if (/^\d+\s+Project/.test(parche)) dop.project.push([n, br]);
        else if (/^\d+\s+Song/.test(parche)) dop.song.push([n, br]);
        else greshki.push(kade + ' · options: непознат вид допълнение при p' + br);
      });
      return;
    }

    pp.forEach(x => tvurdi(x >= start && x <= kraj,
      kade + ' · ' + sec.id + ': p' + x + ' е извън ' + start + '–' + kraj));
    const ochakvani = OCHAKVANI[sec.id].map(d => start + d);
    tvurdi(pp.join(',') === ochakvani.join(','),
           kade + ' · ' + sec.id + ': страниците са ' + pp.join(', ') +
           ', а по модела на учебника трябва да са ' + ochakvani.join(', '));
  });
}

/* ── Допълненията отзад ───────────────────────────────────────────── */
tvurdi(dop.extra.length === 8, 'Extra listening and speaking не е при всичките осем юнита');
dop.extra.forEach(function (x) {
  tvurdi(x[1] === 91 + x[0],
    'Unit ' + x[0] + ': Extra listening е p' + x[1] + ', а трябва да е p' + (91 + x[0]));
});
[['curriculum', 100, 105], ['culture', 106, 111],
 ['project', 112, 115], ['song', 116, 119]].forEach(function (red) {
  const vid = red[0], ot = red[1], do_ = red[2];
  const spisuk = dop[vid];
  tvurdi(spisuk.length === do_ - ot + 1,
    vid + ': страниците са ' + spisuk.length + ', а блокът ' + ot + '–' + do_ +
    ' иска ' + (do_ - ot + 1));
  spisuk.forEach(function (x, i) {
    tvurdi(x[1] === ot + i,
      'Unit ' + x[0] + ': ' + vid + ' е p' + x[1] + ', а по реда на юнитите трябва p' + (ot + i));
  });
  for (let i = 1; i < spisuk.length; i++) {
    tvurdi(spisuk[i][0] > spisuk[i - 1][0], vid + ': юнитите не вървят възходящо');
  }
});

/* ── Имената не се повтарят никъде в каталога ─────────────────────── */
const vidqni = {};
T.all.forEach(function (t) {
  tvurdi(FORMA.test(t.id), 'разделът „' + t.id + '“ не е по формата');
  tvurdi(!vidqni[t.id], 'разделът „' + t.id + '“ го има два пъти');
  vidqni[t.id] = true;
  const vutre = {};
  (t.sections || []).forEach(function (s) {
    tvurdi(!vutre[s.id], t.id + ': подразделът „' + s.id + '“ го има два пъти');
    vutre[s.id] = true;
  });
});

/* ── Платформата знае ли за тях ───────────────────────────────────── */
const tabl = fs.readFileSync(path.join(KOREN, 'teacher.html'), 'utf8');
const port = fs.readFileSync(path.join(KOREN, 'portal.html'), 'utf8');
tvurdi(/assets\/tracks\.js/.test(tabl), 'таблото не зарежда tracks.js');
tvurdi(/assets\/tracks\.js/.test(port), 'порталът не зарежда tracks.js');
tvurdi(/'angliiski':/.test(tabl), 'английският не е сред предметите без седмици');
tvurdi(/groupPresent\(hwAll\)/.test(port), 'порталът не подрежда домашните по юнити');

/* Английският няма седмици: нито един негов лист не бива да носи week. */
const sql = fs.readFileSync(path.join(KOREN, 'supabase/domashno-angliyski-4.sql'), 'utf8');
tvurdi(/null,\s*--\s*английският не върви по седмици/.test(sql),
       'домашното по английски още има седмица');

if (greshki.length) {
  console.log('ГРЕШКИ (' + greshki.length + '):');
  greshki.forEach(g => console.log('  · ' + g));
  process.exit(1);
}
console.log('всичко съвпада с картата на учебника · проверки: ' + proverki +
            ' · юнита: ' + UNITS.length);
