#!/usr/bin/env python3
"""Проверката на домашното по английски — без доверие към ключа.

Нищо тук не чете полето „otgovor“, за да каже „вярно е“. Всеки отговор
се ИЗВЕЖДА наново от правилата за to be:

  · съгласуване:  I → am · you/we/they → are · he/she/it → is
  · кратка форма: I am → I'm · you are → you're · she is → she's
  · отрицание:    not застава веднага след am/is/are
  · въпрос:       глаголът минава пред подлога, накрая има „?“
  · кратък отговор: само подлог + глагол, като подлогът сменя лицето
                  (Are you…? → Yes, I am.)

Чак след това изведеното се сравнява с написаното в
scripts/english4/tobe.py. Разминаване = счупена задача.

Проверява се и готовата страница: че данните са извън коментара, че
всеки отговор е вътре и че входът и записването са на място.

    /usr/bin/python3.13 scripts/check_english4.py
"""
import json
import pathlib
import re
import sys

KOREN = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from english4.tobe import UPRAJNENIQ, GEROI, POHVALI  # noqa: E402
from build_english4 import SLUG, IZHOD              # noqa: E402
from english.build import za_ocenka as broi_redove   # noqa: E402

PROVERKI = 0
GRESHKI = []


def tvurdi(uslovie, kakvo):
    global PROVERKI
    PROVERKI += 1
    if not uslovie:
        GRESHKI.append(kakvo)


# ── правилата ────────────────────────────────────────────────────────
MESTOIMENIQ = {'i': 'am', 'you': 'are', 'we': 'are', 'they': 'are',
               'he': 'is', 'she': 'is', 'it': 'is'}
GLAGOLI = ('am', 'is', 'are')
SVIVANE = {'am': "'m", 'are': "'re", 'is': "'s"}
NE_SVIVANE = {'are': "aren't", 'is': "isn't"}      # amn't го няма в езика
#  Думи, които НИКОГА не са главната дума на подлога — определители.
OPREDELITELI = {'the', 'my', 'our', 'your', 'his', 'her', 'their', 'a', 'an', 'this', 'that'}


def mestoimenie(podlog):
    """Кое местоимение застава на мястото на подлога."""
    s = podlog.strip().rstrip('.,!?')
    nisko = s.lower()
    if nisko in MESTOIMENIQ:
        return nisko
    if s in GEROI:
        return GEROI[s]
    if ' and ' in nisko:
        return 'they'
    glavna = nisko.split()[-1]
    for ime, m in GEROI.items():
        if ime.lower() == glavna:
            return m
    tvurdi(glavna not in OPREDELITELI, 'подлог без главна дума: ' + s)
    #  Множественото число в тези задачи се познава по -s (brothers, cats).
    if glavna.endswith('s') and not glavna.endswith('ss'):
        return 'they'
    return 'it'


def forma(podlog):
    """am, is или are — изведено от подлога, не прочетено."""
    return MESTOIMENIQ[mestoimenie(podlog)]


def razdeli(izrechenie):
    """„Gigi is small.“ → ('Gigi', 'is', 'small', '.')"""
    tqlo = izrechenie.strip()
    znak = tqlo[-1] if tqlo[-1] in '.?!' else ''
    if znak:
        tqlo = tqlo[:-1]
    dumi = tqlo.split()
    mesta = [i for i, d in enumerate(dumi) if d.lower() in GLAGOLI]
    tvurdi(len(mesta) == 1, 'очаква се точно един am/is/are в: ' + izrechenie)
    if len(mesta) != 1:
        return None
    k = mesta[0]
    return ' '.join(dumi[:k]), dumi[k].lower(), ' '.join(dumi[k + 1:]), znak


def sobstveno(podlog):
    """Собствено име ли е подлогът (за „Gigi's“, и за главната буква)."""
    p = podlog.strip()
    return p in GEROI or (p[:1].isupper() and p.lower() not in MESTOIMENIQ
                          and p.lower().split()[0] not in OPREDELITELI)


