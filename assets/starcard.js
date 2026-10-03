/* =====================================================================
   The Light Academy — космическият паспорт (разделът „Профил“)
   ---------------------------------------------------------------------
   Тук детето казва кой е: избира си знак (аватар), светва темите, които
   му харесват, и дописва по едно изречение към тези от тях, които имат
   какво още да питат. Футболът пита за отбор, книгите — за любима
   книга, космосът — за любима планета.

   Три неща, които са нарочно така:

   · Аватарите са РИСУВАНИ ТУК, не са файлове. Няма качване на снимки,
     няма адреси към чужди сървъри, няма как детето да сложи чуждо лице.
     Всеки знак е няколко фигури в svg върху преливка от две цветa.
   · Няма нито един градиент с id в svg-то. Знакът се рисува по дванайсет
     пъти на страницата (веднъж в избора, веднъж в голямо) и еднакви
     id-та в един документ се бият. Преливката идва от css, през --c1 и
     --c2 на обвивката.
   · Списъкът на темите живее САМО тук. Базата не знае имената им — пази
     формата (кратко име от малки букви) и дължината, нищо повече. Нова
     тема значи ред в този файл и нищо друго; без промяна по базата.

   Какво се пази: supabase/schema-v7.sql — таблицата star_cards, по един
   ред на дете, която никой друг не чете. Ни съученик, ни преподавател.

   НА ЕКРАНА се казва „Моят космически паспорт“. В кода и в базата си
   остана star_cards: таблица не се преименува заради надпис — това би
   значело ново пускане на файл в Supabase срещу нула полза, а името ѝ
   никой не вижда.
   ===================================================================== */
