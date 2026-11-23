#!/usr/bin/env python3
"""Проверява урока „Топящото се домашно“ — 6. клас, шест теми.

Нищо не се вярва на доверие:

  1. ОТГОВОРЪТ. Условието се смята наново със sympy и се сверява с
     написания отговор. Когато отговорът е от две части („3⁵ = 243“),
     и двете трябва да дават същото. Уравненията се решават наново.
  2. ВИДЪТ. Опростеният израз трябва да е НАИСТИНА опростен — без
     неразкрити скоби. Където има мерна единица, тя трябва да я има и в
     отговора.
  3. ЕКРАНЪТ. HTML-ът, който вижда детето, се чете назад по свои
     правила (дробта се връща в A/B, <sup> в степен) и полученият израз
     се сравнява със същата стойност.
  4. РЕШЕНИЕТО. То се чете на глас, затова се проверява ред по ред:
     стига ли до същия отговор; вярно ли е всяко написано равенство
     („3,14 · 25 = 78,5“) и всяко тъждество („6a − 2a = 4a“); пази ли
     корена всяко написано уравнение; вярно ли е всяко НОК и НОД; и
     тръгва ли от същия израз, който стои в условието.
  5. УСЛОВИЕТО. При задачите с думи всяко число от текста трябва да го
     има и в сметката (или да личи в решението, ако е получено по
     пътя — диаметър 12 → радиус 6). Изречените формули се сверяват с
     кратък списък, изписан тук наново по учебника.
  6. Структурата: 45 задачи, уникални номера и условия, обяснение
     навсякъде, и градация — всеки таб свършва с по-дълга задача от тази,
     с която почва.

Какво НЕ хваща: цифра, зазидана в обяснителна дума без равенство около
нея („Всичко към основа 2“, „Общ знаменател 6:“). Мутационният тест го
показва — 189 от 193 развалени подробности биват уловени, а четирите
останали са точно от този вид.

    /usr/bin/python3.13 scripts/check_shest.py
"""
import re
import sys
from pathlib import Path

import sympy
from sympy.parsing.sympy_parser import (convert_xor,
                                        implicit_multiplication_application,
                                        parse_expr, split_symbols,
                                        standard_transformations)

KOREN = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from shest.zadachi import TABOVE                   # noqa: E402
from grad6.izraz import izobrazi                   # noqa: E402

T = standard_transformations + (convert_xor, split_symbols,
                                implicit_multiplication_application)
GORNI = {'⁰': '0', '¹': '1', '²': '2', '³': '3', '⁴': '4', '⁵': '5',
         '⁶': '6', '⁷': '7', '⁸': '8', '⁹': '9', 'ⁿ': 'n'}

padnali = []
minali = 0


def ok(ime, uslovie, dop=''):
    global minali
    if uslovie:
        minali += 1
    else:
        padnali.append(ime + (' · ' + str(dop) if dop else ''))


def sp(s):
    """Низ → точен израз на sympy."""
    t = (str(s).replace('−', '-').replace('–', '-').replace('·', '*')
         .replace('×', '*').replace(' ', '').replace(' ', ''))
    t = re.sub(r'[⁰¹²³⁴⁵⁶⁷⁸⁹ⁿ]+',
               lambda m: '^(' + ''.join(GORNI[c] for c in m.group(0)) + ')', t)
    t = re.sub(r'(?<=\d),(?=\d)', '.', t)
    return sympy.nsimplify(parse_expr(t, transformations=T), rational=True)


def chislo(s):
    try:
        return sp(s)
    except Exception:                                    # noqa: BLE001
        return None


def bez_edinica(otg, edinica):
    t = str(otg).strip()
    if edinica and t.endswith(edinica):
        t = t[:-len(edinica)].strip()
    return t


#  Екранът се чете назад — по свои правила, не по тези на сглобяването.
FRAC = re.compile(
    r'<span class="frac"><span class="chis">(.*?)</span>'
    r'<span class="znam">(.*?)</span></span>')


def ot_ekrana(h):
    predi = None
    while predi != h:
        predi = h
        h = FRAC.sub(lambda m: '((%s)/(%s))' % (m.group(1), m.group(2)), h)
    h = re.sub(r'<sup>(.*?)</sup>', lambda m: '^(%s)' % m.group(1), h)
    h = re.sub(r'</?i>', '', h)
    if '<' in h or '>' in h:
        raise ValueError('остана HTML: ' + h)
    return h


