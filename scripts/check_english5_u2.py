#!/usr/bin/env python3
"""Проверката на трите листа за Unit 2 — по друг път, не по същия.

Сглобяването (scripts/build_english5_u2.py) ражда формите по правила.
Ако проверката ползваше СЪЩИТЕ правила, тя нямаше да доказва нищо:
една и съща грешка щеше да мине и през двете. Затова тук:

  · третото лице с -s се сверява с таблица, написана на ръка —
    независим източник, а не същата функция;
  · at / on / in се сверява по вида на израза, записан в задачата;
  · мястото на наречието и на also се проверява СТРУКТУРНО в готовото
    изречение: думата трябва да стои точно преди главния глагол или
    точно след be;
  · отрицанието се разглобява наново и се сравнява с утвърдителното;
  · въпросите за подреждане се сверяват дума по дума;
  · кратките отговори се разчитат с израз и се сверяват с лицето;
  · при „хвани грешката“ подменените думи трябва ТОЧНО да дават вярното,
    а сгрешеното наистина да нарушава съгласуването;
  · речниковите двойки се сверяват с отделен списък.

    /usr/bin/python3.13 scripts/check_english5_u2.py
"""
import json
import pathlib
import re
import sys

KOREN = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from english.build import broi_redove, za_ocenka                  # noqa: E402
from english5 import u2_den, u2_praznik, u2_prosto                # noqa: E402
import build_english5_u2 as B                                      # noqa: E402

PROVERKI = 0
GRESHKI = []


def tvurdi(uslovie, kakvo):
    global PROVERKI
    PROVERKI += 1
    if not uslovie:
        GRESHKI.append(kakvo)


#  Третото лице — написано на ръка, не изведено с правило.
S_FORMI = {
    'watch': 'watches', 'go': 'goes', 'study': 'studies', 'play': 'plays',
    'do': 'does', 'have': 'has', 'finish': 'finishes', 'fly': 'flies',
    'teach': 'teaches', 'get': 'gets', 'rain': 'rains', 'brush': 'brushes',
    'start': 'starts', 'make': 'makes', 'bring': 'brings', 'say': 'says',
    'wear': 'wears', 'celebrate': 'celebrates', 'dance': 'dances',
    'decorate': 'decorates', 'visit': 'visits', 'sing': 'sings',
    'give': 'gives', 'be': 'is', 'like': 'likes', 'work': 'works',
    'live': 'lives', 'read': 'reads',
}

#  Речникът — отделен списък, не същият, от който се сглобява.
RECHNIK = {
    'get up': 'ставам', 'have breakfast': 'закусвам',
    'go to school': 'отивам на училище', 'have classes': 'имам часове',
    'study': 'уча', 'do homework': 'пиша домашно',
    'watch TV': 'гледам телевизия', 'go to bed': 'лягам си',
    'sing': 'пея', 'dance': 'танцувам', 'wear': 'нося (дреха)',
    'give': 'подарявам', 'get': 'получавам', 'celebrate': 'празнувам',
    'decorate': 'украсявам', 'visit': 'гостувам на',
}

PROCENTI = {'always': '100%', 'usually': '80%', 'often': '60%',
            'sometimes': '30%', 'never': '0%'}

BE = ('is', 'are', 'am')


def glagolut(dumi):
    """Главният глагол в изречението и мястото му."""
    for i, d in enumerate(dumi):
        if d.lower() in BE:
            return i, 'be'
    for i, d in enumerate(dumi):
        nisko = d.lower().strip('.,?!')
        if nisko in S_FORMI or nisko in S_FORMI.values():
            return i, 'glagol'
    return -1, None


