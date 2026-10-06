/* =====================================================================
   The Light Academy — раздели вътре в един предмет
   ---------------------------------------------------------------------
   Един предмет не е плосък списък от листове. „Състезателна математика“
   за 4. клас е подготовка за олимпиада, а тя е три кръга един след друг:
   общински, областен, национален. Тук стои тази структура.

   ЗАЩО Е В КОДА, А НЕ В БАЗАТА

   Разделите са учебна наредба, не данни. Кръговете на олимпиадата са
   три и ще са три и догодина; никой не ги въвежда през екран. Същото
   важи и за програмата по седмици, която стои в teacher.html по същата
   причина.

   В базата (supabase/schema-v8.sql) стои само КОЕ задание в кой раздел
   е — две кратки колони, track и section. Следствието е, че разделът
   съществува и празен: таблото показва и трите кръга от първия ден, за
   да се види къде какво да се сложи.

   ДА СЕ ДОБАВИ РАЗДЕЛ

   Нов запис тук и нищо друго — без промяна по базата. Имената (id) се
   пишат с малки букви, цифри и долна черта: базата приема само такива
   и ще откаже останалото.
   ===================================================================== */
(function (global) {
  'use strict';

  var TLA = global.TLA = global.TLA || {};

  var TRACKS = [
    {
      id: 'olimpiada',
      subject: 'sastezatelna-matematika',
      grade: 4,
      title: 'Подготовка за олимпиада',
      note: 'Трите кръга на олимпиадата по математика, един след друг. ' +
            'Всеки кръг си има пробни състезания.',
      sections: [
        { id: 'obshtinski', title: 'Общински кръг',
          note: 'Първият кръг — в училището. Оттук се продължава нататък.' },
        { id: 'oblasten', title: 'Областен кръг',
          note: 'Вторият кръг — за областта. По-малко задачи, но по-дълго време за тях.' },
        { id: 'nacionalen', title: 'Национален кръг',
          note: 'Последният кръг. Задачите искат обяснение, не само отговор.' }
      ]
    }
  ];

  /* Пазач при зареждането. Повторено име или име не по формата не чупи
     нищо видимо — заданието просто няма да се намери в своя раздел, а
     това се забелязва месеци по-късно. Затова се казва веднага. */
  (function selfCheck() {
    var ok = /^[a-z][a-z0-9_]{0,31}$/, bad = [], seen = {};
    TRACKS.forEach(function (t) {
      if (!ok.test(t.id)) bad.push('разделът „' + t.id + '“ не е по формата');
      if (seen[t.id]) bad.push('разделът „' + t.id + '“ го има два пъти');
      seen[t.id] = true;
      var s2 = {};
      (t.sections || []).forEach(function (s) {
        if (!ok.test(s.id)) bad.push('подразделът „' + s.id + '“ не е по формата');
        if (s2[s.id]) bad.push('подразделът „' + s.id + '“ го има два пъти в „' + t.id + '“');
        s2[s.id] = true;
      });
    });
    if (bad.length && global.console) console.error('tracks.js: ' + bad.join(' · '));
  })();

  function byId(id) {
    var hit = TRACKS.filter(function (t) { return t.id === id; });
    return hit.length ? hit[0] : null;
  }

  function sectionOf(trackId, sectionId) {
    var t = byId(trackId);
    if (!t) return null;
    var hit = (t.sections || []).filter(function (s) { return s.id === sectionId; });
    return hit.length ? hit[0] : null;
  }

  /* Разделите, които важат за един предмет и клас. subjectSlug идва от
     таблицата subjects; grade е числото на класа. */
  function forSubject(subjectSlug, grade) {
    return TRACKS.filter(function (t) {
      return t.subject === subjectSlug && String(t.grade) === String(grade);
    });
  }

  /* Надписът на един раздел, готов за екрана. Непознато име НЕ се крие:
     ако заданието сочи към раздел, какъвто вече няма, това трябва да се
     види, а не да изчезне тихо. */
  function label(trackId, sectionId) {
    var t = byId(trackId);
    if (!t) return trackId ? ('непознат раздел: ' + trackId) : '';
    var s = sectionId ? sectionOf(trackId, sectionId) : null;
    if (sectionId && !s) return t.title + ' · непознат подраздел: ' + sectionId;
    return s ? (t.title + ' · ' + s.title) : t.title;
  }

  /* Задания, подредени по раздели. Връща за всеки раздел и подраздел
     онова, което е в него — включително празните, защото празният
     раздел е мястото, което чака да се напълни. `rest` са заданията
     извън всякакъв раздел. */
  function group(assignments, subjectSlug, grade) {
    var tracks = forSubject(subjectSlug, grade).map(function (t) {
      return {
        track: t,
        sections: (t.sections || []).map(function (s) {
          return { section: s, items: [] };
        }),
        loose: []       /* в раздела, но без подраздел */
      };
    });
    var rest = [];

    (assignments || []).forEach(function (a) {
      var box = null;
      tracks.forEach(function (g) { if (g.track.id === a.track) box = g; });
      if (!box) { rest.push(a); return; }
      var hit = null;
      box.sections.forEach(function (sg) { if (sg.section.id === a.section) hit = sg; });
      (hit ? hit.items : box.loose).push(a);
    });

    return { tracks: tracks, rest: rest };
  }

  /* Същото, но тръгнало от самите задания, а не от каталога: връща
     само разделите и кръговете, в които НАИСТИНА има нещо.

     Двете групирания са нарочно различни. Преподавателят трябва да
     вижда и празния кръг — там ще слага. Ученикът не бива: за него
     празен кръг е обещание, което никой не му е давал. */
  function groupPresent(assignments) {
    var order = {}, i = 0;
    TRACKS.forEach(function (t) {
      order[t.id] = i++;
      (t.sections || []).forEach(function (sec, k) { order[t.id + '/' + sec.id] = k; });
    });

    var box = {}, rest = [];
    (assignments || []).forEach(function (a) {
      if (!a.track || !byId(a.track)) { rest.push(a); return; }
      var g = box[a.track] || (box[a.track] = { track: byId(a.track), sections: {}, loose: [] });
      var sec = a.section ? sectionOf(a.track, a.section) : null;
      if (!sec) { g.loose.push(a); return; }
      (g.sections[sec.id] || (g.sections[sec.id] = { section: sec, items: [] })).items.push(a);
    });

    var tracks = Object.keys(box)
      .sort(function (x, y) { return order[x] - order[y]; })
      .map(function (id) {
        var g = box[id];
        return {
          track: g.track,
          loose: g.loose,
          sections: Object.keys(g.sections)
            .sort(function (x, y) { return order[id + '/' + x] - order[id + '/' + y]; })
            .map(function (k) { return g.sections[k]; })
        };
      });
    return { tracks: tracks, rest: rest };
  }

  TLA.Tracks = {
    all: TRACKS,
    byId: byId,
    sectionOf: sectionOf,
    forSubject: forSubject,
    label: label,
    group: group,
    groupPresent: groupPresent
  };
})(typeof window !== 'undefined' ? window : globalThis);
