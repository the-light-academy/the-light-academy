/* =====================================================================
   The Light Academy — календарът на математическите състезания
   ---------------------------------------------------------------------
   Един списък, две места: страницата sastezaniya_4.html го показва цял,
   а порталът на ученика („Пробни изпити“) показва само следващото.
   Затова стои тук, а не вътре в страницата.

   ЗАЩО В КОДА, А НЕ В БАЗАТА

   Същата причина, както при tracks.js: това е календар на външни
   организатори, не данни, които някой въвежда през екран. Сменя се
   веднъж годишно — с една промяна тук, без миграция.

   ДАТИТЕ

   `from` е денят на състезанието, а `to` се попълва само когато то
   трае няколко дни („Математика без граници“ дава прозорец). Пишат се
   по ISO (2027-02-07), защото само така се сравняват правилно.

   `rank` казва колко тежи състезанието за приема:
     key   — балообразуващо или задължително по пътя към него
     rec   — препоръчително, за подготовка и тренировка
     extra — допълнително, по желание
     if    — само при класиране от предишен кръг
   ===================================================================== */
(function (global) {
  'use strict';

  var TLA = global.TLA = global.TLA || {};

  var LIST = [
    { id:'hitar-petar',    name:'„Хитър Петър“',
      from:'2026-10-10', rank:'extra', why:'Допълнителна тренировка.' },
    { id:'mbg-esen',       name:'„Математика без граници“ — есенен кръг',
      from:'2026-10-20', to:'2026-10-31', rank:'extra', why:'Допълнително.' },
    { id:'chernorizec',    name:'„Черноризец Храбър“',
      from:'2026-11-01', rank:'extra', why:'Допълнително.' },
    { id:'sofijski-turnir',name:'Софийски математически турнир',
      from:'2026-11-07', rank:'extra', why:'Допълнително.' },
    { id:'salabashev',     name:'„Иван Салабашев“',
      from:'2026-12-05', rank:'rec', why:'Препоръчително за подготовка.' },
    { id:'olimpiada-obsht',name:'Олимпиада по математика — общински кръг',
      from:'2026-12-12', rank:'key', deadline:true,
      why:'Важно: без общинския кръг няма допускане до областния.' },
    { id:'koledno',        name:'Коледно математическо състезание',
      from:'2026-12-12', rank:'extra', why:'Допълнително.' },
    { id:'mbg-zima',       name:'„Математика без граници“ — зимен кръг',
      from:'2027-01-15', to:'2027-01-25', rank:'extra', why:'Допълнително.' },
    { id:'olimpiada-oblast',name:'Олимпиада по математика — областен кръг',
      from:'2027-02-07', rank:'key', top:true, why:'Балообразуващо — най-важното състезание в годината.' },
    { id:'zimno-sz',       name:'Зимно математическо състезание — Стара Загора',
      from:'2027-02-27', rank:'extra', why:'Допълнително.' },
    { id:'mbg-prolet',     name:'„Математика без граници“ — пролетен кръг',
      from:'2027-03-01', to:'2027-03-10', rank:'extra', why:'Допълнително.' },
    { id:'kenguru',        name:'„Европейско кенгуру“',
      from:'2027-03-18', at:'12:00', rank:'rec', why:'Препоръчително за тренировка.' },
    { id:'proletno-4',     name:'Пролетно математическо състезание за IV клас',
      from:'2027-03-27', rank:'key', top:true, why:'Балообразуващо — специално за четвъртокласници.' },
    { id:'velikdensko',    name:'Великденско математическо състезание',
      from:'2027-04-17', rank:'extra', why:'Допълнително; датата се потвърждава при организатора.' },
    { id:'mbg-polufinal',  name:'„Математика без граници“ — полуфинал',
      from:'2027-04-24', to:'2027-04-25', rank:'extra', why:'Допълнително.' },
    { id:'kiril-popov',    name:'„Академик Кирил Попов“',
      from:'2027-05-01', rank:'extra', why:'Допълнително.' },
    { id:'matematika-za-vseki', name:'„Математика за всеки“',
      from:'2027-05-15', rank:'key', top:true, why:'Балообразуващо — национално състезание за четвъртокласници.' },
    { id:'evrika',         name:'„Еврика“',
      from:'2027-05-29', rank:'extra', why:'Допълнително.' },
    { id:'mbg-final',      name:'„Математика без граници“ — финал',
      from:'2027-07-02', to:'2027-07-05', rank:'if', why:'Само при класиране от предишните кръгове.' }
  ];

  var RANKS = {
    key:   { word:'важно',           cls:'key',   order:0 },
    rec:   { word:'препоръчително',  cls:'rec',   order:1 },
    extra: { word:'допълнително',    cls:'extra', order:2 },
    'if':  { word:'при класиране',   cls:'if',    order:3 }
  };

  var MONTHS = ['януари','февруари','март','април','май','юни',
                'юли','август','септември','октомври','ноември','декември'];

  /* Денят, без часа: иначе „днес“ сутринта и „днес“ вечерта дават
     различен брой дни до едно и също състезание. */
  function day(d){
    d = d ? new Date(d) : new Date();
    return new Date(d.getFullYear(), d.getMonth(), d.getDate());
  }
  function parse(iso){
    var p = String(iso).split('-');
    return new Date(Number(p[0]), Number(p[1]) - 1, Number(p[2]));
  }
  function endOf(c){ return parse(c.to || c.from); }

  /* „10 октомври“, „20–31 октомври“, „24–25 април“, „2 юли – 5 юли“ */
  function dateLabel(c){
    var a = parse(c.from);
    if(!c.to) return a.getDate() + ' ' + MONTHS[a.getMonth()];
    var b = parse(c.to);
    return a.getMonth() === b.getMonth()
      ? a.getDate() + '–' + b.getDate() + ' ' + MONTHS[b.getMonth()]
      : a.getDate() + ' ' + MONTHS[a.getMonth()] + ' – ' + b.getDate() + ' ' + MONTHS[b.getMonth()];
  }
  function yearLabel(c){ return parse(c.from).getFullYear(); }

  function isPast(c, today){ return endOf(c) < day(today); }
  function daysTo(c, today){
    return Math.round((parse(c.from) - day(today)) / 86400000);
  }
  /* Първото състезание, което още не е минало. */
  function next(today){
    var t = day(today), hit = null;
    LIST.forEach(function (c){
      if(endOf(c) < t) return;
      if(!hit || parse(c.from) < parse(hit.from)) hit = c;
    });
    return hit;
  }
  /* Трите балообразуващи. Общинският кръг също е „важно“, но не носи
     бал — той е вратата към областния, затова не стои сред картите, а в
     изречението под тях. */
  function keyOnes(){
    return LIST.filter(function (c){ return c.top === true; });
  }
  /* Подредени по дата и групирани по месец — така се чете календар. */
  function byMonth(){
    var out = [], last = '';
    LIST.slice().sort(function (a, b){ return parse(a.from) - parse(b.from); })
      .forEach(function (c){
        var d = parse(c.from), k = d.getFullYear() + '-' + d.getMonth();
        if(k !== last){
          out.push({ title: MONTHS[d.getMonth()] + ' ' + d.getFullYear(), items: [] });
          last = k;
        }
        out[out.length - 1].items.push(c);
      });
    return out;
  }
  /* „след 12 дни“, „днес“, „мина“ */
  function countdown(c, today){
    var n = daysTo(c, today);
    if(isPast(c, today)) return 'мина';
    if(n <= 0) return (c.to && day(today) <= endOf(c)) ? 'тече' : 'днес';
    if(n === 1) return 'утре';
    return 'след ' + n + ' дни';
  }

  TLA.Sastezaniya = {
    grade: 4,
    subject: 'sastezatelna-matematika',
    page: 'sastezaniya_4.html',
    list: LIST,
    ranks: RANKS,
    months: MONTHS,
    parse: parse, dateLabel: dateLabel, yearLabel: yearLabel,
    isPast: isPast, daysTo: daysTo, next: next, keyOnes: keyOnes,
    byMonth: byMonth, countdown: countdown
  };
})(window);