def otricanie(izrechenie):
    """Всички правилни отрицания на изречението — изведени."""
    r = razdeli(izrechenie)
    if not r:
        return set()
    podlog, glagol, ostatuk, znak = r
    pulno = '{} {} not {}{}'.format(podlog, glagol, ostatuk, znak)
    vidove = {pulno}
    #  свиване на подлога с глагола: I'm not, you're not, Gigi's not
    if podlog.lower() in MESTOIMENIQ or sobstveno(podlog):
        vidove.add('{}{} not {}{}'.format(podlog, SVIVANE[glagol], ostatuk, znak))
    #  свиване на глагола с not: aren't, isn't (am няма такава форма)
    if glagol in NE_SVIVANE:
        vidove.add('{} {} {}{}'.format(podlog, NE_SVIVANE[glagol], ostatuk, znak))
    return vidove


def vupros(izrechenie):
    """Въпросът, изведен с разместване на подлога и глагола."""
    r = razdeli(izrechenie)
    if not r:
        return ''
    podlog, glagol, ostatuk, _ = r
    #  Подлогът слиза с малка буква, освен „I“ и собствените имена.
    nov_podlog = podlog if (podlog == 'I' or sobstveno(podlog)) else podlog[0].lower() + podlog[1:]
    return '{} {} {}?'.format(glagol.capitalize(), nov_podlog, ostatuk)


OBRUSHTANE = {'you': 'I', 'i': 'you', 'we': 'you', 'they': 'they',
              'he': 'he', 'she': 'she', 'it': 'it'}


def kratuk_otgovor(vupros_tekst, da):
    """„Are you a monster?“ + ДА → „Yes, I am.“ — изведено."""
    r = razdeli(vupros_tekst)
    if not r:
        return ''
    predi_glagola, glagol, ostatuk, _ = r
    tvurdi(predi_glagola == '', 'въпросът не започва с глагола: ' + vupros_tekst)
    dumi = ostatuk.split()
    podlog_vupros = dumi[0]
    #  Ако подлогът е име на герой, в отговора застава местоимението му.
    m = mestoimenie(podlog_vupros)
    nov = OBRUSHTANE[m] if podlog_vupros.lower() in MESTOIMENIQ else m
    nov_glagol = forma(nov)
    if da:
        return 'Yes, {} {}.'.format(nov, nov_glagol)
    if nov_glagol == 'am':
        return "No, {}'m not.".format(nov)
    return 'No, {} {}.'.format(nov, NE_SVIVANE[nov_glagol])


def veren_kratuk(izraz):
    """Правилен ли е сам по себе си даден кратък отговор.

    Трите разрешени форми: „Yes, I am.“ · „No, I'm not.“ ·
    „No, they aren't.“ — всичко друго пада.
    """
    m = re.fullmatch(r"(Yes|No), (\S+) (\S+)\.", izraz)
    if not m:
        return False
    da, podlog, opashka = m.group(1) == 'Yes', m.group(2), m.group(3)
    if podlog.endswith("'m"):
        osnova = podlog[:-2]
        return (not da) and osnova.lower() in MESTOIMENIQ \
            and MESTOIMENIQ[osnova.lower()] == 'am' and opashka == 'not'
    if podlog.lower() not in MESTOIMENIQ:
        return False
    pravilna = MESTOIMENIQ[podlog.lower()]
    if da:
        return opashka == pravilna
    return opashka == NE_SVIVANE.get(pravilna)


#  Спрежението на „съм“ — отделна таблица, не се чете от задачата.
SPREJENIE = {'Аз съм': 'I am', 'Ти си': 'You are', 'Той е': 'He is',
             'Тя е': 'She is', 'То е': 'It is', 'Ние сме': 'We are',
             'Вие сте': 'You are', 'Те са': 'They are'}


# ── упражненията едно по едно ────────────────────────────────────────
def obshti(u):
    for pole in ('kod', 'ime', 'bg', 'ukazanie', 'vid', 'zashto'):
        tvurdi(pole in u and str(u[pole]).strip(), u.get('kod', '?') + ': липсва ' + pole)
    tvurdi(len(u['zashto']) >= 40, u['kod'] + ': обяснението е много късо')
    tvurdi(len(u['ukazanie']) >= 15, u['kod'] + ': указанието е много късо')
    tvurdi(u['vid'] in ('tap', 'type', 'dvoiki', 'red'), u['kod'] + ': непознат вид')
    for tekst in (u['ime'], u['bg'], u['ukazanie'], u['zashto']):
        for duma in ('магия', 'magic', 'monster', 'чудовищ'):
            tvurdi(duma not in tekst.lower(),
                   u['kod'] + ': думата „' + duma + '“ не бива да е тук')


