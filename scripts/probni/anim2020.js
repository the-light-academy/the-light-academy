/* Анимираните решения за 2020. Както и при 2018: всяка функция рисува
   състоянието на стъпка k, а не разликата. */
var ANIM = (function () {
  function chip(t, bg, fg) {
    return '<span style="display:inline-block;background:' + (bg || '#EEF0FF') + ';color:' + (fg || '#1F2340') +
      ';border-radius:12px;padding:.35rem .7rem;font-weight:800;font-size:1.05rem">' + t + '</span>';
  }
  function row(h) { return '<div style="display:flex;gap:10px;flex-wrap:wrap;align-items:center;justify-content:center">' + h + '</div>'; }
  var GOLD = '#FFF3DC', GOLDF = '#8A5505', GREEN = '#E6F6EE', GREENF = '#15643C',
      RED = '#FCEBEA', REDF = '#9B2226';

  return {
    /* 1А — двете произведения по 9 се сливат */
    g9: function (host, k) {
      var h;
      if (k === 0) h = row(chip('21 · 9') + chip('+') + chip('29 · 9')) +
        '<div style="height:8px"></div>' +
        row(chip('(21 + 29) · 9', GOLD, GOLDF) + chip('=') + chip('50 · 9', GOLD, GOLDF) +
            chip('=') + chip('450', GREEN, GREENF));
      else if (k === 1) h = row(chip('450 : 5', GOLD, GOLDF) + chip('=') + chip('90', GREEN, GREENF));
      else h = row(chip('2129') + chip('−') + chip('90') + chip('=') + chip('2039', GREEN, GREENF));
      host.innerHTML = h;
    },

    /* 1Б — картите с двойките цифри */
    pairs: function (host, k) {
      var data = [[3,0],[4,1],[5,2],[6,3],[7,4],[8,5],[9,6]];
      var cards = data.map(function (p) {
        var s = p[0] + p[1], h = 11 - s;
        var dead = (h <= 0);
        var show = k >= 1 && dead;
        var win = k >= 3 && p[0] === 6;
        var bg = win ? GREEN : (show ? RED : '#fff');
        var bd = win ? GREENF : (show ? REDF : 'rgba(31,35,64,.18)');
        return '<div style="flex:0 0 86px;border:2px solid ' + bd + ';background:' + bg +
          ';border-radius:12px;padding:.5rem .3rem;text-align:center;position:relative">' +
          '<div style="font-size:1.5rem;font-weight:800">' + p[0] + p[1] + '</div>' +
          (k >= 1 ? '<div style="font-size:.78rem;color:#5A6183">сбор ' + s + '</div>' : '') +
          (k >= 2 ? '<div style="font-size:.78rem;font-weight:800;color:' + (dead ? REDF : GOLDF) + '">' +
            (dead ? 'за стотиците<br>не остава' : 'стотици ' + h) + '</div>' : '') +
          (show ? '<div style="position:absolute;inset:0;display:flex;align-items:center;' +
            'justify-content:center;font-size:2rem;color:' + REDF + '">✕</div>' : '') +
          '</div>';
      }).join('');
      host.innerHTML = '<div style="display:flex;gap:8px;flex-wrap:wrap;justify-content:center">' +
        cards + '</div>' +
        (k >= 1 ? '<p class="muted" style="text-align:center;margin-top:.5rem">' +
          'Зачеркнатите искат 0 или по-малко стотици — тогава числото не е трицифрено.</p>' : '') +
        (k >= 3 ? '<p style="text-align:center;margin-top:.5rem">' +
          chip('2 · 100 + 6 · 10 + 3 = 263', GREEN, GREENF) + '</p>' : '');
    },

    /* 2 — квадратите от клечки и сборът на обиколките */
    squares: function (host, k) {
      var n = (k <= 1) ? 3 : 10;
      var u = Math.max(8, Math.floor(150 / n));
      var side = u * n, pad = 16;
      var sticks = '';
      for (var i = 0; i < n; i++) {
        sticks += '<rect x="' + (pad + u * i + 2) + '" y="' + (pad - 2) + '" width="' + (u - 4) +
          '" height="4" rx="2" fill="#E8CFA0" stroke="#C9A96A"/>';
        sticks += '<rect x="' + (pad + u * i + 2) + '" y="' + (pad + side - 2) + '" width="' + (u - 4) +
          '" height="4" rx="2" fill="#E8CFA0" stroke="#C9A96A"/>';
        sticks += '<rect x="' + (pad - 2) + '" y="' + (pad + u * i + 2) + '" width="4" height="' + (u - 4) +
          '" rx="2" fill="#E8CFA0" stroke="#C9A96A"/>';
        sticks += '<rect x="' + (pad + side - 2) + '" y="' + (pad + u * i + 2) + '" width="4" height="' + (u - 4) +
          '" rx="2" fill="#E8CFA0" stroke="#C9A96A"/>';
      }
      var sum = '';
      if (k >= 2) {
        var parts = [];
        for (var j = 1; j <= 10; j++) parts.push(4 * j);
        sum = '<p style="text-align:center;margin-top:.5rem;font-size:.95rem">' +
          parts.join(' + ') + ' = ' + (k >= 3 ? chip('220 клечки', GOLD, GOLDF) : '…') + '</p>';
      }
      host.innerHTML =
        '<svg viewBox="0 0 ' + (side + pad * 2) + ' ' + (side + pad * 2) + '" width="100%" ' +
          'style="max-width:' + (side + pad * 2) + 'px;display:block;margin:0 auto">' + sticks + '</svg>' +
        '<p style="text-align:center;margin-top:.3rem">' +
          chip('страна ' + n + ' клечки · обиколка ' + (4 * n) + ' клечки', GOLD, GOLDF) + '</p>' +
        (k === 1 ? '<p style="text-align:center;margin-top:.4rem">' +
          chip('4 · (3 · 3 см) = 36 см', GREEN, GREENF) + '</p>' : '') + sum +
        (k >= 4 ? '<p style="text-align:center;margin-top:.4rem">' +
          chip('880 : 220 = 4 см за клечка', GOLD, GOLDF) + '</p>' : '') +
        (k >= 5 ? '<p style="text-align:center;margin-top:.4rem">' +
          chip('40 · 4 = 160 см', GREEN, GREENF) + '</p>' : '');
    },

    /* 3А — равенството се опростява стъпка по стъпка */
    scale: function (host, k) {
      var rows = [
        ['2 · ? + 96 : 4', '8 + 8 · 4'],
        ['2 · ? + 24', '40'],
        ['2 · ?', '16'],
        ['?', '8']
      ].slice(0, k + 2);
      host.innerHTML = '<div style="display:grid;gap:8px;max-width:420px;margin:0 auto">' +
        rows.map(function (r, i) {
          var last = (i === rows.length - 1);
          return '<div style="display:flex;align-items:center;gap:10px;justify-content:center;' +
            'background:' + (last ? GREEN : '#F8F7FF') + ';border-radius:12px;padding:.45rem .7rem">' +
            '<span style="flex:1;text-align:right;font-weight:800">' + r[0] + '</span>' +
            '<span style="font-weight:800;color:#8A5505">=</span>' +
            '<span style="flex:1;font-weight:800">' + r[1] + '</span></div>';
        }).join('') + '</div>';
    },

    /* 3Б — балконът с уред за тегло.
       Скалата върви отляво (0 т) през горе до дясно (42 т). */
    balcony: function (host, k) {
      var bulls = k >= 1 ? 8 : 0;
      var eleph = k >= 1 ? 4 : 0;
      var extra = k <= 2 ? 0 : (k === 3 ? 2 : (k === 4 ? 3 : 4));
      var w = bulls * 1.25 + (eleph + extra) * 4.5;
      var over = w > 42;
      var frac = Math.min(1, w / 42);
      var W = 460, cx = W / 2, cy = 126, R = 92;
      function at(f, r) {
        var a = Math.PI - Math.PI * f;
        return [cx + Math.cos(a) * r, cy + Math.sin(a) * (-r)];
      }
      var ticks = '';
      for (var i = 0; i <= 6; i++) {
        var p1 = at(i / 6, R - 7), p2 = at(i / 6, R + 1), p3 = at(i / 6, R + 15);
        ticks += '<line x1="' + p1[0] + '" y1="' + p1[1] + '" x2="' + p2[0] + '" y2="' + p2[1] +
          '" stroke="#5A6183" stroke-width="2"/>' +
          '<text x="' + p3[0] + '" y="' + (p3[1] + 4) + '" font-size="12" text-anchor="middle" ' +
            'fill="#5A6183">' + (i * 7) + '</text>';
      }
      var n = at(frac, R - 18);
      var arc = 'M' + (cx - R) + ' ' + cy + ' A ' + R + ' ' + R + ' 0 0 1 ' + (cx + R) + ' ' + cy;
      var C = Math.PI * R;
      var animals = '🐂'.repeat(bulls) + (eleph + extra ? ' ' + '🐘'.repeat(eleph + extra) : '');
      host.innerHTML =
        '<svg viewBox="0 0 ' + W + ' 150" width="100%" style="max-width:460px;display:block;margin:0 auto">' +
          '<path d="' + arc + '" fill="none" stroke="rgba(31,35,64,.12)" stroke-width="13"/>' +
          '<path d="' + arc + '" fill="none" stroke="' + (over ? '#9B2226' : '#15643C') +
            '" stroke-width="13" stroke-linecap="round" stroke-dasharray="' + C +
            '" stroke-dashoffset="' + (C * (1 - frac)) + '"/>' + ticks +
          '<line x1="' + cx + '" y1="' + cy + '" x2="' + n[0] + '" y2="' + n[1] + '" stroke="' +
            (over ? '#9B2226' : '#1F2340') + '" stroke-width="4" stroke-linecap="round"/>' +
          '<circle cx="' + cx + '" cy="' + cy + '" r="7" fill="#1F2340"/>' +
        '</svg>' +
        '<p style="text-align:center;margin:.1rem 0 0;font-size:1.3rem;font-weight:800;color:' +
          (over ? REDF : GREENF) + '">' + String(Math.round(w * 10) / 10).replace('.', ',') + ' т</p>' +
        '<p class="muted" style="text-align:center;margin:0">балконът издържа 42 т</p>' +
        (k === 0
          ? '<p style="text-align:center;margin-top:.5rem">' +
              chip('4 бика = 5 т', GOLD, GOLDF) + ' ' + chip('2 слона = 9 т', GOLD, GOLDF) + '</p>'
          : '<p style="text-align:center;font-size:1.35rem;line-height:1.4;margin:.4rem 0 0;' +
            'word-break:break-word">' + animals + '</p>') +
        (k === 2 ? '<p style="text-align:center;margin-top:.3rem">' +
          chip('остават 14 т', GOLD, GOLDF) + '</p>' : '') +
        (k === 5 ? '<p style="text-align:center;margin-top:.4rem">' +
          chip('четвъртият слон прави 46 т — балконът не издържа', RED, REDF) + '</p>' +
          '<p style="text-align:center;margin-top:.3rem">' + chip('отговор: още 3 слона', GREEN, GREENF) +
          '</p>' : '');
    }
  };
})();