# ── лист 1 ───────────────────────────────────────────────────────────
def list_den():
    m = u2_den
    for bg, en in m.DVOJKI:
        tvurdi(RECHNIK.get(en) == bg,
               'ден · речник: „{}“ не е „{}“'.format(en, bg))
    tvurdi(len(m.DVOJKI) == 8, 'ден: двойките не са осем')

    #  at / on / in по вида на израза.
    po_vid = {'chas': 'at', 'den': 'on', 'chast': 'in'}
    for izraz, otg, vid, zashto in m.PREDLOZI:
        if vid == 'izklyuchenie':
            tvurdi(otg == 'at',
                   'ден · предлози: изключението не е с at: ' + izraz)
            tvurdi(any(d in izraz for d in ('weekend', 'night')),
                   'ден · предлози: непознато изключение: ' + izraz)
        else:
            tvurdi(po_vid[vid] == otg,
                   'ден · предлози: „{}“ е {} → иска {}, записано {}'.format(
                       izraz, vid, po_vid[vid], otg))
        tvurdi(len(zashto) >= 20, 'ден · предлози: късо обяснение: ' + izraz)
    tvurdi(len(m.PREDLOZI) == 8, 'ден: предлозите не са осем')

    for adv, proc in m.CHESTOTA:
        tvurdi(PROCENTI.get(adv) == proc,
               'ден · честота: {} не е {}'.format(adv, proc))
    tvurdi([a for a, _ in m.CHESTOTA] ==
           ['always', 'usually', 'often', 'sometimes', 'never'],
           'ден: наречията не вървят от най-често към най-рядко')

    #  Мястото на наречието — структурно, в готовото изречение.
    for razb, vqrno, narechie in m.MQSTO:
        chasti = sorted(d.lower() for d in razb.split(' / '))
        otg = sorted(w.strip('.,').lower() for w in vqrno.rstrip('.?').split())
        tvurdi(chasti == otg,
               'ден · ред: „{}“ не е същите думи като „{}“'.format(razb, vqrno))
        dumi = vqrno.rstrip('.?').split()
        i_adv = [i for i, d in enumerate(dumi) if d.lower() == narechie]
        tvurdi(len(i_adv) == 1, 'ден · ред: наречието не е точно веднъж: ' + vqrno)
        if i_adv:
            i = i_adv[0]
            i_gl, vid = glagolut(dumi)
            tvurdi(i_gl != -1, 'ден · ред: не се намира глагол в: ' + vqrno)
            if vid == 'be':
                tvurdi(i == i_gl + 1,
                       'ден · ред: при be наречието застава СЛЕД него: ' + vqrno)
            else:
                tvurdi(i == i_gl - 1,
                       'ден · ред: наречието застава точно пред глагола: ' + vqrno)
    tvurdi(len(m.MQSTO) == 6, 'ден: изреченията за подреждане не са шест')

    #  Разказът: всяка дупка се сверява с подлога си.
    nomera = [int(x) for x in re.findall(r'\{(\d+)\}', m.TEKST)]
    tvurdi(nomera == list(range(1, 11)), 'ден · разказ: дупките не са 1..10')
    tvurdi(len(m.DUPKI) == 10, 'ден · разказ: отговорите не са десет')
    polzvani = []
    for n, otg, podlog, vid, zashto in m.DUPKI:
        if vid == 'glagol':
            osnova = [g for g, f in S_FORMI.items() if f == otg or g == otg]
            tvurdi(osnova, 'ден · разказ {}: непознат глагол {}'.format(n, otg))
            if osnova:
                g = osnova[0]
                edin = B.edinstveno(podlog)
                trqbva = S_FORMI[g] if edin else g
                tvurdi(otg == trqbva,
                       'ден · разказ {}: „{}“ иска {}, записано {}'.format(
                           n, podlog, trqbva, otg))
        else:
            tvurdi(otg.lower() in ('at', 'on', 'in'),
                   'ден · разказ {}: не е предлог: {}'.format(n, otg))
        tvurdi(len(zashto) >= 15, 'ден · разказ {}: късо обяснение'.format(n))
        polzvani.append(otg)
    tvurdi(sorted(polzvani) == sorted(m.KUTIQ),
           'ден · разказ: Word Box не съвпада с отговорите')