def dupka(u, formi):
    """1, 2, 10 — в празното място застава формата, изведена от подлога."""
    for r in u['redove']:
        izvedeno = forma(r['predi'])
        tvurdi(izvedeno == r['otgovor'],
               '{}: „{} ___ {}“ → изведено {}, записано {}'.format(
                   u['kod'], r['predi'], r['sled'], izvedeno, r['otgovor']))
        tvurdi(r['otgovor'] in formi, u['kod'] + ': отговорът не е am/is/are')
        #  Изречението трябва да е цяло и смислено.
        tvurdi(r['sled'].strip().endswith(('.', '!', '?')),
               u['kod'] + ': изречението не завършва: ' + r['sled'])


def svivane(u):
    """3 — късата форма се сглобява от глагола, не се чете."""
    for r in u['redove']:
        podlog, glagol, ostatuk, _ = razdeli(r['predi'] + '.')
        tvurdi(ostatuk == '', u['kod'] + ': очаква се само подлог и глагол')
        tvurdi(glagol == forma(podlog),
               u['kod'] + ': „' + r['predi'] + '“ не е съгласувано')
        izvedeno = podlog + SVIVANE[glagol]
        tvurdi(izvedeno == r['otgovor'],
               '{}: {} → изведено {}, записано {}'.format(
                   u['kod'], r['predi'], izvedeno, r['otgovor']))
        tvurdi("'" in r['otgovor'], u['kod'] + ': няма апостроф')


def otricaniq(u):
    """4 — всички правилни отрицания трябва да се приемат."""
    for r in u['redove']:
        podlog, glagol, _, _ = razdeli(r['predi'])
        tvurdi(glagol == forma(podlog), u['kod'] + ': даденото не е съгласувано')
        izvedeni = otricanie(r['predi'])
        zapisani = {r['otgovor']} | set(r.get('oshte', []))
        tvurdi(izvedeni == zapisani,
               '{}: „{}“ → изведени {}, записани {}'.format(
                   u['kod'], r['predi'], sorted(izvedeni), sorted(zapisani)))
        tvurdi('not' in r['otgovor'] and r['otgovor'].count('not') == 1,
               u['kod'] + ': основният отговор не е пълното отрицание')


def vuprosi(u):
    """5 — въпросът се извежда с разместване."""
    for r in u['redove']:
        podlog, glagol, _, znak = razdeli(r['predi'])
        tvurdi(glagol == forma(podlog), u['kod'] + ': даденото не е съгласувано')
        tvurdi(znak == '.', u['kod'] + ': дадено е вече въпрос')
        izvedeno = vupros(r['predi'])
        tvurdi(izvedeno == r['otgovor'],
               '{}: „{}“ → изведено „{}“, записано „{}“'.format(
                   u['kod'], r['predi'], izvedeno, r['otgovor']))
        tvurdi(r['otgovor'].endswith('?'), u['kod'] + ': липсва въпросителен знак')


def kratki(u):
    """6 — верният кратък отговор се извежда, а подлъгващите падат."""
    for r in u['redove']:
        da = r['sled'].strip() == '(YES)'
        tvurdi(r['sled'].strip() in ('(YES)', '(NO)'), u['kod'] + ': няма ДА/НЕ')
        izvedeno = kratuk_otgovor(r['predi'], da)
        tvurdi(izvedeno == r['otgovor'],
               '{}: „{}“ {} → изведено „{}“, записано „{}“'.format(
                   u['kod'], r['predi'], r['sled'], izvedeno, r['otgovor']))
        izbori = r['izbori']
        tvurdi(len(izbori) == len(set(izbori)), u['kod'] + ': повтарящи се избори')
        tvurdi(r['otgovor'] in izbori, u['kod'] + ': верният отговор не е сред изборите')
        #  Точно един избор трябва да е правилен — и да е същият.
        pravilni = [iz for iz in izbori if veren_kratuk(iz) and iz == izvedeno]
        drugi = [iz for iz in izbori if iz != r['otgovor'] and veren_kratuk(iz)
                 and iz == kratuk_otgovor(r['predi'], da)]
        tvurdi(len(pravilni) == 1, u['kod'] + ': правилните избори не са един: ' + str(izbori))
        tvurdi(not drugi, u['kod'] + ': има втори правилен избор')
        for iz in izbori:
            if iz == r['otgovor']:
                continue
            #  Подлъгващият или е сгрешено съгласуван, или е друго лице.
            tvurdi(not veren_kratuk(iz) or iz != izvedeno,
                   u['kod'] + ': подлъгващият „' + iz + '“ е правилен')


