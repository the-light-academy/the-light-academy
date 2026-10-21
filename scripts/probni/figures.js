/* Чертежите по време на теста. Верни на оригинала и нарочно НЕ издават
   отговора: правоъгълникът няма размери по страните си, а квадратите
   от клечки не носят числа. */
var FIGURES = {

  /* 2025, задача 10 — лента от девет триъгълника: петте „нагоре“ са бели,
     четирите „надолу“ са сиви. Числата нарочно ги няма. */
  sal25_lenta: (function () {
    var W = 60, H = 70, y0 = 20, y1 = 20 + H, out = '';
    var i;
    for (i = 0; i < 5; i++) {
      out += '<polygon points="' + (i * W) + ',' + y1 + ' ' + (i * W + W) + ',' + y1 +
        ' ' + (i * W + W / 2) + ',' + y0 + '" fill="#fff" stroke="#1F2340" stroke-width="2"/>';
    }
    for (i = 0; i < 4; i++) {
      out += '<polygon points="' + (i * W + W / 2) + ',' + y0 + ' ' + (i * W + W * 1.5) + ',' + y0 +
        ' ' + (i * W + W) + ',' + y1 + '" fill="#C9CCD8" stroke="#1F2340" stroke-width="2"/>';
    }
    return '<svg viewBox="-10 0 320 110" width="100%" style="max-width:420px" role="img" ' +
      'aria-label="Лента от девет триъгълника: пет бели с върха нагоре и четири сиви с върха надолу.">' +
      out + '</svg>';
  })(),

  /* 2025, задача 12 — гирлянда: три шестоъгълника (всеки от шест
     триъгълника) и два квадрата между тях. */
  sal25_girlanda: (function () {
    var a = 34, h = Math.round(a * Math.sqrt(3) * 100) / 100, out = '';
    function hex(cx, cy) {
      var pts = [], i, ang, x, y, g = '';
      for (i = 0; i < 6; i++) {
        ang = Math.PI / 180 * (60 * i);
        x = cx + a * Math.cos(ang); y = cy + a * Math.sin(ang);
        pts.push(Math.round(x * 10) / 10 + ',' + Math.round(y * 10) / 10);
      }
      g += '<polygon points="' + pts.join(' ') + '" fill="#FFF9EC" stroke="#1F2340" stroke-width="2"/>';
      for (i = 0; i < 6; i++) {
        g += '<line x1="' + cx + '" y1="' + cy + '" x2="' + pts[i].split(',')[0] +
          '" y2="' + pts[i].split(',')[1] + '" stroke="#1F2340" stroke-width="1.4"/>';
      }
      return g;
    }
    function sq(x, cy) {
      return '<rect x="' + x + '" y="' + (cy - a / 2) + '" width="' + a + '" height="' + a +
        '" fill="#fff" stroke="#1F2340" stroke-width="2"/>';
    }
    var cy = 60, step = 2 * a + a;
    out += hex(a + 6, cy) + sq(a * 2 + 6, cy) + hex(a * 4 + 6, cy) +
           sq(a * 5 + 6, cy) + hex(a * 7 + 6, cy);
    return '<svg viewBox="0 0 ' + (a * 8 + 18) + ' 120" width="100%" style="max-width:460px" role="img" ' +
      'aria-label="Гирлянда: три шестоъгълника, всеки съставен от шест еднакви триъгълника, ' +
      'и два квадрата между тях.">' + out + '</svg>';
  })(),

  /* 2024, задача 5 — равнобедрен триъгълник с изрязан правоъгълник до
     основата. Страната b е отбелязана, размери няма. */
  sal24_triugalnik:
    '<svg viewBox="0 0 300 220" width="100%" style="max-width:320px" role="img" ' +
      'aria-label="Равнобедрен триъгълник, от който е изрязан правоъгълник, стъпил на основата. ' +
      'Вертикалната страна на правоъгълника е означена с b.">' +
      '<polygon points="150,20 280,190 20,190" fill="#FFF9EC" stroke="#1F2340" stroke-width="2.5"/>' +
      '<rect x="135" y="130" width="42" height="60" fill="#fff" stroke="#1F2340" stroke-width="2.5"/>' +
      '<text x="128" y="165" text-anchor="end" font-size="18" font-style="italic" fill="#1F2340">b</text>' +
    '</svg>',

  /* 2024, задача 10 — знакът „+“ от девет квадратчета и схемата на
     същата фигура от деветдесет и девет. */
  sal24_plus: (function () {
    var u = 26, out = '', i;
    function cell(cx, cy) {
      return '<rect x="' + cx + '" y="' + cy + '" width="' + u + '" height="' + u +
        '" fill="#fff" stroke="#1F2340" stroke-width="2"/>';
    }
    /* малкият: вертикална лента от 5 и хоризонтална от 5 */
    for (i = 0; i < 5; i++) out += cell(20 + 2 * u, 10 + i * u);
    for (i = 0; i < 5; i++) if (i !== 2) out += cell(20 + i * u, 10 + 2 * u);
    /* схемата на големия — по две квадратчета в краищата и точки */
    var ox = 230;
    for (i = 0; i < 2; i++) out += cell(ox + 2 * u, 10 + i * u);
    for (i = 0; i < 2; i++) out += cell(ox + 2 * u, 10 + (3 + i) * u);
    out += cell(ox, 10 + 2 * u) + cell(ox + u, 10 + 2 * u) +
           cell(ox + 3 * u, 10 + 2 * u) + cell(ox + 4 * u, 10 + 2 * u);
    out += '<text x="' + (ox + 2 * u + u / 2) + '" y="' + (10 + 2 * u + 6) +
      '" text-anchor="middle" font-size="18" fill="#5A6183">⋯</text>';
    out += '<text x="' + (ox + 2 * u + u / 2) + '" y="' + (10 + 2.6 * u) +
      '" text-anchor="middle" font-size="16" fill="#5A6183">⋮</text>';
    return '<svg viewBox="0 0 390 150" width="100%" style="max-width:520px" role="img" ' +
      'aria-label="Вляво: знак плюс от девет еднакви квадратчета. Вдясно: схема на същата ' +
      'форма, но с много по-дълги рамене.">' + out +
      '<text x="85" y="145" text-anchor="middle" font-size="14" fill="#5A6183">9 квадратчета</text>' +
      '<text x="295" y="145" text-anchor="middle" font-size="14" fill="#5A6183">99 квадратчета</text>' +
    '</svg>';
  })(),

  /* 2024, задача 15 — правоъгълник 3 на 4 от единични квадратчета. */
  sal24_mreja: (function () {
    var u = 44, out = '', r, c;
    for (r = 0; r < 3; r++) {
      for (c = 0; c < 4; c++) {
        out += '<rect x="' + (10 + c * u) + '" y="' + (10 + r * u) + '" width="' + u +
          '" height="' + u + '" fill="#fff" stroke="#1F2340" stroke-width="2"/>';
      }
    }
    return '<svg viewBox="0 0 ' + (4 * u + 20) + ' ' + (3 * u + 20) + '" width="100%" ' +
      'style="max-width:260px" role="img" aria-label="Правоъгълник три на четири, ' +
      'разрязан на дванайсет единични квадратчета.">' + out + '</svg>';
  })(),

  /* 2018, задача 2 — площадката: правоъгълник 3:1 и четири храста по
     дългата страна (ъгъл, два съседни, и последният в другия ъгъл). */
  ploshtadka:
    '<svg viewBox="0 0 520 210" width="100%" style="max-width:520px" role="img" ' +
      'aria-label="Правоъгълна площадка, дължината е три пъти по-голяма от широчината. ' +
      'По дългата ѝ страна има храсти — първите три и последният.">' +
      '<rect x="40" y="20" width="420" height="140" rx="10" fill="#FFF9EC" ' +
        'stroke="#8A5505" stroke-width="3"/>' +
      '<g fill="#1F2340">' +
        '<circle cx="40" cy="160" r="8"/>' +
        '<circle cx="76" cy="160" r="8"/>' +
        '<circle cx="112" cy="160" r="8"/>' +
        '<circle cx="460" cy="160" r="8"/>' +
      '</g>' +
      '<g fill="#9AA1BD">' +
        '<circle cx="260" cy="160" r="5"/>' +
        '<circle cx="286" cy="160" r="5"/>' +
        '<circle cx="312" cy="160" r="5"/>' +
      '</g>' +
      '<text x="250" y="192" text-anchor="middle" font-size="15" fill="#5A6183">' +
        'храстите са на 2 метра един от друг</text>' +
    '</svg>',

  /* 2023, задача 2 — дворното място: квадратна градина отляво и
     правоъгълна отдясно, с обща страна. Нарочно НЕ е по мащаб и няма
     нито едно число — точно както в оригиналния лист. */
  dvor2023:
    '<svg viewBox="0 0 360 170" width="100%" style="max-width:360px" role="img" ' +
      'aria-label="Правоъгълно дворно място, разделено с отсечка на две градини: ' +
      'квадратна отляво и правоъгълна отдясно, с обща страна.">' +
      '<rect x="20" y="20" width="110" height="110" fill="#FFF9EC" ' +
        'stroke="#1F2340" stroke-width="3"/>' +
      '<rect x="130" y="20" width="200" height="110" fill="#FFF9EC" ' +
        'stroke="#1F2340" stroke-width="3"/>' +
      '<text x="75" y="152" text-anchor="middle" font-size="14" fill="#5A6183">квадрат</text>' +
      '<text x="230" y="152" text-anchor="middle" font-size="14" fill="#5A6183">правоъгълник</text>' +
    '</svg>',

  /* 2020, задача 2 — три квадрата със страни 1, 2 и 3 клечки. Всяка
     клечка е тяло с главичка; точките са съединенията. */
  klechki: (function () {
    function stick(x1, y1, x2, y2) {
      var dx = x2 - x1, dy = y2 - y1;
      var len = Math.sqrt(dx * dx + dy * dy);
      var ang = Math.atan2(dy, dx) * 180 / Math.PI;
      return '<g transform="translate(' + x1 + ' ' + y1 + ') rotate(' + ang + ')">' +
        '<rect x="2" y="-3" width="' + (len - 4) + '" height="6" rx="3" fill="#E8CFA0" ' +
          'stroke="#C9A96A" stroke-width="1"/>' +
        '<circle cx="' + (len - 3) + '" cy="0" r="4.5" fill="#D6453F"/></g>';
    }
    function square(ox, oy, n, u) {
      var out = '', i;
      for (i = 0; i < n; i++) {
        out += stick(ox + u * i, oy, ox + u * (i + 1), oy);
        out += stick(ox + u * i, oy + u * n, ox + u * (i + 1), oy + u * n);
        out += stick(ox, oy + u * i, ox, oy + u * (i + 1));
        out += stick(ox + u * n, oy + u * i, ox + u * n, oy + u * (i + 1));
      }
      for (i = 0; i <= n; i++) {
        out += '<circle cx="' + (ox + u * i) + '" cy="' + oy + '" r="2.2" fill="#1F2340"/>';
        out += '<circle cx="' + (ox + u * i) + '" cy="' + (oy + u * n) + '" r="2.2" fill="#1F2340"/>';
        out += '<circle cx="' + ox + '" cy="' + (oy + u * i) + '" r="2.2" fill="#1F2340"/>';
        out += '<circle cx="' + (ox + u * n) + '" cy="' + (oy + u * i) + '" r="2.2" fill="#1F2340"/>';
      }
      return out;
    }
    var u = 34;
    return '<svg viewBox="0 0 440 150" width="100%" style="max-width:440px" role="img" ' +
      'aria-label="Три квадрата от кибритени клечки със страни една, две и три клечки.">' +
      square(24, 104, 1, u) + square(100, 70, 2, u) + square(244, 36, 3, u) +
      '</svg>';
  })()
};
