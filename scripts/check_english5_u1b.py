#!/usr/bin/env python3
"""Проверява четирите нови листа за Unit 1 — по свой път.

Правилото е същото като при другите листове: нищо не се вярва на
доверие и нищо не се сверява със собствения си източник.

  · Речникът (места, предлози, противоположни, столици) се сверява с
    таблици, написани ТУК на ръка. Ако двете се разминат, пада.
  · a / an / some / any НЕ се сравнява със списък: изчислява се наново
    от изречението — какво е следващото съществително (едно или повече)
    и дали изречението е утвърдително, въпрос или отрицание.
  · is / are в текста се проверява по същия начин — по подлога.
  · Подреждането се проверява като разбъркване: думите отляво трябва да
    са същите като в отговора, нито една в повече или по-малко.
  · Сгрешените изречения минават през отделен списък от правила: всяко
    трябва да ЗАПАЛИ поне едно правило, а поправеното — нито едно.
  · Накрая се гледа и че нито едно условие не повтаря условие от петте
    стари листа на Unit 1.

    /usr/bin/python3.13 scripts/check_english5_u1b.py
"""
import re
import sys
import unicodedata
from pathlib import Path

KOREN = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from english5 import u1_mesta, u1_pitane, u1_pisane, u1_extra   # noqa: E402
from english5 import razkaz, podrejdane, detektiv, smes, dumi    # noqa: E402

padnali = []
minali = 0


def ok(ime, uslovie, dop=''):
    global minali
    if uslovie:
        minali += 1
    else:
        padnali.append(ime + (' · ' + str(dop) if dop else ''))


def norm(s):
    """Маха кавичките-апострофи и двойните интервали — за сравняване."""
    t = unicodedata.normalize('NFC', str(s))
    t = t.replace('’', "'").replace('‘', "'")
    return re.sub(r'\s+', ' ', t).strip()


# ══ 1. Речниците, написани тук на ръка ═══════════════════════════════
MESTA = {
    'музей': 'museum', 'стадион': 'stadium',
    'плувен басейн': 'swimming pool', 'автогара': 'bus station',
    'поща': 'post office', 'болница': 'hospital', 'площад': 'square',
    'замък': 'castle', 'банка': 'bank', 'аптека': "chemist's",
}
PROTIVOPOLOJNI = {
    'old': 'new', 'quiet': 'noisy', 'pretty': 'ugly', 'cheap': 'expensive',
    'big': 'small', 'modern': 'traditional', 'clean': 'dirty',
    'boring': 'interesting',
}
PREDLOZI = {
    'до': 'next to', 'срещу': 'opposite', 'между': 'between', 'зад': 'behind',
    'пред': 'in front of', 'близо до': 'near', 'на ъгъла на': 'on the corner of',
    'в края на': 'at the end of',
}
STOLICI = {
    'England': 'London', 'Scotland': 'Edinburgh', 'Wales': 'Cardiff',
    'Northern Ireland': 'Belfast', 'Bulgaria': 'Sofia',
}
#  Коя дума по коя ключова следа се познава в описанието.
SLEDI = {
    'museum': 'history', 'swimming pool': 'swim', 'bus station': 'buses',
    'hospital': 'ill', 'post office': 'letter', 'square': 'open place',
    'bank': 'money', 'castle': 'kings', "chemist's": 'medicine',
    'stadium': 'football',
}
#  Готовите изрази, които трябва да се получат след попълването.
IZRAZI = ['near here', 'next to', 'on the corner', 'in front of',
          "you're welcome", 'excuse me', 'first name', 'surname',
          'how do you spell', 'phone number', 'how old are you',
          'where are you from', 'email address', 'in the north of',
          'famous for', 'a lot to do', 'favourite place', 'kilometres from',
          'love living']

NEPRAVILNI_MNOJESTVENI = {'people', 'children', 'men', 'women'}
SUGLASEN_ZVUK = {'uniform', 'university', 'unit', 'user', 'useful',
                 'european', 'one', 'once'}