# ── лист 2 ───────────────────────────────────────────────────────────
def list_prosto():
    m = u2_prosto
    for g in m.GLAGOLI:
        tvurdi(g in S_FORMI, 'present: непознат глагол ' + g)
        if g in S_FORMI:
            tvurdi(B.treto_lice(g) == S_FORMI[g],
                   'present · -s: {} → таблицата казва {}, правилото дава {}'.format(
                       g, S_FORMI[g], B.treto_lice(g)))
    tvurdi(len(m.GLAGOLI) == 10, 'present: глаголите не са десет')
    #  Всички четири случая на правилото трябва да са представени.
    vidove = {
        'es': [g for g in m.GLAGOLI if S_FORMI[g].endswith('es')
               and not S_FORMI[g].endswith('ies')],
        'ies': [g for g in m.GLAGOLI if S_FORMI[g].endswith('ies')],
        's': [g for g in m.GLAGOLI if S_FORMI[g] == g + 's'],
        'osoben': [g for g in m.GLAGOLI if g == 'have'],
    }
    for ime, spisuk in vidove.items():
        tvurdi(spisuk, 'present: липсва случай „{}“ в глаголите'.format(ime))

    for izr, podlog, g in m.FORMA:
        tvurdi('__' in izr, 'present · форма: няма празно място: ' + izr)
        #  Подлогът, записан в задачата, трябва да е ТОЗИ от изречението —
        #  иначе формата се извежда от чужда дума.
        tvurdi(izr.lower().startswith(podlog.lower()),
               'present · форма: „{}“ не е подлогът на „{}“'.format(podlog, izr))
        trqbva = S_FORMI[g] if B.edinstveno(podlog) else g
        tvurdi(B.formata(podlog, g) == trqbva,
               'present · форма: „{}“ иска {}'.format(podlog, trqbva))
    tvurdi(len(m.FORMA) == 8, 'present: изреченията за форма не са осем')

    for izr, podlog, g in m.OTRICANIE:
        otr = B.otricanie(izr, podlog, g)
        ne = 'doesn’t' if B.edinstveno(podlog) else 'don’t'
        tvurdi(ne + ' ' + g in otr,
               'present · отрицание: „{}“ трябва да съдържа „{} {}“'.format(otr, ne, g))
        tvurdi(S_FORMI[g] not in otr.split() or g == S_FORMI[g],
               'present · отрицание: -s формата е останала: ' + otr)
        #  Отрицанието е утвърдителното с подменен глагол — нищо друго.
        a = izr.rstrip('.').split()
        b = otr.rstrip('.').split()
        tvurdi(len(b) == len(a) + 1,
               'present · отрицание: сменени са повече думи: ' + otr)
    tvurdi(len(m.OTRICANIE) == 6, 'present: отрицанията не са шест')

    for razb, vqrno in m.VUPROSI:
        chasti = sorted(d.lower() for d in razb.split(' / ') if d != '?')
        otg = sorted(w.strip('.,?').lower() for w in vqrno.rstrip('?').split())
        tvurdi(chasti == otg,
               'present · въпрос: „{}“ не е същите думи като „{}“'.format(razb, vqrno))
        tvurdi(vqrno.endswith('?'), 'present · въпрос: липсва въпросителен знак')
        tvurdi(re.search(r'\b[Dd]o(es)?\b', vqrno),
               'present · въпрос: няма do или does: ' + vqrno)
    tvurdi(len(m.VUPROSI) == 6, 'present: въпросите не са шест')

    for v, podlog, da in m.KRATKI:
        otg = B.kratuk(podlog, da)
        mm = re.fullmatch(r'(Yes|No), (\w+) (do|does|don’t|doesn’t)\.', otg)
        tvurdi(mm is not None, 'present · кратък: странна форма: ' + otg)
        if mm:
            tvurdi((mm.group(1) == 'Yes') == da,
                   'present · кратък: да и не не съвпадат: ' + otg)
            edin = podlog.lower() in ('he', 'she', 'it')
            ochakvan = ('does' if edin else 'do') if da else \
                       ('doesn’t' if edin else 'don’t')
            tvurdi(mm.group(3) == ochakvan,
                   'present · кратък: „{}“ иска {}, а е {}'.format(
                       podlog, ochakvan, mm.group(3)))
        tvurdi(v.startswith(('Do ', 'Does ')),
               'present · кратък: въпросът не започва с Do/Does: ' + v)
        #  Do ↔ does не бива да се разминават между въпрос и отговор.
        s_does = v.startswith('Does ')
        tvurdi(s_does == (podlog.lower() in ('he', 'she', 'it')),
               'present · кратък: въпросът и отговорът са за различно лице: ' + v)
    tvurdi(len(m.KRATKI) == 6, 'present: кратките отговори не са шест')

    for izr, vqrno, zashto in m.GRESHKI:
        r = B.greshka_red(izr, vqrno, zashto)
        a = izr.rstrip('?.!').split()
        b = vqrno.rstrip('?.!').split()
        sglobeno = list(a)
        for i in r['greshni']:
            sglobeno[i] = b[i]
        tvurdi(' '.join(sglobeno) + r['krai'] == vqrno,
               'present · грешка: посочените думи не дават вярното: ' + izr)
        tvurdi(len(r['greshni']) == 1,
               'present · грешка: сгрешената дума не е точно една: ' + izr)
        tvurdi(suglasuvano(vqrno), 'present · грешка: поправеното пак куца: ' + vqrno)
        tvurdi(not suglasuvano(izr),
               'present · грешка: сгрешеното не нарушава нищо: ' + izr)
        tvurdi(len(zashto) >= 20, 'present · грешка: късо обяснение: ' + izr)
    tvurdi(len(m.GRESHKI) == 8, 'present: грешките не са осем')


