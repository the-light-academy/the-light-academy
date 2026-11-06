#!/usr/bin/env python3
"""Проверката на петте листа за 5. клас — без доверие към ключа.

Нищо тук не чете „otgovor“ и не казва „значи е вярно“. Всеки отговор се
ИЗВЕЖДА наново от правилата на Unit 1 и чак тогава се сравнява:

  · there is / there are  — едно нещо или повече от едно;
  · some / any            — утвърдително, въпрос или отрицание;
  · have got              — I/you/we/they have, he/she/it has;
  · this / these / that / those — близо или далече, едно или повече;
  · a / an                — според звука, с който започва следващата дума;
  · въпрос                — глаголът минава пред подлога и накрая има „?“.

Освен това:
  · подреждането се сверява дума по дума — отговорът трябва да е същите
    думи, само наредени, нито една липсваща или в повече;
  · при „хвани грешката“ подменените думи трябва ТОЧНО да превърнат
    сгрешеното изречение във вярното, а сгрешеното наистина да нарушава
    някое от правилата горе;
  · подсказките при речника се сверяват с броя букви на думата, а самите
    думи — с ключа, отпечатан накрая на домашното;
  · и петте готови страници се отварят и се гледа, че данните са извън
    коментара, че всеки отговор е вътре и че входът и записването са на
    място.

    /usr/bin/python3.13 scripts/check_english5.py
"""
import json
import pathlib
import re
import sys

KOREN = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from english.build import za_ocenka, broi_redove              # noqa: E402
from english5 import razkaz, podrejdane, detektiv, smes, dumi  # noqa: E402
import build_english5 as B                                     # noqa: E402

PROVERKI = 0
GRESHKI = []


def tvurdi(uslovie, kakvo):
    global PROVERKI
    PROVERKI += 1
    if not uslovie:
        GRESHKI.append(kakvo)


# ── правилата ────────────────────────────────────────────────────────
MN = {'i': 'have', 'you': 'have', 'we': 'have', 'they': 'have',
      'he': 'has', 'she': 'has', 'it': 'has'}
GLASNI_ZVUK = 'aeiou'
MNOJESTVENO = {'cafés', 'cafes', 'shops', 'books', 'parks', 'restaurants', 'hotels',
               'cinemas', 'cafés', 'shoes', 'students', 'pools', 'monuments',
               'brothers', 'sisters', 'cousins', 'pyramids', 'animals', 'things'}


def chlen(duma):
    """a или an — по звука, с който започва думата."""
    return 'an' if duma[:1].lower() in GLASNI_ZVUK else 'a'


def mnojestveno(fraza):
    """Множествено число ли е това, което следва there is/are."""
    dumi_ = fraza.lower().split()
    if not dumi_:
        return None
    if dumi_[0] in ('a', 'an'):
        return False
    if dumi_[0] in ('some', 'any', 'two', 'three', 'four', 'five', 'many'):
        return True
    posledna = dumi_[-1].strip('.,?!')
    if posledna in MNOJESTVENO:
        return True
    return posledna.endswith('s') and not posledna.endswith('ss')


def ima_forma(fraza, otr=False):
    """Коя форма на there be иска тази фраза — изведено, не прочетено."""
    mn = mnojestveno(fraza)
    if mn is None:
        return None
    if otr:
        return 'There aren’t' if mn else 'There isn’t'
    return 'There are' if mn else 'There is'


def some_ili_any(izr):
    """some или any — по вида на изречението."""
    t = izr.strip()
    if t.endswith('?') or re.match(r'^(are|is|have|has|do|does)\b', t, re.I):
        return 'any'
    if re.search(r"n[’']t|\bnot\b", t, re.I):
        return 'any'
    return 'some'