GLASEN_ZVUK = {'hour', 'honest', 'honour'}
PREDLOG_STOP = {'in', 'on', 'near', 'at', 'with', 'for', 'from', 'of', 'to',
                'every', 'under', 'behind', 'so', 'and', 'but', 'because',
                'here', 'there'}


def mnojestveno(duma):
    """Повече от едно ли е това съществително — по формата му."""
    d = norm(duma).lower().strip('.,?!')
    if d in NEPRAVILNI_MNOJESTVENI:
        return True
    return d.endswith('s') and not d.endswith('ss') and d not in ('this',)


def glava(sled):
    """Съществителното след празното място: думите до първия предлог."""
    dumi = []
    for d in norm(sled).split():
        chist = d.strip('.?!')
        if chist:
            dumi.append(chist)
    vzeti = []
    for d in dumi:
        #  Запетаята се маха само за сравнението — „here,“ е пак here.
        chist = d.rstrip(',')
        if chist.lower() in PREDLOG_STOP and vzeti:
            break
        vzeti.append(d)
        #  Запетаята затваря израза: „people here, so it isn’t…“ свършва
        #  при people, а не продължава до края на изречението.
        if d.endswith(','):
            break
    return vzeti[-1].rstrip(',') if vzeti else ''


def chlen_po_zvuk(duma):
    """a или an — по ЗВУКА на следващата дума."""
    d = norm(duma).lower().strip('.,?!')
    if d in SUGLASEN_ZVUK:
        return 'a'
    if d in GLASEN_ZVUK:
        return 'an'
    return 'an' if d[:1] in 'aeiou' else 'a'


def vid_izrechenie(izr):
    """утвърдително · въпрос · отрицание — от самото изречение."""
    t = norm(izr)
    if t.rstrip().endswith('?'):
        return 'vupros'
    if re.search(r"\b(isn't|aren't|don't|doesn't|haven't|hasn't|not)\b", t):
        return 'otricanie'
    return 'tvurdenie'


def ocakvan_chlen(izr):
    """Кое трябва да застане на празното място: a, an, some или any."""
    predi, _, sled = norm(izr).partition('___')
    sledvashta = sled.split()[0] if sled.split() else ''
    g = glava(sled)
    vid = vid_izrechenie(izr)
    if mnojestveno(g):
        return 'some' if vid == 'tvurdenie' else 'any'
    return chlen_po_zvuk(sledvashta)


def ocakvano_be(izr):
    """is / are / isn’t / aren’t — по съществителното след него."""
    _, _, sled = norm(izr).partition('___')
    g = glava(sled)
    mn = mnojestveno(g)
    otricatelno = bool(re.search(r'\bany\b', sled))
    if mn:
        return "aren't" if otricatelno else 'are'
    return "isn't" if otricatelno else 'is'


# ══ 2. Правилата, по които едно изречение е сгрешено ═════════════════
def zapaleni_pravila(izr):
    """Кои правила хваща това изречение. Празно значи „няма грешка“."""
    t = norm(izr)
    nisko = t.lower()
    hvanati = []
    #  is / are спрямо съществителното след тях
    m = re.search(r'\b(is|are)\s+(?:a lot of\s+|the\s+|a\s+|an\s+|some\s+|any\s+)?'
                  r'([a-z]+)', nisko)
    if m and m.group(2) != 'there':
        #  „there is / there are“ се решава от това, което идва СЛЕД
        #  there, а не от самото there.
        sled = m.group(2)
        if sled == 'there':
            pass
        mn = mnojestveno(sled)
        if (m.group(1) == 'are') != mn:
            hvanati.append('is/are не пасва на съществителното')
    if re.search(r'\bis there some\b', nisko) or re.search(r'\bare there a\b', nisko):
        hvanati.append('some/a на грешно място във въпрос')
    if re.search(r'\bis there any ([a-z]+)\b', nisko):
        sled = re.search(r'\bis there any ([a-z]+)\b', nisko).group(1)
        if not mnojestveno(sled):
            hvanati.append('any пред едно нещо')
    if re.search(r'\bopposite to\b', nisko):
        hvanati.append('opposite не иска to')
    if re.search(r'\bbetween\b.*\bor\b', nisko):
        hvanati.append('between свързва с and, не с or')
    if re.search(r'\bhow much\b\s+[a-z]+s\b', nisko):
        hvanati.append('how much пред броими неща')
    if re.search(r'\bcorner in\b', nisko):
        hvanati.append('on the corner OF')
    if re.search(r'^they are a lot of\b', nisko) or re.search(r'\bthey are a lot of\b', nisko):
        hvanati.append('They are вместо There are')
    return hvanati