def suglasuvano(izr: str) -> bool:
    """Спазва ли изречението правилата на present simple."""
    t = izr.rstrip('?.!')
    dumi = t.split()
    #  Дума, която прилича на -s форма, но не е правилната: studys вместо
    #  studies. Хваща се навсякъде в изречението, преди всичко останало.
    for d in dumi:
        g = d.lower().strip('.,?!')
        if (g.endswith('s') and g not in S_FORMI and g not in S_FORMI.values()
                and g[:-1] in S_FORMI and S_FORMI[g[:-1]] != g):
            return False
    #  Въпрос: Do/Does + подлог + основна форма. Подлогът стига ДОКЪДЕТО
    #  започне глаголът — иначе „your friends“ се реже на „your“ и
    #  проверката съди по грешна дума.
    if dumi and dumi[0] in ('Do', 'Does'):
        i_gl = -1
        for k in range(1, len(dumi)):
            d = dumi[k].lower().strip('.,?!')
            if d in S_FORMI or d in S_FORMI.values():
                i_gl = k
                break
        if i_gl > 1:
            podlog = ' '.join(dumi[1:i_gl])
            g = dumi[i_gl].lower().strip('.,?!')
            if (dumi[0] == 'Does') != B.edinstveno(podlog):
                return False
            if g in S_FORMI.values() and g not in S_FORMI:
                return False      # след do/does глаголът не бива да е с -s
        return True
    #  Отрицание: подлог + don't/doesn't + основна форма.
    mm = re.search(r'^(.+?)\s+(don’t|doesn’t)\s+(\w+)', t)
    if mm:
        edin = B.edinstveno(mm.group(1))
        if (mm.group(2) == 'doesn’t') != edin:
            return False
        g = mm.group(3).lower()
        return not (g in S_FORMI.values() and g not in S_FORMI)
    #  Утвърдително: подлог + глагол.
    i, vid = glagolut(dumi)
    if i <= 0:
        return True
    podlog = ' '.join(dumi[:i])
    g = dumi[i].lower()
    edin = B.edinstveno(podlog)
    osnova = [k for k, v in S_FORMI.items() if v == g or k == g]
    if not osnova:
        #  Дума, която прилича на -s форма, но не е нито основна, нито
        #  правилната: studys вместо studies. Това е грешка, не непознат
        #  глагол — и трябва да се хване.
        if g.endswith('s') and g[:-1] in S_FORMI and S_FORMI[g[:-1]] != g:
            return False
        return True
    k = osnova[0]
    return g == (S_FORMI[k] if edin else k)