def greshki(u):
    """7 — вярната дума се извежда от подлога, а в реда наистина има грешка."""
    for r in u['redove']:
        podlog, glagol, _, _ = razdeli(r['predi'])
        izvedeno = forma(podlog)
        tvurdi(izvedeno == r['otgovor'],
               '{}: „{}“ → изведено {}, записано {}'.format(
                   u['kod'], r['predi'], izvedeno, r['otgovor']))
        tvurdi(glagol != izvedeno, u['kod'] + ': в реда няма грешка: ' + r['predi'])


def dvoiki(u):
    """8 — английското се взема от таблицата на спрежението."""
    tvurdi(len(u['dvojki']) == len({p[0] for p in u['dvojki']}),
           u['kod'] + ': повтарящо се българско')
    for bg, en in u['dvojki']:
        tvurdi(bg in SPREJENIE, u['kod'] + ': непознато „' + bg + '“')
        if bg in SPREJENIE:
            tvurdi(SPREJENIE[bg] == en,
                   '{}: {} → изведено „{}“, записано „{}“'.format(
                       u['kod'], bg, SPREJENIE[bg], en))
        podlog, glagol, ostatuk, _ = razdeli(en + '.')
        tvurdi(ostatuk == '', u['kod'] + ': двойката не е само подлог и глагол')
        tvurdi(glagol == forma(podlog), u['kod'] + ': двойката не е съгласувана')


def redove(u):
    """9 — изречението трябва да е съгласувано и правилно наредено."""
    for r in u['redove']:
        izr = r['otgovor']
        podlog, glagol, _, znak = razdeli(izr)
        dumi = izr.rstrip('.?!').split()
        if znak == '?':
            #  Въпрос: глаголът е най-отпред, после подлогът.
            tvurdi(dumi[0].lower() in GLAGOLI, u['kod'] + ': въпросът не почва с глагола')
            tvurdi(forma(dumi[1]) == dumi[0].lower(),
                   u['kod'] + ': въпросът не е съгласуван: ' + izr)
        else:
            tvurdi(znak == '.', u['kod'] + ': изречението няма край: ' + izr)
            tvurdi(podlog != '', u['kod'] + ': няма подлог: ' + izr)
            tvurdi(forma(podlog) == glagol,
                   u['kod'] + ': не е съгласувано: ' + izr)
        tvurdi(izr[0].isupper(), u['kod'] + ': няма главна буква: ' + izr)
        tvurdi(len(dumi) >= 3, u['kod'] + ': много кратко за подреждане')