# ══ 3. Проверките по упражнения ══════════════════════════════════════
def proveri_dvoiki(kude, dvojki, tablica, obratno=False):
    ok(kude + ': двойките не се повтарят',
       len({norm(a) for a, _ in dvojki}) == len(dvojki))
    for lqvo, dqsno in dvojki:
        kluch = norm(lqvo)
        ochakvano = tablica.get(kluch)
        ok('%s · %s' % (kude, lqvo), ochakvano is not None,
           'няма го в таблицата на проверката')
        if ochakvano is not None:
            ok('%s · %s → %s' % (kude, lqvo, dqsno),
               norm(dqsno).lower() == norm(ochakvano).lower(),
               'проверката очаква „%s“' % ochakvano)


def proveri_chlenove(kude, redove):
    for izr, otg, _oshte, zashto in redove:
        ok('%s · „%s“' % (kude, izr[:38]), '___' in izr, 'няма празно място')
        ochakvano = ocakvan_chlen(izr)
        ok('%s · „%s“ → %s' % (kude, izr[:38], otg), otg == ochakvano,
           'проверката изчислява „%s“' % ochakvano)
        ok('%s · „%s“ има обяснение' % (kude, izr[:28]), len(zashto) > 12)


def proveri_izbor(kude, redove, dopusnati=None):
    """Упражнение с два избора: верният е сред тях и е точно един."""
    for izr, otg, izbori, zashto in redove:
        ok('%s · „%s“ има празно място' % (kude, izr[:34]), '___' in izr)
        ok('%s · „%s“ има два избора' % (kude, izr[:34]), len(izbori) >= 2)
        ok('%s · верният е сред изборите: %s' % (kude, otg), otg in izbori)
        ok('%s · изборите са различни' % kude, len(set(izbori)) == len(izbori))
        ok('%s · „%s“ има обяснение' % (kude, izr[:28]), len(zashto) > 12)
        if dopusnati is not None:
            ok('%s · „%s“ е от очакваните отговори' % (kude, otg),
               otg in dopusnati, sorted(dopusnati))


def proveri_red(kude, redove):
    for razb, vqrno, zashto in redove:
        chasti = [c for c in razb.split(' / ') if c not in ('.', '?')]
        dumi_razb = sorted(w for c in chasti for w in c.split())
        dumi_otg = sorted(norm(vqrno).rstrip('.?!').split())
        ok('%s · „%s“ · същите думи' % (kude, vqrno[:34]),
           [norm(x) for x in dumi_razb] == [norm(x) for x in dumi_otg],
           'разбъркано: %s' % dumi_razb)
        ok('%s · „%s“ · започва с главна' % (kude, vqrno[:34]),
           vqrno[:1].isupper())
        ok('%s · „%s“ · свършва с . или ?' % (kude, vqrno[:34]),
           vqrno.rstrip()[-1] in '.?')
        if razb.rstrip().endswith('?'):
            ok('%s · „%s“ · въпросът свършва с ?' % (kude, vqrno[:34]),
               vqrno.rstrip().endswith('?'))
            purva = norm(vqrno).split()[0].strip(',')
            ok('%s · „%s“ · въпросът започва както трябва' % (kude, vqrno[:34]),
               purva in ('Is', 'Are', 'Can', 'Do', 'Does', 'How', 'What',
                         'Where', 'Who', 'Why', 'When', 'Excuse'),
               purva)
        ok('%s · „%s“ има обяснение' % (kude, vqrno[:28]), len(zashto) > 12)


