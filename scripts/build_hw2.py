#!/usr/bin/env python3
"""Сглобява вторите нива на домашните за 6. клас.

Всяко домашно „ниво 2“ е същият лист като основния за седмицата — същият
стил, същият двигател, същото оценяване — само задачите са други и
по-трудни. Затова файлът не се пише наново: взима се основният, подменят
се заглавието, подзаглавието, описанието, slug-ът и блокът QUESTIONS.

Задачите стоят в scripts/hw2/questions.py. Пуска се така:

    python3 scripts/build_hw2.py            # всички седмици
    python3 scripts/build_hw2.py w01 w04    # само тези

Отговорите се проверяват отделно: scratchpad/hw2check.js пресмята наново
всяка задача, която е израз, и гледа всичко останало — брой отговори,
липсващи обяснения, повтарящи се условия.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'scripts'))
from hw2.questions import WEEKS            # noqa: E402


def js(s: str) -> str:
    """Низ за JavaScript — в двойни кавички, с избягани нови редове."""
    out = (str(s)
           .replace('\\', '\\\\')
           .replace('"', '\\"')
           .replace('\n', '\\n'))
    return '"' + out + '"'


def engine(base_html: str) -> str:
    """Кой двигател е сложен в основния лист.

    Повечето листове приемат дроби в полето („free-frac“). Листът за
    седмица 32 е по-стар и чака чисти числа („free-num“): отговорът там
    е число, а не низ, и полето носи мерна единица и подсказка. Листът
    „ниво 2“ трябва да говори на езика на своя двигател, иначе задачите
    не се изчертават.
    """
    return 'num' if "q.type === 'free-num'" in base_html else 'frac'


def jsnum(a: str) -> str:
    """„129,6“ → 129.6 — число за JavaScript, не низ."""
    t = str(a).replace('\u2212', '-').replace(',', '.').strip()
    v = float(t)
    return str(int(v)) if v == int(v) else repr(v)


def block(qs: list, kind: str = 'frac') -> str:
    """Списъкът със задачи → литералът, който страницата чака."""
    parts = []
    for q in qs:
        head = []
        if kind == 'frac' and q.get('sec'):
            head.append('section:' + js(q['sec']))
            if q.get('secNote'):
                head.append('sectionNote:' + js(q['secNote']))
        if q['t'] == 'mc':
            head.append('type:' + js('mc'))
        else:
            head.append('type:' + js('free-num' if kind == 'num' else 'free-frac'))
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
        if kind == 'num' and q['t'] != 'mc':
            body.append('hint:' + js(q.get('hint', '')))

        parts.append('  { ' + ', '.join(head) + ',\n    ' + ',\n    '.join(body) + ' }')
    return 'const QUESTIONS = [\n\n' + ',\n\n'.join(parts) + '\n];'


def plain_h1(html: str) -> str:
    """Заглавието на основния лист, без <em> и прочее."""
    return re.sub(r'<[^>]+>', '', html).strip()


def build(key: str, spec: dict) -> str:
    base = (ROOT / spec['base']).read_text(encoding='utf-8')
    out = base

    # 1. <title>: „ · ниво 2“ влиза преди „ — 6. клас“
    m = re.search(r'<title>(.*?)</title>', out, re.S)
    if not m:
        sys.exit(spec['base'] + ': няма <title>')
    title = m.group(1)
    if ' · ниво 2' in title:
        sys.exit(spec['base'] + ': това вече е лист от ниво 2')
    new_title = title.replace(' — 6. клас', ' · ниво 2 — 6. клас', 1)
    out = out.replace(m.group(0), '<title>' + new_title + '</title>', 1)

    # 2. описанието за търсачките и за споделяне
    out = re.sub(r'<meta name="description" content="[^"]*" />',
                 '<meta name="description" content="' + spec['desc'] + '" />',
                 out, count=1)

    # 3. H1 и редът под него
    m = re.search(r'<h1>(.*?)</h1>', out, re.S)
    if not m:
        sys.exit(spec['base'] + ': няма <h1>')
    out = out.replace(
        m.group(0),
        '<h1>' + plain_h1(m.group(1)) + ' <em>· ниво 2</em></h1>', 1)
    m = re.search(r'<div class="subhead">(.*?)</div>', out, re.S)
    if not m:
        sys.exit(spec['base'] + ': няма ред под заглавието')
    out = out.replace(m.group(0),
                      '<div class="subhead">' + spec['sub'] + '</div>', 1)

    # 4. slug-ът, по който резултатът влиза в профила
    m = re.search(r"saveAttempt\('([^']+)'", out)
    if not m:
        sys.exit(spec['base'] + ': няма saveAttempt')
    out = out.replace("saveAttempt('" + m.group(1) + "'",
                      "saveAttempt('" + spec['slug'] + "'", 1)

    # 5. самите задачи
    i = out.find('const QUESTIONS')
    j = out.find('\n];', i)
    if i < 0 or j < 0:
        sys.exit(spec['base'] + ': не намирам блока със задачите')
    out = out[:i] + block(spec['qs'], engine(base)) + out[j + len('\n];'):]

    # 6. един ред отгоре, за да се знае какво е това
    out = out.replace('<style>', '<!-- Лист „ниво 2“ към ' + spec['base'] +
                      ' — сглобен от scripts/build_hw2.py. Не го пипай на ръка:\n'
                      '     задачите се редактират в scripts/hw2/questions.py. -->\n<style>', 1)
    return out


def main() -> None:
    want = sys.argv[1:]
    keys = [k for k in WEEKS if not want or k in want]
    if want:
        missing = [w for w in want if w not in WEEKS]
        if missing:
            sys.exit('няма такива седмици: ' + ', '.join(missing))
    for k in sorted(keys):
        spec = WEEKS[k]
        html = build(k, spec)
        (ROOT / spec['out']).write_text(html, encoding='utf-8')
        kb = len(html.encode('utf-8')) / 1024
        print('%-26s %6.1f KB · %d задачи' % (spec['out'], kb, len(spec['qs'])))


if __name__ == '__main__':
    main()
