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

  /* Разделите на 4. клас по състезателна математика са СЪСТЕЗАНИЯТА от
     календара (sastezaniya_4.html), а не седмици: предметът не върви по
     учебна програма, а от турнир към турнир. Подредбата отдолу е
     подредбата на екрана — първо двете, с които се занимаваме, после
     останалите по реда на календара.

     „Минали теми“ е мястото за пробните варианти от предишни години.
     Празният раздел не е грешка: той е мястото, което чака да се
     напълни, и точно затова се вижда в таблото на преподавателя. */
  var MINALI = [{ id: 'minali', title: 'Минали теми',
                  note: 'Варианти от предишни години, разписани като пробен тест.' }];

  function contest(id, title, note) {
    return { id: id, subject: 'sastezatelna-matematika', grade: 4,
             title: title, note: note, sections: MINALI };
  }

  var TRACKS = [
    {
      id: 'salabashev',
      subject: 'sastezatelna-matematika',
      grade: 4,
      title: 'Състезание „Иван Салабашев“',
      note: 'Турнирът на СМБ, секция Стара Загора — края на ноември. ' +
            '15 задачи за 120 минути: първите десет с избираем отговор, последните пет с число.',
      sections: MINALI
    },
    {
      id: 'olimpiada',
      subject: 'sastezatelna-matematika',
      grade: 4,
      title: 'Олимпиада по математика',
      note: 'Двата кръга, които ни интересуват, един след друг. Общинският е вратата: ' +
            'без него няма областен.',
      sections: [
        { id: 'obshtinski', title: 'Общински кръг',
          note: 'Първият кръг — в училището, до средата на декември. Оттук се продължава нататък.' },
        { id: 'oblasten', title: 'Областен кръг',
          note: 'Вторият кръг — за областта, в началото на февруари. Балообразуващ.' }
      ]
    },
    contest('hitar_petar', '„Хитър Петър“',
            'Октомври. Допълнително състезание — добро за тренировка в началото на годината.'),
    { id: 'bez_granici', subject: 'sastezatelna-matematika', grade: 4,
      title: '„Математика без граници“',
      note: 'Четири кръга през годината и финал при класиране.',
      sections: [
        { id: 'esen', title: 'Есенен кръг', note: 'Края на октомври.' },
        { id: 'zima', title: 'Зимен кръг', note: 'Втората половина на януари.' },
        { id: 'prolet', title: 'Пролетен кръг', note: 'Началото на март.' },
        { id: 'polufinal', title: 'Полуфинал', note: 'Края на април.' },
        { id: 'final', title: 'Финал', note: 'Юли — само при класиране.' }
      ] },
    contest('chernorizec', '„Черноризец Храбър“', 'Началото на ноември.'),
    contest('sofijski', 'Софийски математически турнир', 'Началото на ноември.'),
    contest('koledno', 'Коледно математическо състезание', 'Средата на декември.'),
    contest('zimno', 'Зимно математическо състезание', 'Края на февруари, Стара Загора.'),
    contest('kenguru', '„Европейско кенгуру“',
            'Средата на март. Кратки задачи с избираем отговор — най-доброто за тренировка.'),
    contest('proletno', 'Пролетно математическо състезание',
            'Края на март, специално за IV клас. Балообразуващо.'),
    contest('velikdensko', 'Великденско математическо състезание', 'Април.'),
    contest('kiril_popov', '„Академик Кирил Попов“', 'Началото на май.'),
    contest('za_vseki', '„Математика за всеки“',
            'Средата на май. Национално състезание за четвъртокласници. Балообразуващо.'),
    contest('evrika', '„Еврика“', 'Края на май.')
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