def proveri_greshki(kude, redove):
    for sgresheno, vqrno, zashto in redove:
        a, b = norm(sgresheno).split(), norm(vqrno).split()
        razlika = (len(a) == len(b) and sum(1 for x, y in zip(a, b) if x != y)
                   or (1 if len(a) == len(b) + 1 else 0))
        ok('%s · „%s“ · точно една разлика' % (kude, sgresheno[:34]),
           razlika == 1, 'разлики: %s' % razlika)
        hvanati = zapaleni_pravila(sgresheno)
        ok('%s · „%s“ · правило я хваща' % (kude, sgresheno[:34]),
           bool(hvanati), 'никое правило не се задейства')
        chisti = zapaleni_pravila(vqrno)
        ok('%s · поправеното е чисто: „%s“' % (kude, vqrno[:34]),
           not chisti, chisti)
        ok('%s · „%s“ има обяснение' % (kude, sgresheno[:28]), len(zashto) > 12)


def proveri_pisane(kude, redove, trqbva_izraz=True):
    for izr, otg, oshte, zashto in redove:
        ok('%s · „%s“ има празно място' % (kude, izr[:34]), '___' in izr)
        pulno = norm(izr).replace('___', norm(otg)).lower()
        if trqbva_izraz:
            namereni = [i for i in IZRAZI if i in pulno]
            ok('%s · „%s“ → готов израз' % (kude, otg), bool(namereni),
               'попълненото „%s“ не дава познат израз' % pulno[:60])
        ok('%s · „%s“ има обяснение' % (kude, izr[:28]), len(zashto) > 12)
        for d in oshte:
            ok('%s · другият приет вид е различен: %s' % (kude, d),
               norm(d).lower() != norm(otg).lower())


def proveri_opisaniq(kude, redove):
    vidqni = set()
    for opis, otg, oshte in redove:
        kluch = norm(otg).lower()
        sleda = SLEDI.get(kluch)
        ok('%s · „%s“ е в таблицата' % (kude, otg), sleda is not None)
        if sleda:
            ok('%s · описанието сочи към „%s“' % (kude, otg),
               sleda in norm(opis).lower(),
               'очаквах следа „%s“' % sleda)
        #  Никое описание не бива да сочи към ДРУГА дума.
        chujdi = [w for w, s in SLEDI.items()
                  if w != kluch and s in norm(opis).lower()]
        ok('%s · „%s“ не сочи към друга дума' % (kude, otg), not chujdi, chujdi)
        ok('%s · „%s“ не се повтаря' % (kude, otg), kluch not in vidqni)
        vidqni.add(kluch)
        for d in oshte:
            ok('%s · приетият вид е различен: %s' % (kude, d),
               norm(d).lower() != kluch)


def proveri_razkaz(kude, kutiq, tekst, otgovori):
    nomera = [int(n) for n in re.findall(r'\{(\d+)\}', tekst)]
    ok(kude + ': празните места са по ред', nomera == list(range(1, len(nomera) + 1)),
       nomera)
    ok(kude + ': толкова отговора, колкото са местата',
       len(otgovori) == len(nomera), '%d срещу %d' % (len(otgovori), len(nomera)))
    for n, otg, _oshte, zashto in otgovori:
        ok('%s · {%d} е в Word Box' % (kude, n), otg in kutiq, otg)
        ok('%s · {%d} има обяснение' % (kude, n), len(zashto) > 12)
    #  Граматиката в текста се пресмята наново: be и членът.
    karta = {n: otg for n, otg, _o, _z in otgovori}
    for n, otg, _o, _z in otgovori:
        parche = tekst.split('{%d}' % n, 1)
        sled = parche[1] if len(parche) > 1 else ''
        izr = '___' + sled.split('\n')[0]
        if otg in ('is', 'are', "isn't", "aren't", 'isn’t', 'aren’t'):
            ochakvano = ocakvano_be(izr)
            ok('%s · {%d} „%s“ пасва на подлога' % (kude, n, otg),
               norm(otg).lower() == ochakvano, 'проверката чака „%s“' % ochakvano)
        if otg in ('a', 'an', 'some', 'any'):
            ochakvano = ocakvan_chlen('There isn’t ___' + sled.split('\n')[0]
                                      if 'isn’t' in tekst.split('{%d}' % n)[0][-12:]
                                      else '___' + sled.split('\n')[0])
            ok('%s · {%d} членът „%s“ пасва' % (kude, n, otg), otg == ochakvano,
               'проверката чака „%s“' % ochakvano)
    del karta


