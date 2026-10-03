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

  /* ═══ ЗНАЦИТЕ ═══════════════════════════════════════════════════════
     Дванайсет, всичките от небето. c1 и c2 са преливката на кръга, а
     glyph е рисунката върху нея — само плътни цветове, за да няма id-та.
     Всяка нова рисунка трябва да е в кутия 0 0 64 64, инак ще скача
     спрямо другите.                                                     */
  var AVATARS = [
    { id: 'astronaut', name: 'Астронавт', c1: '#5B8DEF', c2: '#1B2E52', glyph:
      '<path d="M14 55c2.5-7.5 8.5-11 18-11s15.5 3.5 18 11z" fill="#E7ECF6"/>' +
      '<rect x="14.2" y="22" width="4.4" height="9" rx="2.2" fill="#D9E3F5"/>' +
      '<rect x="45.4" y="22" width="4.4" height="9" rx="2.2" fill="#D9E3F5"/>' +
      '<circle cx="32" cy="26" r="15.5" fill="#fff"/>' +
      '<rect x="21.5" y="19.5" width="21" height="12.5" rx="6.2" fill="#1A2440"/>' +
      '<circle cx="27.5" cy="24" r="2.9" fill="#fff" opacity=".5"/>' },

    { id: 'rocket', name: 'Ракета', c1: '#FFB65C', c2: '#C2410C', glyph:
      '<path d="M23.5 37.5c-4 2.2-6.5 6.2-6.5 11.5l8.5-4.5z" fill="#1A2440"/>' +
      '<path d="M40.5 37.5c4 2.2 6.5 6.2 6.5 11.5l-8.5-4.5z" fill="#1A2440"/>' +
      '<path d="M32 9c6.2 6.4 9.5 14.6 9.5 23.8 0 5-0.8 9.2-2 12.2H24.5c-1.2-3-2-7.2-2-12.2C22.5 23.6 25.8 15.4 32 9z" fill="#fff"/>' +
      '<circle cx="32" cy="26.5" r="5.2" fill="#1A2440"/>' +
      '<path d="M27.5 47.5h9L32 57z" fill="#FFE2A8"/>' },

    { id: 'planet', name: 'Планета', c1: '#A78BFA', c2: '#4C1D95', glyph:
      '<circle cx="32" cy="31" r="14.5" fill="#fff"/>' +
      '<circle cx="26" cy="26" r="3.4" fill="#CBD6EA"/>' +
      '<circle cx="37.5" cy="35" r="2.4" fill="#CBD6EA"/>' +
      '<ellipse cx="32" cy="34" rx="23" ry="6.4" fill="none" stroke="#FFD98A" ' +
        'stroke-width="3.4" transform="rotate(-18 32 34)"/>' },

    { id: 'star', name: 'Звезда', c1: '#FDE68A', c2: '#B45309', glyph:
      '<path d="M32 11l5.4 14.6L52.9 26.2 40.8 35.8 44.9 50.7 32 42.2 19.1 50.7 ' +
        '23.3 35.8 11.1 26.2 26.6 25.6z" fill="#fff"/>' },

    { id: 'moon', name: 'Луна', c1: '#93C5FD', c2: '#1E3A8A', glyph:
      '<path d="M38 11a21 21 0 1 0 0 42 25.5 25.5 0 0 1 0-42z" fill="#fff"/>' +
      '<circle cx="26" cy="24" r="3.4" fill="#D7E3F7"/>' +
      '<circle cx="22" cy="36" r="2.4" fill="#D7E3F7"/>' +
      '<circle cx="30" cy="42" r="1.8" fill="#D7E3F7"/>' },

    { id: 'comet', name: 'Комета', c1: '#67E8F9', c2: '#0E7490', glyph:
      '<g stroke="#FFF3CF" stroke-linecap="round" fill="none">' +
      '<path d="M33 31 13 51" stroke-width="4.4"/>' +
      '<path d="M37 36 25 48" stroke-width="3.2"/>' +
      '<path d="M28 25 13 37" stroke-width="2.8"/></g>' +
      '<circle cx="42" cy="22" r="9.5" fill="#fff"/>' },

    { id: 'alien', name: 'Извънземно', c1: '#86EFAC', c2: '#166534', glyph:
      '<path d="M32 11c10.5 0 17.5 7.2 17.5 17.5C49.5 40 40 53 32 53S14.5 40 14.5 28.5C14.5 18.2 21.5 11 32 11z" fill="#fff"/>' +
      '<ellipse cx="24.5" cy="29" rx="4.8" ry="6.8" fill="#1A2440" transform="rotate(-16 24.5 29)"/>' +
      '<ellipse cx="39.5" cy="29" rx="4.8" ry="6.8" fill="#1A2440" transform="rotate(16 39.5 29)"/>' +
      '<path d="M28.5 42h7" stroke="#1A2440" stroke-width="2.4" stroke-linecap="round"/>' },

    { id: 'ufo', name: 'Чинийка', c1: '#C4B5FD', c2: '#3730A3', glyph:
      '<path d="M20 33a12 12 0 0 1 24 0z" fill="#BFDBFE"/>' +
      '<ellipse cx="32" cy="37" rx="22" ry="7.6" fill="#fff"/>' +
      '<circle cx="21" cy="39" r="2.2" fill="#F7AD19"/>' +
      '<circle cx="32" cy="40.4" r="2.2" fill="#F7AD19"/>' +
      '<circle cx="43" cy="39" r="2.2" fill="#F7AD19"/>' +
      '<path d="M26 46l-4 9M38 46l4 9" stroke="#FFE2A8" stroke-width="2.6" stroke-linecap="round"/>' },

    { id: 'satellite', name: 'Спътник', c1: '#7DD3FC', c2: '#075985', glyph:
      '<rect x="5" y="27" width="17" height="10.5" rx="2.4" fill="#BFDBFE"/>' +
      '<rect x="42" y="27" width="17" height="10.5" rx="2.4" fill="#BFDBFE"/>' +
      '<path d="M22 32.2h20" stroke="#fff" stroke-width="2.6"/>' +
      '<rect x="25.5" y="23.5" width="13" height="17.5" rx="3.4" fill="#fff"/>' +
      '<path d="M32 23.5V15l6.5-5" stroke="#fff" stroke-width="2.6" fill="none" stroke-linecap="round"/>' +
      '<circle cx="40.5" cy="8.5" r="4.2" fill="#F7AD19"/>' },

    { id: 'telescope', name: 'Телескоп', c1: '#FCA5A5', c2: '#991B1B', glyph:
      '<rect x="13" y="25" width="34" height="11.5" rx="5.7" fill="#fff" transform="rotate(-22 30 31)"/>' +
      '<path d="M30 40v9M21 56l9-7 9 7" stroke="#fff" stroke-width="3.4" fill="none" stroke-linecap="round"/>' +
      '<path d="M50 12l1.8 3.8 3.8 1.8-3.8 1.8L50 23.2l-1.8-3.8-3.8-1.8 3.8-1.8z" fill="#FFE2A8"/>' },

    { id: 'galaxy', name: 'Галактика', c1: '#F0ABFC', c2: '#6B21A8', glyph:
      '<g fill="none" stroke="#fff" stroke-width="3.4" stroke-linecap="round">' +
      '<path d="M45 19c-8.5-6-20-3.5-24.5 5s-0.5 18 8.5 20.5"/>' +
      '<path d="M19 45c8.5 6 20 3.5 24.5-5s0.5-18-8.5-20.5"/></g>' +
      '<ellipse cx="32" cy="32" rx="7.4" ry="5" fill="#fff" transform="rotate(-32 32 32)"/>' +
      '<circle cx="48" cy="46" r="2.1" fill="#FFE2A8"/>' +
      '<circle cx="16" cy="18" r="1.7" fill="#FFE2A8"/>' },

    { id: 'sun', name: 'Слънце', c1: '#FDBA74', c2: '#9A3412', glyph:
      '<g stroke="#FFF3CF" stroke-width="3.6" stroke-linecap="round">' +
      '<path d="M32 5v7M32 52v7M5 32h7M52 32h7M13 13l5 5M46 46l5 5M51 13l-5 5M18 46l-5 5"/></g>' +
      '<circle cx="32" cy="32" r="13.5" fill="#fff"/>' }
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

     Сметката: знакът е 25, темите — до 50 (шест стигат за пълното),
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
              ? 'Знак: <strong>' + esc(chosen.name) + '</strong>'
              : 'Още не си си избрал знак') + '</p>' +
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
        '<h3 class="sc__h">Избери си знак</h3>' +
        '<p class="sc__m">Дванайсет знака от небето. Онзи, който избереш, ще ' +
          'стои до името ти в профила.</p>' +
        '<div class="sc__avas" role="radiogroup" aria-label="Знак за профила">' +
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
        /* Второ щракване по същия знак го маха — инак избран веднъж
           знак няма как да се върне на „никакъв“. */
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