(function (global) {
  'use strict';

  var TLA = global.TLA = global.TLA || {};

  function esc(v) {
    return TLA.escapeHtml ? TLA.escapeHtml(v)
      : String(v == null ? '' : v).replace(/&/g, '&amp;').replace(/</g, '&lt;')
        .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }

  /* ═══ ЕКИПАЖЪТ ══════════════════════════════════════════════════════
     Дванайсет космонавта: седем деца и пет животни, всичките в един и
     същ скафандър. Скафандърът е ОБЩ нарочно — това е един екипаж, а не
     дванайсет отделни рисунки, и затова се рисува от една функция, не се
     преписва дванайсет пъти.

     Как е направено:

     · Всяка рисунка е в кутия 0 0 64 64. Излезе ли някоя от нея, ще
       подскача спрямо останалите.
     · Нито един градиент няма id. Знакът се рисува по много пъти на
       една страница (веднъж в избора, веднъж голям в шапката) и еднакви
       id-та в един документ се бият. Преливката на кръга идва от css,
       през --c1 и --c2.
     · Кръговете са в тъмната гама на LightSpace — тъмносиньо, индиго,
       морско, слива. Така дванайсетте значки изглеждат като един
       комплект, а не като дъга, и златните звездички вътре връзват
       всяка от тях с марката.                                          */

  /* Скафандърът: рамене, презрамки, яка и емблемата на гърдите. Еднакъв
     за всички — и за децата, и за животните. */
  function suit() {
    return '<path d="M11 58c2.4-8 9.4-12.4 21-12.4S50.6 50 53 58z" fill="#fff"/>' +
      '<path d="M23.5 48l-3 9M40.5 48l3 9" stroke="#2F5FB3" stroke-width="3.2" stroke-linecap="round"/>' +
      '<rect x="21" y="41.5" width="22" height="6.8" rx="3.4" fill="#E6EDF9"/>' +
      '<rect x="21" y="41.5" width="22" height="6.8" rx="3.4" fill="none" stroke="#C8D6EC" stroke-width="0.8"/>' +
      '<circle cx="46.5" cy="53.5" r="3" fill="#1B2E52"/>' +
      '<circle cx="46.5" cy="53.5" r="1.5" fill="#F7AD19"/>';
  }

  /* Две-три златни звездички зад главата — същият знак, който стои и в
     логото. Подават се координати, за да не са еднакви навсякъде. */
  function stars(pts) {
    return pts.map(function (p) {
      var r = p[2];
      return '<path d="M' + p[0] + ' ' + (p[1] - r) +
        'l' + (r * 0.32) + ' ' + (r * 0.68) + 'l' + (r * 0.68) + ' ' + (r * 0.32) +
        'l' + (-r * 0.68) + ' ' + (r * 0.32) + 'l' + (-r * 0.32) + ' ' + (r * 0.68) +
        'l' + (-r * 0.32) + ' ' + (-r * 0.68) + 'l' + (-r * 0.68) + ' ' + (-r * 0.32) +
        'l' + (r * 0.68) + ' ' + (-r * 0.32) + 'z" fill="#FFD98A" opacity=".85"/>';
    }).join('');
  }

  /* Лице: очи с ирис и искрица, вежди, бузки и усмивка. Ирисът е довод,
     защото цветът на очите е част от избора („момче със зелени очи“). */
  function face(eye, opts) {
    opts = opts || {};
    var brow = opts.brow || '#6B4A33';
    var e = function (x) {
      return '<ellipse cx="' + x + '" cy="29.4" rx="3.3" ry="3.8" fill="#fff"/>' +
        '<circle cx="' + x + '" cy="29.8" r="2.4" fill="' + eye + '"/>' +
        '<circle cx="' + x + '" cy="29.8" r="1.15" fill="#241E1A"/>' +
        '<circle cx="' + (x - 0.95) + '" cy="28.6" r="0.85" fill="#fff"/>';
    };
    return e(26) + e(38) +
      '<path d="M22.6 24.4q3.4-2 6.8-.3" stroke="' + brow + '" stroke-width="1.5" fill="none" stroke-linecap="round"/>' +
      '<path d="M34.6 24.1q3.4-1.7 6.8.3" stroke="' + brow + '" stroke-width="1.5" fill="none" stroke-linecap="round"/>' +
      '<circle cx="21.6" cy="34.6" r="2.5" fill="#EE8E8E" opacity=".5"/>' +
      '<circle cx="42.4" cy="34.6" r="2.5" fill="#EE8E8E" opacity=".5"/>' +
      (opts.freckles
        ? '<g fill="#B5713F" opacity=".75"><circle cx="24" cy="33.6" r="0.7"/>' +
          '<circle cx="21.4" cy="31.8" r="0.6"/><circle cx="40" cy="33.6" r="0.7"/>' +
          '<circle cx="42.6" cy="31.8" r="0.6"/></g>'
        : '') +
      '<path d="M28 36.4q4 3.6 8 0" stroke="#A85C45" stroke-width="1.8" fill="none" stroke-linecap="round"/>' +
      (opts.glasses
        ? '<g fill="none" stroke="#2F3F63" stroke-width="1.5">' +
          '<circle cx="26" cy="29.6" r="5.4"/><circle cx="38" cy="29.6" r="5.4"/>' +
          '<path d="M31.4 29.6h1.2M20.6 29.2l-2.6.6M43.4 29.2l2.6.6"/></g>'
        : '');
  }

  /* Главата на дете: лице, уши, шия. Косата идва отделно — отзад и
     отпред, за да може кичурът да пада ВЪРХУ челото. */
  function head(skin) {
    return '<circle cx="18.8" cy="30" r="3.1" fill="' + skin + '"/>' +
      '<circle cx="45.2" cy="30" r="3.1" fill="' + skin + '"/>' +
      '<path d="M32 13.5c8.6 0 14.6 6.2 14.6 14.8 0 9.4-6.4 16-14.6 16s-14.6-6.6-14.6-16c0-8.6 6-14.8 14.6-14.8z" fill="' + skin + '"/>';
  }

  var SKIN  = { light: '#F7D5BD', warm: '#EDBE9B', tan: '#CE9068', deep: '#9C6240' };
  var EYE   = { brown: '#6B4226', blue: '#3B7DD8', green: '#3E8E62', dark: '#3A2B22' };

  function kid(opts) {
    return suit() + stars(opts.stars) + (opts.back || '') +
           head(opts.skin) + (opts.hair || '') +
           face(opts.eye, opts) ;
  }

  var AVATARS = [
    /* ── децата ─────────────────────────────────────────────────────── */
    { id: 'lora', name: 'Русо момиче', c1: '#2E4A86', c2: '#101D3C', glyph:
      kid({ skin: SKIN.light, eye: EYE.blue, brow: '#C79B4C',
            stars: [[50, 17, 3], [13, 24, 2.2], [52, 34, 1.8]],
            /* дълга коса: закръглена форма зад главата, после бретон */
            back: '<path d="M14.6 32c0-11.4 7.6-19.4 17.4-19.4S49.4 20.6 49.4 32v9.6c0 2.4-2 3.8-4 3.1V31.6H18.6V44.7c-2 .7-4-.7-4-3.1z" fill="#F2C75C"/>',
            hair: '<path d="M17.6 27.6c1-7.4 7-12.2 14.4-12.2s13.4 4.8 14.4 12.2c-3.4-3.6-8-5-13-6.4-2.6 2.8-6.6 5-10.2 5.6z" fill="#F2C75C"/>' +
                  '<circle cx="47.6" cy="20.6" r="2.4" fill="#F7AD19"/>' }) },

    { id: 'mina', name: 'Момиче с кок', c1: '#3B2F74', c2: '#161032', glyph:
      kid({ skin: SKIN.warm, eye: EYE.brown, brow: '#6B4A33',
            stars: [[14, 20, 2.4], [50, 23, 2], [16, 38, 1.7]],
            back: '<circle cx="32" cy="10.4" r="7" fill="#8B5E3C"/>' +
                  '<path d="M17.8 31c0-10 6.2-17.6 14.2-17.6S46.2 21 46.2 31v3.4c-1.8.6-3-.6-3-2.6v-5H20.8v5c0 2-1.2 3.2-3 2.6z" fill="#8B5E3C"/>',
            hair: '<path d="M18.4 26.6c1.4-7 7-11.4 13.6-11.4s12.2 4.4 13.6 11.4c-3.6-3.4-8.4-4.8-13.6-4.8s-10 1.4-13.6 4.8z" fill="#8B5E3C"/>' }) },

    { id: 'niki', name: 'Момче със зелени очи', c1: '#1F4E63', c2: '#0B2230', glyph:
      kid({ skin: SKIN.light, eye: EYE.green, brow: '#6B4A33',
            stars: [[49, 18, 2.6], [14, 27, 2], [48, 36, 1.7]],
            hair: '<path d="M17.4 28.4c-.6-8.6 5.6-15.4 14.6-15.4 8.2 0 14.2 5.4 14.6 13.2-2.4-2.6-5.4-4.4-8.8-5.2-3.4 3.4-8.8 5.6-14.4 5.6-2.2 1.2-4.4 1.2-6 1.8z" fill="#8B5E3C"/>' }) },

    { id: 'sara', name: 'Момиче с плитки', c1: '#5C2A5E', c2: '#24102A', glyph:
      kid({ skin: SKIN.deep, eye: EYE.dark, brow: '#2A1B14',
            stars: [[13, 22, 2.4], [51, 20, 2], [50, 37, 1.7]],
            back: '<path d="M17.6 31c0-10.2 6.4-17.8 14.4-17.8S46.4 20.8 46.4 31v2.6H17.6z" fill="#2E1F18"/>' +
                  '<g fill="#2E1F18"><circle cx="15.4" cy="35" r="3.4"/><circle cx="14.2" cy="41.4" r="3"/>' +
                  '<circle cx="48.6" cy="35" r="3.4"/><circle cx="49.8" cy="41.4" r="3"/></g>' +
                  '<g fill="#F7AD19"><circle cx="14.6" cy="45.4" r="1.7"/><circle cx="49.4" cy="45.4" r="1.7"/></g>',
            hair: '<path d="M18.2 27.2c1.2-7.4 6.8-12 13.8-12s12.6 4.6 13.8 12c-3.6-3.6-8.4-5.2-13.8-5.2s-10.2 1.6-13.8 5.2z" fill="#2E1F18"/>' }) },

    { id: 'tomi', name: 'Момче с лунички', c1: '#6B3A1E', c2: '#2A1409', glyph:
      kid({ skin: SKIN.light, eye: EYE.brown, brow: '#B4521F', freckles: true,
            stars: [[50, 19, 2.5], [13, 25, 2], [15, 39, 1.7]],
            hair: '<path d="M17.2 28c-.4-8.4 5.8-15 14.8-15s15 6.6 14.8 15c-1.6-2.6-3.4-3.6-5.6-4.6.4 2 .2 3.2-.6 4.6-1.2-3.4-3.6-5.4-6.6-6.4.8 2.2.6 3.8-.4 5.4-1.6-3.6-4.6-5.8-8.4-6.4-2.6 1.4-5.2 3.8-8 7.4z" fill="#D9682E"/>' }) },

    { id: 'ema', name: 'Момиче с очила', c1: '#235A4E', c2: '#0C2721', glyph:
      kid({ skin: SKIN.warm, eye: EYE.brown, brow: '#7A5638', glasses: true,
            stars: [[14, 21, 2.4], [50, 24, 2], [49, 38, 1.7]],
            back: '<path d="M15.6 32c0-10.8 7.2-18.6 16.4-18.6S48.4 21.2 48.4 32v8.6c0 2.4-2 3.6-3.8 2.9V31.6H19.4v11.9c-1.8.7-3.8-.5-3.8-2.9z" fill="#A9794F"/>',
            hair: '<path d="M18.4 26.6c1.4-7 7-11.4 13.6-11.4s12.2 4.4 13.6 11.4c-3.6-3.4-8.4-4.8-13.6-4.8s-10 1.4-13.6 4.8z" fill="#A9794F"/>' }) },

    { id: 'boris', name: 'Момче с къдрици', c1: '#2B3C70', c2: '#0F1733', glyph:
      kid({ skin: SKIN.tan, eye: EYE.dark, brow: '#2A1B14',
            stars: [[50, 20, 2.5], [13, 26, 2], [48, 37, 1.7]],
            hair: '<g fill="#2E1F18"><circle cx="22" cy="20.6" r="5.2"/><circle cx="29" cy="16.8" r="5.6"/>' +
                  '<circle cx="36.4" cy="16.8" r="5.4"/><circle cx="43" cy="21" r="5"/>' +
                  '<circle cx="18.8" cy="25.6" r="4"/><circle cx="45.6" cy="25.8" r="3.8"/></g>' }) },

    /* ── животните ──────────────────────────────────────────────────── */
    { id: 'meche', name: 'Мече', c1: '#7A4A22', c2: '#2E190A', glyph:
      suit() + stars([[50, 18, 2.5], [13, 24, 2], [49, 37, 1.7]]) +
      '<circle cx="19.6" cy="17.4" r="6.2" fill="#A9743F"/><circle cx="19.6" cy="17.4" r="3.2" fill="#D9A777"/>' +
      '<circle cx="44.4" cy="17.4" r="6.2" fill="#A9743F"/><circle cx="44.4" cy="17.4" r="3.2" fill="#D9A777"/>' +
      '<circle cx="32" cy="29.6" r="15.4" fill="#A9743F"/>' +
      '<ellipse cx="32" cy="35" rx="9.4" ry="7.4" fill="#E8CBA8"/>' +
      '<ellipse cx="32" cy="31.6" rx="3.1" ry="2.4" fill="#3B2518"/>' +
      '<path d="M32 33.8v2.6M32 36.4q-2.6 2.4-4.6.2M32 36.4q2.6 2.4 4.6.2" stroke="#3B2518" stroke-width="1.5" fill="none" stroke-linecap="round"/>' +
      '<circle cx="25.4" cy="26.4" r="2.5" fill="#2A1B12"/><circle cx="24.6" cy="25.6" r="0.9" fill="#fff"/>' +
      '<circle cx="38.6" cy="26.4" r="2.5" fill="#2A1B12"/><circle cx="37.8" cy="25.6" r="0.9" fill="#fff"/>' },

    { id: 'maimunka', name: 'Маймунка', c1: '#6B4A1E', c2: '#2A1A08', glyph:
      suit() + stars([[13, 20, 2.4], [51, 22, 2], [15, 38, 1.7]]) +
      '<circle cx="16.6" cy="29" r="6.4" fill="#9A6B3C"/><circle cx="16.6" cy="29" r="3.4" fill="#D9AF84"/>' +
      '<circle cx="47.4" cy="29" r="6.4" fill="#9A6B3C"/><circle cx="47.4" cy="29" r="3.4" fill="#D9AF84"/>' +
      '<circle cx="32" cy="28.6" r="15" fill="#9A6B3C"/>' +
      '<path d="M32 18.6c7.4 0 12.4 5.6 12.4 12.6S38.8 43.6 32 43.6 19.6 38.2 19.6 31.2 24.6 18.6 32 18.6z" fill="#E8C49A"/>' +
      '<circle cx="26.6" cy="27.4" r="2.7" fill="#2A1B12"/><circle cx="25.7" cy="26.5" r="0.95" fill="#fff"/>' +
      '<circle cx="37.4" cy="27.4" r="2.7" fill="#2A1B12"/><circle cx="36.5" cy="26.5" r="0.95" fill="#fff"/>' +
      '<g fill="#8A5B32"><circle cx="30.2" cy="34" r="0.95"/><circle cx="33.8" cy="34" r="0.95"/></g>' +
      '<path d="M28.4 37.4q3.6 3.4 7.2 0" stroke="#8A5B32" stroke-width="1.6" fill="none" stroke-linecap="round"/>' },

    { id: 'zaiche', name: 'Зайче', c1: '#4A3B7A', c2: '#1A1336', glyph:
      suit() + stars([[50, 22, 2.4], [13, 28, 2], [49, 39, 1.7]]) +
      '<ellipse cx="25.4" cy="12.6" rx="4" ry="9.6" fill="#F0F2F8" transform="rotate(-9 25.4 12.6)"/>' +
      '<ellipse cx="25.4" cy="13.4" rx="2" ry="6.6" fill="#F2B6C4" transform="rotate(-9 25.4 13.4)"/>' +
      '<ellipse cx="38.6" cy="12.6" rx="4" ry="9.6" fill="#F0F2F8" transform="rotate(9 38.6 12.6)"/>' +
      '<ellipse cx="38.6" cy="13.4" rx="2" ry="6.6" fill="#F2B6C4" transform="rotate(9 38.6 13.4)"/>' +
      '<circle cx="32" cy="31" r="14.6" fill="#F0F2F8"/>' +
      '<circle cx="26.2" cy="29" r="2.6" fill="#3A3140"/><circle cx="25.4" cy="28.2" r="0.9" fill="#fff"/>' +
      '<circle cx="37.8" cy="29" r="2.6" fill="#3A3140"/><circle cx="37" cy="28.2" r="0.9" fill="#fff"/>' +
      '<circle cx="20.8" cy="34.4" r="2.4" fill="#F2B6C4" opacity=".7"/>' +
      '<circle cx="43.2" cy="34.4" r="2.4" fill="#F2B6C4" opacity=".7"/>' +
      '<path d="M32 33.4l-2.2 2.4h4.4z" fill="#E08BA0"/>' +
      '<path d="M32 36.2v1.6M32 37.8q-2.4 2-4.2 0M32 37.8q2.4 2 4.2 0" stroke="#B9728A" stroke-width="1.4" fill="none" stroke-linecap="round"/>' },

    { id: 'kotence', name: 'Котенце', c1: '#2F5A72', c2: '#0E2533', glyph:
      suit() + stars([[14, 22, 2.4], [50, 20, 2], [50, 38, 1.7]]) +
      /* Ушите са триъгълници ВЪРХУ главата. Първо бяха тънки резени
         отстрани и котето четеше с антенки, не с уши. */
      '<path d="M19.4 25.8L23 10.8l9.8 8.6z" fill="#C9A26A"/>' +
      '<path d="M22.4 22.4L24.2 14.4l5.4 5z" fill="#F2C9A0"/>' +
      '<path d="M44.6 25.8L41 10.8l-9.8 8.6z" fill="#C9A26A"/>' +
      '<path d="M41.6 22.4L39.8 14.4l-5.4 5z" fill="#F2C9A0"/>' +
      '<circle cx="32" cy="30.4" r="15" fill="#C9A26A"/>' +
      '<ellipse cx="26" cy="29" rx="2.5" ry="3.1" fill="#2E2A22"/><circle cx="25.2" cy="27.9" r="0.9" fill="#fff"/>' +
      '<ellipse cx="38" cy="29" rx="2.5" ry="3.1" fill="#2E2A22"/><circle cx="37.2" cy="27.9" r="0.9" fill="#fff"/>' +
      '<path d="M32 33.4l-2 2.2h4z" fill="#E0899A"/>' +
      '<path d="M32 35.8v1.4M32 37.2q-2.3 2-4 0M32 37.2q2.3 2 4 0" stroke="#7A5A3A" stroke-width="1.4" fill="none" stroke-linecap="round"/>' +
      '<g stroke="#8A6A46" stroke-width="1.1" stroke-linecap="round">' +
      '<path d="M18.6 33.4l-5.4-1.4M18.6 36l-5 1.4M45.4 33.4l5.4-1.4M45.4 36l5 1.4"/></g>' },

    { id: 'pingvinche', name: 'Пингвинче', c1: '#1E4470', c2: '#091A30', glyph:
      suit() + stars([[50, 19, 2.5], [13, 23, 2], [15, 38, 1.7]]) +
      '<circle cx="32" cy="29.4" r="15.2" fill="#2B3450"/>' +
      '<path d="M32 19.4c6.8 0 11.4 5 11.4 11.4S38.4 43.4 32 43.4 20.6 37.2 20.6 30.8 25.2 19.4 32 19.4z" fill="#F2F5FA"/>' +
      '<circle cx="26.6" cy="28" r="2.7" fill="#2A2E3C"/><circle cx="25.8" cy="27.1" r="0.95" fill="#fff"/>' +
      '<circle cx="37.4" cy="28" r="2.7" fill="#2A2E3C"/><circle cx="36.6" cy="27.1" r="0.95" fill="#fff"/>' +
      '<path d="M32 32.6l-4.2 3 4.2 3 4.2-3z" fill="#F7AD19"/>' +
      '<circle cx="22.4" cy="33.6" r="2.3" fill="#F2B6C4" opacity=".6"/>' +
      '<circle cx="41.6" cy="33.6" r="2.3" fill="#F2B6C4" opacity=".6"/>' }
  ];

  var AVATAR_BY_ID = {};
  AVATARS.forEach(function (a) { AVATAR_BY_ID[a.id] = a; });

  /* ═══ ТЕМИТЕ ════════════════════════════════════════════════════════
     Шест съзвездия. Всяка тема е { id, label, emoji } и може да носи
     ask — питането, което се появява САМО ако темата е светната:

       ask: { key, label, kind:'text', hint }     → едно кратко поле
       ask: { key, label, kind:'pick', options }  → избор от няколко

     key-овете са отделни от id-тата на темите нарочно: ако някой ден
     една тема се прекръсти, отговорът ѝ не се губи. Два ключа не бива
     да се повтарят — проверява се долу, при зареждането на файла.      */
  var GROUPS = [
    { id: 'sport', name: 'Спорт и движение', emoji: '🏅', items: [
      { id: 'football', label: 'Футбол', emoji: '⚽', ask: {
        key: 'football_team', label: 'Любим отбор', kind: 'text', hint: 'напр. Левски' } },
      { id: 'basketball', label: 'Баскетбол', emoji: '🏀', ask: {
        key: 'basket_team', label: 'Любим отбор или играч', kind: 'text', hint: 'напр. Лейкърс' } },
      { id: 'volleyball', label: 'Волейбол', emoji: '🏐' },
      { id: 'tennis', label: 'Тенис', emoji: '🎾', ask: {
        key: 'tennis_player', label: 'Любим тенисист', kind: 'text', hint: 'напр. Григор Димитров' } },
      { id: 'swimming', label: 'Плуване', emoji: '🏊', ask: {
        key: 'swim_where', label: 'Къде обичаш да плуваш', kind: 'pick',
        options: ['в басейн', 'в морето', 'в езеро', 'навсякъде'] } },
      { id: 'gymnastics', label: 'Гимнастика', emoji: '🤸' },
      { id: 'martial', label: 'Бойни спортове', emoji: '🥋', ask: {
        key: 'martial_kind', label: 'Кой точно', kind: 'pick',
        options: ['карате', 'джудо', 'таекуондо', 'бокс', 'борба', 'друг'] } },
      { id: 'cycling', label: 'Колоездене', emoji: '🚴' },
      { id: 'climbing', label: 'Катерене', emoji: '🧗' },
      { id: 'ski', label: 'Ски и сноуборд', emoji: '⛷️', ask: {
        key: 'ski_kind', label: 'Кое от двете', kind: 'pick',
        options: ['ски', 'сноуборд', 'и двете'] } },
      { id: 'athletics', label: 'Лека атлетика', emoji: '🏃' },
      { id: 'skating', label: 'Пързаляне', emoji: '⛸️' },
      { id: 'horses', label: 'Езда', emoji: '🐴' },
      { id: 'skate', label: 'Скейтборд', emoji: '🛹' },
      { id: 'handball', label: 'Хандбал', emoji: '🤾' },
      { id: 'chess', label: 'Шах', emoji: '♟️', ask: {
        key: 'chess_piece', label: 'Любима фигура', kind: 'pick',
        options: ['кон', 'царица', 'пешка', 'топ', 'офицер', 'цар'] } }
    ] },

    { id: 'art', name: 'Изкуство и сцена', emoji: '🎨', items: [
      { id: 'drawing', label: 'Рисуване', emoji: '🎨', ask: {
        key: 'draw_with', label: 'С какво рисуваш', kind: 'pick',
        options: ['моливи', 'акварел', 'пастели', 'на таблет', 'с всичко'] } },
      { id: 'music', label: 'Музика', emoji: '🎵', ask: {
        key: 'music_fav', label: 'Любима песен или изпълнител', kind: 'text', hint: 'която си пееш' } },
      { id: 'instrument', label: 'Инструмент', emoji: '🎹', ask: {
        key: 'instrument_kind', label: 'На какво свириш', kind: 'pick',
        options: ['пиано', 'гитара', 'флейта', 'цигулка', 'барабани', 'друго'] } },
      { id: 'singing', label: 'Пеене', emoji: '🎤' },
      { id: 'theatre', label: 'Театър', emoji: '🎭' },
      { id: 'photo', label: 'Фотография', emoji: '📷' },
      { id: 'writing', label: 'Писане', emoji: '✍️', ask: {
        key: 'writing_kind', label: 'Какво пишеш', kind: 'pick',
        options: ['разкази', 'стихове', 'дневник', 'комикси'] } },
      { id: 'dance', label: 'Танци', emoji: '💃', ask: {
        key: 'dance_kind', label: 'Какъв танц', kind: 'text', hint: 'напр. народни, балет, хип-хоп' } },
      { id: 'clay', label: 'Глина и скулптура', emoji: '🏺' },
      { id: 'origami', label: 'Оригами', emoji: '📄' },
      { id: 'knitting', label: 'Плетене и шиене', emoji: '🧶' }
    ] },

    { id: 'space', name: 'Космос и природа', emoji: '🪐', items: [
      { id: 'space', label: 'Космос', emoji: '🚀', ask: {
        key: 'planet', label: 'Любима планета', kind: 'pick',
        options: ['Меркурий', 'Венера', 'Земята', 'Марс', 'Юпитер', 'Сатурн',
                  'Уран', 'Нептун'] } },
      { id: 'stars', label: 'Звезди и съзвездия', emoji: '✨', ask: {
        key: 'constellation', label: 'Любимо съзвездие', kind: 'text', hint: 'напр. Голямата мечка' } },
      { id: 'rockets', label: 'Ракети и спътници', emoji: '🛰️' },
      { id: 'mountain', label: 'Планина', emoji: '⛰️', ask: {
        key: 'peak', label: 'Любим връх или планина', kind: 'text', hint: 'напр. Мусала' } },
      { id: 'sea', label: 'Море', emoji: '🌊' },
      { id: 'forest', label: 'Гора и походи', emoji: '🌲' },
      { id: 'animals', label: 'Животни', emoji: '🐾', ask: {
        key: 'animal', label: 'Любимо животно', kind: 'text', hint: 'напр. делфин' } },
      { id: 'birds', label: 'Птици', emoji: '🦜' },
      { id: 'dinos', label: 'Динозаври', emoji: '🦖', ask: {
        key: 'dino', label: 'Любим динозавър', kind: 'text', hint: 'напр. трицератопс' } },
      { id: 'plants', label: 'Растения', emoji: '🌱' },
      { id: 'rocks', label: 'Камъни и минерали', emoji: '💎' },
      { id: 'volcano', label: 'Вулкани', emoji: '🌋' },
      { id: 'weather', label: 'Времето и облаците', emoji: '⛅' }
    ] },

    { id: 'science', name: 'Наука и машини', emoji: '🔬', items: [
      { id: 'maths', label: 'Математика', emoji: '➗', ask: {
        key: 'maths_part', label: 'Кое ти е най-интересно', kind: 'pick',
        options: ['задачите', 'геометрията', 'числата', 'логическите задачи'] } },
      { id: 'robots', label: 'Роботи', emoji: '🤖' },
      { id: 'coding', label: 'Програмиране', emoji: '💻', ask: {
        key: 'coding_what', label: 'На какво или какво правиш', kind: 'text',
        hint: 'напр. Scratch, игри' } },
      { id: 'chemistry', label: 'Химия и опити', emoji: '🧪' },
      { id: 'physics', label: 'Физика', emoji: '🧲' },
      { id: 'invent', label: 'Изобретения', emoji: '💡' },
      { id: 'electronics', label: 'Електроника', emoji: '🔌' },
      { id: 'printing', label: '3D принтиране', emoji: '🖨️' },
      { id: 'history', label: 'История', emoji: '📜', ask: {
        key: 'history_what', label: 'Любима епоха или личност', kind: 'text',
        hint: 'напр. древен Египет' } },
      { id: 'geography', label: 'География и карти', emoji: '🗺️' },
      { id: 'languages', label: 'Чужди езици', emoji: '🗣️', ask: {
        key: 'language', label: 'Кой език', kind: 'text', hint: 'който учиш или искаш да научиш' } }
    ] },

    { id: 'play', name: 'Четене и игри', emoji: '📚', items: [
      { id: 'reading', label: 'Книги', emoji: '📚', ask: {
        key: 'book', label: 'Любима книга', kind: 'text', hint: 'напр. Матилда' } },
      { id: 'comics', label: 'Комикси', emoji: '💥' },
      { id: 'board', label: 'Настолни игри', emoji: '🎲', ask: {
        key: 'board_game', label: 'Любима игра', kind: 'text', hint: 'напр. Не се сърди, човече' } },
      { id: 'video', label: 'Видеоигри', emoji: '🎮', ask: {
        key: 'video_game', label: 'Любима игра', kind: 'text', hint: 'на компютър или телефон' } },
      { id: 'puzzles', label: 'Пъзели', emoji: '🧩' },
      { id: 'lego', label: 'Лего и конструктори', emoji: '🧱', ask: {
        key: 'lego_what', label: 'Какво строиш', kind: 'pick',
        options: ['коли', 'къщи', 'космически кораби', 'роботи', 'измислям си'] } },
      { id: 'riddles', label: 'Загадки и мистерии', emoji: '🔍' },
      { id: 'cards', label: 'Карти', emoji: '🃏' },
      { id: 'cinema', label: 'Кино', emoji: '🎬', ask: {
        key: 'movie', label: 'Любим филм', kind: 'text', hint: 'който си гледал много пъти' } },
      { id: 'anime', label: 'Анимация и аниме', emoji: '🌸', ask: {
        key: 'anime_title', label: 'Любимо заглавие', kind: 'text' } },
      { id: 'magic', label: 'Фокуси', emoji: '🪄' }
    ] },

    { id: 'life', name: 'Всекидневни неща', emoji: '🌼', items: [
      { id: 'cooking', label: 'Готвене и печене', emoji: '🍳', ask: {
        key: 'dish', label: 'Любимо ястие или сладкиш', kind: 'text', hint: 'което правиш сам' } },
      { id: 'garden', label: 'Градинарство', emoji: '🪴' },
      { id: 'collect', label: 'Колекции', emoji: '🏷️', ask: {
        key: 'collection', label: 'Какво колекционираш', kind: 'text', hint: 'напр. камъчета, стикери' } },
      { id: 'travel', label: 'Пътуване', emoji: '✈️', ask: {
        key: 'travel_where', label: 'Къде мечтаеш да отидеш', kind: 'text', hint: 'напр. Исландия' } },
      { id: 'pets', label: 'Домашен любимец', emoji: '🐶', ask: {
        key: 'pet_name', label: 'Как се казва', kind: 'text', hint: 'и какъв е' } },
      { id: 'friends', label: 'Време с приятели', emoji: '🤝' },
      { id: 'helping', label: 'Да помагам на другите', emoji: '💛' },
      { id: 'cars', label: 'Коли и машини', emoji: '🚗' },
      { id: 'trains', label: 'Влакове', emoji: '🚆' },
      { id: 'planes', label: 'Самолети', emoji: '🛩️' },
      { id: 'fashion', label: 'Мода и стил', emoji: '👗' }
    ] }
  ];

  /* Общият въпрос — не виси на никоя тема, затова стои отделно. */
  var DREAM = { key: 'dream', label: 'Когато порасна, искам да…', hint: 'с едно изречение' };

  /* ── пазач при зареждането ──────────────────────────────────────────
     Повторено id на тема или повторен ключ на отговор не чупи нищо
     видимо — просто едната тема тихо изяжда отговора на другата. Такава
     грешка се намира месеци по-късно и затова се казва веднага, в
     конзолата, още щом файлът се зареди.                               */
  (function selfCheck() {
    var seenId = {}, seenKey = {}, bad = [];
    var okId = /^[a-z][a-z0-9_]{0,31}$/;
    GROUPS.forEach(function (g) {
      g.items.forEach(function (it) {
        if (!okId.test(it.id)) bad.push('темата „' + it.id + '“ не е по формата, която базата приема');
        if (seenId[it.id]) bad.push('темата „' + it.id + '“ я има два пъти');
        seenId[it.id] = true;
        if (it.ask) {
          if (seenKey[it.ask.key]) bad.push('ключът „' + it.ask.key + '“ го има два пъти');
          seenKey[it.ask.key] = true;
        }
      });
    });
    AVATARS.forEach(function (a) {
      if (!/^[a-z][a-z0-9_]{0,23}$/.test(a.id)) bad.push('знакът „' + a.id + '“ не е по формата');
    });
    if (bad.length && global.console) {
      console.error('starcard.js: ' + bad.join(' · '));
    }
  })();

  var ITEM_BY_ID = {};
  GROUPS.forEach(function (g) {
    g.items.forEach(function (it) { ITEM_BY_ID[it.id] = it; });
  });

  /* ═══ РИСУВАНЕ НА ЗНАК ══════════════════════════════════════════════ */

  /* Един знак, готов за слагане където и да е. cls добавя размер
     (sc__ava--lg за голямия). Непознато id дава въпросителна, а не
     празно място — инак изтрит от списъка знак оставя дупка без обяснение. */
  function avatarHtml(id, cls) {
    var a = AVATAR_BY_ID[id];
    var extra = cls ? ' ' + cls : '';
    if (!a) {
      return '<span class="sc__ava sc__ava--none' + extra + '" aria-hidden="true">✦</span>';
    }
    return '<span class="sc__ava' + extra + '" style="--c1:' + a.c1 + ';--c2:' + a.c2 + '"' +
      ' aria-hidden="true"><svg viewBox="0 0 64 64" focusable="false">' + a.glyph + '</svg></span>';
  }

  /* ═══ СВЕТИМОСТ ═════════════════════════════════════════════════════
     Колко е попълнен паспортът. Нарочно НЕ е оценка: нищо не се сравнява
     с другите деца и 100 не значи „правилно“. Затова и имената са от
     небето, а не „слабо/добро“.

     Сметката: космонавтът е 25, темите — до 50 (шест стигат за пълното),
     дописаните отговори — до 25. Дете, което е светнало шест теми и е
     отговорило на всичките им въпроси, е на 100 и без мечтата.          */
  function brightness(state) {
    var score = state.avatar ? 25 : 0;
    score += Math.min(50, Math.round(state.interests.length / 6 * 50));

    var asked = 0, answered = 0;
    state.interests.forEach(function (id) {
      var it = ITEM_BY_ID[id];
      if (it && it.ask) {
        asked++;
        if (state.answers[it.ask.key]) answered++;
      }
    });
    if (state.answers[DREAM.key]) { asked++; answered++; }
    score += asked ? Math.round(answered / asked * 25) : 0;
    return Math.max(0, Math.min(100, score));
  }

  function rank(pct) {
    if (pct === 0) return 'Тъмно небе';
    if (pct < 40) return 'Искра';
    if (pct < 70) return 'Светило';
    if (pct < 100) return 'Съзвездие';
    return 'Свръхнова';
  }

  /* ═══ ПАСПОРТЪТ ═════════════════════════════════════════════════════ */

  /* mount(root, opts)
       root          — където да се нарисува
       opts.load     — () => паспортът от базата (или null)
       opts.save     — (паспорт) => записва
       opts.name     — име на детето за надписа
       opts.grade    — „6. клас“ или празно
       opts.onAvatar — вика се при всяка смяна на знака, за да може
                       страницата да го сложи и горе, до поздрава      */
  function mount(root, opts) {
    opts = opts || {};
    var state = { avatar: null, interests: [], answers: {} };
    var dirty = false;
    var busy = false;

    function clean(card) {
      card = card || {};
      var av = AVATAR_BY_ID[card.avatar] ? card.avatar : null;
      var picked = (Array.isArray(card.interests) ? card.interests : [])
        .filter(function (id) { return !!ITEM_BY_ID[id]; });
      /* без повторения — в базата има ограничение за дължина, не за
         повторени стойности */
      var seen = {}, list = [];
      picked.forEach(function (id) { if (!seen[id]) { seen[id] = true; list.push(id); } });

      /* Остават само отговорите, които имат на какво да висят: ако
         темата е махната, нейният отговор не бива да се връща при
         следващото отваряне. */
      var keep = {};
      list.forEach(function (id) {
        var it = ITEM_BY_ID[id];
        if (it && it.ask) keep[it.ask.key] = true;
      });
      keep[DREAM.key] = true;

      var ans = {};
      var src = (card.answers && typeof card.answers === 'object') ? card.answers : {};
      Object.keys(src).forEach(function (k) {
        if (!keep[k]) return;
        var v = String(src[k] == null ? '' : src[k]).slice(0, 80).trim();
        if (v) ans[k] = v;
      });
      return { avatar: av, interests: list, answers: ans };
    }

    function has(id) { return state.interests.indexOf(id) !== -1; }

    function toggle(id) {
      var at = state.interests.indexOf(id);
      if (at === -1) {
        if (state.interests.length >= 60) return;     /* таванът на базата */
        state.interests.push(id);
      } else {
        state.interests.splice(at, 1);
        var it = ITEM_BY_ID[id];
        if (it && it.ask) delete state.answers[it.ask.key];
      }
      dirty = true;
      render();
    }

    /* ---- рисуване ------------------------------------------------- */

    function heroHtml() {
      var pct = brightness(state);
      var name = opts.name || '';
      var chosen = state.avatar ? AVATAR_BY_ID[state.avatar] : null;
      return '' +
      '<div class="sc__hero">' +
        '<div class="sc__sky" aria-hidden="true"></div>' +
        '<div class="sc__hero-in">' +
          avatarHtml(state.avatar, 'sc__ava--lg') +
          '<div class="sc__hero-txt">' +
            '<p class="sc__eyebrow">Моят космически паспорт</p>' +
            '<h3 class="sc__name">' + esc(name || 'Ученик') +
              (opts.grade ? ' <span class="sc__grade">' + esc(opts.grade) + '</span>' : '') +
            '</h3>' +
            '<p class="sc__sign">' + (chosen
              ? 'Екипаж: <strong>' + esc(chosen.name) + '</strong>'
              : 'Още не си си избрал космонавт') + '</p>' +
            '<div class="sc__meter" role="img" aria-label="Светимост на паспорта: ' + pct + ' от 100">' +
              '<span style="width:' + pct + '%"></span>' +
            '</div>' +
            '<p class="sc__meter-t">Светимост ' + pct + '% · <strong>' + esc(rank(pct)) + '</strong></p>' +
          '</div>' +
        '</div>' +
      '</div>';
    }

    function avatarsHtml() {
      var cells = AVATARS.map(function (a) {
        var on = state.avatar === a.id;
        return '<button type="button" class="sc__pickava' + (on ? ' is-on' : '') + '"' +
          ' role="radio" aria-checked="' + (on ? 'true' : 'false') + '"' +
          ' data-ava="' + esc(a.id) + '">' +
          avatarHtml(a.id) +
          '<span class="sc__pickava-n">' + esc(a.name) + '</span>' +
        '</button>';
      }).join('');
      return '' +
      '<section class="sc__block">' +
        '<h3 class="sc__h">Избери си космонавт</h3>' +
        '<p class="sc__m">Седем деца и пет животни в скафандри. Онзи, когото ' +
          'избереш, ще стои до името ти в профила.</p>' +
        '<div class="sc__avas" role="radiogroup" aria-label="Космонавт за профила">' +
          cells + '</div>' +
      '</section>';
    }

    function dreamHtml() {
      return '' +
      '<section class="sc__block">' +
        '<h3 class="sc__h">Моята мисия</h3>' +
        '<p class="sc__m">Едно изречение, което е само твое. Може и да го смениш, ' +
          'когато решиш нещо друго.</p>' +
        '<div class="sc__ask sc__ask--wide">' +
          '<label for="sc-dream">' + esc(DREAM.label) + '</label>' +
          '<input type="text" id="sc-dream" maxlength="80" data-ans="' + esc(DREAM.key) + '"' +
            ' placeholder="' + esc(DREAM.hint) + '" />' +
        '</div>' +
      '</section>';
    }

    function groupsHtml() {
      var blocks = GROUPS.map(function (g) {
        var chips = g.items.map(function (it) {
          var on = has(it.id);
          return '<button type="button" class="sc__chip' + (on ? ' is-on' : '') + '"' +
            ' role="checkbox" aria-checked="' + (on ? 'true' : 'false') + '"' +
            ' data-item="' + esc(it.id) + '">' +
            '<span class="sc__chip-e" aria-hidden="true">' + it.emoji + '</span>' +
            esc(it.label) +
            (it.ask ? '<span class="sc__chip-q" aria-hidden="true">+</span>' : '') +
          '</button>';
        }).join('');
        var n = g.items.filter(function (it) { return has(it.id); }).length;
        return '' +
        '<div class="sc__grp">' +
          '<h4 class="sc__grp-h">' +
            '<span class="sc__grp-e" aria-hidden="true">' + g.emoji + '</span>' +
            esc(g.name) +
            (n ? '<span class="sc__grp-n">' + n + '</span>' : '') +
          '</h4>' +
          '<div class="sc__chips">' + chips + '</div>' +
        '</div>';
      }).join('');
      return '' +
      '<section class="sc__block">' +
        '<h3 class="sc__h">Съзвездия</h3>' +
        '<p class="sc__m">Светни всичко, което ти харесва. Темите с ' +
          '<span class="sc__chip-q sc__chip-q--inline" aria-hidden="true">+</span> ' +
          'питат и по още нещо, щом ги светнеш.</p>' +
        blocks +
      '</section>';
    }

    /* „Разкажи още“ — само за светнатите теми, които имат питане. Редът
       следва реда на светване, не реда на каталога: детето вижда най-долу
       онова, което току-що е добавило. */
    function asksHtml() {
      var rows = [];
      state.interests.forEach(function (id) {
        var it = ITEM_BY_ID[id];
        if (!it || !it.ask) return;
        var a = it.ask;
        var val = state.answers[a.key] || '';
        var body;
        if (a.kind === 'pick') {
          body = '<div class="sc__opts" role="radiogroup" aria-label="' + esc(a.label) + '">' +
            a.options.map(function (o) {
              var on = (val === o);
              return '<button type="button" class="sc__opt' + (on ? ' is-on' : '') + '"' +
                ' role="radio" aria-checked="' + (on ? 'true' : 'false') + '"' +
                ' data-pick="' + esc(a.key) + '" data-val="' + esc(o) + '">' + esc(o) + '</button>';
            }).join('') + '</div>';
        } else {
          body = '<input type="text" id="sc-a-' + esc(a.key) + '" maxlength="80"' +
            ' data-ans="' + esc(a.key) + '"' +
            (a.hint ? ' placeholder="' + esc(a.hint) + '"' : '') + ' />';
        }
        rows.push('' +
        '<div class="sc__ask">' +
          '<label' + (a.kind === 'pick' ? '' : ' for="sc-a-' + esc(a.key) + '"') + '>' +
            '<span class="sc__ask-e" aria-hidden="true">' + it.emoji + '</span>' +
            esc(a.label) +
          '</label>' + body +
        '</div>');
      });
      if (!rows.length) return '';
      return '' +
      '<section class="sc__block">' +
        '<h3 class="sc__h">Разкажи още</h3>' +
        '<p class="sc__m">По едно нещо за темите, които светна. Нищо не е ' +
          'задължително — празното поле си остава празно.</p>' +
        '<div class="sc__asks">' + rows.join('') + '</div>' +
      '</section>';
    }

    function footHtml() {
      var n = state.interests.length;
      return '' +
      '<div class="sc__foot">' +
        '<p class="sc__count">' + (n
          ? 'Светнати теми: <strong>' + n + '</strong>'
          : 'Още нищо не е светнато') + '</p>' +
        '<div class="sc__foot-r">' +
          '<span class="sc__state" id="scState" aria-live="polite">' +
            (dirty ? 'Има незаписани промени' : '') + '</span>' +
          '<button type="button" class="tla-btn" id="scSave"' +
            (busy ? ' disabled' : '') + '>' +
            (busy ? 'Записва…' : 'Запази паспорта') + '</button>' +
        '</div>' +
      '</div>';
    }

    function render() {
      /* Кой елемент е на фокус и докъде е курсорът — за да не изскача
         полето под пръстите при всяко прерисуване. */
      var act = document.activeElement;
      var keep = act && act.dataset && (act.dataset.ans || null);
      var caret = keep && act.selectionStart;

      root.innerHTML =
        '<div class="sc">' + heroHtml() + avatarsHtml() + dreamHtml() +
        groupsHtml() + asksHtml() + footHtml() + '</div>';

      /* Стойностите се слагат през .value, а не в html-а: така нищо
         написано от детето не минава през разбор на html, дори да е
         започнало с „<“. */
      Array.prototype.forEach.call(root.querySelectorAll('input[data-ans]'), function (el) {
        el.value = state.answers[el.dataset.ans] || '';
      });

      if (keep) {
        var again = root.querySelector('input[data-ans="' + keep + '"]');
        if (again) {
          again.focus();
          try { again.setSelectionRange(caret, caret); } catch (e) {}
        }
      }
    }

    /* Само числата, които зависят от написаното: лентата на светимостта
       и надписът под нея. Нищо не се заменя, затова нищо не изчезва
       изпод пръстите. */
    function refresh() {
      var pct = brightness(state);
      var bar = root.querySelector('.sc__meter > span');
      if (bar) bar.style.width = pct + '%';
      var box = root.querySelector('.sc__meter');
      if (box) box.setAttribute('aria-label', 'Светимост на паспорта: ' + pct + ' от 100');
      var txt = root.querySelector('.sc__meter-t');
      if (txt) txt.innerHTML = 'Светимост ' + pct + '% · <strong>' + esc(rank(pct)) + '</strong>';
    }

    /* ---- слушатели (един на целия блок, не по един на чип) --------- */

    root.addEventListener('click', function (e) {
      var ava = e.target.closest ? e.target.closest('[data-ava]') : null;
      if (ava) {
        /* Второ щракване по същия космонавт го маха — инак избран веднъж
           космонавт няма как да се върне на „никакъв“. */
        state.avatar = (state.avatar === ava.dataset.ava) ? null : ava.dataset.ava;
        dirty = true;
        if (opts.onAvatar) opts.onAvatar(state.avatar);
        render();
        return;
      }
      var chip = e.target.closest ? e.target.closest('[data-item]') : null;
      if (chip) { toggle(chip.dataset.item); return; }

      var opt = e.target.closest ? e.target.closest('[data-pick]') : null;
      if (opt) {
        var k = opt.dataset.pick;
        state.answers[k] = (state.answers[k] === opt.dataset.val) ? '' : opt.dataset.val;
        if (!state.answers[k]) delete state.answers[k];
        dirty = true;
        render();
        return;
      }
      if (e.target.id === 'scSave') save();
    });

    /* Писането НЕ прерисува паспорта — само пази стойността и побутва
       светимостта. Прерисуване при всеки знак би местило курсора.

       И нещо по-лошо от курсора: първата версия прерисуваше, щом полето
       изгуби фокус. Фокусът обаче се губи при НАТИСКАНЕТО на мишката, а
       щракването идва след това — тоест чипът, по който детето е
       натиснало, беше изтрит, преди щракването да стигне до него. След
       писане в поле първото щракване никъде не работеше, включително по
       бутона „Запази“. Затова тук се пипат само числата, не дървото. */
    root.addEventListener('input', function (e) {
      var el = e.target;
      if (!el.dataset || !el.dataset.ans) return;
      var v = el.value.slice(0, 80);
      if (v.trim()) state.answers[el.dataset.ans] = v;
      else delete state.answers[el.dataset.ans];
      dirty = true;
      var s = document.getElementById('scState');
      if (s) { s.textContent = 'Има незаписани промени'; s.className = 'sc__state'; }
      refresh();
    });

    /* ---- запис ----------------------------------------------------- */

    function note(msg, bad) {
      var s = document.getElementById('scState');
      if (!s) return;
      s.textContent = msg;
      s.className = 'sc__state' + (bad ? ' is-bad' : ' is-ok');
    }

    async function save() {
      if (busy) return;
      busy = true; render();
      try {
        await opts.save(clean(state));
        dirty = false; busy = false; render();
        note('Паспортът е записан ✦', false);
      } catch (err) {
        busy = false; render();
        note('Не се записа. Провери връзката и опитай пак.', true);
        if (global.console) console.error('starcard save:', err);
      }
    }

    /* Затваряне на страницата с незаписан паспорт. Браузърът показва
       своето си съобщение — нашият текст не стига до него, но питането
       се появява и това е смисълът. */
    global.addEventListener('beforeunload', function (e) {
      if (dirty) { e.preventDefault(); e.returnValue = ''; }
    });

    /* ---- начало ---------------------------------------------------- */

    root.innerHTML = '<p class="tlp__note">Зареждане…</p>';
    (async function () {
      var card = null;
      try { card = await opts.load(); }
      catch (err) {
        root.innerHTML = '<div class="tlp__card"><p class="tlp__card-m">' +
          'Паспортът не се зареди. Ако това се повтаря, кажи на преподавателя си — ' +
          'най-вероятно разделът още не е включен в базата.</p></div>';
        if (global.console) console.error('starcard load:', err);
        return;
      }
      state = clean(card);
      if (opts.onAvatar) opts.onAvatar(state.avatar);
      dirty = false;
      render();
    })();

    return { avatar: function () { return state.avatar; } };
  }

  TLA.StarCard = {
    avatars: AVATARS,
    groups: GROUPS,
    avatarHtml: avatarHtml,
    brightness: brightness,
    rank: rank,
    mount: mount
  };
})(window);