def proveri_fakti(kude, redove, tablica):
    for izr, otg, izbori, zashto in redove:
        ok('%s · „%s“ има два избора' % (kude, izr[:34]), len(izbori) >= 2)
        ok('%s · верният е сред тях' % kude, otg in izbori)
        kluch = norm(izr).lower()
        ocakvano = None
        for sled, stoinost in tablica.items():
            if sled in kluch:
                ocakvano = stoinost
                break
        ok('%s · „%s“ е в таблицата на проверката' % (kude, izr[:34]),
           ocakvano is not None)
        if ocakvano is not None:
            ok('%s · „%s“ → %s' % (kude, izr[:34], otg),
               norm(otg).lower() == norm(ocakvano).lower(),
               'проверката очаква „%s“' % ocakvano)
        ok('%s · „%s“ има обяснение' % (kude, izr[:28]), len(zashto) > 12)


#  Независими таблици за фактите.
KARTA = {
    'scotland is in the': 'north', 'wales is in the': 'west',
    'london is in the': 'south-east', 'varna is in the': 'east',
    'greece is in the': 'south', 'romania is in the': 'north',
}
KULTURA = {
    'capital city of the united kingdom': 'London',
    'flag of the uk': 'Union',
    'people in wales speak': 'Welsh',
    'united kingdom has': 'four',
    'big ben is in': 'London',
    'longest river in the uk': 'Severn',
}
PRILAGATELNI = {
    'cars and buses everywhere': 'noisy',
    '400 leva a night': 'expensive',
    '800 years old': 'old',
    'love walking there': 'pretty',
    'nothing to do there': 'boring',
    'no rubbish on it': 'clean',
}
KUDE_TABLICA = {
    'it is in the middle': 'between',
    'you cross the road': 'opposite',
    'cannot see it from the street': 'behind',
    'side by side': 'next to',
    'you see them first': 'in front of',
    'two streets meet there': 'on the corner of',
}