def golo(s):
    """Сметка без интервали и знаци за умножение — за сравняване с текст.

    Горните индекси в решението („5²“) и степените в сметката („5^2“) са
    едно и също нещо, затова се привеждат към един вид.
    """
    t = str(s).replace('−', '-').replace('·', '*').replace('×', '*')
    t = re.sub(r'(?<=\d),(?=\d)', '.', t)
    t = re.sub(r'[⁰¹²³⁴⁵⁶⁷⁸⁹]+',
               lambda m: '^' + ''.join(GORNI[c] for c in m.group(0)), t)
    return re.sub(r'[\s*\u00a0]', '', t)


def smetkata_lichi(mat, reshenie):
    """Личи ли сметката в написаното решение.

    Цялата наведнъж — или поне най-дългото ѝ парче, защото решението
    често я разбива на две стъпки („намалението е …, остава …“).
    """
    cqlo, teksta = golo(mat), golo(reshenie)
    if cqlo in teksta:
        return True
    parcheta = [x for x in re.split(r'[+-]', cqlo) if len(x) >= 3]
    return bool(parcheta) and max(parcheta, key=len) in teksta



def otgovorut_lichi(z):
    """Личи ли отговорът и в написаното решение.

    Госпожата чете решението на глас, затова то трябва да стига до
    същото число, което стои в полето „отговор“. Без тази проверка
    стъпките може да водят към едно, а отговорът да сочи друго.
    """
    otg = str(z['otgovor']).split('=')[-1].strip()
    if z.get('edinica'):
        otg = bez_edinica(otg, z['edinica'])
    return golo(otg) in golo(z['reshenie'])


#  Какво е написано вътре в решението
#  --------------------------------------------------------------------
#  Решението се чете на глас, затова всяка междинна стъпка трябва да е
#  вярна, не само крайният отговор. Оттук се изваждат написаните
#  равенства и се пресмятат наново:
#
#    · при изразите „=“ значи тъждество — двете страни трябва да са
#      едно и също („6a − 2a = 4a“);
#    · при уравненията „=“ значи „решаваме“ — всяко написано уравнение
#      трябва да пази корена на условието („2x + 6 = 3x − 12“);
#    · в текстовите задачи остават чисто числовите равенства.
#
#  Парче, отрязано от по-дълъг израз, се подминава — то не е равенство,
#  а къс от него.
ZNACI = '0123456789()+-−·×/:.  ^'
BUKVI = 'abcdefghijklmnopqrstuvwxyz'
GORNI_ZNACI = '⁰¹²³⁴⁵⁶⁷⁸⁹'


def _normalizirai(tekst):
    t = re.sub(r'(?<=\d),(?=\d)', '.', str(tekst))
    #  „10 000“ е едно число, а не „10“ и „000“.
    t = re.sub(r'(?<=\d)[  ](?=\d{3}\b)', '', t)
    #  Двоеточието е две неща. Залепено за думата („Проверка:“,
    #  „знаменател 6:“) е пунктуация и спира израза; с интервали от
    #  двете страни („12 : 4“) е делене и остава вътре в сметката.
    t = re.sub(r'(?<=\S):(?=\s|$)', ';', t)
    return re.sub('[' + GORNI_ZNACI + ']+',
                  lambda m: '^' + ''.join(GORNI[c] for c in m.group(0)), t)


def _bukva(c):
    return c.isalpha()


def _otrqzano_otpred(t, i, parche):
    """Продължава ли изразът наляво преди парчето.

    Цифра или степен отпред значи продължение. Буква — само ако е
    залепена за израза или ако парчето започва със знак за действие,
    тоест е къс от по-дълъг израз; „излиза 3,14 · 5²“ е цяла сметка
    след дума. „12 : 4“ е делене, но „Проверка: 4 · 3“ е пунктуация.
    """
    if i <= 0:
        return False
    c, nachaloto = t[i - 1], parche.lstrip()[:1]
    if c.isdigit() or c == '^':
        return True
    if _bukva(c):
        #  „значи −(2²) = −4“ е цял израз след дума; „3x − 7 = 3“ е къс
        #  от израз, защото „x“ е неизвестно, а не дума.
        if 'Ѐ' <= c <= 'ӿ':
            return not parche[:1].isspace()
        return (not parche[:1].isspace()) or nachaloto in '+-−·×/'
    return False