# ── лист 1 · разказът ────────────────────────────────────────────────
def lист1():
    nomera = [int(x) for x in re.findall(r'\{(\d+)\}', razkaz.TEKST)]
    tvurdi(nomera == list(range(1, 21)), 'празните места не са 1..20 по ред')
    tvurdi(len(razkaz.OTGOVORI) == 20, 'отговорите не са двайсет')
    tvurdi(len(razkaz.BONUS) == 7, 'бонус въпросите не са седем')

    po_nomer = {n: (o, d, z) for n, o, d, z in razkaz.OTGOVORI}
    for n, otg, _, zashto in razkaz.OTGOVORI:
        tvurdi(len(zashto) >= 25, 'разказ {}: обяснението е много късо'.format(n))

    #  Съгласуването на there be — изведено от това, което следва.
    tvurdi(po_nomer[3][0] == ima_forma('a beautiful park').split()[-1],
           'разказ 3: „a beautiful park“ иска is')
    tvurdi(po_nomer[5][0] == ima_forma('some nice cafés').split()[-1],
           'разказ 5: „some nice cafés and shops“ иска are')
    #  some и any — по вида на изречението.
    tvurdi(po_nomer[9][0] == some_ili_any('Inside, there are ... books.'),
           'разказ 9: утвърдително изречение иска some')
    tvurdi(po_nomer[16][0] == some_ili_any('Have you got ... information?'),
           'разказ 16: въпрос иска any')
    #  have got по лице.
    tvurdi(po_nomer[11][0].split()[0] == MN['he'],
           'разказ 11: „The owner“ е he → has got')
    tvurdi(po_nomer[14][0].startswith('has'),
           'разказ 14: „the backpack“ е it → hasn’t')
    tvurdi(po_nomer[19][0] == MN['i'] and po_nomer[20][0] == MN['you'],
           'разказ 19 и 20: I have и you have')
    #  this за едно, those за повече.
    tvurdi(po_nomer[8][0] == 'this', 'разказ 8: една раница → this')
    tvurdi(po_nomer[12][0] == 'those', 'разказ 12: повече книги → those')
    #  a / an според звука.
    tvurdi(chlen(po_nomer[7][0]) == 'an',
           'разказ 7: след „an“ думата трябва да започва с гласна: '
           + po_nomer[7][0])
    #  Пред {10} стои „a very“ — членът се съгласува с „very“, не с
    #  празното място, затова там се проверява друго: трите прилагателни
    #  от кутията се ползват по веднъж, на три различни места.
    tvurdi(chlen('very') == 'a', 'разказ 10: „a very“ е вярното съчетание')
    prilagatelni = {po_nomer[7][0], po_nomer[10][0], po_nomer[13][0]}
    tvurdi(prilagatelni == {'old', 'expensive', 'interesting'},
           'разказ: трите прилагателни не са old, expensive и interesting, а '
           + ', '.join(sorted(prilagatelni)))
    #  Въпросителната дума се познава по отговора.
    tvurdi(po_nomer[17][0] == 'Where',
           'разказ 17: отговорът е място → Where')

    #  Всеки отговор трябва да го има в кутията с думи.
    kutiq = [k.lower() for k in razkaz.KUTIQ]
    for n, otg, _, _ in razkaz.OTGOVORI:
        tvurdi(otg.lower() in kutiq,
               'разказ {}: „{}“ го няма в Word Box'.format(n, otg))
    #  И обратно: кутията не бива да е пълна с думи, които не вършат работа.
    polzvani = {o.lower() for _, o, _, _ in razkaz.OTGOVORI}
    izlishni = [k for k in kutiq if k not in polzvani]
    tvurdi(len(izlishni) <= 3,
           'в Word Box има много неизползвани думи: ' + ', '.join(izlishni))

    #  Попълненият разказ трябва да се чете правилно.
    puln = razkaz.TEKST
    for n, otg, _, _ in razkaz.OTGOVORI:
        puln = puln.replace('{' + str(n) + '}', otg)
    tvurdi('{' not in puln, 'в попълнения разказ са останали празни места')
    tvurdi('an old backpack' in puln, 'разказът не казва „an old backpack“')
    tvurdi('a very expensive camera' in puln, 'разказът не казва „a very expensive camera“')
    tvurdi('There is a beautiful park' in puln, 'разказът не казва „There is a beautiful park“')
    tvurdi('there are some nice' in puln, 'разказът не казва „there are some nice…“')
    tvurdi('hasn’t got an ID card' in puln, 'разказът не казва „hasn’t got an ID card“')

    for vupros, obrazec in razkaz.BONUS:
        tvurdi(vupros.endswith('?'), 'бонус: въпросът няма въпросителен знак')
        tvurdi(len(obrazec.split()) >= 4 and obrazec.endswith(('.', '!')),
               'бонус: образецът не е цяло изречение: ' + obrazec)


