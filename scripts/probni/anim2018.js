/* Анимираните решения за 2018. Всяка функция рисува СЪСТОЯНИЕТО на
   стъпка k — не разликата спрямо предишната. Така редът няма значение
   и повторното рисуване е безопасно. */
var ANIM = (function () {
  function box(h) { return '<div style="display:flex;gap:10px;flex-wrap:wrap;align-items:center">' + h + '</div>'; }
  function chip(t, bg, fg) {
    return '<span style="display:inline-block;background:' + (bg || '#EEF0FF') + ';color:' + (fg || '#1F2340') +
      ';border-radius:12px;padding:.35rem .7rem;font-weight:800;font-size:1.05rem">' + t + '</span>';
  }
  var GOLD = '#FFF3DC', GOLDF = '#8A5505', GREEN = '#E6F6EE', GREENF = '#15643C';

  return {
    /* 1а — трите произведения се сливат в 7 · 100 */
    g7: function (host, k) {
      var h = '';
      if (k === 0) {
        h = box(chip('12 · 7') + chip('+') + chip('13 · 7') + chip('+') + chip('75 · 7')) +
            '<p class="muted" style="margin-top:.5rem">И трите са „нещо · 7“.</p>';
      } else if (k === 1) {
        h = box(chip('7 · (12 + 13 + 75)', GOLD, GOLDF) + chip('=') + chip('7 · 100', GOLD, GOLDF) +
                chip('=') + chip('700', GREEN, GREENF));
      } else if (k === 2) {
        h = box(chip('700') + chip('+') + chip('219 : 3 = 73') + chip('=') + chip('773', GOLD, GOLDF));
      } else {
        h = box(chip('2018') + chip('−') + chip('773') + chip('=') + chip('1245', GREEN, GREENF)) +
            '<p class="muted" style="margin-top:.5rem">Отговор: <b>1245</b>.</p>';
      }
      host.innerHTML = h;
    },

    /* 1б — таблица на разредите с буквите отгоре */
    digits: function (host, k) {
      var names = ['стотици хиляди', 'десетохиляди', 'хиляди', 'стотици', 'десетици', 'единици'];
      var ds = ['3', '0', '5', '7', '1', '4'];
      var letters = ['', 'a', 'b', 'c', 'd', ''];
      var cells = ds.map(function (d, i) {
        var lit = (k >= 1 && letters[i]);
        return '<td style="text-align:center;padding:.3rem .5rem;border:1px solid rgba(31,35,64,.15);' +
          (lit ? 'background:' + GOLD : '') + '">' +
          '<div style="font-size:.7rem;color:#5A6183">' + names[i] + '</div>' +
          '<div style="font-size:1.5rem;font-weight:800">' + d + '</div>' +
          '<div style="font-weight:800;color:' + GOLDF + ';min-height:1.2em">' +
            (lit ? letters[i] : '&nbsp;') + '</div></td>';
      }).join('');
      host.innerHTML = '<table style="border-collapse:collapse;margin:0 auto"><tr>' + cells + '</tr></table>' +
        (k >= 2 ? '<p style="margin-top:.6rem;text-align:center">' +
          chip('5 · 7', GOLD, GOLDF) + ' <b>−</b> ' + chip('0 · 1', GOLD, GOLDF) + ' <b>=</b> ' +
          chip('35', GREEN, GREENF) + '</p>' : '');
    },

    /* 1в — веригата се развива наобратно */
    chain: function (host, k) {
      var fwd = box(chip('x') + chip('→ 73 − x') + chip('→ · 5') + chip('→ − 16') + chip('= 344', GOLD, GOLDF));
      var rows = [
        '<b>+ 16</b> → (73 − x) · 5 = ' + chip('360', GOLD, GOLDF),
        '<b>: 5</b> → 73 − x = ' + chip('72', GOLD, GOLDF),
        '<b>73 − 72</b> → x = ' + chip('1', GREEN, GREENF)
      ].slice(0, k + 1);
      host.innerHTML = fwd + '<div style="margin-top:.6rem;display:grid;gap:6px">' +
        rows.map(function (r) {
          return '<div style="background:#F8F7FF;border-radius:10px;padding:.4rem .7rem">' + r + '</div>';
        }).join('') + '</div>';
    },

    /* 2а — правоъгълникът, разделен на 8 равни части */
    rect: function (host, k) {
      var W = 480, H = 160, x0 = 20, y0 = 20, w = 420, h = 140;
      var seg = w / 3;                       /* дължината е 3 части */
      var marks = '';
      if (k >= 1) {
        for (var i = 1; i < 3; i++) {
          marks += '<line x1="' + (x0 + seg * i) + '" y1="' + y0 + '" x2="' + (x0 + seg * i) +
            '" y2="' + (y0 + h) + '" stroke="#F7AD19" stroke-width="2" stroke-dasharray="5 4"/>';
        }
      }
      var labels = '<text x="' + (x0 + w / 2) + '" y="' + (y0 + h + 22) + '" text-anchor="middle" ' +
          'font-size="15" font-weight="700" fill="#1F2340">дължина = 3 части' +
          (k >= 2 ? ' = 126 м' : '') + '</text>' +
        '<text x="' + (x0 - 8) + '" y="' + (y0 + h / 2) + '" text-anchor="end" font-size="15" ' +
          'font-weight="700" fill="#1F2340">' + (k >= 1 ? '42 м' : '1 част') + '</text>';
      host.innerHTML = '<svg viewBox="0 0 ' + W + ' ' + (H + 40) + '" width="100%" style="max-width:520px">' +
        '<rect x="' + x0 + '" y="' + y0 + '" width="' + w + '" height="' + h + '" rx="8" ' +
          'fill="#FFF9EC" stroke="#8A5505" stroke-width="2.5"/>' + marks + labels + '</svg>' +
        (k >= 1 ? '<p style="margin-top:.4rem;text-align:center">' +
          chip('336 : 8', GOLD, GOLDF) + ' <b>=</b> ' + chip('42 м', GREEN, GREENF) + '</p>' : '') +
        (k >= 3 ? '<p style="margin-top:.4rem;text-align:center">' +
          chip('126 − 42', GOLD, GOLDF) + ' <b>=</b> ' + chip('84 м', GREEN, GREENF) + '</p>' : '');
    },

    /* 2б — храстите се засаждат по дългата страна */
    bushes: function (host, k) {
      var n = 9, W = 520, y = 46, x0 = 30, step = (W - 2 * x0) / (n - 1);
      var dots = '', gaps = '';
      for (var i = 0; i < n; i++) {
        var x = x0 + step * i;
        dots += '<circle cx="' + x + '" cy="' + y + '" r="9" fill="#2F7A4F"/>' +
                '<rect x="' + (x - 2) + '" y="' + y + '" width="4" height="12" fill="#7A5A3A"/>';
        if (i < n - 1 && k >= 1) {
          gaps += '<text x="' + (x + step / 2) + '" y="' + (y - 16) + '" text-anchor="middle" ' +
            'font-size="12" fill="#8A5505">2 м</text>';
        }
      }
      host.innerHTML = '<svg viewBox="0 0 ' + W + ' 86" width="100%" style="max-width:560px">' +
        '<line x1="' + x0 + '" y1="' + (y + 14) + '" x2="' + (W - x0) + '" y2="' + (y + 14) +
          '" stroke="#C9B48F" stroke-width="5" stroke-linecap="round"/>' + gaps + dots +
        '<text x="' + (W / 2) + '" y="80" text-anchor="middle" font-size="13" fill="#5A6183">' +
          '… и така до края на 126-те метра …</text></svg>' +
        (k >= 1 ? '<p style="margin-top:.4rem;text-align:center">' +
          chip('126 : 2 = 63 разстояния', GOLD, GOLDF) + ' <b>→</b> ' +
          chip('63 + 1 = 64 храста', GREEN, GREENF) + '</p>' +
          '<p class="muted" style="text-align:center;margin-top:.3rem">' +
          'Има храст и в двата края, затова храстите са с един повече от разстоянията.</p>' : '');
    },

    /* 3 — трите сметки се събират, делят на две и се вадят една по една */
    bills: function (host, k) {
      function bill(who, what, sum, dim) {
        return '<div style="flex:0 0 150px;background:#fff;border:1.5px dashed #C9B48F;border-radius:12px;' +
          'padding:.6rem;text-align:center;' + (dim ? 'opacity:.4;' : '') + '">' +
          '<div style="font-size:.8rem;color:#5A6183">' + who + '</div>' +
          '<div style="font-size:1.6rem;line-height:1.3">' + what + '</div>' +
          '<div style="font-weight:800">' + sum + ' ст.</div></div>';
      }
      var three = box(bill('мама', '☕🍰', 660, k >= 2) + bill('татко', '☕🥪', 505, k >= 2) +
                      bill('Тони', '🥪🍰', 925, k >= 2));
      var h = three;
      if (k >= 0 && k < 1) {
        h += '<p style="margin-top:.5rem;text-align:center">' +
          chip('660 + 505 + 925 = 2090 ст.', GOLD, GOLDF) + '</p>';
      }
      if (k >= 1) {
        h += '<p style="margin-top:.5rem;text-align:center">' +
          chip('2 · ☕ + 2 · 🥪 + 2 · 🍰 = 2090', GOLD, GOLDF) + ' <b>→</b> ' +
          chip('☕ + 🥪 + 🍰 = 1045', GREEN, GREENF) + '</p>';
      }
      var lines = [
        ['1045 − 660 (мама: ☕🍰)', '🥪 = 385 ст. = 3 лв. 85 ст.'],
        ['1045 − 925 (Тони: 🥪🍰)', '☕ = 120 ст. = 1 лв. 20 ст.'],
        ['1045 − 505 (татко: ☕🥪)', '🍰 = 540 ст. = 5 лв. 40 ст.']
      ].slice(0, Math.max(0, k - 1));
      if (lines.length) {
        h += '<div style="margin-top:.6rem;display:grid;gap:6px">' + lines.map(function (r) {
          return '<div style="background:#F8F7FF;border-radius:10px;padding:.4rem .7rem">' +
            r[0] + ' <b>→</b> ' + chip(r[1], GREEN, GREENF) + '</div>';
        }).join('') + '</div>';
      }
      host.innerHTML = h;
    }
  };
})();