def _otrqzano_otzad(sled, parche):
    """Продължава ли изразът надясно след парчето.

    Буква, залепена за израза („= 2x“), го продължава. Буква след
    интервал е дума — най-често мерната единица („= 78,5 cm²“) — и
    парчето е цяло.
    """
    if not sled:
        return False
    if sled.isdigit() or sled == '^':
        return True
    return _bukva(sled) and not parche.endswith((' ', ' '))


def _parcheta(tekst, znaci):
    """Изважда от текста цели равенства, написани с дадените знаци."""
    t = _normalizirai(tekst)
    i, n = 0, len(t)
    while i < n:
        if t[i] not in znaci and t[i] != '=':
            i += 1
            continue
        j = i
        while j < n and (t[j] in znaci or t[j] == '='):
            j += 1
        parche, sled, nachalo = t[i:j], t[j] if j < n else '', i
        i = j
        if '=' not in parche:
            continue
        if _otrqzano_otpred(t, nachalo, parche) or _otrqzano_otzad(sled, parche):
            continue
        yield parche


def _strana(s, s_bukvi=False):
    """Превръща писаното на български в сметка или връща None."""
    s = s.strip(' . ')
    if not s or not (s_bukvi or any(c.isdigit() for c in s)):
        return None
    s = (s.replace('−', '-').replace('·', '*').replace('×', '*')
          .replace(' ', ' ').replace('^', '**').replace(':', '/'))
    if re.search(r'\d\s+\d', s) or s.rstrip().endswith(('+', '-', '*', '/')):
        return None                      # скъсано парче, не е сметка
    try:
        return sympy.nsimplify(sp(s), rational=True) if not s_bukvi else sp(s)
    except Exception:                                      # noqa: BLE001
        return None


def _strani(parche, s_bukvi=False):
    """Разбива парчето на страни и маха празните в двата края.

    „S = 3,14 · 3² = 28,26“ започва с нищо (буквата остава вън от
    парчето); това не е повод да се подмине цялата сметка.
    """
    chasti = parche.split('=')
    while chasti and not chasti[0].strip(' .\u00a0'):
        chasti.pop(0)
    while chasti and not chasti[-1].strip(' .\u00a0'):
        chasti.pop()
    strani = [_strana(x, s_bukvi) for x in chasti]
    return [] if (len(strani) < 2 or any(x is None for x in strani)) else strani


def tojdestvata_sa_verni(z):
    """Връща написаните равенства, в които двете страни не са едно и също.

    Важи за изразите, където „=“ е тъждество. Буквите се пускат вътре,
    за да се хване и стъпка като „6a − 2a = 8a“.
    """
    znaci = ZNACI + BUKVI + BUKVI.upper()
    losho = []
    for parche in _parcheta(z['reshenie'], znaci):
        strani = _strani(parche, True)
        if not strani:
            continue
        for a, b in zip(strani, strani[1:]):
            try:
                edno = sympy.simplify(a - b) == 0
            except Exception:                              # noqa: BLE001
                continue
            if not edno:
                losho.append(parche.strip())
    return losho


def ravenstvata_sa_verni(tekst):
    """Връща неверните чисто числови равенства в текста."""
    losho = []
    for parche in _parcheta(tekst, ZNACI):
        strani = _strani(parche)
        if not strani:
            continue
        for a, b in zip(strani, strani[1:]):
            if sympy.simplify(a - b) != 0:
                losho.append(parche.strip())
    return losho


def uravneniqta_sled_sebe_si(z):
    """Връща написаните в решението уравнения с друг корен."""
    lqvo, dqsno = z['mat'].split('=')
    koren = sympy.solve(sympy.Eq(sp(lqvo), sp(dqsno)), sympy.Symbol('x'))
    losho = []
    for parche in _parcheta(z['reshenie'], ZNACI + 'x'):
        if 'x' not in parche:
            continue
        strani = parche.split('=')
        if len(strani) != 2:
            continue
        try:
            l, r = (_strana(s, True) for s in strani)
            if l is None or r is None:
                continue
            negov = sympy.solve(sympy.Eq(l, r), sympy.Symbol('x'))
        except Exception:                                  # noqa: BLE001
            continue
        if negov != koren:
            losho.append('%s → %s вместо %s' % (parche.strip(), negov, koren))
    return losho



