# -*- coding: utf-8 -*-
"""Общите проверки за уроците по математика.

Тук стои всичко, което не зависи от конкретния урок: превръщането на
писаното на български в точен израз на sympy, четенето на готовия HTML
НАЗАД, и проверките върху текста на решението — вярно ли е всяко
написано равенство и тъждество, пази ли корена всяко уравнение, личи
ли отговорът, има ли числата от условието и в сметката.

Ползва се от scripts/check_shest.py (6. клас, „Топящото се домашно“) и
scripts/check_kapani.py (7. клас, „Осемте капана“). Всяка промяна тук
минава през проверките И на двата урока.
"""
import re

import sympy
from sympy.parsing.sympy_parser import (parse_expr, standard_transformations,
                                        convert_xor, split_symbols,
                                        implicit_multiplication_application)


T = standard_transformations + (convert_xor, split_symbols,
                                implicit_multiplication_application)
GORNI = {'⁰': '0', '¹': '1', '²': '2', '³': '3', '⁴': '4', '⁵': '5',
         '⁶': '6', '⁷': '7', '⁸': '8', '⁹': '9', 'ⁿ': 'n'}

padnali = []
minali = 0


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
    #  Екранът пише делението на дроб с дроб като двоеточие; тук то пак
    #  става наклонена черта. Дробите вече са в скоби, затова редът на
    #  действията се запазва.
    h = h.replace(' : ', '/')
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
