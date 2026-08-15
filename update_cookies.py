#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import re

files = ['index.html', 'birthdays.html', 'nvo7.html']

# Bulgarian translations to add to the js translations object
bg_translations = '''        "cookies.title": "Политика за бисквитките",
        "cookies.desc": "Този сайт използва бисквитки, за да осигури нормалното му функциониране и да събира анонимни данни за посещаемостта. Избирате между \\"Приемам всички\\", \\"Само основни\\" и \\"Отказвам\\". Вижте <a href=\\"cookie-policy.html\\" style=\\"color:#F5A623; text-decoration: underline;\\">Политиката за бисквитките</a>.",
        "cookies.link": "Политиката за бисквитките",
        "cookies.accept": "Приемам всички",
        "cookies.essential": "Само основни",
        "cookies.reject": "Отказвам",
        "cookies.settings": "Настройки на бисквитките"'''

# English translations
en_translations = '''        "cookies.title": "Cookie Policy",
        "cookies.desc": "This site uses cookies to provide its core functionality and, when consent is given, to collect anonymous analytics. You can choose between \\"Accept all\\", \\"Only essential\\", and \\"Reject optional cookies\\". See our <a href=\\"cookie-policy.html\\" style=\\"color:#F5A623; text-decoration: underline;\\">Cookie Policy</a>.",
        "cookies.link": "Cookie Policy",
        "cookies.accept": "Accept all",
        "cookies.essential": "Only essential",
        "cookies.reject": "Reject",
        "cookies.settings": "Cookie settings"'''

for fname in files:
    print(f"Processing {fname}...")
    with open(fname, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Add Bulgarian translations before the closing of the 'bg' translations object
    # Look for the pattern: "footer.birthdays": "..." with bg language, followed by closing }
    bg_pattern = r'("footer\.birthdays":\s*"[^"]*")\s*\n\s*}\s*\n\s*};'
    bg_replacement = f'\\1,\n{bg_translations}\n        }}\n    }};'
    content = re.sub(bg_pattern, bg_replacement, content)
    
    # Add English translations
    en_pattern = r'("footer\.birthdays":\s*"[^"]*")\s*\n\s*}\s*\n\s*};'
    en_replacement = f'\\1,\n{en_translations}\n        }}\n    }};'
    # Only replace the first occurrence (English) in the translations object
    content = re.sub(en_pattern, en_replacement, content, count=1)
    
    with open(fname, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✓ Updated {fname}")

print("\n✓ All files updated!")