def chislata_v_teksta(z):
    """Връща числата от условието, които ги няма нито в сметката, нито
    в решението.

    Детето чете условието — „кръг с радиус 5 cm“ — а проверката пресмята
    по сметката. Ако двете се разминат, екранът ще показва едно, а
    отговорът ще е за друго. Числа, получени по пътя (диаметър 12 →
    радиус 6), се признават, ако личат в решението.
    """
    #  Тук степените не се превръщат в „^2“ — инак „cm²“ ще мине за
    #  число. Сменя се само десетичната запетая.
    zapetaq = lambda s: re.sub(r'(?<=\d),(?=\d)', '.', str(s))
    proza = zapetaq(z.get('izraz', ''))
    kude_oshte = zapetaq(z['mat'] + ' ' + z['reshenie'] + ' ' + str(z['otgovor']))
    #  Сверява се число с число: „8“ не бива да минава само защото
    #  в „168“ има осмица.
    nalichni = set(re.findall(r'\d+(?:\.\d+)?', kude_oshte))
    return [ch for ch in re.findall(r'\d+(?:\.\d+)?', proza)
            if ch not in nalichni]


#  Формулите за 6. клас, изписани тук наново по учебника. Щом в текста
#  се изрече формула („S = π · r²“), тя трябва да е една от тези — така
#  сбъркана формула не стига до дъската.
FORMULI = {
    'C = 2 · π · r',        # дължина на окръжност
    'S = π · r²',           # лице на кръг
    'V = S основа · h',     # обем на призма и цилиндър
    'S = a · b',            # лице на правоъгълник
    'S = a · h / 2',        # лице на триъгълник
    'P = 2 · (a + b)',      # периметър на правоъгълник
}


def formulite_sa_pravilni(tekst):
    """Връща изречените формули, които не са в учебниковия списък."""
    losho = []
    for m in re.finditer(r'\b([A-Z]) = ([^.,;]+)', str(tekst)):
        dqsno = m.group(2).split(' излиза')[0].split(' Тогава')[0].strip()
        if 'π' not in dqsno and not re.search(r'[a-z]', dqsno):
            continue                     # това е сметка, не формула
        formula = '%s = %s' % (m.group(1), dqsno)
        if formula not in FORMULI:
            losho.append(formula)
    return losho


def nok_i_nod(tekst):
    """Връща сбърканите НОК и НОД, изписани в текста.

    „НОК(3, 2) = 6“ е твърдение като всяко друго и се пресмята наново.
    """
    losho = []
    for ime, f in (('НОК', sympy.lcm), ('НОД', sympy.gcd)):
        for m in re.finditer(ime + r'\s*\((\d+)\s*,\s*(\d+)\)\s*=\s*(\d+)',
                             str(tekst)):
            a, b, c = (int(x) for x in m.groups())
            if f(a, b) != c:
                losho.append('%s(%d, %d) = %d, а е %s' % (ime, a, b, c, f(a, b)))
    return losho


def nachaloto_na_resheniyeto(z):
    """Проверява израза, с който решението започва.

    При изразите решението често тръгва направо с разкритите скоби
    („6x − 2 − 3x + 12.“). Този израз трябва да е същият като условието
    — инак детето преписва нещо друго.
    """
    purvo = str(z['reshenie']).split('.')[0]
    if '=' in purvo or re.search('[\u0400-\u04ff]', purvo):
        return None                      # това е изречение, не израз
    nachaloto = _strana(_normalizirai(purvo), True)
    if nachaloto is None:
        return None
    try:
        return sympy.simplify(nachaloto - sp(z['mat'])) == 0
    except Exception:                                      # noqa: BLE001
        return None

# ── проверките по видове ─────────────────────────────────────────────
def proveri_izraz(kude, z):
    stoinost = sympy.expand(sp(z['mat']))
    chasti = [c.strip() for c in z['otgovor'].split('=')]
    for c in chasti:
        e = chislo(c)
        ok('%s: „%s“ се чете като израз' % (kude, c), e is not None)
        if e is not None:
            ok('%s: „%s“ дава същото' % (kude, c),
               sympy.simplify(sympy.expand(e) - stoinost) == 0,
               'пресметнато „%s“' % stoinost)
    if len(chasti) == 1:
        e = chislo(chasti[0])
        if e is not None:
            ok(kude + ': отговорът е опростен докрай',
               sympy.expand(e) == e and '(' not in chasti[0],
               'остават скоби: ' + chasti[0])
    else:
        ok(kude + ': първата част е записана като степен',
           any(c in chasti[0] for c in GORNI), chasti[0])


