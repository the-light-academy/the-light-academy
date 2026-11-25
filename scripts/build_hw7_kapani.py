#!/usr/bin/env python3
"""Сглобява homework_7_kapani.html — домашното „Осемте капана“.

Листът не се пише от нулата: взима се вече работещият homework_7_w12.html
и в него се сменят само заглавието, въпросите и короткото име, с което
резултатът влиза в платформата. Така входът, записът на опита, бутоните
и целият вид остават същите, каквито детето вече познава, и нищо от тях
не може да се счупи по невнимание.

Въпросите стоят в scripts/kapani/domashno.py. Грешните отговори там не
са измислени — те са точно тези, които са дадени в таблото.

    /usr/bin/python3.13 scripts/build_hw7_kapani.py
"""
import json
import pathlib
import sys

KOREN = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from kapani.domashno import VUPROSI                       # noqa: E402

KALUP = KOREN / 'homework_7_w12.html'
IZHOD = KOREN / 'homework_7_kapani.html'
SLUG = 'hw7-kapani'

GLAVA = '''/* Домашно за 7. клас — осемте капана.

   Десет въпроса по осемте места, на които сметката се обърква най-често.
   Не е ново учебно съдържание: всеки въпрос се връща към капан, минат в
   урока „Осемте капана“, но с ДРУГИ числа — проверява се разбирането, не
   паметта.

   Грешните отговори не са измислени. Всеки от тях е сметка, която
   наистина е дадена: x² − 49 вместо x² − 14x + 49, 7x³y вместо 12x³y,
   (x − 50)(x + 50) вместо (x − 10)(x + 10). Затова изборът на разсейващ
   отговор не е случайност — той казва точно кой капан още стои.

   Нито един разсейващ отговор не е тъждествено равен на верния: дете,
   написало вярното нещо по друг начин, не получава кръстче. Проверката
   scripts/check_kapani.py го налага. */'''


def niz(s):
    """Низ за JavaScript — през json, за да няма ръчно екраниране."""
    return json.dumps(s, ensure_ascii=False)


def vupros(v):
    if v['tip'] == 'mc':
        return ('  { type:"mc", tag:%s,\n'
                '    expr:%s,\n'
                '    choices:[%s],\n'
                '    correct:%d,\n'
                '    explain:%s },'
                % (niz(v['etiket']), niz(v['uslovie']),
                   ', '.join(niz(x) for x in v['izbori']),
                   v['veren'], niz(v['obyasnenie'])))
    return ('  { type:"free-frac", tag:%s, label:"=",\n'
            '    expr:%s,\n'
            '    answer:%s,\n'
            '    explain:%s },'
            % (niz(v['etiket']), niz(v['uslovie']),
               niz(v['otgovor']), niz(v['obyasnenie'])))


def smeni(tekst, star, nov, kakvo):
    if tekst.count(star) != 1:
        raise SystemExit('калъпът се е променил: %s (%d пъти)'
                         % (kakvo, tekst.count(star)))
    return tekst.replace(star, nov)


def main() -> None:
    t = KALUP.read_text(encoding='utf-8')

    t = smeni(t,
              '<title>Домашно — Разлагане чрез формулите за съкратено '
              'умножение — 7. клас · The Light Academy</title>',
              '<title>Домашно — Осемте капана — 7. клас · '
              'The Light Academy</title>', 'заглавие')
    t = smeni(t,
              'content="Домашно за 7. клас, седмица 12 — разлагане на '
              'множители чрез формулите за съкратено умножение. За ученици '
              'с профил в платформата."',
              'content="Домашно за 7. клас — десет въпроса по осемте '
              'места, на които сметката се обърква най-често. За ученици '
              'с профил в платформата."', 'описание')
    t = smeni(t,
              '<div class="eyebrow"><span class="dot"></span>Домашно · '
              '7. клас · седмица 12</div>',
              '<div class="eyebrow"><span class="dot"></span>Домашно · '
              '7. клас · по грешките</div>', 'надпис')
    t = smeni(t, '<h1>Разлагане чрез <em>формулите</em></h1>',
              '<h1>Осемте <em>капана</em></h1>', 'главно заглавие')
    t = smeni(t,
              '<div class="subhead">10 задачи: пълен квадрат и разлика на '
              'квадрати, прочетени наобратно, плюс задачи, в които първо се '
              'изнася общ множител и чак после идва формулата. Избери или '
              'напиши по един отговор на всяка.</div>',
              '<div class="subhead">10 задачи по осемте места, на които '
              'сметката се обърква най-често: минусът пред скобата, средният '
              'член, разликата на квадрати, заместването, знаците, степените '
              'и процентът. Избери или напиши по един отговор на всяка.</div>',
              'подзаглавие')
    t = smeni(t, "await TLA.saveAttempt('hw7-w12', {",
              "await TLA.saveAttempt('%s', {" % SLUG, 'кратко име')

    #  въпросите: от обяснението отгоре до затварящата скоба
    nachalo = t.index('/* Домашно за 7. клас, седмица 12')
    kraj = t.index('\n];\n', nachalo) + len('\n];\n')
    nov = (GLAVA + '\n\nconst QUESTIONS = [\n\n'
           + '\n\n'.join(vupros(v) for v in VUPROSI) + '\n];\n')
    t = t[:nachalo] + nov + t[kraj:]

    IZHOD.write_text(t, encoding='utf-8')
    print('%s · въпроси: %d · %.1f KB'
          % (IZHOD.name, len(VUPROSI), len(t.encode('utf-8')) / 1024))


if __name__ == '__main__':
    main()