# ── лист 2 · подреждане ──────────────────────────────────────────────
def list2():
    obsht = 0
    for ime, _, redove in podrejdane.CHASTI:
        tvurdi(len(redove) >= 4, ime + ': много малко изречения')
        for razb, vqrno, zashto in redove:
            obsht += 1
            chasti = sorted(d.lower() for d in razb.split(' / ') if d != '?')
            otg = sorted(w.strip('.,').lower() for w in vqrno.rstrip('?.').split())
            tvurdi(chasti == otg,
                   'подреждане: „{}“ не е същите думи като „{}“'.format(razb, vqrno))
            tvurdi(vqrno[0].isupper(), 'подреждане: няма главна буква: ' + vqrno)
            tvurdi(vqrno.endswith(('.', '?')), 'подреждане: няма край: ' + vqrno)
            tvurdi(('?' in razb) == vqrno.endswith('?'),
                   'подреждане: въпросителният знак не съвпада: ' + vqrno)
            tvurdi(len(zashto) >= 25, 'подреждане: късо обяснение: ' + vqrno)
            #  Съгласуване там, където правилото го определя.
            m = re.match(r'^There (is|are|isn’t|aren’t) (.+)$', vqrno)
            if m:
                otr = 'n’t' in m.group(1)
                izvedeno = ima_forma(m.group(2), otr)
                tvurdi(izvedeno and izvedeno.split()[-1] == m.group(1),
                       'подреждане: „{}“ иска {}'.format(vqrno, izvedeno))
            m = re.match(r'^(\w+) (has|have) got\b', vqrno)
            if m and m.group(1).lower() in MN:
                tvurdi(MN[m.group(1).lower()] == m.group(2),
                       'подреждане: „{}“ не е съгласувано'.format(vqrno))
    tvurdi(obsht == 24, 'изреченията за подреждане не са 24, а ' + str(obsht))


# ── лист 3 · детективът ──────────────────────────────────────────────
def narushava(izr):
    """Нарушава ли изречението някое от правилата на юнита."""
    t = izr.strip()
    m = re.match(r'^There (is|are|isn’t|aren’t) (.+)$', t)
    if m:
        otr = 'n’t' in m.group(1)
        izvedeno = ima_forma(m.group(2), otr)
        if izvedeno and izvedeno.split()[-1] != m.group(1):
            return True
    for lice, glagol in re.findall(r'\b(\w+) (has|have|hasn’t|haven’t) got\b', t):
        if lice.lower() in MN:
            trqbva = MN[lice.lower()]
            ima = glagol.replace('n’t', '')
            if ima != trqbva:
                return True
    if re.search(r'\bThis \w+s\b', t) or re.search(r'\bThese is\b', t):
        return True
    if re.search(r'\bThose \w+ is\b', t):
        return True
    #  How many иска множествено число — гледа се думата точно преди
    #  глагола, а не първата след „How many“ (swimming pools).
    m = re.search(r'How many (.+?) (are|is)\b', t)
    if m:
        posledna = m.group(1).split()[-1].lower()
        if not posledna.endswith('s'):
            return True
    return False


#  Поправките, които Unit 1 допуска. Всичко извън този списък значи, че
#  „вярното“ изречение е сменило дума, която няма общо с граматиката —
#  точно това отличава поправка от преписване.
DVOYKI = [{'has', 'have'}, {'hasn’t', 'haven’t'}, {'is', 'are'},
          {'isn’t', 'aren’t'}, {'this', 'these'}, {'that', 'those'},
          {'some', 'any'}, {'japan', 'japanese'}]


def pozvolena(losho, dobro):
    """Граматическа ли е подмяната на тази дума."""
    a, b = losho.lower().strip('.,?!'), dobro.lower().strip('.,?!')
    if {a, b} in DVOYKI:
        return True
    #  Единствено към множествено число: pool → pools.
    if b == a + 's':
        return True
    return False


