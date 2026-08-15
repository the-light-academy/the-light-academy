#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Fix the cookie banner p tag for all files
files = {
    'index.html': {
        'old_p': '<p>This site uses cookies to provide its core functionality and, when consent is given, to collect anonymous analytics. You can choose between "Accept all", "Only essential", and "Reject optional cookies". See our <a href="cookie-policy.html" style="color:#F5A623; text-decoration: underline;">Cookie Policy</a>.</p>',
        'new_p': '<p data-i18n="cookies.desc">Този сайт използва бисквитки, за да осигури нормалното му функциониране и да събира анонимни данни за посещаемостта. Избирате между "Приемам всички", "Само основни" и "Отказвам". Вижте <a href="cookie-policy.html" style="color:#F5A623; text-decoration: underline;">Политиката за бисквитките</a>.</p>'
    },
    'birthdays.html': {
        'old_p': '<p>This site uses cookies to provide its core functionality and, when consent is given, to collect anonymous analytics. You can choose between "Accept all", "Only essential", and "Reject optional cookies". See our <a href="cookie-policy.html" style="color:#F5A623; text-decoration: underline;">Cookie Policy</a>.</p>',
        'new_p': '<p data-i18n="cookies.desc">Този сайт използва бисквитки, за да осигури нормалното му функциониране и да събира анонимни данни за посещаемостта. Избирате между "Приемам всички", "Само основни" и "Отказвам". Вижте <a href="cookie-policy.html" style="color:#F5A623; text-decoration: underline;">Политиката за бисквитките</a>.</p>'
    },
    'nvo7.html': {
        'old_p': '<p>Този сайт използва бисквитки, за да осигури нормалното му функциониране и да събира анонимни данни за посещаемостта. Използваме три възможности за избор: „Приемам всички", „Само основни" и „Отказвам". Вижте <a href="cookie-policy.html" style="color:#F5A623; text-decoration: underline;">Политиката за бисквитките</a>.</p>',
        'new_p': '<p data-i18n="cookies.desc">Този сайт използва бисквитки, за да осигури нормалното му функциониране и да събира анонимни данни за посещаемостта. Избирате между "Приемам всички", "Само основни" и "Отказвам". Вижте <a href="cookie-policy.html" style="color:#F5A623; text-decoration: underline;">Политиката за бисквитките</a>.</p>'
    }
}

for fname, replacements in files.items():
    with open(fname, 'r', encoding='utf-8') as f:
        content = f.read()
    
    old = replacements['old_p']
    new = replacements['new_p']
    
    if old in content:
        content = content.replace(old, new)
        with open(fname, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✓ Fixed {fname}")
    else:
        print(f"✗ Could not find p tag in {fname} (might already be fixed)")

print("Done!")
