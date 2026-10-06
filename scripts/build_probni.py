#!/usr/bin/env python3
"""Сглобява готовите пробни тестове от частите в scripts/probni/.

Всеки изходен файл е самостоятелен: стил, двигател, чертежи, условия и
анимации влизат вътре. Няма външни заявки, няма CDN — отваря се с двоен
клик и работи без интернет.

Отговорите в файловете с условията се пишат четимо (ans: '1245'). Тук
стават enc: '<base64>', за да не лъснат при набързо отваряне на кода.
"""
import base64
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / 'scripts' / 'probni'
OUT = ROOT / 'probni_testove'

TESTS = [
    {
        'data': 'test2018.js',
        'anim': 'anim2018.js',
        'out': 'probna_obshtinski_2018_4klas.html',
        'title': 'Пробен общински кръг 2018 — математика, 4. клас',
        'desc': 'Интерактивна пробна тема за общинския кръг на олимпиадата '
                'по математика, 4. клас — темата от 15.12.2018 г. с таймер, '
                'проверка на отговорите и анимирани решения.',
    },
    {
        'data': 'test2020.js',
        'anim': 'anim2020.js',
        'out': 'probna_obshtinski_2020_4klas.html',
        'title': 'Пробен общински кръг 2020 — математика, 4. клас',
        'desc': 'Интерактивна пробна тема за общинския кръг на олимпиадата '
                'по математика, 4. клас — темата от 2020 г. с таймер, '
                'проверка на отговорите и анимирани решения.',
    },
]


def enc(s: str) -> str:
    return base64.b64encode(s.encode('utf-8')).decode('ascii')


ANS_RE = re.compile(r"ans:\s*'([^']*)'")


def encode_answers(js: str) -> tuple[str, int]:
    """ans: 'x'  ->  enc: '<base64x>'. Връща и броя сменени."""
    n = 0

    def sub(m):
        nonlocal n
        n += 1
        return "enc: '" + enc(m.group(1)) + "'"

    return ANS_RE.sub(sub, js), n


def fill_figures(js: str, figures: dict) -> str:
    for name, svg in figures.items():
        ph = '__FIG_' + name.upper() + '__'
        if ph in js:
            js = js.replace("'" + ph + "'", json.dumps(svg, ensure_ascii=False))
    left = re.findall(r'__FIG_[A-Z_]+__', js)
    if left:
        sys.exit('няма чертеж за: ' + ', '.join(sorted(set(left))))
    return js


def read_figures() -> dict:
    """Изпълнява figures.js през node и прибира готовите SVG-та."""
    import subprocess
    src = (SRC / 'figures.js').read_text(encoding='utf-8')
    code = src + '\nprocess.stdout.write(JSON.stringify(FIGURES));'
    p = subprocess.run(['node', '-e', code], capture_output=True, text=True)
    if p.returncode != 0:
        sys.exit('figures.js не се изпълнява:\n' + p.stderr)
    return json.loads(p.stdout)


def main() -> None:
    shell = (SRC / 'shell.html').read_text(encoding='utf-8')
    css = (SRC / 'engine.css').read_text(encoding='utf-8')
    engine = (SRC / 'engine.js').read_text(encoding='utf-8')
    figures = read_figures()
    OUT.mkdir(exist_ok=True)

    for t in TESTS:
        data = (SRC / t['data']).read_text(encoding='utf-8')
        anim = (SRC / t['anim']).read_text(encoding='utf-8')
        data = fill_figures(data, figures)
        data, n = encode_answers(data)
        if n == 0:
            sys.exit(t['data'] + ': не намерих нито един отговор за кодиране')
        if "ans:" in data:
            sys.exit(t['data'] + ': остана некодиран отговор')

        html = (shell
                .replace('__TITLE__', t['title'])
                .replace('__DESC__', t['desc'])
                .replace('__CSS__', css)
                .replace('__DATA__', data + '\n' + anim)
                .replace('__ENGINE__', engine))
        left = re.findall(r'__[A-Z_]+__', html)
        if left:
            sys.exit(t['out'] + ': незаменени места: ' + ', '.join(sorted(set(left))))
        (OUT / t['out']).write_text(html, encoding='utf-8')
        kb = len(html.encode('utf-8')) / 1024
        print('%-42s %6.1f KB · %d отговора' % (t['out'], kb, n))


if __name__ == '__main__':
    main()
