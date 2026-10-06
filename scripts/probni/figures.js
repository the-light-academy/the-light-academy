/* Чертежите по време на теста. Верни на оригинала и нарочно НЕ издават
   отговора: правоъгълникът няма размери по страните си, а квадратите
   от клечки не носят числа. */
var FIGURES = {

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