# ── страницата ───────────────────────────────────────────────────────
def stranicata():
    s = IZHOD.read_text(encoding='utf-8')
    i = s.index('/* ДАННИ:НАЧАЛО')
    kraj = s.index('*/', i) + 2
    tvurdi('\n' not in s[i:kraj], 'маркерът не затваря коментара си на своя ред')
    tvurdi(s[kraj:kraj + 1] == '\n' and s[kraj + 1:].lstrip().startswith('const DANNI = {'),
           'данните не започват веднага след маркера')
    danni = json.loads(s[s.index('const DANNI = ') + len('const DANNI = '):
                         s.index(';\n/* ДАННИ:КРАЙ */')])
    tvurdi(danni['slug'] == SLUG, 'слугът в страницата не е ' + SLUG)
    tvurdi(len(danni['upr']) == len(UPRAJNENIQ), 'упражненията в страницата не са толкова')
    tvurdi(danni['upr'] == json.loads(json.dumps(UPRAJNENIQ, ensure_ascii=False)),
           'задачите в страницата се различават от tobe.py')
    tvurdi(danni['pohvali'] == POHVALI, 'похвалите липсват')

    #  Платформата: вход, записване, изход.
    for parche in ('assets/supabase-config.js', 'assets/auth.js',
                   'TLA.requireAuth()', 'TLA.isConfigured()', 'TLA.signOut()',
                   'TLA.saveAttempt(DANNI.slug', 'id="gate"', 'id="sheet"',
                   'id="checkBtn"', 'id="resetBtn"', 'id="signOutBtn"'):
        tvurdi(parche in s, 'липсва от страницата: ' + parche)
    tvurdi(s.count('<style>') == s.count('</style>'), 'незатворен <style>')
    tvurdi(s.rstrip().endswith('</html>'), 'страницата не завършва с </html>')
    tvurdi('.tlp-bar{' in s and '--accent-ink:' in s, 'лентата не е вградена')
    tvurdi('магия' not in s.lower(), 'думата „магия“ е в страницата')
    tvurdi('Cat Family Album' in s, 'заглавието не е „Cat Family Album“')
    for kote in ('Milo', 'Daisy', 'Luna', 'Tom and Tim'):
        tvurdi(kote in s, 'липсва котето ' + kote)
    #  Четирите котета в шапката се рисуват, не са емоджи.
    tvurdi(s.count('function kote(') == 1 and s.count('kote(BOI[') == 4,
           'котетата в шапката не са четири нарисувани')
    #  Листът е за котета — от чудовищата не бива да е останала следа.
    for duma in ('monster', 'чудовищ'):
        tvurdi(duma not in s.lower(), 'останала е думата „' + duma + '“')
    tvurdi('noindex' in s, 'листът трябва да е noindex')

    #  Всеки отговор трябва да стои в данните — иначе не може да се познае.
    for u in UPRAJNENIQ:
        if u['vid'] == 'dvoiki':
            for bg, en in u['dvojki']:
                tvurdi(json.dumps(en, ensure_ascii=False)[1:-1] in s, 'липсва: ' + en)
        else:
            for r in u['redove']:
                tvurdi(json.dumps(r['otgovor'], ensure_ascii=False)[1:-1] in s,
                       'липсва отговор: ' + r['otgovor'])
    #  Двигателят трябва да познава всички видове.
    for vid in sorted({u['vid'] for u in UPRAJNENIQ}):
        tvurdi("'" + vid + "'" in s, 'двигателят не познава вид ' + vid)
    #  Редът в базата и страницата трябва да си говорят едно и също.
    red = (KOREN / 'supabase/domashno-angliyski-4.sql').read_text(encoding='utf-8')
    tvurdi("'" + SLUG + "'" in red, 'слугът липсва от SQL файла')
    tvurdi("'" + IZHOD.name + "'" in red, 'SQL файлът сочи друга страница')
    tvurdi('Cat Family Album' in red, 'SQL файлът още пише старото заглавие')
    tvurdi('\n     49,' in red, 'точките в SQL файла не са 49')
    return len(s)


def main():
    kodove = [u['kod'] for u in UPRAJNENIQ]
    tvurdi(kodove == [str(i + 1) for i in range(len(UPRAJNENIQ))], 'номерацията е счупена')
    tvurdi(len(UPRAJNENIQ) == 10, 'упражненията не са 10')
    tvurdi(len(POHVALI) == 3, 'похвалите не са три')

    po_kod = {u['kod']: u for u in UPRAJNENIQ}
    for u in UPRAJNENIQ:
        obshti(u)
    #  tap/type с am-is-are
    dupka(po_kod['1'], ('am', 'is', 'are'))
    for r in po_kod['1']['redove']:
        tvurdi(r['otgovor'] in po_kod['1']['izbori'], '1: отговорът не е сред изборите')
    dupka(po_kod['2'], ('am', 'is', 'are'))
    dupka(po_kod['10'], ('am', 'is', 'are'))
    svivane(po_kod['3'])
    otricaniq(po_kod['4'])
    vuprosi(po_kod['5'])
    kratki(po_kod['6'])
    greshki(po_kod['7'])
    dvoiki(po_kod['8'])
    redove(po_kod['9'])

    obshto = sum(broi_redove(u) for u in UPRAJNENIQ)
    tvurdi(obshto == 49, 'отговорите не са 49, а ' + str(obshto))
    znaka = stranicata()

    if GRESHKI:
        print('ГРЕШКИ ({}):'.format(len(GRESHKI)))
        for g in GRESHKI:
            print('  ·', g)
        sys.exit(1)
    print('всичко е вярно · проверки: {} · упражнения: {} · отговора: {} · {} знака'
          .format(PROVERKI, len(UPRAJNENIQ), obshto, znaka))


if __name__ == '__main__':
    main()
