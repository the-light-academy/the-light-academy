/* =====================================================================
   Състезание Формула 1 — картината и класирането
   ---------------------------------------------------------------------
   Един файл, две страници. Таблото на преподавателя (teacher.html) си
   смята класирането от данните, които вече е заредило; профилът на
   ученика (portal.html) го получава наготово от public.my_race(). И
   двете подават един и същ списък и получават една и съща картина —
   така преподавателят и детето гледат едно и също нещо.

   Картината е SVG, нарисуван на ръка. Пистата се събира в точка
   (VX, VY) — истинска перспективна точка — и точно затова движението
   работи: всичко по пистата е поставено по един параметър u, а
   приближаването към зрителя е просто scale() около тази точка. Затуй
   лентите и бордюрите се въртят в безкраен цикъл, без нито един кадър
   да се вижда как се „пренавиват“. Стиловете и движението са в
   assets/portal.css, раздел „Състезание Формула 1“.
   ===================================================================== */
(function () {
  'use strict';

  function esc(v) {
    return (typeof TLA !== 'undefined' && TLA.escapeHtml)
      ? TLA.escapeHtml(v)
      : String(v == null ? '' : v).replace(/[&<>"']/g, function (c) {
          return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
        });
  }

  /* Цветовете на колите са проверените осем от палитрата за тъмен фон.
     Пуснати са през валидатора срещу точно този тъмносин фон и минават
     и петте проверки по съседни двойки. Но цветът никъде не носи смисъл
     сам: всяка кола си носи името, а класирането отдолу е същото нещо с
     думи и числа. */
  var COLORS = ['#3987e5', '#d95926', '#199e70', '#c98500',
                '#d55181', '#008300', '#9085e9', '#e66767'];
  var DARK   = ['#1d5ba6', '#9c3d17', '#0f6f4a', '#8d5c00',
                '#9c3459', '#005700', '#5b4fb5', '#a63b3a'];

  /* На широк екран пистата побира шест коли. На телефон същите шест
     стават 4-пикселови петна — там картината се изрязва отстрани и
     показва само тримата отпред, точно както изглежда снимка от финал.
     Имената и точките на всички остават в класирането отдолу. */
  function onTrack() { return window.innerWidth < 720 ? 3 : 6; }

  function pos(n) {
    var tail = (n === 1) ? 'ви' : (n === 2) ? 'ри' : (n === 7 || n === 8) ? 'ми' : 'ти';
    return n + tail;
  }

  function shortName(full) {
    var parts = String(full || '').trim().split(/\s+/);
    if (!parts[0]) return '—';
    if (parts.length === 1) return parts[0].slice(0, 11);
    return parts[0].slice(0, 10) + ' ' + parts[1].charAt(0) + '.';
  }

  function num(v) {
    return String(Math.round(v * 10) / 10).replace('.', ',');
  }

  function starsText(n) {
    return '★★★★★'.slice(0, n) + '☆☆☆☆☆'.slice(0, 5 - n);
  }

  /* Звездите казват колко ТОЧНО е решавал — делът на спечеленото от
     възможното. Нарочно не зависят от броя задания: дете, предало
     по-малко, но безгрешно, пак свети с пет. */
  function starsFor(pct, done) {
    if (!done) return 0;
    return pct >= 0.90 ? 5 : pct >= 0.75 ? 4 : pct >= 0.60 ? 3 : pct >= 0.40 ? 2 : 1;
  }

  /* Приема [{ name, points, max, done, mine }] и връща същото, наредено
     и с раздадени цветове. */
  function build(list) {
    var rows = list.map(function (r) {
      var max = Number(r.max || 0), points = Number(r.points || 0);
      var pct = max > 0 ? (points / max) : 0;
      var done = r.done === undefined ? (max > 0 || points > 0) : !!r.done;
      return { name: r.name || '—', short: shortName(r.name), mine: !!r.mine,
               points: points, max: max, pct: pct, stars: starsFor(pct, done), done: done };
    });
    /* Цветът се раздава по азбучен ред, не по класиране: така едно
       изпреварване мести колите, но не им сменя боята. */
    rows.slice().sort(function (a, b) {
      return a.name.localeCompare(b.name, 'bg');
    }).forEach(function (r, i) {
      r.color = COLORS[i % COLORS.length];
      r.dark  = DARK[i % DARK.length];
    });
    rows.sort(function (a, b) {
      return (b.points - a.points) || (b.pct - a.pct) ||
             a.name.localeCompare(b.name, 'bg');
    });
    return rows;
  }

  /* ---- геометрията -------------------------------------------------
     Цялата картина виси на един параметър: u е „колко близо до
     зрителя“. y и ширината са линейни по u и минават през (VX, VY),
     затова умножаването на u по едно и също число е точно движение
     напред. Оттам идва и анимацията.                                  */

  var VX = 600, VY = 252, YB = 690, WB = 760;
  var STEP = 1.30;                       /* разстояние между две ленти */
  function rY(u) { return VY + (YB - VY) * u; }
  function rW(u) { return WB * u; }

  function rand(seed) {
    return function () {
      seed |= 0; seed = seed + 0x6D2B79F5 | 0;
      var t = Math.imul(seed ^ seed >>> 15, 1 | seed);
      t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t;
      return ((t ^ t >>> 14) >>> 0) / 4294967296;
    };
  }

  function sky() {
    var rnd = rand(20260928), out = [], i;
    out.push('<ellipse cx="300" cy="120" rx="330" ry="150" fill="#6B4BC8" opacity=".24" filter="url(#rBlur)"/>');
    out.push('<ellipse cx="960" cy="90" rx="260" ry="120" fill="#199e70" opacity=".16" filter="url(#rBlur)"/>');
    out.push('<ellipse cx="600" cy="258" rx="540" ry="74" fill="#F7AD19" opacity=".30" filter="url(#rBlur)"/>');
    /* Звездите са постоянни, защото зърното е постоянно — иначе всяко
       прерисуване щеше да пренарежда небето пред очите на детето. */
    for (i = 0; i < 130; i++) {
      out.push('<circle class="tla-race__star" cx="' + Math.round(rnd() * 1200) +
               '" cy="' + Math.round(rnd() * 246) +
               '" r="' + (0.7 + rnd() * 1.6).toFixed(1) +
               '" fill="#FFFFFF" style="animation-delay:' + (rnd() * 4).toFixed(2) + 's"/>');
    }
    /* Планета с пръстен: задната половина на пръстена, после тялото,
       после предната — така пръстенът наистина минава зад планетата.
       Стои вляво от средата, но не чак в ъгъла: на телефон картината се
       реже отстрани и ъглите изчезват. */
    out.push(
      '<g class="tla-race__planet">' +
      '<ellipse cx="420" cy="118" rx="128" ry="27" fill="none" stroke="#7FD8C4" stroke-width="7" opacity=".55" transform="rotate(-17 420 118)"/>' +
      '<circle cx="420" cy="118" r="76" fill="url(#rPlanet)"/>' +
      '<path d="M 420 42 a 76 76 0 0 0 0 152 a 60 76 0 0 1 0 -152" fill="#0A0F22" opacity=".45"/>' +
      '<clipPath id="rRingFront"><rect x="284" y="118" width="280" height="80"/></clipPath>' +
      '<g clip-path="url(#rRingFront)">' +
      '<ellipse cx="420" cy="118" rx="128" ry="27" fill="none" stroke="#9FE7D6" stroke-width="7" opacity=".85" transform="rotate(-17 420 118)"/>' +
      '</g></g>');
    out.push('<g class="tla-race__planet tla-race__planet--b">' +
      '<circle cx="800" cy="86" r="42" fill="url(#rPlanetB)"/>' +
      '<path d="M 800 44 a 42 42 0 0 0 0 84 a 30 42 0 0 1 0 -84" fill="#0A0F22" opacity=".5"/>' +
      '</g>');
    out.push('<circle cx="690" cy="196" r="15" fill="#D8DEEC" opacity=".9"/>' +
      '<circle cx="684" cy="192" r="4" fill="#A8B2C8" opacity=".8"/>');
    return out.join('');
  }

  /* Лентите и бордюрите се нареждат по геометрична прогресия на u,
     затова групата се самоизобразява при умножение по STEP². Точно
     това умножение прави анимацията — и цикълът се затваря без скок.
     (STEP², а не STEP, защото бордюрите се редуват по цвят.) */
  function road() {
    var out = [], i, u, u2, w1, w2, y1, y2, inner = 0.90;
    for (i = 0; i < 15; i++) {
      u = 0.99 / Math.pow(STEP, i);
      u2 = u * 0.74;
      y1 = rY(u).toFixed(1); y2 = rY(u2).toFixed(1);
      w1 = rW(u) * 0.014; w2 = rW(u2) * 0.014;
      out.push('<polygon points="' + (VX - w1).toFixed(1) + ',' + y1 +
               ' ' + (VX + w1).toFixed(1) + ',' + y1 +
               ' ' + (VX + w2).toFixed(1) + ',' + y2 +
               ' ' + (VX - w2).toFixed(1) + ',' + y2 +
               '" fill="#E8EDF8" opacity=".85"/>');
      var col = (i % 2 === 0) ? '#C9302C' : '#F2F5FB';
      [-1, 1].forEach(function (sgn) {
        var a = VX + sgn * rW(u) * inner, b = VX + sgn * rW(u);
        var c = VX + sgn * rW(u2), d = VX + sgn * rW(u2) * inner;
        out.push('<polygon points="' + a.toFixed(1) + ',' + y1 + ' ' + b.toFixed(1) + ',' + y1 +
                 ' ' + c.toFixed(1) + ',' + y2 + ' ' + d.toFixed(1) + ',' + y2 +
                 '" fill="' + col + '" opacity=".92"/>');
      });
    }
    return out.join('');
  }

  /* Финалът: карирана лента напряко на пистата, точно под водача. */
  function finish() {
    var out = [], uA = 0.995, uM = 0.945, uB = 0.895, cols = 18, i, r;
    for (r = 0; r < 2; r++) {
      var u1 = r === 0 ? uA : uM, u2 = r === 0 ? uM : uB;
      var y1 = rY(u1).toFixed(1), y2 = rY(u2).toFixed(1);
      for (i = 0; i < cols; i++) {
        var f1 = -1 + 2 * i / cols, f2 = -1 + 2 * (i + 1) / cols;
        out.push('<polygon points="' +
          (VX + f1 * rW(u1)).toFixed(1) + ',' + y1 + ' ' +
          (VX + f2 * rW(u1)).toFixed(1) + ',' + y1 + ' ' +
          (VX + f2 * rW(u2)).toFixed(1) + ',' + y2 + ' ' +
          (VX + f1 * rW(u2)).toFixed(1) + ',' + y2 +
          '" fill="' + (((i + r) % 2) ? '#F5F8FF' : '#0E1526') + '"/>');
      }
    }
    var yl = (rY(0.895) - 12).toFixed(1);
    [-1, 1].forEach(function (sgn) {
      out.push('<text class="tla-race__finish" x="' + (VX + sgn * rW(0.895) * 0.62).toFixed(0) +
               '" y="' + yl + '" text-anchor="middle">ФИНАЛ</text>');
    });
    return out.join('');
  }

  /* Една кола, в свои координати: земята е y = 0, колата расте нагоре
     до -119, половин ширина 106. Големината после я дава само scale(). */
  function car(c, d, no) {
    return '' +
      '<ellipse cx="0" cy="-4" rx="96" ry="14" fill="#04070F" opacity=".55"/>' +
      '<rect x="-64" y="-115" width="128" height="15" rx="3" fill="' + c + '"/>' +
      '<rect x="-64" y="-101" width="128" height="4" fill="' + d + '"/>' +
      '<rect x="-70" y="-119" width="9" height="27" rx="2" fill="' + d + '"/>' +
      '<rect x="61"  y="-119" width="9" height="27" rx="2" fill="' + d + '"/>' +
      '<path d="M -17 -93 L 17 -93 L 13 -46 L -13 -46 Z" fill="' + c + '"/>' +
      '<path d="M 0 -93 L 17 -93 L 13 -46 L 0 -46 Z" fill="' + d + '" opacity=".5"/>' +
      '<path d="M -52 -58 q -9 0 -9 9 l 0 15 q 0 9 9 9 l 29 0 l 5 -33 z" fill="' + c + '"/>' +
      '<path d="M  52 -58 q  9 0  9 9 l 0 15 q 0 9 -9 9 l -29 0 l -5 -33 z" fill="' + d + '"/>' +
      '<path d="M -20 -60 q 0 -23 20 -23 q 20 0 20 23" fill="none" stroke="#C9D4E8" stroke-width="5"/>' +
      '<ellipse cx="0" cy="-70" rx="14" ry="12" fill="#E9EEF8"/>' +
      '<path d="M -12 -73 q 12 -7 24 0 l 0 7 q -12 5 -24 0 z" fill="#0D1B36"/>' +
      '<path d="M -13 -46 L 13 -46 L 9 -13 L -9 -13 Z" fill="' + c + '"/>' +
      '<g fill="#10151F">' +
      '<rect x="-90" y="-67" width="35" height="62" rx="11"/>' +
      '<rect x="55"  y="-67" width="35" height="62" rx="11"/>' +
      '</g>' +
      '<rect x="-86" y="-59" width="27" height="12" rx="6" fill="#2B3446"/>' +
      '<rect x="59"  y="-59" width="27" height="12" rx="6" fill="#2B3446"/>' +
      '<rect x="-100" y="-19" width="200" height="10" rx="3" fill="' + c + '"/>' +
      '<rect x="-100" y="-10" width="200" height="5" rx="2" fill="' + d + '"/>' +
      '<rect x="-106" y="-31" width="11" height="27" rx="3" fill="' + d + '"/>' +
      '<rect x="95"   y="-31" width="11" height="27" rx="3" fill="' + d + '"/>' +
      '<circle cx="0" cy="-31" r="12.5" fill="#FFFFFF"/>' +
      '<text class="tla-race__no" x="0" y="-26" text-anchor="middle">' + no + '</text>';
  }

  /* Местата в дълбочина. Първият е най-едър и най-близо до финала,
     останалите се редят зад него — вляво и вдясно през едно. */
  var U    = [0.93, 0.72, 0.565, 0.45, 0.365, 0.30];
  var LANE = [0.00, -0.46, 0.46, -0.82, 0.82, 0.02];
  /* Изправената картина на телефона показва само средната ивица от
     платното. Затова там колите се събират към средата и са малко
     по-дребни — иначе предното крило на втория увисва извън кадъра. */
  var LANE_N = [0.00, -0.28, 0.28];

  function hits(a, b) {
    return a.x < b.x + b.w + 8 && b.x < a.x + a.w + 8 &&
           a.y < b.y + b.h + 6 && b.y < a.y + a.h + 6;
  }

  /* Надписите се разполагат от водача назад: неговият е на мястото си,
     а всеки следващ, ако попадне върху вече поставен, се изтласква
     навън от центъра и чак ако и там няма място — нагоре. Това е
     разликата между картина, която работи за всяко име, и такава,
     нагласена за едни конкретни деца. */
  function placeTag(placed, x0, y0, w, h) {
    var dir = (x0 + w / 2) < VX ? -1 : 1, lift, k, x, y, box;
    for (lift = 0; lift < 4; lift++) {
      y = Math.max(y0 - lift * 46, 6);
      for (k = 0; k < 26; k++) {
        x = Math.min(Math.max(x0 + dir * k * 24, 8), 1192 - w);
        box = { x: x, y: y, w: w, h: h };
        if (!placed.some(function (b) { return hits(b, box); })) return box;
      }
    }
    return { x: Math.min(Math.max(x0, 8), 1192 - w), y: Math.max(y0, 6), w: w, h: h };
  }

  function scene(rows) {
    var narrow = window.innerWidth < 720;
    var lanes = narrow ? LANE_N : LANE;
    var size  = narrow ? 1.6 : 1.9;
    var on = rows.slice(0, onTrack());
    var cars = [], tags = [], i;

    /* Рисува се отзад напред: по-близката кола покрива по-далечната,
       точно както се вижда с очи. */
    for (i = on.length - 1; i >= 0; i--) {
      var r = on[i], u = U[i], sc = u * size;
      var x = VX + lanes[i] * rW(u), y = rY(u);
      var top = y - 119 * sc;

      cars.push('<path d="M ' + (x - 46 * sc).toFixed(1) + ' ' + (top + 10 * sc).toFixed(1) +
                ' L ' + (x + 46 * sc).toFixed(1) + ' ' + (top + 10 * sc).toFixed(1) +
                ' L ' + (x + 16 * sc).toFixed(1) + ' ' + (top - 120 * sc).toFixed(1) +
                ' L ' + (x - 16 * sc).toFixed(1) + ' ' + (top - 120 * sc).toFixed(1) +
                ' Z" fill="url(#rTrail)"/>');

      cars.push('<g class="tla-race__car' + (r.mine ? ' tla-race__car--me' : '') +
        '" style="animation-delay:' + (i * 0.09).toFixed(2) + 's">' +
        '<g transform="translate(' + x.toFixed(1) + ',' + y.toFixed(1) + ') scale(' + sc.toFixed(3) + ')">' +
        (i === 0 ? '<ellipse cx="0" cy="-6" rx="112" ry="20" fill="#F7AD19" opacity=".30" filter="url(#rBlur)"/>' : '') +
        car(r.color, r.dark, i + 1) +
        '<text class="tla-race__livery" x="0" y="-103.5" text-anchor="middle">' +
          esc(r.short) + '</text>' +
        '</g></g>');
    }

    /* Надписът НЕ се смалява с колата: далечната кола е малка, но името
       ѝ трябва да се чете. Затова той живее извън scale(). */
    var placed = [];
    for (i = 0; i < on.length; i++) {
      var rr = on[i], uu = U[i], ss = uu * size;
      var cx = VX + lanes[i] * rW(uu), cy = rY(uu) - 119 * ss;
      var l1 = pos(i + 1) + ' · ' + rr.name + (rr.mine ? ' (ти)' : '');
      var l2 = starsText(rr.stars) + '  ·  ' + num(rr.points) + ' т.';
      var w = Math.max(l1.length * 7.6, l2.length * 7.2) + 26;
      var box = placeTag(placed, cx - w / 2, cy - 44, w, 36);
      placed.push(box);
      tags.push('<g class="tla-race__tag" style="animation-delay:' + (0.35 + i * 0.09).toFixed(2) + 's">' +
        '<rect x="' + box.x.toFixed(1) + '" y="' + box.y.toFixed(1) + '" width="' + w.toFixed(1) +
          '" height="36" rx="10" fill="#080E1E" fill-opacity=".88" stroke="' +
          (rr.mine ? '#F7AD19' : '#33477A') + '" stroke-width="' + (rr.mine ? '2' : '1') + '"/>' +
        '<rect x="' + box.x.toFixed(1) + '" y="' + (box.y + 7).toFixed(1) +
          '" width="5" height="22" rx="2.5" fill="' + rr.color + '"/>' +
        '<text class="tla-race__tagname" x="' + (box.x + 14).toFixed(1) + '" y="' + (box.y + 16).toFixed(1) + '">' +
          esc(l1) + '</text>' +
        '<text class="tla-race__tagsub" x="' + (box.x + 14).toFixed(1) + '" y="' + (box.y + 29).toFixed(1) + '">' +
          esc(l2) + '</text>' +
        '</g>');
    }

    return '' +
      '<svg class="tla-race__svg" viewBox="0 0 1200 690" role="img" ' +
        'xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="' +
        (narrow ? 'xMidYMax slice' : 'xMidYMid meet') + '">' +
      '<defs>' +
        '<linearGradient id="rSky" x1="0" y1="0" x2="0" y2="1">' +
          '<stop offset="0" stop-color="#04060F"/><stop offset=".55" stop-color="#0D1B36"/>' +
          '<stop offset="1" stop-color="#27407C"/></linearGradient>' +
        '<linearGradient id="rRoad" x1="0" y1="0" x2="0" y2="1">' +
          '<stop offset="0" stop-color="#26355C"/><stop offset=".45" stop-color="#141C33"/>' +
          '<stop offset="1" stop-color="#0A0F1E"/></linearGradient>' +
        '<radialGradient id="rPlanet" cx=".35" cy=".3">' +
          '<stop offset="0" stop-color="#A88CF0"/><stop offset="1" stop-color="#3B2A78"/></radialGradient>' +
        '<radialGradient id="rPlanetB" cx=".35" cy=".3">' +
          '<stop offset="0" stop-color="#F2A15C"/><stop offset="1" stop-color="#8C3A22"/></radialGradient>' +
        '<linearGradient id="rTrail" x1="0" y1="1" x2="0" y2="0">' +
          '<stop offset="0" stop-color="#9FB6E8" stop-opacity=".40"/>' +
          '<stop offset="1" stop-color="#9FB6E8" stop-opacity="0"/></linearGradient>' +
        '<filter id="rBlur" x="-50%" y="-50%" width="200%" height="200%">' +
          '<feGaussianBlur stdDeviation="26"/></filter>' +
        '<clipPath id="rClip"><rect x="0" y="0" width="1200" height="690"/></clipPath>' +
      '</defs>' +
      '<g clip-path="url(#rClip)">' +
        '<rect width="1200" height="690" fill="url(#rSky)"/>' +
        sky() +
        '<polygon points="600,252 1360,690 -160,690" fill="url(#rRoad)"/>' +
        '<g class="tla-race__rush">' + road() + '</g>' +
        finish() +
        cars.join('') +
        tags.join('') +
      '</g></svg>';
  }

  /* Класирането под картината — същото с думи и числа. */
  function standings(rows) {
    return rows.map(function (r, i) {
      var medal = i < 3 ? ' tla-grid__pos--' + (i + 1) : '';
      return '<li class="tla-grid__row' + (r.mine ? ' tla-grid__row--me' : '') + '">' +
        '<span class="tla-grid__pos' + medal + '">' + esc(pos(i + 1)) + '</span>' +
        '<span class="tla-grid__dot" style="background:' + esc(r.color) + '"></span>' +
        '<span class="tla-grid__name">' + esc(r.name) +
          (r.mine ? ' <span class="tla-grid__me">ти</span>' : '') + '</span>' +
        '<span class="tla-grid__stars" title="' + r.stars + ' от 5">' +
          esc(starsText(r.stars)) + '</span>' +
        '<span class="tla-grid__pts">' + esc(num(r.points)) + ' т.</span>' +
        '</li>';
    }).join('');
  }

  /* Редът под картината: колко са, кой клас, кой предмет — и честно
     казано, ако някой е останал извън пистата. */
  function note(rows, what) {
    var nobody = rows.every(function (r) { return !r.done; });
    var extra = rows.length > onTrack()
      ? ' На пистата са първите ' + onTrack() + '; всички са в класирането отдолу.' : '';
    if (rows.length < 2) {
      return 'Засега си сам в тази група — състезанието започва, когато има с кого.';
    }
    return (nobody
      ? 'Още никой от групата не е предал задание — състезанието започва с първото.'
      : 'Класиране на ' + rows.length + ' ученици' + (what ? ', ' + what : '') + '.') + extra;
  }

  /* Пуска анимацията отначало. Скрит елемент не анимира нищо, затова
     картината трябва да се „бутне“ в мига, в който се покаже. */
  function play(box) {
    box.classList.remove('tla-race--go');
    void box.offsetWidth;
    box.classList.add('tla-race--go');
  }

  window.TLARace = {
    COLORS: COLORS, build: build, scene: scene, standings: standings,
    note: note, play: play, onTrack: onTrack, pos: pos,
    starsText: starsText, starsFor: starsFor, num: num, shortName: shortName
  };
})();