def proveri_uravnenie(kude, z):
    x = sympy.Symbol('x')
    l, d = z['mat'].split('=')
    koreni = sympy.solve(sympy.Eq(sp(l), sp(d)), x)
    ok(kude + ': уравнението има точно един корен', len(koreni) == 1, koreni)
    m = re.fullmatch(r'x\s*=\s*(.+)', z['otgovor'].strip())
    ok(kude + ': отговорът е записан като x = …', bool(m), z['otgovor'])
    if m and len(koreni) == 1:
        ok(kude + ': коренът съвпада', chislo(m.group(1)) == koreni[0],
           'на екрана „%s“, решено „%s“' % (z['otgovor'], koreni[0]))


def proveri_tekst(kude, z):
    x = sympy.Symbol('x')
    l, d = z['mat'].split('=')
    koreni = sympy.solve(sympy.Eq(sp(l), sp(d)), x)
    ok(kude + ': уравнението има точно един корен', len(koreni) == 1, koreni)
    gol = bez_edinica(z['otgovor'], z.get('edinica'))
    chisla = re.findall(r'-?\d+(?:[.,]\d+)?', gol)
    ok(kude + ': отговорът носи точно едно число', len(chisla) == 1, chisla)
    if len(koreni) == 1 and len(chisla) == 1:
        ok(kude + ': отговорът съвпада с корена',
           chislo(chisla[0]) == koreni[0], 'решено „%s“' % koreni[0])
        ok(kude + ': отговорът има смисъл (положителен)', koreni[0] > 0,
           koreni[0])


def proveri_smetka(kude, z):
    stoinost = sympy.expand(sp(z['mat']))
    gol = bez_edinica(z['otgovor'], z.get('edinica'))
    ok(kude + ': числото съвпада с пресметнатото', chislo(gol) == stoinost,
       'на екрана „%s“, пресметнато „%s“' % (z['otgovor'], stoinost))


PROVERKI = {'izraz': proveri_izraz, 'uravnenie': proveri_uravnenie,
            'tekst': proveri_tekst, 'smetka': proveri_smetka}


