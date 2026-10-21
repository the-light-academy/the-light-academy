/* Анимираните решения за темата от 09.12.2023 г. Както при 2018 и 2020:
   всяка функция рисува СЪСТОЯНИЕТО на стъпка k, а не разликата — така
   връщането назад е безплатно. */
var ANIM = (function () {
  function chip(t, bg, fg) {
    return '<span style="display:inline-block;background:' + (bg || '#EEF0FF') + ';color:' + (fg || '#1F2340') +
      ';border-radius:12px;padding:.35rem .7rem;font-weight:800;font-size:1.05rem">' + t + '</span>';
  }
  function row(h) {
    return '<div style="display:flex;gap:10px;flex-wrap:wrap;align-items:center;justify-content:center">' + h + '</div>';
  }
  var GOLD = '#FFF3DC', GOLDF = '#8A5505', GREEN = '#E6F6EE', GREENF = '#15643C',
      BLUE = '#E7EDFA', BLUEF = '#26406F', GREY = '#F1F2F7', GREYF = '#5A6183';

  return {
    /* Задача 1 — трите числа едно по едно, после изразът.
       k: 0–2 за A, 3–4 за B, 5 за C, 6 за крайния израз. */
    abc: function (host, k) {
      var lines = [];
      if (k === 0) {
        lines.push(row(chip('3125 : 5 − 2125 : 5', GREY, GREYF) + chip('→') +
                       chip('(3125 − 2125) : 5', GOLD, GOLDF)));
        lines.push(row(chip('120 : 2 + 1080 : 2', GREY, GREYF) + chip('→') +
                       chip('(120 + 1080) : 2', GOLD, GOLDF)));
      } else if (k === 1) {
        lines.push(row(chip('1000 : 5 = 200', GOLD, GOLDF) + chip('1200 : 2 = 600', GOLD, GOLDF)));
      } else if (k === 2) {
        lines.push(row(chip('(200 + 600) : 100', GOLD, GOLDF) + chip('=') +
                       chip('800 : 100', GOLD, GOLDF) + chip('=') + chip('A = 8', GREEN, GREENF)));
      } else if (k === 3) {
        lines.push(row(chip('2023 · 12 · 0', GREY, GREYF) + chip('=') + chip('0', GOLD, GOLDF) +
                       chip('255 : 3 = 85', GOLD, GOLDF)));
        lines.push(row(chip('(0 + 85) · 6', GOLD, GOLDF) + chip('=') + chip('510', GOLD, GOLDF)));
      } else if (k === 4) {
        lines.push(row(chip('1445 − B = 510', GOLD, GOLDF) + chip('→') +
                       chip('B = 1445 − 510 = 935', GREEN, GREENF)));
      } else if (k === 5) {
        var digits = ['9', '9', '7', '9', '9', '8'];
        var names = ['стотици<br>хиляди', 'десетки<br>хиляди', 'хиляди', 'стотици', 'десетици', 'единици'];
        var boxes = digits.map(function (d, i) {
          var hot = (i === 2), even = (i === 5);
          return '<div style="flex:0 0 76px;text-align:center">' +
            '<div style="border:2px solid ' + (hot ? GOLDF : (even ? GREENF : 'rgba(31,35,64,.18)')) +
              ';background:' + (hot ? GOLD : (even ? GREEN : '#fff')) +
              ';border-radius:12px;padding:.45rem 0;font-size:1.5rem;font-weight:800">' + d + '</div>' +
            '<div style="font-size:.72rem;color:#5A6183;margin-top:.2rem">' + names[i] + '</div></div>';
        }).join('');
        lines.push('<div style="display:flex;gap:6px;justify-content:center;flex-wrap:wrap">' + boxes + '</div>');
        lines.push('<p class="muted" style="text-align:center;margin-top:.5rem">' +
          'Хилядите са заковани на 7. Останалите цифри са възможно най-големите, а последната ' +
          'трябва да е четна — най-голямата четна цифра е 8.</p>');
        lines.push(row(chip('C = 997 998', GREEN, GREENF)));
      } else {
        lines.push(row(chip('935 : 5 = 187', BLUE, BLUEF) + chip('8 · 11 = 88', BLUE, BLUEF)));
        lines.push(row(chip('187 − 88 = 99', GOLD, GOLDF)));
        lines.push(row(chip('99 + 997 998', GOLD, GOLDF) + chip('=') + chip('998 097', GREEN, GREENF)));
      }
      host.innerHTML = lines.join('<div style="height:8px"></div>');
    },

    /* Задача 2 — дворът: квадратът отляво, правоъгълникът отдясно.
       Чертежът НЕ е по мащаб (както и в оригинала), затова размерите
       се изписват с надписи, а не с дължини. */
    dvor: function (host, k) {
      var X = 30, Y = 26, S = 110, L = 220, H = 110;   /* квадрат S×H, правоъгълник L×H */
      var know = k >= 1;                                /* знаем ли вече 32 */
      var knowL = k >= 2;                               /* знаем ли вече 96 */
      var sq = k >= 3;                                  /* квадратът е в играта */
      var whole = k >= 5;                               /* целият двор */
      var svg =
        '<svg viewBox="0 0 ' + (X * 2 + S + L) + ' 200" width="100%" ' +
          'style="max-width:420px;display:block;margin:0 auto">' +
          '<rect x="' + X + '" y="' + Y + '" width="' + S + '" height="' + H + '" ' +
            'fill="' + (sq ? GREEN : '#FFF9EC') + '" stroke="' + (sq ? GREENF : '#8A5505') + '" stroke-width="3"/>' +
          '<rect x="' + (X + S) + '" y="' + Y + '" width="' + L + '" height="' + H + '" ' +
            'fill="' + (k <= 2 ? GOLD : '#FFF9EC') + '" stroke="#8A5505" stroke-width="3"/>' +
          '<text x="' + (X + S / 2) + '" y="' + (Y + H / 2 + 5) + '" text-anchor="middle" ' +
            'font-size="14" font-weight="700" fill="#1F2340">квадрат</text>' +
          '<text x="' + (X + S + L / 2) + '" y="' + (Y + H / 2 + 5) + '" text-anchor="middle" ' +
            'font-size="14" font-weight="700" fill="#1F2340">правоъгълник</text>' +
          /* общата страна */
          '<line x1="' + (X + S) + '" y1="' + Y + '" x2="' + (X + S) + '" y2="' + (Y + H) + '" ' +
            'stroke="' + (sq ? GREENF : '#1F2340') + '" stroke-width="' + (sq ? 5 : 3) + '"/>' +
          /* надписите по страните */
          (know ? '<text x="' + (X - 8) + '" y="' + (Y + H / 2 + 5) + '" text-anchor="end" ' +
            'font-size="14" font-weight="800" fill="' + GOLDF + '">32 м</text>' : '') +
          (knowL ? '<text x="' + (X + S + L / 2) + '" y="' + (Y + H + 22) + '" text-anchor="middle" ' +
            'font-size="14" font-weight="800" fill="' + GOLDF + '">96 м</text>' : '') +
          (sq ? '<text x="' + (X + S / 2) + '" y="' + (Y + H + 22) + '" text-anchor="middle" ' +
            'font-size="14" font-weight="800" fill="' + GREENF + '">32 м</text>' : '') +
          (whole ? '<text x="' + (X + (S + L) / 2) + '" y="' + (Y - 8) + '" text-anchor="middle" ' +
            'font-size="14" font-weight="800" fill="' + BLUEF + '">128 м = 96 + 32</text>' : '') +
          (k >= 7 ? '<rect x="' + (X + S + L - 56) + '" y="' + (Y + H - 5) + '" width="46" height="10" ' +
            'rx="4" fill="#9B2226"/><text x="' + (X + S + L - 33) + '" y="' + (Y + H + 30) + '" ' +
            'text-anchor="middle" font-size="13" font-weight="800" fill="#9B2226">врата 3 м</text>' : '') +
        '</svg>';
      var note =
        (k === 0 ? row(chip('8 части = 256 м', GOLD, GOLDF)) :
         k === 1 ? row(chip('256 : 8 = 32 м — ширината', GREEN, GREENF)) :
         k === 2 ? row(chip('32 · 3 = 96 м — дължината', GREEN, GREENF)) :
         k === 3 ? row(chip('страната на квадрата е общата страна: 32 м', GOLD, GOLDF)) :
         k === 4 ? row(chip('4 · 32 = 128 м — обиколка на квадрата', GREEN, GREENF)) :
         k === 5 ? row(chip('дворът е 128 м на 32 м', BLUE, BLUEF)) :
         k === 6 ? row(chip('2 · (128 + 32) = 320 м', GOLD, GOLDF)) :
                   row(chip('320 − 3 = 317 м мрежа', GREEN, GREENF)));
      host.innerHTML = svg + '<div style="height:8px"></div>' + note;
    },

    /* Задача 3 — трите състезания като кръгове, които се застъпват.
       Числата влизат едно по едно, точно по реда на решението. */
    venn: function (host, k) {
      function circ(cx, cy, r, fill) {
        return '<circle cx="' + cx + '" cy="' + cy + '" r="' + r + '" fill="' + fill +
          '" fill-opacity=".45" stroke="#1F2340" stroke-width="2"/>';
      }
      function txt(x, y, t, big, color) {
        return '<text x="' + x + '" y="' + y + '" text-anchor="middle" font-size="' + (big ? 20 : 12) +
          '" font-weight="' + (big ? 800 : 700) + '" fill="' + (color || '#1F2340') + '">' + t + '</text>';
      }
      var only1 = k >= 3 ? '22' : '?';
      var onlyO = k >= 4 ? '35' : '?';
      var onlyK = k >= 5 ? '12' : '?';
      var ok = k >= 2 ? '24' : '?';
      var svg =
        '<svg viewBox="0 0 440 250" width="100%" style="max-width:440px;display:block;margin:0 auto">' +
          circ(140, 100, 72, '#FFD9A8') + circ(240, 100, 72, '#A8C6FF') + circ(190, 175, 72, '#B8ECCB') +
          txt(96, 102, only1, true) +
          txt(285, 102, onlyO, true) +
          txt(190, 215, onlyK, true) +
          txt(190, 95, '15', true, '#8A5505') +
          txt(228, 156, ok, true, '#15643C') +
          (k >= 3 ? txt(152, 156, '0', true, '#9B2226') : '') +
          txt(140, 40, 'турнир', false) +
          txt(252, 40, 'олимпиада', false) +
          txt(190, 240, 'коледно', false) +
          txt(392, 40, '29 извън', false, '#5A6183') +
          (k >= 3 ? txt(152, 176, 'няма данни', false, '#9B2226') : '') +
        '</svg>';
      var note =
        (k === 0 ? row(chip('37 · 2 = 74 в олимпиадата', GOLD, GOLDF)) :
         k === 1 ? row(chip('74 − 38 = 36 в коледното', GOLD, GOLDF)) :
         k === 2 ? row(chip('15 + 9 = 24 в олимпиадата и коледното', GOLD, GOLDF)) :
         k === 3 ? row(chip('37 − 15 = 22 само в турнира', BLUE, BLUEF)) :
         k === 4 ? row(chip('74 − 15 − 24 = 35 само в олимпиадата', BLUE, BLUEF)) :
         k === 5 ? row(chip('36 − 24 = 12 само в коледното', BLUE, BLUEF)) :
                   row(chip('22 + 15 + 35 + 24 + 12 + 29 = 137', GREEN, GREENF)));
      host.innerHTML = svg + note;
    }
  };
})();