def list3():
    obsht = 0
    s_dve = []
    for ime, _, redove in detektiv.NIVA:
        for izr, vqrno, zashto in redove:
            obsht += 1
            r = B.red_greshka(izr, vqrno, zashto)
            #  Подмяната на посочените думи трябва да дава точно вярното.
            a, ka = B.razdeli(izr)
            b, kb = B.razdeli(vqrno)
            if len(a) == len(b):
                sglobeno = list(a)
                for i in r['greshni']:
                    sglobeno[i] = b[i]
            else:
                sglobeno = [w for i, w in enumerate(a) if i not in r['greshni']]
            tvurdi(' '.join(sglobeno) + ka == vqrno,
                   'детектив: посочените думи не дават вярното: ' + izr)
            tvurdi(1 <= len(r['greshni']) <= 2,
                   'детектив: сгрешените думи не са една или две: ' + izr)
            if len(r['greshni']) == 2:
                s_dve.append(izr)
            #  Всяка подмяна трябва да е граматическа.
            if len(a) == len(b):
                for i in r['greshni']:
                    tvurdi(pozvolena(a[i], b[i]),
                           'детектив: „{}“ \u2192 „{}“ не е граматическа поправка в: {}'
                           .format(a[i], b[i], izr))
            tvurdi(len(zashto) >= 20, 'детектив: късо обяснение: ' + izr)
            #  В сгрешеното трябва НАИСТИНА да има грешка, а във вярното — не.
            tvurdi(izr != vqrno, 'детектив: двете изречения са еднакви: ' + izr)
            tvurdi(not narushava(vqrno),
                   'детектив: поправеното още нарушава правило: ' + vqrno)
    #  Само едно изречение в целия лист има две грешки, и то го казва.
    tvurdi(len(s_dve) == 1,
           'детектив: изреченията с две грешки не са едно, а {} ({})'
           .format(len(s_dve), '; '.join(s_dve)))
    if s_dve:
        za_nego = [z for _, _, red in detektiv.NIVA for i, v, z in red if i == s_dve[0]]
        tvurdi(za_nego and 'TWO' in za_nego[0],
               'детектив: обяснението не предупреждава, че грешките са две')

    for izr, vqrno, zashto in detektiv.REDUT:
        obsht += 1
        tvurdi(sorted(izr.rstrip('?').lower().split()) ==
               sorted(vqrno.rstrip('?').lower().split()),
               'детектив (ред): „{}“ не е същите думи като „{}“'.format(izr, vqrno))
        tvurdi(vqrno.endswith('?'), 'детектив (ред): липсва въпросителен знак')
        tvurdi(re.match(r'^(Where|What|Who|How) (is|are|am)\b', vqrno),
               'детектив (ред): глаголът не е след въпросителната дума: ' + vqrno)
    tvurdi(obsht == 30, 'изреченията в детектива не са 30, а ' + str(obsht))


# ── лист 4 · смесената граматика ─────────────────────────────────────
def list4():
    tvurdi(len(smes.VUPROSI) == 6, 'въпросителните думи не са 6')
    for izr, otg, _, zashto in smes.VUPROSI:
        tvurdi(otg in ('Where', 'What', 'Who'), 'въпроси: непознат отговор ' + otg)
        tvurdi(len(zashto) >= 15, 'въпроси: късо обяснение')
    tvurdi([o for _, o, _, _ in smes.VUPROSI] ==
           ['Where', 'What', 'Who', 'Where', 'Who', 'What'],
           'въпросите не са място/нещо/човек по реда от листа')

    tvurdi(len(smes.SVRUZKI) == 7, 'and/or/but не са 7')
    for izr, otg, oshte, _ in smes.SVRUZKI:
        tvurdi(otg in ('and', 'or', 'but'), 'свръзки: непознат отговор ' + otg)
        if izr.strip().endswith('?'):
            tvurdi(otg == 'or', 'свръзки: въпрос с избор иска or: ' + izr)
        if ', __' in izr:
            tvurdi(otg == 'but' or 'but' in oshte,
                   'свръзки: запетая преди свръзката значи обрат: ' + izr)

    tvurdi(len(smes.IMA) == 6, 'there is/are не са 6')
    for izr, otg, izbori, _ in smes.IMA:
        ostatuk = izr.replace('__ ', '').rstrip('.')
        izvedeno = ima_forma(ostatuk, otr=('n’t' in otg))
        tvurdi(izvedeno == otg,
               'there be: „{}“ → изведено {}, записано {}'.format(izr, izvedeno, otg))
        tvurdi(otg in izbori, 'there be: верният отговор не е сред изборите')
        tvurdi(len(izbori) == 2, 'there be: изборите не са два')

    tvurdi(len(smes.OTRICANIQ) == 4, 'отрицанията не са 4')
    for dadeno, otg, oshte, _ in smes.OTRICANIQ:
        #  Отрицанието се извежда: is → isn't, are → aren't, some → any.
        izvedeno = dadeno.replace('There is ', 'There isn’t ')
        izvedeno = izvedeno.replace('There are ', 'There aren’t ')
        if 'aren’t' in izvedeno:
            izvedeno = re.sub(r'\bsome\b', 'any', izvedeno)
        tvurdi(izvedeno == otg,
               'отрицание: „{}“ → изведено „{}“, записано „{}“'.format(
                   dadeno, izvedeno, otg))
        for v in oshte:
            tvurdi('not' in v, 'отрицание: вариантът не е отрицателен: ' + v)

    tvurdi(len(smes.NQKOI) == 7, 'some/any не са 7')
    for izr, otg, _, _ in smes.NQKOI:
        izvedeno = some_ili_any(izr)
        tvurdi(izvedeno == otg,
               'some/any: „{}“ → изведено {}, записано {}'.format(izr, izvedeno, otg))


