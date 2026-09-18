/* =====================================================================
   TLAEmail — проверка на имейл, преди да бъде изпратена формата
   ---------------------------------------------------------------------
   КАКВО НЕ ПРАВИ ТОЗИ ФАЙЛ, за да няма недоразумение: той НЕ може да
   каже дали един имейл наистина съществува. Това го знае само пощенският
   сървър отсреща, а от страница в браузъра до него не се стига — нужен е
   собствен сървър или платена услуга с таен ключ, който няма как да стои
   в страницата.

   Затова тук се лови другото — това, което всъщност поврежда адресите:
   правописните грешки. Родител, който бърза, пише gmial.com, abv.bgg или
   gmail.bg, а браузърът приема всичко това за редовен имейл.

   Три проверки, в този ред:

     1. Формат — по-строг от този на браузъра. `type="email"` приема
        „ivan@b“ и „ivan@gmail“ за валидни; тук домейнът трябва да има
        точка и завършек от поне две букви.

     2. Кирилица — българският капан. „аbv.bg“ с българско „а“ изглежда
        точно като „abv.bg“ и не може да се различи с око. Същото за о, е,
        р, с, у, х. Пощата отива в нищото.

        Тук има подводен камък, който сам по себе си оправдава файла:
        `<input type="email">` в Chrome МЪЛЧЕШКОМ превръща домейна с
        кирилица в punycode. Родителят вижда в полето един адрес, а
        страницата чете съвсем друг:

            написано : ivan@аbv.bg          (кирилско „а“)
            прочетено: ivan@xn--bv-6kc.bg

        Тоест без превод обратно нито окото, нито проверката виждат
        грешката — и писмото тръгва към домейн, който не съществува.
        Затова домейнът първо се разкодира, а чак после се проверява.

     3. Заблуден домейн — сравнява се с домейните, които българските
        родители наистина ползват, и ако е на една-две грешки от някой от
        тях, се предлага поправка.

   Връща: { ok, reason, message, suggestion }
   ===================================================================== */

