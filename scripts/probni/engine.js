/* =====================================================================
   Двигателят на пробния тест
   ---------------------------------------------------------------------
   Един и същ за всички години. Темата (условия, отговори, критерии,
   анимации) идва отвън, в обекта TEST, и двигателят не знае нищо за
   съдържанието ѝ. Нова година значи нов файл с данни и нищо друго.

   Три неща, които се правят нарочно така:

   · Времето се мери с Date.now(), а не с броене на тиктакания. Таб,
     който е бил на заден план, не „дължи“ секунди — браузърът спира
     таймерите му, а часовникът на олимпиадата не спира.
   · Отговорите са кодирани. Не е ключалка, а предпазване от случайно
     лъсване, докато листът е отворен пред класа.
   · Проверка има САМО след предаване. По време на теста няма зелено и
     червено — иначе детето решава по сигналите, а не по задачата.
   ===================================================================== */
(function () {
  'use strict';

  /* ── дребни помощници ─────────────────────────────────────────────*/
  var $ = function (id) { return document.getElementById(id); };
  function el(tag, cls, html) {
    var e = document.createElement(tag);
    if (cls) e.className = cls;
    if (html != null) e.innerHTML = html;
    return e;
  }
  function esc(v) {
    return String(v == null ? '' : v).replace(/&/g, '&amp;').replace(/</g, '&lt;')
      .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }
  function dec(s) {
    try { return decodeURIComponent(escape(atob(s))); } catch (e) { return ''; }
  }
  /* 5,5 → „5,5“; 5 → „5“. Точките са половинки, затова не се закръглят. */
  function pts(n) {
    var r = Math.round(n * 2) / 2;
    return (r === Math.floor(r)) ? String(r) : String(r).replace('.', ',');
  }
  function plural(n, a, b, c) { return n === 1 ? a : (n < 5 ? b : c); }

  /* ── нормализиране на въведеното ──────────────────────────────────
     Детето пише „42 м“, „42м“, „ 42 “ или „42,0“ — всичко това е 42.
     Мерните единици се махат, защото са изписани до полето; запетаята
     и точката са едно и също; интервалите вътре в числото също падат,
     за да мине „1 045“. */
  function normalizeInput(raw) {
    var t = String(raw == null ? '' : raw).trim().toLowerCase();
    if (!t) return '';
    t = t.replace(/[а-я.]*$/u, function (m) {
      /* маха само мерна единица накрая, не цифри */
      return /^[а-я.\s]*$/u.test(m) ? '' : m;
    });
    t = t.replace(/\s+/g, '').replace(/,/g, '.');
    if (!/^-?\d+(\.\d+)?$/.test(t)) return t;        /* не е число — връща се както е */
    var n = parseFloat(t);
    if (isNaN(n)) return t;
    /* 42.0 и 42 са едно и също */
    return String(Math.round(n * 1000) / 1000);
  }
  function sameNum(a, b) { return a !== '' && normalizeInput(a) === normalizeInput(b); }

  /* ── състояние ────────────────────────────────────────────────────*/
  var KEY = 'tla-probna-' + TEST.id;
  var S = {
    name: '', mode: 'train', minutes: 60,
    startedAt: 0, endsAt: 0, paused: false, pausedAt: 0,
    answers: {}, drafts: {}, submitted: false, usedMs: 0, result: null,
    screen: 'start', tab: 0, shown: {}
  };

  function save() {
    try {
      localStorage.setItem(KEY, JSON.stringify({
        name: S.name, mode: S.mode, minutes: S.minutes, startedAt: S.startedAt,
        endsAt: S.endsAt, paused: S.paused, pausedAt: S.pausedAt,
        answers: S.answers, drafts: S.drafts, submitted: S.submitted, usedMs: S.usedMs
      }));
    } catch (e) { /* без localStorage тестът пак работи, просто не оцелява презареждане */ }
  }
  function load() {
    try {
      var raw = localStorage.getItem(KEY);
      return raw ? JSON.parse(raw) : null;
    } catch (e) { return null; }
  }
  function wipe() { try { localStorage.removeItem(KEY); } catch (e) {} }

  /* ── известия и модални прозорци ──────────────────────────────────*/
  var toastWrap;
  function toast(msg, ms) {
    if (!toastWrap) { toastWrap = el('div', 'toast-wrap'); document.body.appendChild(toastWrap); }
    var t = el('div', 'toast', esc(msg));
    toastWrap.appendChild(t);
    setTimeout(function () { t.remove(); }, ms || 4200);
  }
  function ask(title, text, okLabel, onOk) {
    var m = el('div', 'modal');
    m.innerHTML = '<div class="modal__box" role="dialog" aria-modal="true">' +
      '<h2>' + esc(title) + '</h2><p class="muted" style="margin-top:.4rem">' + esc(text) + '</p>' +
      '<div class="modal__btns">' +
        '<button type="button" class="btn btn--ghost" data-no>Не, връщам се</button>' +
        '<button type="button" class="btn" data-yes>' + esc(okLabel) + '</button>' +
      '</div></div>';
    document.body.appendChild(m);
    m.querySelector('[data-yes]').focus();
    m.addEventListener('click', function (e) {
      if (e.target.closest('[data-yes]')) { m.remove(); onOk(); }
      else if (e.target.closest('[data-no]') || e.target === m) m.remove();
    });
  }

  /* ── таймерът ─────────────────────────────────────────────────────*/
  var tick = null, flags = {};
  function msLeft() {
    if (S.paused) return Math.max(0, S.endsAt - S.pausedAt);
    return Math.max(0, S.endsAt - Date.now());
  }
  function fmt(ms) {
    var s = Math.floor(ms / 1000), h = Math.floor(s / 3600);
    var m = Math.floor((s % 3600) / 60), q = s % 60;
    return h + ':' + ('0' + m).slice(-2) + ':' + ('0' + q).slice(-2);
  }
  function startClock() {
    stopClock();
    tick = setInterval(paintClock, 250);
    paintClock();
  }
  function stopClock() { if (tick) { clearInterval(tick); tick = null; } }

  function paintClock() {
    var box = $('clock');
    if (!box) return;
    var left = msLeft(), total = S.minutes * 60000;
    var frac = total ? left / total : 0;
    $('clockT').textContent = fmt(left);
    var ring = $('clockFg');
    var C = 2 * Math.PI * 24;
    ring.setAttribute('stroke-dasharray', C);
    ring.setAttribute('stroke-dashoffset', String(C * (1 - frac)));
    box.className = 'clock' + (left <= 300000 ? ' is-hot' : (frac <= 0.25 ? ' is-warn' : ''));

    if (!flags.half && left <= total / 2 && left > total / 2 - 2000) {
      flags.half = true; toast('Половината време мина.');
    }
    if (!flags.ten && left <= 600000) { flags.ten = true; toast('Остават 10 минути.'); }
    if (!flags.one && left <= 60000) { flags.one = true; toast('Остава 1 минута!'); }
    if (left <= 0) { stopClock(); submit(true); }
  }

  /* ── събиране на отговорите от екрана ─────────────────────────────*/
  function inputId(pk, k, i) { return 'in-' + pk + '-' + k + (i == null ? '' : '-' + i); }

  /* На екрана стои само отворената задача — полетата на другите две ги
     няма в DOM-а. Затова се чете САМО онова, което наистина е на екрана:
     иначе смяната на раздел би изтрила вече попълнените отговори. */
  function readInputs() {
    TEST.problems.forEach(function (pr) {
      pr.parts.forEach(function (pt) {
        pt.inputs.forEach(function (inp) {
          if (inp.kind === 'money') {
            var lv = $(inputId(pt.key, inp.key, 'lv')), st = $(inputId(pt.key, inp.key, 'st'));
            if (!lv && !st) return;
            S.answers[inp.key] = [lv ? lv.value : '', st ? st.value : ''];
          } else if (inp.kind === 'digits') {
            if (!$(inputId(pt.key, inp.key, 0))) return;
            S.answers[inp.key] = inp.boxes.map(function (b, i) {
              var e = $(inputId(pt.key, inp.key, i));
              return e ? e.value : '';
            });
          } else {
            var e2 = $(inputId(pt.key, inp.key));
            if (!e2) return;
            S.answers[inp.key] = e2.value;
          }
        });
      });
      var d = $('draft-' + pr.n);
      if (d) S.drafts['p' + pr.n] = d.value;
    });
  }

  /* Колко полета са попълнени — само крайните броят за прогреса, защото
     междинните са по желание. */
  function progress() {
    var done = 0, all = 0;
    TEST.problems.forEach(function (pr) {
      pr.parts.forEach(function (pt) {
        pt.inputs.forEach(function (inp) {
          if (!inp.final) return;
          all++;
          if (filled(inp)) done++;
        });
      });
    });
    return { done: done, all: all };
  }
  function filled(inp) {
    var v = S.answers[inp.key];
    if (v == null) return false;
    if (inp.kind === 'money') return String(v[0] || '').trim() !== '' || String(v[1] || '').trim() !== '';
    if (inp.kind === 'digits') return v.every(function (x) { return String(x).trim() !== ''; });
    return String(v).trim() !== '';
  }

  /* ── оценяване ────────────────────────────────────────────────────
     Правилото е едно: верни ВСИЧКИ крайни полета → пълните точки за
     подточката. Инак — сборът от точките на верните полета (и крайни,
     и междинни), без да надхвърля пълните. */
  function inputCorrect(inp) {
    var v = S.answers[inp.key];
    if (v == null) return false;
    if (inp.kind === 'money') {
      var lv = normalizeInput(v[0]) === '' ? 0 : parseFloat(normalizeInput(v[0]));
      var st = normalizeInput(v[1]) === '' ? 0 : parseFloat(normalizeInput(v[1]));
      if (isNaN(lv) || isNaN(st)) return false;
      if (String(v[0]).trim() === '' && String(v[1]).trim() === '') return false;
      return (lv * 100 + st) === parseFloat(dec(inp.enc));
    }
    if (inp.kind === 'digits') {
      var want = dec(inp.enc).split(',');
      return v.length === want.length && want.every(function (w, i) { return sameNum(v[i], w); });
    }
    return sameNum(v, dec(inp.enc));
  }

  function scorePart(pt) {
    var finals = pt.inputs.filter(function (i) { return i.final; });
    var allFinal = finals.length > 0 && finals.every(inputCorrect);
    if (allFinal) return { got: pt.points, full: true };
    var sum = 0;
    pt.inputs.forEach(function (i) { if (inputCorrect(i)) sum += i.points || 0; });
    return { got: Math.min(sum, pt.points), full: false };
  }

  function scoreTest() {
    var rows = [], total = 0;
    TEST.problems.forEach(function (pr) {
      pr.parts.forEach(function (pt) {
        var r = scorePart(pt);
        total += r.got;
        rows.push({ pr: pr.n, label: pt.label, points: pt.points, got: r.got, part: pt });
      });
    });
    return { rows: rows, total: Math.round(total * 2) / 2 };
  }

  /* ── екран: начало ────────────────────────────────────────────────*/
  function screenStart(resume) {
    var modes = [
      { id: 'real', t: 'Като на олимпиадата', s: '4 часа, без пауза — точно както е на истинската.', m: TEST.officialMinutes },
      { id: 'train', t: 'Тренировка', s: '60 минути, с бутон „Пауза“.', m: 60 },
      { id: 'mine', t: 'Мое време', s: 'Избираш сам между 10 и 240 минути.', m: 60 }
    ];
    var app = $('app');
    app.innerHTML = '<div class="wrap"><div class="card hero">' +
      '<span class="hero__badge">Общински кръг · IV клас</span>' +
      '<h1>' + esc(TEST.title) + '</h1>' +
      '<p class="hero__sub">По темата от ' + esc(TEST.originalDate) +
        ' · три задачи по 7 точки, общо 21.</p>' +
      (resume ? '<div class="rules" style="background:var(--good-w)"><b>Има започнат тест.</b> ' +
        'Можеш да продължиш оттам, където си спрял.' +
        '<div style="margin-top:.7rem;display:flex;gap:10px;flex-wrap:wrap">' +
        '<button class="btn" id="goOn">Продължи започнатия тест</button>' +
        '<button class="btn btn--ghost" id="goNew">Започни отначало</button></div></div>' : '') +
      '<div class="field"><label for="nm">Име</label>' +
        '<input id="nm" type="text" placeholder="напиши името си" value="' + esc(S.name) + '" /></div>' +
      '<div class="modes">' + modes.map(function (m) {
        return '<label class="mode' + (S.mode === m.id ? ' is-on' : '') + '" data-mode="' + m.id + '">' +
          '<input type="radio" name="mode" value="' + m.id + '"' +
            (S.mode === m.id ? ' checked' : '') + ' />' +
          '<span><b>' + esc(m.t) + '</b><span>' + esc(m.s) + '</span></span></label>';
      }).join('') + '</div>' +
      '<div class="field" id="mineWrap" ' + (S.mode === 'mine' ? '' : 'hidden') + '>' +
        '<label for="mins">Колко минути</label>' +
        '<input id="mins" type="number" min="10" max="240" value="' + (S.minutes || 60) + '" /></div>' +
      '<div class="rules"><b>Как се работи</b><ul>' +
        '<li>Три задачи по 7 точки — общо 21.</li>' +
        '<li>В полетата пиши само крайния отговор, с цифри.</li>' +
        '<li>Има и полета „междинен резултат“ — те не са задължителни, но носят точки, ако крайният отговор е сбъркан.</li>' +
        '<li>Ползвай хартия за чернова. Има и място за бележки под всяка задача.</li>' +
        '<li>Проверка има чак след предаване.</li>' +
      '</ul></div>' +
      '<p style="margin-top:18px"><button class="btn" id="go">Започни</button></p>' +
      '<p class="muted" style="margin-top:.6rem">Прагът за областен кръг е ' +
        TEST.passThreshold + ' точки' + (TEST.thresholdNote ? ' (' + esc(TEST.thresholdNote) + ')' : '') + '.</p>' +
      '</div></div>';

    app.addEventListener('change', onStartChange);
    app.addEventListener('click', onStartClick);
  }
  function onStartChange(e) {
    var m = e.target.closest('[name="mode"]');
    if (m) {
      S.mode = m.value;
      Array.prototype.forEach.call(document.querySelectorAll('.mode'), function (l) {
        l.classList.toggle('is-on', l.dataset.mode === S.mode);
      });
      $('mineWrap').hidden = (S.mode !== 'mine');
    }
  }
  function onStartClick(e) {
    if (e.target.closest('#goOn')) { resumeRun(); return; }
    if (e.target.closest('#goNew')) { wipe(); S.submitted = false; S.answers = {}; screenStart(false); return; }
    if (!e.target.closest('#go')) return;
    S.name = ($('nm').value || '').trim();
    var mins = S.mode === 'real' ? TEST.officialMinutes : (S.mode === 'train' ? 60 : Number($('mins').value || 60));
    if (S.mode === 'mine') mins = Math.max(10, Math.min(240, mins || 60));
    S.minutes = mins;
    S.startedAt = Date.now();
    S.endsAt = S.startedAt + mins * 60000;
    S.paused = false; S.submitted = false; S.answers = {}; S.drafts = {}; flags = {};
    save();
    screenTest();
  }
  function resumeRun() {
    var d = load();
    if (!d) { screenStart(false); return; }
    S.name = d.name; S.mode = d.mode; S.minutes = d.minutes;
    S.startedAt = d.startedAt; S.endsAt = d.endsAt;
    S.paused = !!d.paused; S.pausedAt = d.pausedAt || 0;
    S.answers = d.answers || {}; S.drafts = d.drafts || {};
    if (msLeft() <= 0) { S.submitted = true; screenTest(); submit(true); return; }
    screenTest();
  }

  /* ── екран: тестът ────────────────────────────────────────────────*/
  function screenTest() {
    S.screen = 'test';
    var app = $('app');
    app.innerHTML =
      '<div class="bar">' +
        '<span class="bar__who">' + (S.name ? esc(S.name) : 'Пробен тест') + '</span>' +
        '<span class="bar__prog" id="prog"></span>' +
        '<span class="bar__sp"></span>' +
        '<span class="clock" id="clock">' +
          '<svg class="clock__ring" viewBox="0 0 54 54" aria-hidden="true">' +
            '<circle class="clock__bg" cx="27" cy="27" r="24"></circle>' +
            '<circle class="clock__fg" id="clockFg" cx="27" cy="27" r="24" ' +
              'transform="rotate(-90 27 27)"></circle></svg>' +
          '<span class="clock__t" id="clockT">0:00:00</span>' +
        '</span>' +
        (S.mode === 'train' ? '<button class="btn btn--ghost btn--sm" id="pause">Пауза</button>' : '') +
        '<button class="btn btn--sm" id="send">Предай теста</button>' +
      '</div>' +
      '<div class="wrap">' +
        '<div class="tabs" id="tabs"></div>' +
        '<div id="probBox"></div>' +
      '</div>';
    paintTabs();
    paintProblem();
    startClock();
    app.addEventListener('input', onTestInput);
    app.addEventListener('click', onTestClick);
    window.addEventListener('beforeunload', guard);
  }
  function guard(e) {
    if (S.screen === 'test' && !S.submitted) { e.preventDefault(); e.returnValue = ''; }
  }
  function paintTabs() {
    $('tabs').innerHTML = TEST.problems.map(function (pr, i) {
      var done = pr.parts.every(function (pt) {
        return pt.inputs.filter(function (x) { return x.final; }).every(filled);
      });
      return '<button class="tab' + (i === S.tab ? ' is-on' : '') + '" data-tab="' + i + '">' +
        '<span>Задача ' + pr.n + '</span>' +
        '<span class="tab__pts">' + pr.points + ' точки</span>' +
        '<span class="tab__ok">' + (done ? '✓ попълнена' : '&nbsp;') + '</span></button>';
    }).join('');
    var p = progress();
    $('prog').textContent = 'Попълнени ' + p.done + ' от ' + p.all + ' ' +
      plural(p.all, 'поле', 'полета', 'полета');
  }

  function inputHtml(pt, inp) {
    if (inp.kind === 'money') {
      return '<div class="ans__box' + (inp.final ? '' : ' ans--hint') + '">' +
        '<span class="ans__lab">' + esc(inp.label) + '</span>' +
        '<span class="ans__row">' +
          '<input class="sm" id="' + inputId(pt.key, inp.key, 'lv') + '" inputmode="numeric" />' +
          '<span class="ans__u">лв.</span>' +
          '<input class="sm" id="' + inputId(pt.key, inp.key, 'st') + '" inputmode="numeric" />' +
          '<span class="ans__u">ст.</span>' +
        '</span></div>';
    }
    if (inp.kind === 'digits') {
      return '<div class="ans__box' + (inp.final ? '' : ' ans--hint') + '">' +
        '<span class="ans__lab">' + esc(inp.label) + '</span>' +
        '<span class="ans__row">' + inp.boxes.map(function (b, i) {
          return '<span class="ans__u">' + esc(b) + '</span>' +
            '<input class="sm" id="' + inputId(pt.key, inp.key, i) + '" inputmode="numeric" maxlength="1" />';
        }).join('') + '</span></div>';
    }
    return '<div class="ans__box' + (inp.final ? '' : ' ans--hint') + '">' +
      '<span class="ans__lab">' + esc(inp.label) + '</span>' +
      '<span class="ans__row">' +
        '<input id="' + inputId(pt.key, inp.key) + '" inputmode="numeric" />' +
        (inp.unit ? '<span class="ans__u">' + esc(inp.unit) + '</span>' : '') +
      '</span></div>';
  }

  function paintProblem() {
    var pr = TEST.problems[S.tab];
    $('probBox').innerHTML = '<div class="card">' +
      '<div class="prob__h"><span class="prob__n">Задача ' + pr.n + '</span>' +
        '<span class="prob__p">' + pr.points + ' точки</span></div>' +
      (pr.introHtml ? '<p class="prob__text">' + pr.introHtml + '</p>' : '') +
      (pr.figure ? '<div class="fig">' + pr.figure + '</div>' : '') +
      pr.parts.map(function (pt) {
        return '<div class="part">' +
          '<p class="prob__text"><span class="part__l">' + esc(pt.label) + '</span>' + pt.textHtml + '</p>' +
          '<div class="ans">' + pt.inputs.map(function (inp) { return inputHtml(pt, inp); }).join('') + '</div>' +
        '</div>';
      }).join('') +
      '<div class="draft"><label class="ans__lab" for="draft-' + pr.n + '">Чернова (не се оценява)</label>' +
        '<textarea id="draft-' + pr.n + '"></textarea></div>' +
    '</div>';
    /* стойностите се връщат през .value, а не в html-а */
    TEST.problems[S.tab].parts.forEach(function (pt) {
      pt.inputs.forEach(function (inp) {
        var v = S.answers[inp.key];
        if (v == null) return;
        if (inp.kind === 'money') {
          var a = $(inputId(pt.key, inp.key, 'lv')), b = $(inputId(pt.key, inp.key, 'st'));
          if (a) a.value = v[0] || ''; if (b) b.value = v[1] || '';
        } else if (inp.kind === 'digits') {
          v.forEach(function (x, i) { var e = $(inputId(pt.key, inp.key, i)); if (e) e.value = x || ''; });
        } else {
          var e3 = $(inputId(pt.key, inp.key)); if (e3) e3.value = v;
        }
      });
    });
    var d = $('draft-' + pr.n);
    if (d) d.value = S.drafts['p' + pr.n] || '';
    if (S.submitted) lockFields();
  }
  function lockFields() {
    Array.prototype.forEach.call(document.querySelectorAll('#probBox input, #probBox textarea'),
      function (e) { e.disabled = true; });
    var b = $('probBox'); if (b) b.classList.add('locked');
  }

  function onTestInput() { readInputs(); save(); paintTabs(); }
  function onTestClick(e) {
    var t = e.target.closest('[data-tab]');
    if (t) { readInputs(); S.tab = Number(t.dataset.tab); paintTabs(); paintProblem(); return; }
    if (e.target.closest('#pause')) {
      if (S.paused) { S.endsAt += Date.now() - S.pausedAt; S.paused = false; $('pause').textContent = 'Пауза'; }
      else { S.paused = true; S.pausedAt = Date.now(); $('pause').textContent = 'Продължи'; }
      save(); paintClock(); return;
    }
    if (e.target.closest('#send')) {
      readInputs();
      var p = progress();
      ask('Да предам ли теста?',
          'Попълнени са ' + p.done + ' от ' + p.all + '. След предаване полетата се заключват и излиза резултатът.',
          'Да, предавам', function () { submit(false); });
    }
  }

  /* ── предаване и резултат ─────────────────────────────────────────*/
  function submit(auto) {
    if (S.submitted) return;
    readInputs();
    S.submitted = true;
    S.usedMs = Math.max(0, Math.min(S.minutes * 60000, (S.paused ? S.pausedAt : Date.now()) - S.startedAt));
    stopClock();
    S.result = scoreTest();
    save();
    if (auto) toast('Времето изтече! Тестът е предаден.', 6000);
    screenResults();
  }

  function screenResults() {
    S.screen = 'result';
    var r = S.result, max = 21;
    var passed = r.total >= TEST.passThreshold;
    var msg = passed
      ? (r.total === max ? 'Всичко вярно. Това е пълен резултат.'
                         : 'Над прага — с този резултат се продължава към областния кръг.')
      : (r.total >= TEST.passThreshold - 4
          ? 'Малко остава до прага. Виж решенията — обикновено е един пропуснат детайл.'
          : 'Още има какво да се навакса. Решенията отдолу вървят стъпка по стъпка.');

    $('app').innerHTML = '<div class="wrap">' +
      '<div class="card">' +
        '<h1>Резултат</h1>' +
        '<p class="muted">' + esc(TEST.title) + (S.name ? ' · ' + esc(S.name) : '') +
          ' · използвано време ' + fmt(S.usedMs) + ' от ' + S.minutes + ' мин.</p>' +
        '<div class="score" style="margin-top:14px">' +
          '<div class="score__ring"><svg viewBox="0 0 120 120" aria-hidden="true">' +
            '<circle class="score__bg" cx="60" cy="60" r="52"></circle>' +
            '<circle class="score__fg" id="scoreFg" cx="60" cy="60" r="52"></circle></svg>' +
            '<span class="score__num"><b id="scoreN">0</b><span>от ' + max + ' точки</span></span></div>' +
          '<div class="score__msg"><h2>' + esc(msg) + '</h2>' +
            '<p class="muted" style="margin-top:.4rem">Прагът е ' + TEST.passThreshold + ' точки' +
            (TEST.thresholdNote ? ' (' + esc(TEST.thresholdNote) + ')' : '') + '. ' +
            'Ти имаш ' + pts(r.total) + '.</p>' +
          '</div>' +
        '</div>' +
        resultTable(r) +
        '<p style="margin-top:16px;display:flex;gap:10px;flex-wrap:wrap">' +
          '<button class="btn btn--ghost" id="again">Опитай отново</button>' +
          '<button class="btn btn--ghost" id="print">Принтирай резултата</button>' +
        '</p>' +
      '</div>' +
      '<h2 style="margin:22px 0 8px">Решения</h2>' +
      TEST.problems.map(solBlock).join('') +
    '</div><canvas id="conf"></canvas>';

    var C = 2 * Math.PI * 52, fg = $('scoreFg');
    fg.setAttribute('stroke-dasharray', C);
    fg.setAttribute('stroke-dashoffset', String(C));
    setTimeout(function () {
      fg.setAttribute('stroke-dashoffset', String(C * (1 - r.total / max)));
      fg.setAttribute('stroke', passed ? 'var(--good)' : 'var(--sun)');
    }, 60);
    countTo($('scoreN'), r.total, 1100);
    if (passed) confetti();

    $('app').addEventListener('click', onResultClick);
  }

  function resultTable(r) {
    return '<table class="tbl"><thead><tr><th>Задача</th><th>Твоят отговор</th>' +
      '<th>Верен отговор</th><th>Точки</th></tr></thead><tbody>' +
      r.rows.map(function (row) {
        var cls = row.got === row.points ? 'is-ok' : (row.got > 0 ? 'is-part' : 'is-bad');
        var mark = row.got === row.points ? '✓' : (row.got > 0 ? '◐' : '✕');
        var mine = row.part.inputs.filter(function (i) { return i.final; })
          .map(function (i) { return showAnswer(i, S.answers[i.key]); })
          .filter(function (x) { return x !== ''; }).join(' · ') || '—';
        var right = row.part.inputs.filter(function (i) { return i.final; })
          .map(function (i) { return showCorrect(i); }).join(' · ');
        return '<tr class="' + cls + '"><td><b>' + row.pr + row.label.replace(')', '') + '</b></td>' +
          '<td>' + esc(mine) + '</td><td>' + esc(right) + '</td>' +
          '<td class="mark">' + mark + ' ' + pts(row.got) + ' / ' + pts(row.points) + '</td></tr>';
      }).join('') +
      '<tr><td colspan="3"><b>Общо</b></td><td class="mark"><b>' + pts(r.total) + ' / 21</b></td></tr>' +
      '</tbody></table>';
  }
  function showAnswer(inp, v) {
    if (v == null) return '';
    if (inp.kind === 'money') {
      if (String(v[0]).trim() === '' && String(v[1]).trim() === '') return '';
      return inp.label + ': ' + (v[0] || '0') + ' лв. ' + (v[1] || '0') + ' ст.';
    }
    if (inp.kind === 'digits') {
      if (!v.some(function (x) { return String(x).trim() !== ''; })) return '';
      return inp.boxes.map(function (b, i) { return b + (v[i] || '—'); }).join(' ');
    }
    return String(v).trim() === '' ? '' : (String(v) + (inp.unit ? ' ' + inp.unit : ''));
  }
  function showCorrect(inp) {
    var d = dec(inp.enc);
    if (inp.kind === 'money') {
      var n = parseFloat(d);
      return inp.label + ': ' + Math.floor(n / 100) + ' лв. ' + (n % 100) + ' ст.';
    }
    if (inp.kind === 'digits') {
      return inp.boxes.map(function (b, i) { return b + d.split(',')[i]; }).join(' ');
    }
    return d + (inp.unit ? ' ' + inp.unit : '');
  }

  function countTo(node, to, ms) {
    var from = 0, t0 = performance.now();
    (function step(t) {
      var k = Math.min(1, (t - t0) / ms);
      node.textContent = pts(Math.round((from + (to - from) * k) * 2) / 2);
      if (k < 1) requestAnimationFrame(step); else node.textContent = pts(to);
    })(t0);
  }

  /* ── решенията ────────────────────────────────────────────────────*/
  function solBlock(pr) {
    return '<div class="sol" id="sol-' + pr.n + '">' +
      '<div class="sol__h"><h2>Задача ' + pr.n + '</h2>' +
        '<button class="btn btn--sm btn--ghost" data-sol="' + pr.n + '">Покажи решението</button>' +
        '<button class="btn btn--sm" data-next="' + pr.n + '" hidden>Следваща стъпка</button>' +
        '<span class="muted" data-cnt="' + pr.n + '"></span></div>' +
      '<div class="stage" id="stage-' + pr.n + '"></div>' +
      '<div class="steps" id="steps-' + pr.n + '"></div></div>';
  }
  function allSteps(pr) {
    var out = [];
    pr.parts.forEach(function (pt) {
      (pt.solutionSteps || []).forEach(function (s) {
        out.push({ label: pt.label, html: s.html, points: s.points, anim: s.anim, k: s.k });
      });
    });
    return out;
  }
  function onResultClick(e) {
    var s = e.target.closest('[data-sol]');
    if (s) { S.shown[s.dataset.sol] = 0; stepOn(Number(s.dataset.sol)); s.hidden = true; return; }
    var n = e.target.closest('[data-next]');
    if (n) { stepOn(Number(n.dataset.next)); return; }
    if (e.target.closest('#again')) {
      ask('Отначало?', 'Отговорите и времето се изтриват и тестът започва наново.', 'Да, отначало',
        function () { wipe(); location.reload(); });
      return;
    }
    if (e.target.closest('#print')) window.print();
  }
  function stepOn(n) {
    var pr = TEST.problems.filter(function (p) { return p.n === n; })[0];
    var steps = allSteps(pr);
    var i = S.shown[n] || 0;
    if (i >= steps.length) return;
    var st = steps[i];
    var box = $('steps-' + n);
    box.appendChild(el('div', 'step',
      (st.points ? '<span class="step__p">' + pts(st.points) + ' т.</span>' : '') +
      '<b>' + esc(st.label) + '</b> ' + st.html));
    if (st.anim && typeof ANIM[st.anim] === 'function') {
      try { ANIM[st.anim]($('stage-' + n), st.k == null ? 0 : st.k); }
      catch (err) { if (window.console) console.error('анимация ' + st.anim + ':', err); }
    }
    S.shown[n] = i + 1;
    var next = document.querySelector('[data-next="' + n + '"]');
    var cnt = document.querySelector('[data-cnt="' + n + '"]');
    next.hidden = (S.shown[n] >= steps.length);
    cnt.textContent = 'стъпка ' + S.shown[n] + ' от ' + steps.length;
  }

  /* ── конфети ──────────────────────────────────────────────────────*/
  function confetti() {
    if (window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    var c = $('conf'); if (!c) return;
    var x = c.getContext('2d');
    c.width = innerWidth; c.height = innerHeight;
    var cols = ['#F7AD19', '#15643C', '#0D1B36', '#E86A6A', '#7C5CD6'];
    var ps = [];
    for (var i = 0; i < 110; i++) {
      ps.push({ x: Math.random() * c.width, y: -20 - Math.random() * c.height / 2,
        r: 4 + Math.random() * 5, s: 1.6 + Math.random() * 2.4,
        a: Math.random() * Math.PI, c: cols[i % cols.length] });
    }
    var t0 = performance.now();
    (function draw(t) {
      x.clearRect(0, 0, c.width, c.height);
      ps.forEach(function (p) {
        p.y += p.s; p.a += 0.05; p.x += Math.sin(p.a) * 0.9;
        x.fillStyle = p.c;
        x.fillRect(p.x, p.y, p.r, p.r * 1.7);
      });
      if (t - t0 < 4200) requestAnimationFrame(draw); else x.clearRect(0, 0, c.width, c.height);
    })(t0);
  }

  /* ── тръгване ─────────────────────────────────────────────────────*/
  var old = load();
  if (old && old.startedAt && !old.submitted) {
    S.name = old.name || ''; S.mode = old.mode || 'train'; S.minutes = old.minutes || 60;
    screenStart(true);
  } else {
    screenStart(false);
  }
})();