# ── лист 3 ───────────────────────────────────────────────────────────
def list_praznik():
    m = u2_praznik
    for bg, en in m.DVOJKI:
        tvurdi(RECHNIK.get(en) == bg,
               'празник · речник: „{}“ не е „{}“'.format(en, bg))
    tvurdi(len(m.DVOJKI) == 8, 'празник: двойките не са осем')

    for izr, v, drugi, zashto in m.GLAGOLI:
        tvurdi(v not in drugi, 'празник · глаголи: верният е и сред примамките')
        tvurdi(len(drugi) == 2, 'празник · глаголи: примамките не са две')
        tvurdi('__' in izr, 'празник · глаголи: няма празно място')
        #  Подлогът е думата ТОЧНО преди празното място, а не началото на
        #  изречението: в „At the party everybody __…“ командва everybody.
        predi = izr.split('__')[0].strip().rstrip(',').split()
        tvurdi(predi, 'празник · глаголи: няма подлог пред празното място')
        if predi:
            podlog = predi[-1]
            edin = B.edinstveno(podlog)
            osnova = [k for k, f in S_FORMI.items() if f == v or k == v]
            tvurdi(osnova, 'празник · глаголи: непознат глагол ' + v)
            if osnova:
                trqbva = S_FORMI[osnova[0]] if edin else osnova[0]
                tvurdi(v == trqbva,
                       'празник · глаголи: „{}“ иска {}, записано {}'.format(
                           podlog, trqbva, v))
        tvurdi(len(zashto) >= 20, 'празник · глаголи: късо обяснение')
    tvurdi(len(m.GLAGOLI) == 6, 'празник: глаголите не са шест')

    for izr, v, drugi, zashto in m.PLANOVE + m.OTGOVORI:
        tvurdi(v not in drugi, 'празник · избор: верният е и сред примамките')
        tvurdi(len(drugi) == 2, 'празник · избор: примамките не са две')
        tvurdi(len(zashto) >= 20, 'празник · избор: късо обяснение')
    tvurdi(len(m.PLANOVE) == 6, 'празник: предложенията не са шест')
    tvurdi(len(m.OTGOVORI) == 5, 'празник: отговорите не са пет')

    for razb, vqrno in m.ALSO:
        chasti = sorted(d.lower() for d in razb.split(' / '))
        otg = sorted(w.strip('.,').lower() for w in vqrno.rstrip('.').split())
        tvurdi(chasti == otg,
               'празник · also: „{}“ не е същите думи като „{}“'.format(razb, vqrno))
        dumi = vqrno.rstrip('.').split()
        i = [k for k, d in enumerate(dumi) if d.lower() == 'also']
        tvurdi(len(i) == 1, 'празник · also: не е точно веднъж: ' + vqrno)
        if i:
            i_gl, vid = glagolut(dumi)
            tvurdi(i_gl != -1, 'празник · also: не се намира глагол: ' + vqrno)
            if vid == 'be':
                tvurdi(i[0] == i_gl + 1,
                       'празник · also: при be застава след него: ' + vqrno)
            else:
                tvurdi(i[0] == i_gl - 1,
                       'празник · also: застава точно пред глагола: ' + vqrno)
    tvurdi(len(m.ALSO) == 5, 'празник: изреченията с also не са пет')

    nomera = [int(x) for x in re.findall(r'\{(\d+)\}', m.TEKST)]
    tvurdi(nomera == list(range(1, 9)), 'празник · текст: дупките не са 1..8')
    polzvani = []
    for n, otg, podlog, zashto in m.DUPKI:
        if otg == 'don’t':
            tvurdi(not B.edinstveno(podlog),
                   'празник · текст {}: „{}“ иска doesn’t'.format(n, podlog))
        else:
            osnova = [k for k, s in S_FORMI.items() if s == otg or k == otg]
            tvurdi(osnova, 'празник · текст {}: непознат глагол {}'.format(n, otg))
            if osnova:
                edin = B.edinstveno(podlog)
                trqbva = S_FORMI[osnova[0]] if edin else osnova[0]
                tvurdi(otg == trqbva,
                       'празник · текст {}: „{}“ иска {}, записано {}'.format(
                           n, podlog, trqbva, otg))
        tvurdi(len(zashto) >= 15, 'празник · текст {}: късо обяснение'.format(n))
        polzvani.append(otg)
    tvurdi(sorted(polzvani) == sorted(m.KUTIQ),
           'празник · текст: Word Box не съвпада с отговорите')

    for v, o in m.SVOBODNI:
        tvurdi(v.endswith('?'), 'празник · свободни: въпросът няма знак: ' + v)
        tvurdi(len(o.split()) >= 4 and o.endswith('.'),
               'празник · свободни: образецът не е цяло изречение: ' + o)
    tvurdi(len(m.SVOBODNI) == 4, 'празник: свободните въпроси не са четири')