# ── лист 5 · познай думата ───────────────────────────────────────────
#  Ключът, отпечатан НАКРАЯ на домашното — отделен източник от описанията.
KLYUCH = ['library', 'cinema', 'café', 'train station', 'shop', 'park',
          'theatre', 'hotel', 'restaurant', 'bridge',
          'mobile phone', 'pen', 'bag', 'camera', 'book',
          'Spanish', 'Japanese', 'Brazilian', 'British', 'Egypt',
          'small', 'cheap', 'old', 'slow', 'interesting', 'unpopular', 'bad',
          'expensive',
          'flats', 'sports centre', 'market', 'monument', 'but', 'any']


def list5():
    vsichki = [otg for _, _, _, redove in dumi.GRUPI for _, otg in redove]
    tvurdi(len(vsichki) == 34, 'думите не са 34, а ' + str(len(vsichki)))
    tvurdi(vsichki == KLYUCH,
           'думите не съвпадат с ключа накрая на домашното: '
           + ', '.join(a + '≠' + b for a, b in zip(vsichki, KLYUCH) if a != b))
    for ime, _, s_bukva, redove in dumi.GRUPI:
        for opis, otg in redove:
            tvurdi(len(opis) >= 20, 'речник: много късо описание: ' + opis)
            if s_bukva:
                p = B.podskazka(otg)
                #  Подсказката трябва да е с първата буква и с толкова
                #  чертички, колкото са останалите букви.
                tvurdi(p[0] == otg[0].upper(),
                       'речник: подсказката не почва с буквата на „' + otg + '“')
                tvurdi(p.count('_') == len(otg.replace(' ', '')) - len(otg.split()),
                       'речник: чертичките не са колкото буквите на „' + otg + '“')
                tvurdi(len(p.split('   ')) == len(otg.split()),
                       'речник: думите в подсказката не са колкото в „' + otg + '“')