(function (global) {
  'use strict';

  /* Домейните, които наистина се срещат тук. Списъкът не е за да
     ограничава — всеки друг домейн минава спокойно — а само за да има
     спрямо какво да се мери правописната грешка. */
  var KNOWN = [
    'abv.bg', 'gmail.com', 'mail.bg', 'dir.bg', 'yahoo.com', 'yahoo.co.uk',
    'icloud.com', 'me.com', 'outlook.com', 'hotmail.com', 'live.com',
    'mail.com', 'proton.me', 'protonmail.com', 'aol.com', 'mail.ru'
  ];
  /* mail.ru е тук не защото го предлагаме, а защото е истински и голям:
     без него „mail.ru“ се мери с „mail.bg“ и излиза за грешка.
     gbg.bg пък беше махнат — твърде рядък е, а караше „bg.bg“ да мине за
     сбъркан. Списък от този вид струва толкова, колкото са малко
     лъжливите му попадения. */

  /* Кирилските букви, които изглеждат като латински. Ако някоя от тях
     попадне в имейл, адресът е друг, различен от този, който се вижда. */
  var CYRILLIC_LOOKALIKES = 'аАвВеЕкКмМнНоОрРсСтТуУхХіІјЈ';

  /* По-строг от браузъра: домейн с поне една точка и завършек от поне
     две букви. Нарочно не се гони пълният стандарт — той допуска неща,
     които никой родител не пише, а отхвърля неща, които са наред. */
  var SHAPE = /^[^\s@]+@[^\s@.]+(\.[^\s@.]+)+$/;
  var TLD = /\.[a-z]{2,}$/i;

  /* --- punycode ---------------------------------------------------------
     Обратното на това, което браузърът прави сам. Нужно е, защото до
     проверката стига „xn--bv-6kc.bg“, а грешката се вижда само в
     „аbv.bg“. Това е RFC 3492, декодиращата половина. */
  var PB = 36, PTMIN = 1, PTMAX = 26, PSKEW = 38, PDAMP = 700;

  function adapt(delta, numPoints, firstTime) {
    delta = firstTime ? Math.floor(delta / PDAMP) : delta >> 1;
    delta += Math.floor(delta / numPoints);
    var k = 0;
    while (delta > Math.floor(((PB - PTMIN) * PTMAX) / 2)) {
      delta = Math.floor(delta / (PB - PTMIN));
      k += PB;
    }
    return k + Math.floor(((PB - PTMIN + 1) * delta) / (delta + PSKEW));
  }

  function punyDecode(input) {
    var out = [], i = 0, n = 128, bias = 72, j;
    var delim = input.lastIndexOf('-');
    var basic = delim > 0 ? input.slice(0, delim) : '';
    for (j = 0; j < basic.length; j++) {
      if (basic.charCodeAt(j) >= 0x80) return null;
      out.push(basic.charCodeAt(j));
    }
    var idx = delim > 0 ? delim + 1 : 0;
    while (idx < input.length) {
      var oldi = i, w = 1, k = PB, digit, t;
      for (;;) {
        if (idx >= input.length) return null;
        var c = input.charCodeAt(idx++);
        if (c >= 0x30 && c <= 0x39) digit = c - 0x30 + 26;
        else if (c >= 0x61 && c <= 0x7A) digit = c - 0x61;
        else if (c >= 0x41 && c <= 0x5A) digit = c - 0x41;
        else return null;
        if (digit > Math.floor((0x7FFFFFFF - i) / w)) return null;
        i += digit * w;
        t = k <= bias ? PTMIN : (k >= bias + PTMAX ? PTMAX : k - bias);
        if (digit < t) break;
        if (w > Math.floor(0x7FFFFFFF / (PB - t))) return null;
        w *= (PB - t);
        k += PB;
      }
      var len = out.length + 1;
      bias = adapt(i - oldi, len, oldi === 0);
      if (Math.floor(i / len) > 0x7FFFFFFF - n) return null;
      n += Math.floor(i / len);
      i %= len;
      out.splice(i, 0, n);
      i++;
    }
    var str = '';
    for (j = 0; j < out.length; j++) str += String.fromCodePoint(out[j]);
    return str;
  }

  /* Връща адреса така, както го е видял човекът — с буквите, а не с
     „xn--“. Ако нищо не е кодирано, връща го непроменен. */
  function expandPuny(value) {
    var at = value.lastIndexOf('@');
    if (at === -1) return value;
    var domain = value.slice(at + 1);
    if (domain.toLowerCase().indexOf('xn--') === -1) return value;
    var parts = domain.split('.'), changed = false, i, d;
    for (i = 0; i < parts.length; i++) {
      if (parts[i].toLowerCase().indexOf('xn--') === 0) {
        d = punyDecode(parts[i].slice(4).toLowerCase());
        if (d === null) return value;
        parts[i] = d;
        changed = true;
      }
    }
    return changed ? value.slice(0, at + 1) + parts.join('.') : value;
  }

  /* Кирилица → латиницата, която ѝ прилича. Използва се само за да се
     предложи поправка, и то единствено когато полученото е домейн от
     KNOWN — така никога не се предлага нещо измислено. */
  var HOMOGLYPH = {
    'а': 'a', 'А': 'A', 'в': 'b', 'В': 'B', 'е': 'e', 'Е': 'E',
    'к': 'k', 'К': 'K', 'м': 'm', 'М': 'M', 'н': 'n', 'Н': 'H',
    'о': 'o', 'О': 'O', 'р': 'p', 'Р': 'P', 'с': 'c', 'С': 'C',
    'т': 't', 'Т': 'T', 'у': 'y', 'У': 'Y', 'х': 'x', 'Х': 'X',
    'і': 'i', 'І': 'I', 'ј': 'j', 'Ј': 'J', 'г': 'r', 'Г': 'r'
  };

  function toLatin(value) {
    var out = '', ch, i;
    for (i = 0; i < value.length; i++) {
      ch = value.charAt(i);
      if (HOMOGLYPH.hasOwnProperty(ch)) out += HOMOGLYPH[ch];
      else if (/[Ѐ-ӿ]/.test(ch)) return null;   /* буква без двойник — не гадаем */
      else out += ch;
    }
    return out;
  }

  /* Дамерау–Левенщайн: брои разместените две съседни букви за ЕДНА
     грешка, а не за две. Това не е дреболия — „abv.gb“ и „gmial.com“ са
     точно такива размествания и са най-честият начин да се сбърка адрес. */
  function distance(a, b) {
    if (a === b) return 0;
    var m = a.length, n = b.length;
    if (!m) return n;
    if (!n) return m;
    var d = [], i, j;
    for (i = 0; i <= m; i++) { d[i] = [i]; }
    for (j = 0; j <= n; j++) { d[0][j] = j; }
    for (i = 1; i <= m; i++) {
      for (j = 1; j <= n; j++) {
        var cost = a.charAt(i - 1) === b.charAt(j - 1) ? 0 : 1;
        d[i][j] = Math.min(d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + cost);
        if (i > 1 && j > 1 &&
            a.charAt(i - 1) === b.charAt(j - 2) &&
            a.charAt(i - 2) === b.charAt(j - 1)) {
          d[i][j] = Math.min(d[i][j], d[i - 2][j - 2] + cost);
        }
      }
    }
    return d[m][n];
  }

  function hasCyrillic(value) {
    for (var i = 0; i < value.length; i++) {
      if (CYRILLIC_LOOKALIKES.indexOf(value.charAt(i)) !== -1) return true;
    }
    /* и всяка друга кирилица в адреса — латиницата е правилото тук */
    return /[Ѐ-ӿ]/.test(value);
  }

  /* Името и завършекът се мерят ПООТДЕЛНО, а не домейнът наведнъж.
     Меренето наведнъж бърка: „abv.com“ излизаше на две грешки от
     „aol.com“ и се предлагаше то, вместо очевидното „abv.bg“.

     Две правила, в този ред:

       1. Името съвпада точно, завършекът не — „gmail.bg“, „abv.bgg“,
          „yahoo.co“. Това е сигурно: човекът знае при кого е пощата му и
          е сбъркал само края.
       2. Завършекът съвпада точно, името е на една-две грешки —
          „gmial.com“, „hotmial.com“, „av.bg“.

     Всичко останало се пуска. Непознат домейн не значи сбъркан. */
  function splitDomain(d) {
    var dot = d.lastIndexOf('.');
    return { name: d.slice(0, dot), tld: d.slice(dot + 1) };
  }

  function nearestDomain(domain) {
    if (KNOWN.indexOf(domain) !== -1) return null;
    var me = splitDomain(domain), i, k;

    for (i = 0; i < KNOWN.length; i++) {
      k = splitDomain(KNOWN[i]);
      if (k.name === me.name && k.tld !== me.tld) return KNOWN[i];
    }

    var best = null, bestDist = 99;
    for (i = 0; i < KNOWN.length; i++) {
      k = splitDomain(KNOWN[i]);
      if (k.tld !== me.tld) continue;
      var d = distance(me.name, k.name);
      if (d > 0 && d < bestDist) { bestDist = d; best = KNOWN[i]; }
    }
    if (best === null) return null;
    var limit = me.name.length <= 5 ? 1 : 2;
    return bestDist <= limit ? best : null;
  }

  function check(raw) {
    var value = String(raw == null ? '' : raw).trim();

    if (!value) {
      return { ok: false, reason: 'empty', message: 'Въведете имейл на родителя.', suggestion: null };
    }

    /* Първо обратно от punycode — иначе кирилицата е невидима и за нас. */
    value = expandPuny(value);

    if (hasCyrillic(value)) {
      var latin = toLatin(value), suggestion = null;
      if (latin && SHAPE.test(latin) && TLD.test(latin)) {
        var lat = latin.lastIndexOf('@');
        var ld = latin.slice(lat + 1).toLowerCase();
        /* Предлага се само познат домейн — иначе мълчим, вместо да гадаем.
           Две стъпки, защото едната сама не стига: „аbv.bg“ след замяната
           е готов домейн, а „хotmail.com“ става „xotmail.com“ — кирилското
           „х“ прилича на латинското „x“, не на „h“. Затова латинизираното
           минава и през проверката за правописна грешка. */
        if (KNOWN.indexOf(ld) !== -1) {
          suggestion = latin;
        } else {
          var near = nearestDomain(ld);
          if (near) suggestion = latin.slice(0, lat + 1) + near;
        }
      }
      return {
        ok: false, reason: 'cyrillic', suggestion: suggestion,
        message: suggestion
          ? ('В имейла има кирилица и пощата няма да стигне. Имахте предвид ' + suggestion + '?')
          : ('В имейла има кирилица. Български „а“, „о“ или „е“ изглеждат ' +
             'като латинските, но пощата не стига. Напишете адреса на латиница.')
      };
    }

    if (!SHAPE.test(value) || !TLD.test(value)) {
      return {
        ok: false, reason: 'format', suggestion: null,
        message: 'Този адрес не изглежда като имейл. Проверете дали има @ и завършек като .bg или .com.'
      };
    }

    var at = value.lastIndexOf('@');
    var local = value.slice(0, at);
    var domain = value.slice(at + 1).toLowerCase();

    if (local.length > 64 || value.length > 254) {
      return { ok: false, reason: 'format', suggestion: null,
               message: 'Този адрес е твърде дълъг, за да е истински.' };
    }
    if (/\.\./.test(value) || /^\./.test(local) || /\.$/.test(local)) {
      return { ok: false, reason: 'format', suggestion: null,
               message: 'Има излишна точка в адреса. Проверете го още веднъж.' };
    }

    var near = nearestDomain(domain);
    if (near) {
      return {
        ok: false, reason: 'typo', suggestion: local + '@' + near,
        message: 'Имахте предвид ' + local + '@' + near + '?'
      };
    }

    return { ok: true, reason: null, message: null, suggestion: null };
  }

  global.TLAEmail = { check: check, knownDomains: KNOWN };

})(typeof window !== 'undefined' ? window : globalThis);