# ── общото за трите ──────────────────────────────────────────────────
def izborite():
    """Упражнение, в което всеки избор минава за верен, не учи нищо."""
    for danni, pat in B.vsichki():
        for u in danni['upr']:
            if u['vid'] != 'tap':
                continue
            for n, r in enumerate(u['redove'], 1):
                izbori = r.get('izbori') or u.get('izbori') or []
                priemani = {r['otgovor']} | set(r.get('oshte', []))
                kade = '{} · {} · ред {}'.format(pat.name, u['ime'], n)
                tvurdi(len(izbori) >= 2, kade + ': изборите са по-малко от два')
                tvurdi(r['otgovor'] in izbori, kade + ': верният не е сред изборите')
                tvurdi(priemani <= set(izbori), kade + ': приема се отговор, който го няма')
                tvurdi(len(priemani) < len(izbori),
                       kade + ': всеки избор минава за верен')


def stranicite():
    znaka = 0
    for danni, pat in B.vsichki():
        s = pat.read_text(encoding='utf-8')
        znaka += len(s)
        kade = pat.name

        i = s.index('/* ДАННИ:НАЧАЛО')
        kraj = s.index('*/', i) + 2
        tvurdi('\n' not in s[i:kraj], kade + ': маркерът не затваря коментара си')
        d = json.loads(s[s.index('const DANNI = ') + len('const DANNI = '):
                         s.index(';\n/* ДАННИ:КРАЙ */')])
        tvurdi(d['slug'] == danni['slug'], kade + ': слугът не съвпада')
        tvurdi(len(danni['upr']) <= 10, kade + ': упражненията са повече от десет')
        tvurdi(d['shapka'] in ('den', 'baloni', 'praznik'),
               kade + ': непозната шапка ' + str(d.get('shapka')))
        tvurdi("function " + {'den': 'den', 'baloni': 'balon',
                              'praznik': 'praznik'}[d['shapka']] + "(" in s,
               kade + ': рисунката на шапката липсва от страницата')

        for parche in ('assets/supabase-config.js', 'assets/auth.js',
                       'TLA.requireAuth()', 'TLA.saveAttempt(DANNI.slug',
                       'id="gate"', 'id="sheet"', 'id="checkBtn"'):
            tvurdi(parche in s, kade + ': липсва ' + parche)
        tvurdi('Unit 2' in s, kade + ': никъде не пише Unit 2')
        tvurdi(s.rstrip().endswith('</html>'), kade + ': не завършва с </html>')

        for u in danni['upr']:
            if u['vid'] == 'svoboden':
                continue
            if u['vid'] == 'razkaz':
                for dd in u['dupki']:
                    tvurdi(json.dumps(dd['otgovor'], ensure_ascii=False)[1:-1] in s,
                           kade + ': липсва отговор ' + dd['otgovor'])
                continue
            if u['vid'] == 'dvoiki':
                continue
            for r in u['redove']:
                otg = r['vqrno'] if u['vid'] == 'greshka' else r['otgovor']
                tvurdi(json.dumps(otg, ensure_ascii=False)[1:-1] in s,
                       kade + ': липсва отговор ' + otg)

    sql = (KOREN / 'supabase/domashni-angliyski-5-u2.sql').read_text(encoding='utf-8')
    for danni, pat in B.vsichki():
        tvurdi("'" + danni['slug'] + "'" in sql, 'SQL: липсва слугът ' + danni['slug'])
        tvurdi("'" + pat.name + "'" in sql, 'SQL: липсва файлът ' + pat.name)
    tvurdi("'ep1_unit2'" in sql, 'SQL: домашните не влизат в Unit 2')
    tvurdi('angliiski' in sql, 'SQL: предметът не е английският')
    return znaka


def main():
    list_den()
    list_prosto()
    list_praznik()
    izborite()

    listove = B.vsichki()
    tvurdi(len(listove) == 3, 'листовете не са три')
    avto = sum(za_ocenka(u) for d, _ in listove for u in d['upr'])
    ruch = sum(broi_redove(u) for d, _ in listove for u in d['upr']
               if u['vid'] == 'svoboden')
    tvurdi(avto == 119, 'автоматичните задачи не са 119, а ' + str(avto))
    tvurdi(ruch == 4, 'за ръчна оценка не са 4, а ' + str(ruch))
    znaka = stranicite()

    if GRESHKI:
        print('ГРЕШКИ ({}):'.format(len(GRESHKI)))
        for g in GRESHKI:
            print('  ·', g)
        sys.exit(1)
    print('всичко е вярно · проверки: {} · листа: {} · задачи: {} + {} за ръчна '
          'оценка · {} знака'.format(PROVERKI, len(listove), avto, ruch, znaka))


if __name__ == '__main__':
    main()
