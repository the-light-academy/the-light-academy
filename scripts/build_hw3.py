#!/usr/bin/env python3
"""Сглобява третото ниво на домашните за 6. клас — „ниво В група“.

Същият ред като при ниво 2: листът не се пише наново, а се взема
основният за седмицата и в него се подменят заглавието, подзаглавието,
описанието, slug-ът и задачите. Така всички листове за една тема си
приличат и детето не се учи да работи с нов интерфейс, а с по-трудни
задачи.

Разликата е в задачите. Тук те са състезателни: такива, каквито се
дават на Иван Салабашев, Европейско кенгуру, Черноризец Храбър и на
общинските кръгове. Десет на лист, подредени от „трудна“ към „много
трудна“, всяка с една идея, която трябва да се види.

Задачите стоят в scripts/hw3/zadachi.py. Пуска се така:

    python3 scripts/build_hw3.py            # всички теми
    python3 scripts/build_hw3.py w01 w04    # само тези

Отговорите се проверяват отделно — scripts/check_hw3.py ги пресмята
наново, най-често с изчерпване (търсене сред всички възможности), а не
по формулата от решението.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'scripts'))
from build_hw2 import engine, js, jsnum, plain_h1   # noqa: E402
from hw3.zadachi import TEMI                        # noqa: E402

NIVO = ' · ниво В група'


def block(qs: list, kind: str = 'frac') -> str:
    """Списъкът със задачи → литералът, който страницата чака.

    Същото като при ниво 2, но тук всяка задача може да носи и подсказка:
    при състезателните задачи едно изречение „откъде се хваща“ върши
    повече работа от готовото решение.
    """
    parts = []
    for q in qs:
        head = []
        if kind == 'frac' and q.get('sec'):
            head.append('section:' + js(q['sec']))
            if q.get('secNote'):
                head.append('sectionNote:' + js(q['secNote']))
        head.append('type:' + js('mc' if q['t'] == 'mc' else
                                 ('free-num' if kind == 'num' else 'free-frac')))
        head.append('tag:' + js(q['tag']))
        if q['t'] == 'mc' and len(q['opts']) == 3 and kind == 'frac':
            head.append('three:true')
        if q['t'] != 'mc' and kind == 'num':
            head.append('label:' + js(q.get('label', '=')))
            if q.get('unit'):
                head.append('unit:' + js(q['unit']))
            head.append('placeholder:' + js(q.get('ph', 'Въведи числото…')))
        else:
            if q.get('label'):
                head.append('label:' + js(q['label']))
            if q.get('ph'):
                head.append('placeholder:' + js(q['ph']))

        body = ['expr:' + js(q['q'])]
        if q['t'] == 'mc':
            body.append('choices:[' + ', '.join(js(o) for o in q['opts']) + ']')
            body.append('correct:' + str(q['c']))
        elif kind == 'num':
            body.append('answer:' + jsnum(q['a']))
        else:
            body.append('answer:' + js(q['a']))
        body.append('explain:' + js(q['why']))
        if q['t'] != 'mc' and (kind == 'num' or q.get('hint')):
            body.append('hint:' + js(q.get('hint', '')))

        parts.append('  { ' + ', '.join(head) + ',\n    ' + ',\n    '.join(body) + ' }')
    return 'const QUESTIONS = [\n\n' + ',\n\n'.join(parts) + '\n];'


def build(spec: dict) -> str:
    base = (ROOT / spec['base']).read_text(encoding='utf-8')
    out = base

    m = re.search(r'<title>(.*?)</title>', out, re.S)
    if not m:
        sys.exit(spec['base'] + ': няма <title>')
    if NIVO in m.group(1) or ' · ниво 2' in m.group(1):
        sys.exit(spec['base'] + ': това вече е лист от по-горно ниво')
    out = out.replace(m.group(0), '<title>' +
                      m.group(1).replace(' — 6. клас', NIVO + ' — 6. клас', 1) +
                      '</title>', 1)

    out = re.sub(r'<meta name="description" content="[^"]*" />',
                 '<meta name="description" content="' + spec['desc'] + '" />',
                 out, count=1)

    m = re.search(r'<h1>(.*?)</h1>', out, re.S)
    if not m:
        sys.exit(spec['base'] + ': няма <h1>')
    out = out.replace(m.group(0), '<h1>' + plain_h1(m.group(1)) +
                      ' <em>· ниво В група</em></h1>', 1)
    m = re.search(r'<div class="subhead">(.*?)</div>', out, re.S)
    if not m:
        sys.exit(spec['base'] + ': няма ред под заглавието')
    out = out.replace(m.group(0), '<div class="subhead">' + spec['sub'] + '</div>', 1)

    m = re.search(r"saveAttempt\('([^']+)'", out)
    if not m:
        sys.exit(spec['base'] + ': няма saveAttempt')
    out = out.replace("saveAttempt('" + m.group(1) + "'",
                      "saveAttempt('" + spec['slug'] + "'", 1)

    i = out.find('const QUESTIONS')
    j = out.find('\n];', i)
    if i < 0 or j < 0:
        sys.exit(spec['base'] + ': не намирам блока със задачите')
    out = out[:i] + block(spec['qs'], engine(base)) + out[j + len('\n];'):]

    out = out.replace('<style>', '<!-- Лист „ниво В група“ към ' + spec['base'] +
                      ' — сглобен от scripts/build_hw3.py. Не го пипай на ръка:\n'
                      '     задачите се редактират в scripts/hw3/zadachi.py. -->\n<style>', 1)
    return out


def main() -> None:
    want = sys.argv[1:]
    missing = [w for w in want if w not in TEMI]
    if missing:
        sys.exit('няма такива теми: ' + ', '.join(missing))
    for k in sorted(want or TEMI):
        spec = TEMI[k]
        html = build(spec)
        (ROOT / spec['out']).write_text(html, encoding='utf-8')
        print('%-28s %6.1f KB · %d задачи' % (spec['out'],
              len(html.encode('utf-8'))/1024, len(spec['qs'])))


if __name__ == '__main__':
    main()