def main():
    vidqni, uslovia, broi = {}, {}, 0
    ok('табовете са шест', len(TABOVE) == 6, len(TABOVE))

    for t in TABOVE:
        kude_t = '[%s]' % t['ime']
        ok(kude_t + ' има идея', len(t.get('ideya', '')) > 40)
        ok(kude_t + ' има правила', len(t.get('pravila', [])) >= 2)
        #  Правилата стоят най-отгоре в таба — ако там е изписана
        #  сбъркана формула, целият таб тръгва накриво.
        losho = [x for red in list(t['pravila']) + [t['ideya']]
                 for x in formulite_sa_pravilni(red)]
        ok(kude_t + ': формулите в правилата са по учебник',
           not losho, ' · '.join(losho))
        ok(kude_t + ' има кратко име', len(t.get('kratko', '')) > 2)
        ok(kude_t + ' има знак', bool(t.get('znak')))

        for i, z in enumerate(t['zadachi'], 1):
            broi += 1
            kude = '%s задача %d' % (kude_t, i)
            ok(kude + ': номерът не се повтаря', z['id'] not in vidqni,
               vidqni.get(z['id']))
            vidqni[z['id']] = kude
            ok(kude + ': условието не се повтаря', z['mat'] not in uslovia,
               uslovia.get(z['mat']))
            uslovia[z['mat']] = kude
            ok(kude + ': има решение с обяснение',
               len(z.get('reshenie', '')) > 25, z.get('reshenie', '')[:25])
            ok(kude + ': има отговор', bool(str(z.get('otgovor', '')).strip()))
            ok(kude + ': решението стига до същия отговор',
               otgovorut_lichi(z), z['otgovor'])
            losho = ravenstvata_sa_verni(z['reshenie'])
            ok(kude + ': всяка стъпка в решението е вярна',
               not losho, ' · '.join(losho))
            if '=' in z['mat'] and 'x' in z['mat']:
                losho = uravneniqta_sled_sebe_si(z)
                ok(kude + ': всяко уравнение в решението пази корена',
                   not losho, ' · '.join(losho))
            if z['vid'] == 'izraz':
                losho = tojdestvata_sa_verni(z)
                ok(kude + ': всяко тъждество в решението е вярно',
                   not losho, ' · '.join(losho))
            losho = nok_i_nod(z['reshenie'])
            ok(kude + ': НОК и НОД са пресметнати вярно',
               not losho, ' · '.join(losho))
            edno_i_sushto = nachaloto_na_resheniyeto(z)
            if edno_i_sushto is not None:
                ok(kude + ': решението тръгва от същия израз',
                   edno_i_sushto, z['reshenie'].split('.')[0])
            losho = formulite_sa_pravilni(z['reshenie'])
            ok(kude + ': изречените формули са по учебник',
               not losho, ' · '.join(losho))
            if z.get('izraz'):
                lipsvat = chislata_v_teksta(z)
                ok(kude + ': числата в условието ги има и в сметката',
                   not lipsvat, ', '.join(lipsvat))
            if z.get('edinica'):
                ok(kude + ': решението носи мерната единица',
                   z['edinica'] in z['reshenie'], z['reshenie'][-20:])
            if z.get('edinica'):
                ok(kude + ': отговорът носи мерната единица',
                   str(z['otgovor']).strip().endswith(z['edinica']),
                   z['otgovor'])

            #  екранът показва същото условие
            if z['vid'] in ('izraz', 'uravnenie'):
                try:
                    ekran = izobrazi(z['mat'], True)
                    nazad = ot_ekrana(ekran)
                    if '=' in z['mat']:
                        a1, a2 = z['mat'].split('=')
                        b1, b2 = nazad.split('=')
                        ok(kude + ': екранът показва същото условие',
                           sympy.simplify(sp(a1) - sp(b1)) == 0
                           and sympy.simplify(sp(a2) - sp(b2)) == 0, nazad)
                    else:
                        ok(kude + ': екранът показва същото условие',
                           sympy.simplify(sp(z['mat']) - sp(nazad)) == 0, nazad)
                except Exception as ex:                   # noqa: BLE001
                    padnali.append(kude + ': екранът не се чете · ' + repr(ex))
            else:
                #  Тук условието е изречение; сметката зад него трябва да
                #  личи в написаното решение, инак проверката пази нещо,
                #  което детето никъде не вижда.
                ok(kude + ': решението показва същата сметка',
                   smetkata_lichi(z['mat'], z['reshenie']), golo(z['mat']))

            f = PROVERKI.get(z['vid'])
            ok(kude + ': познат вид', f is not None, z['vid'])
            if f is None:
                continue
            try:
                f(kude, z)
            except Exception as ex:                       # noqa: BLE001
                padnali.append(kude + ': сметката не тръгва · ' + repr(ex))

        #  градация: последната задача в таба е по-дълга от първата
        purva, posledna = t['zadachi'][0], t['zadachi'][-1]
        ok(kude_t + ': последната задача е по-тежка от първата',
           len(posledna['mat']) > len(purva['mat'])
           or len(posledna.get('izraz', '')) > len(purva.get('izraz', '')),
           '%s → %s' % (purva['mat'], posledna['mat']))

    ok('задачите са точно 45', broi == 45, broi)

    #  сглобената страница
    stranica = KOREN / 'artefakti/urok_6_shest_temi.html'
    ok('страницата е сглобена', stranica.exists(), stranica.name)
    if stranica.exists():
        html = stranica.read_text(encoding='utf-8')
        ok('никъде няма поле за въвеждане',
           '<input' not in html and '<textarea' not in html)
        ok('всички задачи са вътре', html.count('"reshenie": "') == broi,
           html.count('"reshenie": "'))
        ok('има бутон „Покажи решението“', 'Покажи решението' in html)
        ok('има тикче за решена задача', 'data-o=' in html)
        ok('има лента с напредъка', 'id="lenta"' in html)
        ok('брои какво остава за домашно', 'за домашно' in html)
        ok('заглавието е на мястото си',
           '<title>Топящото се домашно</title>' in html)
        ok('страницата не носи своя <body>',
           '<body' not in html and '<html' not in html)
        ok('цветовете са определени и за тъмна тема',
           'prefers-color-scheme: dark' in html
           and ':root[data-theme="dark"]' in html)
        ok('страничният отстъп пази системната лента',
           'max(16px, env(safe-area-inset-left' in html
           and 'max(16px, env(safe-area-inset-right' in html)

    print('задачи: %d · проверки: %d' % (broi, minali))
    if padnali:
        print('ПАДНАЛИ (%d):' % len(padnali))
        for x in padnali[:30]:
            print(' -', x)
        sys.exit(1)
    print('✓ всеки отговор е пресметнат наново и екранът съвпада с него')


if __name__ == '__main__':
    main()