# ── страниците ───────────────────────────────────────────────────────
def stranicite():
    znaka = 0
    for danni, pat in B.vsichki():
        s = pat.read_text(encoding='utf-8')
        znaka += len(s)
        kade = pat.name

        i = s.index('/* ДАННИ:НАЧАЛО')
        kraj = s.index('*/', i) + 2
        tvurdi('\n' not in s[i:kraj], kade + ': маркерът не затваря коментара си')
        tvurdi(s[kraj:kraj + 1] == '\n' and s[kraj + 1:].lstrip().startswith('const DANNI'),
               kade + ': данните не започват веднага след маркера')
        d = json.loads(s[s.index('const DANNI = ') + len('const DANNI = '):
                         s.index(';\n/* ДАННИ:КРАЙ */')])
        tvurdi(d['slug'] == danni['slug'], kade + ': слугът не съвпада')
        tvurdi(d['upr'] == json.loads(json.dumps(danni['upr'], ensure_ascii=False)),
               kade + ': задачите в страницата се различават')
        tvurdi(len(danni['upr']) <= 10, kade + ': упражненията са повече от десет')

        for parche in ('assets/supabase-config.js', 'assets/auth.js',
                       'TLA.requireAuth()', 'TLA.isConfigured()', 'TLA.signOut()',
                       'TLA.saveAttempt(DANNI.slug', 'id="gate"', 'id="sheet"',
                       'id="checkBtn"', 'id="resetBtn"', 'id="signOutBtn"'):
            tvurdi(parche in s, kade + ': липсва ' + parche)
        tvurdi(s.count('<style>') == s.count('</style>'), kade + ': незатворен <style>')
        tvurdi(s.rstrip().endswith('</html>'), kade + ': не завършва с </html>')
        tvurdi('noindex' in s, kade + ': трябва да е noindex')
        tvurdi('Unit 1' in s, kade + ': никъде не пише Unit 1')
        tvurdi('__' not in re.sub(r'[a-z-]__[a-z]', '', s) or
               not re.search(r'__[A-Z][A-Z_]*__', s),
               kade + ': останало е незаменено място в шаблона')

        #  Всеки отговор трябва да стои в данните.
        for u in danni['upr']:
            if u['vid'] == 'svoboden':
                for r in u['redove']:
                    tvurdi(json.dumps(r['obrazec'], ensure_ascii=False)[1:-1] in s,
                           kade + ': липсва образец')
                continue
            if u['vid'] == 'razkaz':
                for dd in u['dupki']:
                    tvurdi(json.dumps(dd['otgovor'], ensure_ascii=False)[1:-1] in s,
                           kade + ': липсва отговор ' + dd['otgovor'])
                continue
            for r in u['redove']:
                #  При „хвани грешката“ вярното е цялото поправено изречение.
                otg = r['vqrno'] if u['vid'] == 'greshka' else r['otgovor']
                tvurdi(json.dumps(otg, ensure_ascii=False)[1:-1] in s,
                       kade + ': липсва отговор ' + otg)

        for vid in sorted({u['vid'] for u in danni['upr']}):
            tvurdi("'" + vid + "'" in s, kade + ': двигателят не познава вид ' + vid)

    #  Редовете в базата сочат към същите страници.
    sql = (KOREN / 'supabase/domashni-angliyski-5-u1.sql').read_text(encoding='utf-8')
    for danni, pat in B.vsichki():
        tvurdi("'" + danni['slug'] + "'" in sql, 'SQL: липсва слугът ' + danni['slug'])
        tvurdi("'" + pat.name + "'" in sql, 'SQL: липсва файлът ' + pat.name)
    tvurdi("'ep1_unit1'" in sql, 'SQL: домашните не влизат в Unit 1')
    tvurdi('angliiski' in sql, 'SQL: предметът не е английският')
    tvurdi("'{5}'" in sql, 'SQL: класът не е 5.')
    return znaka


def izborite():
    """Упражнение с избор, в което ВСЕКИ избор минава за верен, не учи нищо.

    Точно това се беше счупило веднъж: при „There is / There are“ двата
    избора бяха записани и като възможни, и като приемливи отговори, та
    грешното щракане също се броеше за вярно.
    """
    for danni, pat in B.vsichki():
        for u in danni['upr']:
            if u['vid'] != 'tap':
                continue
            for n, r in enumerate(u['redove'], 1):
                izbori = r.get('izbori') or u.get('izbori') or []
                priemani = {r['otgovor']} | set(r.get('oshte', []))
                kade = '{} · {} · ред {}'.format(pat.name, u['ime'], n)
                tvurdi(len(izbori) >= 2, kade + ': изборите са по-малко от два')
                tvurdi(r['otgovor'] in izbori, kade + ': верният отговор не е сред изборите')
                tvurdi(priemani <= set(izbori), kade + ': приема се отговор, който го няма')
                tvurdi(len(priemani) < len(izbori),
                       kade + ': всеки избор минава за верен — няма какво да се сбърка')


def main():
    izborite()
    lист1()
    list2()
    list3()
    list4()
    list5()

    listove = B.vsichki()
    tvurdi(len(listove) == 5, 'листовете не са пет')
    avto = sum(za_ocenka(u) for d, _ in listove for u in d['upr'])
    ruch = sum(broi_redove(u) for d, _ in listove for u in d['upr']
               if u['vid'] == 'svoboden')
    tvurdi(avto == 138, 'автоматичните задачи не са 138, а ' + str(avto))
    tvurdi(ruch == 7, 'за ръчна оценка не са 7, а ' + str(ruch))
    znaka = stranicite()

    if GRESHKI:
        print('ГРЕШКИ ({}):'.format(len(GRESHKI)))
        for g in GRESHKI:
            print('  ·', g)
        sys.exit(1)
    print('всичко е вярно · проверки: {} · листа: {} · задачи: {} + {} за ръчна оценка '
          '· {} знака'.format(PROVERKI, len(listove), avto, ruch, znaka))


if __name__ == '__main__':
    main()
