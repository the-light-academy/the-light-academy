/* =====================================================================
   The Light Academy — раздели вътре в един предмет
   ---------------------------------------------------------------------
   Един предмет не е плосък списък от листове. „Състезателна математика“
   за 4. клас е подготовка за олимпиада, а тя е три кръга един след друг:
   общински, областен, национален. Тук стои тази структура.

   ЗАЩО Е В КОДА, А НЕ В БАЗАТА

   Разделите са учебна наредба, не данни. Кръговете на олимпиадата са
   три и ще са три и догодина; никой не ги въвежда през екран. Същото
   важи и за програмата по седмици, която стои в teacher.html по същата
   причина.

   В базата (supabase/schema-v8.sql) стои само КОЕ задание в кой раздел
   е — две кратки колони, track и section. Следствието е, че разделът
   съществува и празен: таблото показва и трите кръга от първия ден, за
   да се види къде какво да се сложи.

   ДА СЕ ДОБАВИ РАЗДЕЛ

   Нов запис тук и нищо друго — без промяна по базата. Имената (id) се
   пишат с малки букви, цифри и долна черта: базата приема само такива
   и ще откаже останалото.
   ===================================================================== */
(function (global) {
  'use strict';

  var TLA = global.TLA = global.TLA || {};

  /* Разделите на 4. клас по състезателна математика са СЪСТЕЗАНИЯТА от
     календара (sastezaniya_4.html), а не седмици: предметът не върви по
     учебна програма, а от турнир към турнир. Подредбата отдолу е
     подредбата на екрана — първо двете, с които се занимаваме, после
     останалите по реда на календара.

     „Минали теми“ е мястото за пробните варианти от предишни години.
     Празният раздел не е грешка: той е мястото, което чака да се
     напълни, и точно затова се вижда в таблото на преподавателя. */
  var MINALI = [{ id: 'minali', title: 'Минали теми',
                  note: 'Варианти от предишни години, разписани като пробен тест.' }];

  function contest(id, title, note) {
    return { id: id, subject: 'sastezatelna-matematika', grade: 4,
             title: title, note: note, sections: MINALI };
  }

  /* =================================================================
     АНГЛИЙСКИ, 5. КЛАС — English Plus 1
     -----------------------------------------------------------------
     Този предмет не върви по седмици, а по юнитите на учебника:
     Starter unit и осем юнита. Затова разделите тук са самите юнити,
     а подразделите — колоните от „Map of the book“: Vocabulary,
     Reading, Language focus, Speaking, Writing, Review и English Plus
     options.

     Надписите са на английски нарочно — така пише в учебника и така
     ги търси детето, когато отвори книгата до компютъра. Страниците
     са преписани от картата на учебника и служат за едно: като се
     качва лист, да се види на коя страница отговаря.
     ================================================================= */
  var EP1 = [
    ['ep1_starter', 'Starter unit',
     'be, subject pronouns and possessive adjectives, possessive ’s, ' +
     'this / that / these / those, have got, question words and conjunctions — ' +
     'the language the rest of the book stands on.',
     [
       ['vocabulary', 'Vocabulary',
        'p4 Free time — video games, music, art, animals, etc. ' +
        'Key phrases: Talking about hobbies and interests. · ' +
        'p6 Prepositions and everyday objects — on, in, under, laptop, bag, coat, phone, etc. · ' +
        'p8 Basic adjectives — new, fast, cheap, boring, etc. Key phrases: Adverbs of degree. · ' +
        'p10 Countries and nationalities — Spain, Turkey, Japan, China, etc.'],
       ['language_focus', 'Language focus',
        'p5 be: affirmative and negative. Subject pronouns and possessive adjectives. ' +
        'Key phrases: Introducing people. · p7 Possessive ’s. be: questions. · ' +
        'p9 this, that, these, those. have got. · ' +
        'p11 Question words: Where … ?, What … ?, Who … ? Conjunctions: and, or, but. ' +
        'Key phrases: Thinking of answers. Key phrases: Writing about yourself.']
     ]],

    ['ep1_unit1', 'Unit 1 · Towns and cities',
     'There’s / There are and comparative adjectives — describing a place and ' +
     'comparing it with another. Pages 12–21.',
     [
       ['vocabulary', 'Vocabulary',
        'p12 Places in a town or city — restaurant, school, park, etc. ' +
        'Language point: There’s, There are + a, an, some and any. ' +
        'Key phrases: Talking about places. · ' +
        'p16 Vocabulary and listening: Comparing places — old, quiet, pretty, etc.'],
       ['reading', 'Reading',
        'p14 A description of a cruise ship. ' +
        'Vocabulary plus: fantastic, comfortable, swimming pool, etc.'],
       ['language_focus', 'Language focus',
        'p15 Is there … ?, Are there … ?, How many … ? · ' +
        'p17 Comparative adjectives. Pronunciation: /ə/ sound in comparatives. ' +
        'Key phrases: Comparing opinions.'],
       ['speaking', 'Speaking',
        'p18 Asking and saying where places are. Study strategy: Learning the key phrases. ' +
        'Key phrases: Asking and saying where places are.'],
       ['writing', 'Writing',
        'p19 A description of a town or city. Key phrases: Describing a town or city. ' +
        'Language point: Position of adjectives.'],
       ['review', 'Review',
        'p20 Review Unit 1. p21 Puzzles and games.'],
       ['options', 'English Plus options',
        'p92 Extra listening and speaking: Asking for and giving personal information. ' +
        'p100 Curriculum Extra: Geography: Reading a map. p106 Culture: The United Kingdom. ' +
        'p116 Song: I’m the King.']
     ]],

    ['ep1_unit2', 'Unit 2 · Days',
     'Present simple and adverbs of frequency — daily routines, timetables and ' +
     'special days. Pages 22–31.',
     [
       ['vocabulary', 'Vocabulary',
        'p22 Daily routines — get up, have classes, study, etc. ' +
        'Language point: Adverbs of frequency. Key phrases: Comparing answers. · ' +
        'p26 Vocabulary and listening: Special days — sing, dance, wear, etc. ' +
        'Study strategy: Preparing to listen.'],
       ['reading', 'Reading',
        'p24 A busy day. Vocabulary plus: son, daughter, parent, etc.'],
       ['language_focus', 'Language focus',
        'p25 Present simple: affirmative and negative. Pronunciation: Third person -s. · ' +
        'p27 Present simple: questions. Key phrases: Time expressions.'],
       ['speaking', 'Speaking',
        'p28 Making plans and suggestions. Key phrases: Making plans and suggestions.'],
       ['writing', 'Writing',
        'p29 A special day. Key phrases: Talking about a celebration. Language point: also.'],
       ['review', 'Review',
        'p30 Review Unit 2. p31 Puzzles and games.'],
       ['options', 'English Plus options',
        'p93 Extra listening and speaking: Talking about timetables. ' +
        'p101 Curriculum Extra: Geography: Time zones. p107 Culture: Weird festivals. ' +
        'p112 Project: A class survey.']
     ]],

    ['ep1_unit3', 'Unit 3 · Wild life',
     'Superlative adjectives and can for ability — animals, what they can do and ' +
     'asking for permission. Pages 32–41.',
     [
       ['vocabulary', 'Vocabulary',
        'p32 Animals — camel, butterfly, snake, etc. Key phrases: Identifying things. ' +
        'Pronunciation: Sentence stress. · ' +
        'p36 Vocabulary and listening: Amazing animals — kill, grow, survive, etc.'],
       ['reading', 'Reading',
        'p34 The ugliest animals? Vocabulary plus: beautiful, common, dull, etc.'],
       ['language_focus', 'Language focus',
        'p35 Superlative adjectives. Study strategy: Improving your grammar. · ' +
        'p37 can for ability. Questions with How … ? Key phrases: Estimating.'],
       ['speaking', 'Speaking',
        'p38 Asking for permission. Key phrases: Requesting, giving and refusing permission.'],
       ['writing', 'Writing',
        'p39 Animals in danger. Key phrases: Describing animals in danger. ' +
        'Language point: Giving examples.'],
       ['review', 'Review',
        'p40 Review Unit 3. p41 Puzzles and games.'],
       ['options', 'English Plus options',
        'p94 Extra listening and speaking: Phoning a friend. ' +
        'p102 Curriculum Extra: Natural science: Animals. p117 Song: I Can Tell You.']
     ]],

    ['ep1_unit4', 'Unit 4 · Learning world',
     'Present continuous against present simple — school subjects, studying a ' +
     'language and writing about your school. Pages 42–51.',
     [
       ['vocabulary', 'Vocabulary',
        'p42 School subjects — maths, English, history, etc. ' +
        'Key phrases: Talking about school subjects. · ' +
        'p46 Vocabulary and listening: Verbs: Studying a language — listen, check, repeat, etc. ' +
        'Study strategy: Thinking about learning.'],
       ['reading', 'Reading',
        'p44 Schools project. Vocabulary plus: primary school, private school, boarding school, etc.'],
       ['language_focus', 'Language focus',
        'p45 Present continuous: affirmative and negative. · ' +
        'p47 Present continuous: questions. Present continuous and present simple.'],
       ['speaking', 'Speaking',
        'p48 Asking for help when you’re studying. Key phrases: Asking for help with languages. ' +
        'Pronunciation: The alphabet.'],
       ['writing', 'Writing',
        'p49 An email about your school. Key phrases: Giving information about your school. ' +
        'Language point: so.'],
       ['review', 'Review',
        'p50 Review Unit 4. p51 Puzzles and games.'],
       ['options', 'English Plus options',
        'p95 Extra listening and speaking: Comparing two pictures. ' +
        'p108 Culture: Home schooling. p113 Project: My dream school.']
     ]],

    ['ep1_unit5', 'Unit 5 · Food and health',
     'Countable and uncountable nouns with some, any, much, many and a lot of — ' +
     'food, health and ordering in a café. Pages 52–61.',
     [
       ['vocabulary', 'Vocabulary',
        'p52 Food — burger, salad, meat, etc. ' +
        'Study strategy: Organizing and remembering vocabulary. ' +
        'Pronunciation: Short and long vowels. Key phrases: Likes and dislikes. · ' +
        'p56 Vocabulary and listening: Adjectives: Health — fit, hungry, etc.'],
       ['reading', 'Reading',
        'p54 Sumo wrestlers. Vocabulary plus: dish, vitamins, etc.'],
       ['language_focus', 'Language focus',
        'p55 Countable and uncountable nouns + some, any, much, many and a lot of. · ' +
        'p57 Verb + -ing. Imperatives.'],
       ['speaking', 'Speaking',
        'p58 In a café. Key phrases: Ordering food.'],
       ['writing', 'Writing',
        'p59 A food blog. Key phrases: Writing a food blog. Language point: Sequencing.'],
       ['review', 'Review',
        'p60 Review Unit 5. p61 Puzzles and games.'],
       ['options', 'English Plus options',
        'p96 Extra listening and speaking: Shopping at the market. ' +
        'p103 Curriculum Extra: Science: Food and nutrients. p118 Song: Delicious.']
     ]],

    ['ep1_unit6', 'Unit 6 · Sport',
     'there was / there were and the past simple of regular and irregular verbs — ' +
     'sport, the Olympics and last weekend. Pages 62–71.',
     [
       ['vocabulary', 'Vocabulary',
        'p62 Sports — football, athletics, cycling, etc. Key phrases: Talking about sports. · ' +
        'p66 Vocabulary and listening: X Games: Regular and irregular verbs — ' +
        'completed, became, etc.'],
       ['reading', 'Reading',
        'p64 The Olympics then and now. Vocabulary plus: winner, competitor, swimmer, etc.'],
       ['language_focus', 'Language focus',
        'p65 there was, there were, was, were. · ' +
        'p67 Past simple: affirmative. Past time expressions. ' +
        'Study strategy: Learning irregular verbs. Pronunciation: -ed endings. ' +
        'Key phrases: Past time expressions.'],
       ['speaking', 'Speaking',
        'p68 Last weekend. Key phrases: Talking about the weekend.'],
       ['writing', 'Writing',
        'p69 A sports star. Key phrases: Profile of a sports star. Language point: Paragraphs.'],
       ['review', 'Review',
        'p70 Review Unit 6. p71 Puzzles and games.'],
       ['options', 'English Plus options',
        'p97 Extra listening and speaking: Talking about video games. ' +
        'p109 Culture: Football vs. baseball. p114 Project: A new sport.']
     ]],

    ['ep1_unit7', 'Unit 7 · Growing up',
     'Past simple — affirmative, negative and questions — with object pronouns: ' +
     'describing people and telling a life story. Pages 72–81.',
     [
       ['vocabulary', 'Vocabulary',
        'p72 Describing people — short, round, moustache, etc. Pronunciation: Diphthongs. ' +
        'Key phrases: Guessing answers. · ' +
        'p76 Vocabulary and listening: Life events — grow up, go to school, etc.'],
       ['reading', 'Reading',
        'p74 Childhood photos. Vocabulary plus: grow, change, give.'],
       ['language_focus', 'Language focus',
        'p75 Object pronouns. Past simple: affirmative and negative. · ' +
        'p77 Past simple: questions.'],
       ['speaking', 'Speaking',
        'p78 Role-play: an interview with a famous person. Key phrases: Doing an interview. ' +
        'Study strategy: Improve your speaking.'],
       ['writing', 'Writing',
        'p79 Biographical questions and answers. ' +
        'Key phrases: A biography: questions and answers. Language point: Punctuation.'],
       ['review', 'Review',
        'p80 Review Unit 7. p81 Puzzles and games.'],
       ['options', 'English Plus options',
        'p98 Extra listening and speaking: Describing people. ' +
        'p104 Curriculum Extra: Language and Literature: The Elephant Man. ' +
        'p110 Culture: Amazing people. p119 Song: The Story of Your Life.']
     ]],

    ['ep1_unit8', 'Unit 8 · Going away',
     'be going to and will / won’t — holidays, the weather and making offers and ' +
     'promises. Pages 82–91.',
     [
       ['vocabulary', 'Vocabulary',
        'p82 Things for a holiday — rucksack, tent, water bottle, etc. · ' +
        'p86 Vocabulary and listening: Weather conditions — windy, stormy, foggy, etc. ' +
        'Study strategy: Guessing answers before listening.'],
       ['reading', 'Reading',
        'p84 Summer holidays. Vocabulary plus: cool, expensive, boring, etc.'],
       ['language_focus', 'Language focus',
        'p85 be going to: affirmative, negative and questions. ' +
        'Pronunciation: Question stress and rhythm. · p87 will and won’t.'],
       ['speaking', 'Speaking',
        'p88 Offers and promises. Key phrases: Making offers and promises.'],
       ['writing', 'Writing',
        'p89 An email. Key phrases: Writing an email about a friend’s visit. ' +
        'Language point: because.'],
       ['review', 'Review',
        'p90 Review Unit 8. p91 Puzzles and games.'],
       ['options', 'English Plus options',
        'p99 Extra listening and speaking: The weather forecast. ' +
        'p105 Curriculum Extra: Language and literature: The Adventures of Tom Sawyer. ' +
        'p111 Culture: Theme parks in the USA. p115 Project: A holiday.']
     ]]
  ];

  /* Редовете отгоре стават раздели по общия образец. Пише се веднъж,
     за да не се преписва едно и също девет пъти. */
  function ep1(row) {
    return {
      id: row[0], subject: 'angliiski', grade: 5,
      title: row[1], note: row[2],
      sections: row[3].map(function (s) {
        return { id: s[0], title: s[1], note: s[2] };
      })
    };
  }

  var TRACKS = [
    {
      id: 'salabashev',
      subject: 'sastezatelna-matematika',
      grade: 4,
      title: 'Състезание „Иван Салабашев“',
      note: 'Турнирът на СМБ, секция Стара Загора — края на ноември. ' +
            '15 задачи за 120 минути: първите десет с избираем отговор, последните пет с число.',
      sections: MINALI
    },
    {
      id: 'olimpiada',
      subject: 'sastezatelna-matematika',
      grade: 4,
      title: 'Олимпиада по математика',
      note: 'Двата кръга, които ни интересуват, един след друг. Общинският е вратата: ' +
            'без него няма областен.',
      sections: [
        { id: 'obshtinski', title: 'Общински кръг',
          note: 'Първият кръг — в училището, до средата на декември. Оттук се продължава нататък.' },
        { id: 'oblasten', title: 'Областен кръг',
          note: 'Вторият кръг — за областта, в началото на февруари. Балообразуващ.' }
      ]
    },
    contest('hitar_petar', '„Хитър Петър“',
            'Октомври. Допълнително състезание — добро за тренировка в началото на годината.'),
    { id: 'bez_granici', subject: 'sastezatelna-matematika', grade: 4,
      title: '„Математика без граници“',
      note: 'Четири кръга през годината и финал при класиране.',
      sections: [
        { id: 'esen', title: 'Есенен кръг', note: 'Края на октомври.' },
        { id: 'zima', title: 'Зимен кръг', note: 'Втората половина на януари.' },
        { id: 'prolet', title: 'Пролетен кръг', note: 'Началото на март.' },
        { id: 'polufinal', title: 'Полуфинал', note: 'Края на април.' },
        { id: 'final', title: 'Финал', note: 'Юли — само при класиране.' }
      ] },
    contest('chernorizec', '„Черноризец Храбър“', 'Началото на ноември.'),
    contest('sofijski', 'Софийски математически турнир', 'Началото на ноември.'),
    contest('koledno', 'Коледно математическо състезание', 'Средата на декември.'),
    contest('zimno', 'Зимно математическо състезание', 'Края на февруари, Стара Загора.'),
    contest('kenguru', '„Европейско кенгуру“',
            'Средата на март. Кратки задачи с избираем отговор — най-доброто за тренировка.'),
    contest('proletno', 'Пролетно математическо състезание',
            'Края на март, специално за IV клас. Балообразуващо.'),
    contest('velikdensko', 'Великденско математическо състезание', 'Април.'),
    contest('kiril_popov', '„Академик Кирил Попов“', 'Началото на май.'),
    contest('za_vseki', '„Математика за всеки“',
            'Средата на май. Национално състезание за четвъртокласници. Балообразуващо.'),
    contest('evrika', '„Еврика“', 'Края на май.')
  ].concat(EP1.map(ep1));

  /* Пазач при зареждането. Повторено име или име не по формата не чупи
     нищо видимо — заданието просто няма да се намери в своя раздел, а
     това се забелязва месеци по-късно. Затова се казва веднага. */
  (function selfCheck() {
    var ok = /^[a-z][a-z0-9_]{0,31}$/, bad = [], seen = {};
    TRACKS.forEach(function (t) {
      if (!ok.test(t.id)) bad.push('разделът „' + t.id + '“ не е по формата');
      if (seen[t.id]) bad.push('разделът „' + t.id + '“ го има два пъти');
      seen[t.id] = true;
      var s2 = {};
      (t.sections || []).forEach(function (s) {
        if (!ok.test(s.id)) bad.push('подразделът „' + s.id + '“ не е по формата');
        if (s2[s.id]) bad.push('подразделът „' + s.id + '“ го има два пъти в „' + t.id + '“');
        s2[s.id] = true;
      });
    });
    if (bad.length && global.console) console.error('tracks.js: ' + bad.join(' · '));
  })();

  function byId(id) {
    var hit = TRACKS.filter(function (t) { return t.id === id; });
    return hit.length ? hit[0] : null;
  }

  function sectionOf(trackId, sectionId) {
    var t = byId(trackId);
    if (!t) return null;
    var hit = (t.sections || []).filter(function (s) { return s.id === sectionId; });
    return hit.length ? hit[0] : null;
  }

  /* Разделите, които важат за един предмет и клас. subjectSlug идва от
     таблицата subjects; grade е числото на класа. */
  function forSubject(subjectSlug, grade) {
    return TRACKS.filter(function (t) {
      return t.subject === subjectSlug && String(t.grade) === String(grade);
    });
  }

  /* Надписът на един раздел, готов за екрана. Непознато име НЕ се крие:
     ако заданието сочи към раздел, какъвто вече няма, това трябва да се
     види, а не да изчезне тихо. */
  function label(trackId, sectionId) {
    var t = byId(trackId);
    if (!t) return trackId ? ('непознат раздел: ' + trackId) : '';
    var s = sectionId ? sectionOf(trackId, sectionId) : null;
    if (sectionId && !s) return t.title + ' · непознат подраздел: ' + sectionId;
    return s ? (t.title + ' · ' + s.title) : t.title;
  }

  /* Задания, подредени по раздели. Връща за всеки раздел и подраздел
     онова, което е в него — включително празните, защото празният
     раздел е мястото, което чака да се напълни. `rest` са заданията
     извън всякакъв раздел. */
  function group(assignments, subjectSlug, grade) {
    var tracks = forSubject(subjectSlug, grade).map(function (t) {
      return {
        track: t,
        sections: (t.sections || []).map(function (s) {
          return { section: s, items: [] };
        }),
        loose: []       /* в раздела, но без подраздел */
      };
    });
    var rest = [];

    (assignments || []).forEach(function (a) {
      var box = null;
      tracks.forEach(function (g) { if (g.track.id === a.track) box = g; });
      if (!box) { rest.push(a); return; }
      var hit = null;
      box.sections.forEach(function (sg) { if (sg.section.id === a.section) hit = sg; });
      (hit ? hit.items : box.loose).push(a);
    });

    return { tracks: tracks, rest: rest };
  }

  /* Същото, но тръгнало от самите задания, а не от каталога: връща
     само разделите и кръговете, в които НАИСТИНА има нещо.

     Двете групирания са нарочно различни. Преподавателят трябва да
     вижда и празния кръг — там ще слага. Ученикът не бива: за него
     празен кръг е обещание, което никой не му е давал. */
  function groupPresent(assignments) {
    var order = {}, i = 0;
    TRACKS.forEach(function (t) {
      order[t.id] = i++;
      (t.sections || []).forEach(function (sec, k) { order[t.id + '/' + sec.id] = k; });
    });

    var box = {}, rest = [];
    (assignments || []).forEach(function (a) {
      if (!a.track || !byId(a.track)) { rest.push(a); return; }
      var g = box[a.track] || (box[a.track] = { track: byId(a.track), sections: {}, loose: [] });
      var sec = a.section ? sectionOf(a.track, a.section) : null;
      if (!sec) { g.loose.push(a); return; }
      (g.sections[sec.id] || (g.sections[sec.id] = { section: sec, items: [] })).items.push(a);
    });

    var tracks = Object.keys(box)
      .sort(function (x, y) { return order[x] - order[y]; })
      .map(function (id) {
        var g = box[id];
        return {
          track: g.track,
          loose: g.loose,
          sections: Object.keys(g.sections)
            .sort(function (x, y) { return order[id + '/' + x] - order[id + '/' + y]; })
            .map(function (k) { return g.sections[k]; })
        };
      });
    return { tracks: tracks, rest: rest };
  }

  TLA.Tracks = {
    all: TRACKS,
    byId: byId,
    sectionOf: sectionOf,
    forSubject: forSubject,
    label: label,
    group: group,
    groupPresent: groupPresent
  };
})(typeof window !== 'undefined' ? window : globalThis);