def main():
    m, p, w, e = u1_mesta, u1_pitane, u1_pisane, u1_extra

    # ── лист 1 · Vocabulary ──────────────────────────────────────────
    proveri_dvoiki('[Around Town] места', m.MESTA, MESTA)
    proveri_chlenove('[Around Town] a/an/some/any', m.CHLENOVE)
    proveri_opisaniq('[Around Town] описания', m.OPISANIQ)
    proveri_dvoiki('[Around Town] противоположни', m.PROTIVOPOLOJNI,
                   PROTIVOPOLOJNI)
    proveri_izbor('[Around Town] прилагателни', m.PRILAGATELNI)
    proveri_fakti('[Around Town] прилагателни по смисъл', m.PRILAGATELNI,
                  PRILAGATELNI)
    proveri_red('[Around Town] фрази', m.FRAZI)

    # ── лист 2 · Speaking ────────────────────────────────────────────
    proveri_dvoiki('[Speaking] предлози', p.PREDLOZI, PREDLOZI)
    proveri_izbor('[Speaking] къде е', p.KUDE)
    proveri_fakti('[Speaking] къде е по смисъл', p.KUDE, KUDE_TABLICA)
    proveri_red('[Speaking] фрази', p.FRAZI)
    proveri_pisane('[Speaking] разговори', p.RAZGOVORI)
    proveri_greshki('[Speaking] грешки', p.GRESHKI)
    ok('[Speaking] четири свободни отговора', len(p.SVOBODNI) == 4,
       len(p.SVOBODNI))
    for v, o in p.SVOBODNI:
        ok('[Speaking] „%s“ има образец' % v[:30], len(o) > 20)

    # ── лист 3 · Writing ─────────────────────────────────────────────
    proveri_red('[Writing] ред на прилагателното', w.REDUT)
    proveri_chlenove('[Writing] a/an', w.CHLENOVE)
    proveri_razkaz('[Writing] образецът', w.KUTIQ, w.TEKST, w.OTGOVORI)
    proveri_pisane('[Writing] ключови фрази', w.FRAZI)
    ok('[Writing] четири свободни отговора', len(w.SVOBODNI) == 4,
       len(w.SVOBODNI))
    for v, o in w.SVOBODNI:
        ok('[Writing] „%s“ има образец' % v[:30], len(o) > 20)

    # ── лист 4 · options ─────────────────────────────────────────────
    proveri_dvoiki('[Extra] столици', e.STOLICI, STOLICI)
    proveri_izbor('[Extra] посоки', e.POSOKI)
    proveri_fakti('[Extra] посоки по карта', e.POSOKI, KARTA)
    proveri_pisane('[Extra] лични данни', e.LICHNI)
    proveri_izbor('[Extra] викторина', e.VIKTORINA)
    proveri_fakti('[Extra] викторина по факти', e.VIKTORINA, KULTURA)
    proveri_red('[Extra] песента', e.PESEN)
    ok('[Extra] три свободни отговора', len(e.SVOBODNI) == 3, len(e.SVOBODNI))

    # ── нищо не повтаря старите пет листа ────────────────────────────
    stari = set()
    for n, otg, oshte, zashto in razkaz.OTGOVORI:
        stari.add(norm(zashto))
    for _, _, redove in podrejdane.CHASTI:
        for a, b, c in redove:
            stari.add(norm(b))
    for _, _, redove in detektiv.NIVA:
        for a, b, c in redove:
            stari.add(norm(a))
            stari.add(norm(b))
    for ime in ('VUPROSI', 'SVRUZKI', 'IMA', 'OTRICANIQ', 'NQKOI'):
        for red in getattr(smes, ime):
            stari.add(norm(red[0]))
    for _, _, _, redove in dumi.GRUPI:
        for opis, duma in redove:
            stari.add(norm(opis))
            stari.add(norm(duma))

    novi = []
    for red in m.CHLENOVE + m.PRILAGATELNI + p.KUDE + p.RAZGOVORI + \
            w.CHLENOVE + w.FRAZI + e.POSOKI + e.LICHNI + e.VIKTORINA:
        novi.append(norm(red[0]))
    for opis, otg, _ in m.OPISANIQ:
        novi.append(norm(opis))
        novi.append(norm(otg))
    for _razb, vqrno, _z in (m.FRAZI + p.FRAZI + w.REDUT + e.PESEN):
        novi.append(norm(vqrno))
    for sgr, vqr, _z in p.GRESHKI:
        novi.append(norm(sgr))

    povtoreni = sorted(set(novi) & stari)
    ok('нито едно условие не повтаря старите пет листа', not povtoreni,
       '; '.join(povtoreni[:3]))
    ok('нито едно условие не се повтаря и вътре в новите',
       len(novi) == len(set(novi)),
       '; '.join(sorted(x for x in novi if novi.count(x) > 1))[:120])

    # ── сглобените страници ──────────────────────────────────────────
    import build_english5_u1b as b
    for danni, pat in b.vsichki():
        ok('%s е сглобен' % pat.name, pat.exists())
        if not pat.exists():
            continue
        html = pat.read_text(encoding='utf-8')
        ok('%s · slug-ът е вътре' % pat.name,
           '"slug": "' + danni['slug'] + '"' in html, danni['slug'])
        ok('%s · няма останали заготовки' % pat.name,
           not re.search(r'__[A-Z][A-Z_]*__', html))
        ok('%s · упражненията са вътре' % pat.name,
           html.count('"vid"') >= len(danni['upr']),
           html.count('"vid"'))
        ok('%s · данните не са глътнати от коментар' % pat.name,
           'ДАННИ:КРАЙ' in html)

    print('проверки: %d' % minali)
    if padnali:
        print('ПАДНАЛИ (%d):' % len(padnali))
        for x in padnali[:30]:
            print(' -', x)
        sys.exit(1)
    print('✓ всеки отговор е изведен наново и съвпада')


if __name__ == '__main__':
    main()
