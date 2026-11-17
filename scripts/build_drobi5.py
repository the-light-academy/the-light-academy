#!/usr/bin/env python3
"""Сглобява artefakti/urok_5_drobi.html — урокът „Дроби в сладкарницата“.

Интерактивен урок по математика за 5. клас в два таба: събиране и
изваждане с привеждане под общ знаменател, и умножение и деление на
обикновени дроби. Всеки таб върви от лесни към трудни, а всяка задача
има бутон „Покажи решението“, който отваря отговора заедно със стъпките.

Страницата е направена като АРТЕФАКТ: няма свои <html>, <head> и <body>
— те идват от самия артефакт при качването. Отваря се и направо в
браузър: той сам дописва обвивката.

Задачите стоят в scripts/drobi5/zadachi.py, изразите се изчертават от
scripts/grad6/izraz.py, а scripts/check_drobi5.py ги пресмята наново с
точни дроби и чете екрана назад.

    /usr/bin/python3.13 scripts/build_drobi5.py
"""
import json
import math
import pathlib
import sys

KOREN = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from drobi5.zadachi import TABOVE                   # noqa: E402
from grad6.izraz import izobrazi                    # noqa: E402

IZHOD = KOREN / 'artefakti/urok_5_drobi.html'


def parche(cx, cy, r, ot, do):
    """Едно парче от кръга — пресметнато, а не писано на ръка."""
    a1, a2 = math.radians(ot - 90), math.radians(do - 90)
    x1, y1 = cx + r * math.cos(a1), cy + r * math.sin(a1)
    x2, y2 = cx + r * math.cos(a2), cy + r * math.sin(a2)
    golqma = 1 if (do - ot) > 180 else 0
    return ('M %.2f %.2f L %.2f %.2f A %d %d 0 %d 1 %.2f %.2f Z'
            % (cx, cy, x1, y1, r, r, golqma, x2, y2))


def tortichki():
    """Три торти, нарязани на 2, 3 и 4 — с отрязаното в акцента."""
    centrove = [(36, 34), (110, 34), (184, 34)]
    narqzani = [(2, 1, '1/2'), (3, 1, '1/3'), (4, 3, '3/4')]
    out = []
    for (cx, cy), (chasti, vzeti, nadpis) in zip(centrove, narqzani):
        stupka = 360 / chasti
        out.append('<circle cx="%d" cy="%d" r="25" fill="var(--testo)" />'
                   % (cx, cy))
        for i in range(vzeti):
            out.append('<path d="%s" fill="var(--malina)" />'
                       % parche(cx, cy, 25, i * stupka, (i + 1) * stupka))
        for i in range(chasti):
            a = math.radians(i * stupka - 90)
            out.append('<line x1="%d" y1="%d" x2="%.2f" y2="%.2f" '
                       'stroke="var(--kora)" stroke-width="1.6" />'
                       % (cx, cy, cx + 25 * math.cos(a), cy + 25 * math.sin(a)))
        out.append('<circle cx="%d" cy="%d" r="25" fill="none" '
                   'stroke="var(--kora)" stroke-width="2.4" />' % (cx, cy))
        out.append('<text x="%d" y="70" text-anchor="middle" fill="var(--kora)" '
                   'font-size="13" font-weight="700" '
                   'font-family="Nunito, sans-serif">%s</text>' % (cx, nadpis))
    return '\n      '.join(out)


STRANICA = r"""<title>Дроби в сладкарницата</title>
<meta name="claude:viewport-fit-sides" content="cover" />
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Fredoka:wght@500;600;700&family=Nunito:wght@400;600;700;800&display=swap" />
<style>
/* Разположение: една колона — шапка с три нарязани торти, лента с двата
   таба, после нивата едно под друго. Всяка задача е картичка с едър
   израз и бутон, който отваря решението под него. */
:root{
  --mastilo:#3B2418;        /* какао — основният текст */
  --mastilo-blqdo:#7A5C49;
  --hartiq:#FFF9F1;         /* фон на страницата */
  --karta:#FFFFFF;
  --ramka:#F0DFC9;
  --malina:#C2185B;         /* акцентът — малиновият пълнеж */
  --malina-meko:#FCE7EF;
  --karamel:#B9681A;
  --karamel-meko:#FBEBD8;
  --testo:#F6E3C8;          /* тестото на тортите */
  --kora:#5A3A26;
  --zeleno:#1C6B45;
  --zeleno-meko:#E2F3EA;
  --senka:24 40% 30%;
}
@media (prefers-color-scheme: dark){
  :root:not([data-theme="light"]){
    --mastilo:#F6E8DA; --mastilo-blqdo:#C2A58F;
    --hartiq:#1A120D; --karta:#271A13; --ramka:#443023;
    --malina:#F48FB1; --malina-meko:#3C1526;
    --karamel:#E8A765; --karamel-meko:#3A2614;
    --testo:#4A3321; --kora:#F6E8DA;
    --zeleno:#7BD7A6; --zeleno-meko:#15301F;
    --senka:24 60% 4%;
    color-scheme: dark;
  }
}
:root[data-theme="dark"]{
  --mastilo:#F6E8DA; --mastilo-blqdo:#C2A58F;
  --hartiq:#1A120D; --karta:#271A13; --ramka:#443023;
  --malina:#F48FB1; --malina-meko:#3C1526;
  --karamel:#E8A765; --karamel-meko:#3A2614;
  --testo:#4A3321; --kora:#F6E8DA;
  --zeleno:#7BD7A6; --zeleno-meko:#15301F;
  --senka:24 60% 4%;
  color-scheme: dark;
}
*,*::before,*::after{ box-sizing:border-box }
body{
  margin:0; background:var(--hartiq); color:var(--mastilo);
  font-family:'Nunito',system-ui,-apple-system,sans-serif;
  font-size:18px; line-height:1.55; -webkit-text-size-adjust:100%;
  overflow-x:hidden;
}
body::before{
  content:""; position:fixed; inset:0 0 auto; height:env(safe-area-inset-top, 0px);
  z-index:10; background:var(--malina);
}
h1,h2,h3{ font-family:'Fredoka',system-ui,sans-serif; margin:0; text-wrap:balance }
button{ font:inherit; cursor:pointer }
[hidden]{ display:none !important }

.ramka{
  max-width:860px; margin:0 auto;
  padding-left:max(16px, env(safe-area-inset-left, 0px));
  padding-right:max(16px, env(safe-area-inset-right, 0px));
}

/* ── шапка ─────────────────────────────────────────────────────── */
.shapka{ background:var(--malina); color:#FFF4F8 }
.shapka .ramka{ padding-block:20px 0; display:flex; gap:20px; align-items:flex-end;
  flex-wrap:wrap }
.shapka__text{ flex:1 1 320px; min-width:0; padding-bottom:16px }
.shapka h1{ font-size:clamp(27px,7vw,42px); line-height:1.06; margin-bottom:8px }
.shapka p{ margin:0; color:#FBD9E5; font-size:clamp(16px,4.2vw,18px); max-width:52ch }
.nadpis{ font-size:14px; font-weight:800; letter-spacing:.08em;
  text-transform:uppercase; color:#F6B9CE; margin-bottom:6px }
.torti{ flex:0 0 auto; width:min(230px, 68vw); height:auto; align-self:flex-end;
  margin-bottom:-2px }

/* ── лентата с табовете ────────────────────────────────────────── */
.tabove{ position:sticky; top:env(safe-area-inset-top, 0px); z-index:9;
  background:var(--malina) }
.tabove .ramka{ display:flex; gap:8px; padding-block:0; flex-wrap:wrap }
.tab-b{ border:none; background:rgba(255,255,255,.16); color:#FFF0F5;
  padding:12px 16px; border-radius:16px 16px 0 0; font-family:'Fredoka',sans-serif;
  font-size:clamp(15px,4vw,19px); font-weight:600; min-height:52px;
  display:flex; align-items:center; gap:9px; transition:background .15s, color .15s }
.tab-b:hover{ background:rgba(255,255,255,.26); color:#fff }
.tab-b[aria-selected="true"]{ background:var(--hartiq); color:var(--mastilo) }
.tab-b .znak{ font-family:'Fredoka',sans-serif; font-size:20px; color:#FFD9E6 }
.tab-b[aria-selected="true"] .znak{ color:var(--malina) }
.tab-b .broi{ font-family:'Nunito',sans-serif; font-size:13px; font-weight:800;
  opacity:.9 }

/* ── идеята на таба ────────────────────────────────────────────── */
.ideq{ background:var(--karta); border:1px solid var(--ramka); border-radius:20px;
  padding:18px clamp(14px,3.4vw,22px); margin:20px 0 6px;
  box-shadow:0 10px 28px hsl(var(--senka) / .08) }
.ideq h2{ font-size:clamp(20px,5.2vw,25px); margin-bottom:8px }
.ideq p{ margin:0; color:var(--mastilo-blqdo); font-size:clamp(16px,4.2vw,18px) }
.pravila{ display:flex; flex-wrap:wrap; gap:9px; margin-top:14px; padding:0;
  list-style:none }
.pravila li{ background:var(--karamel-meko); border:1.5px dashed var(--karamel);
  color:var(--karamel); border-radius:999px; padding:9px 16px; font-weight:800;
  font-size:clamp(15.5px,4.1vw,19px) }

/* ── ниво ──────────────────────────────────────────────────────── */
.nivo{ margin-top:26px }
.nivo__red{ display:flex; align-items:baseline; gap:12px; flex-wrap:wrap;
  margin-bottom:4px }
.nivo__ime{ font-family:'Fredoka',sans-serif; font-size:clamp(20px,5.2vw,26px) }
.znachka{ font-size:13px; font-weight:800; letter-spacing:.06em;
  text-transform:uppercase; border-radius:999px; padding:5px 12px;
  background:var(--zeleno-meko); color:var(--zeleno) }
.znachka--2{ background:var(--karamel-meko); color:var(--karamel) }
.znachka--3{ background:var(--malina-meko); color:var(--malina) }
.nivo__opis{ margin:0 0 12px; color:var(--mastilo-blqdo);
  font-size:clamp(15.5px,4vw,17px) }

/* ── задача ────────────────────────────────────────────────────── */
.zadachi{ display:grid; gap:12px }
.zad{ position:relative; background:var(--karta); border:1px solid var(--ramka);
  border-radius:18px; padding:14px 64px 14px clamp(14px,3.4vw,18px);
  transition:background .15s, border-color .15s }
.zad.reshena{ background:var(--zeleno-meko); border-color:var(--zeleno) }
.zad__n{ font-size:13.5px; font-weight:800; letter-spacing:.05em;
  text-transform:uppercase; color:var(--mastilo-blqdo) }
.izraz{ font-size:clamp(25px,6.6vw,34px); font-weight:700; line-height:1.5;
  margin:10px 0 0; letter-spacing:.01em; overflow-wrap:break-word }
.frac{ display:inline-flex; flex-direction:column; align-items:center;
  vertical-align:middle; text-align:center; margin:0 .2em }
.frac .chis{ padding:0 .3em .06em; border-bottom:.075em solid currentColor }
.frac .znam{ padding:.06em .3em 0 }
.frac.smes{ margin-left:.14em }
.pokaji{ margin-top:12px; border:2px solid var(--malina); background:var(--malina-meko);
  color:var(--malina); border-radius:999px; padding:11px 20px; font-weight:800;
  font-size:16px; min-height:46px }
.pokaji:hover{ filter:brightness(1.04) }
.reshenie{ margin-top:12px; background:var(--hartiq); border:1px solid var(--ramka);
  border-radius:14px; padding:14px 16px }
.reshenie .otg{ font-family:'Fredoka',sans-serif; font-size:clamp(21px,5.4vw,27px);
  color:var(--zeleno); line-height:1.4 }
.reshenie .otg .frac{ font-family:'Nunito',sans-serif }
.reshenie .stupki{ margin:8px 0 0; color:var(--mastilo-blqdo);
  font-size:clamp(16px,4.2vw,18px) }
.otmetka{ position:absolute; top:12px; right:12px; width:46px; height:46px;
  border-radius:50%; border:2px solid var(--ramka); background:var(--karta);
  color:var(--ramka); display:grid; place-items:center; font-size:22px;
  font-weight:800; line-height:1; transition:.15s }
.otmetka:hover{ border-color:var(--malina); color:var(--malina) }
.otmetka[aria-pressed="true"]{ border-color:var(--zeleno);
  background:var(--zeleno-meko); color:var(--zeleno) }

/* ── долната лента ─────────────────────────────────────────────── */
.dolu{ position:fixed; left:0; right:0; bottom:0; z-index:8;
  background:color-mix(in srgb, var(--hartiq) 92%, transparent);
  backdrop-filter:blur(10px); border-top:1px solid var(--ramka);
  padding-bottom:env(safe-area-inset-bottom, 0px) }
.dolu .ramka{ display:flex; align-items:center; gap:12px; padding-block:10px }
.lenta{ flex:1; min-width:80px; height:10px; border-radius:999px;
  background:var(--ramka); overflow:hidden }
.lenta i{ display:block; height:100%; width:0; border-radius:999px;
  background:linear-gradient(90deg, var(--malina), var(--zeleno));
  transition:width .35s }
.broiach{ font-weight:800; font-size:15.5px; white-space:nowrap;
  font-variant-numeric:tabular-nums }
.izchisti{ border:1.5px solid var(--ramka); background:transparent;
  color:var(--mastilo-blqdo); border-radius:999px; padding:8px 14px;
  font-size:14px; font-weight:700; min-height:40px }
.izchisti:hover{ border-color:var(--malina); color:var(--malina) }

.kraj{ margin:22px 0 0; padding:22px; border-radius:20px; text-align:center;
  background:var(--zeleno-meko); border:2px solid var(--zeleno) }
.kraj h2{ font-size:clamp(22px,5.6vw,28px); color:var(--zeleno); margin-bottom:6px }
.kraj p{ margin:0 auto; max-width:48ch; color:var(--mastilo) }

:focus-visible{ outline:3px solid var(--malina); outline-offset:2px }
@media (prefers-reduced-motion: reduce){ *{ transition:none !important } }
.sled{ height:96px }
</style>

<header class="shapka">
  <div class="ramka">
    <div class="shapka__text">
      <div class="nadpis">Математика · 5. клас</div>
      <h1>Дроби в сладкарницата</h1>
      <p>Два таба и шест нива — от най-лесното към най-трудното.
        Всяка задача си носи решението: натискаш бутона и то се отваря.</p>
    </div>
    <svg class="torti" viewBox="0 0 220 78" aria-hidden="true">
      __TORTI__
    </svg>
  </div>
</header>

<nav class="tabove" aria-label="Теми">
  <div class="ramka" id="tabove" role="tablist"></div>
</nav>

<main class="ramka" id="sudurjanie"></main>
<div class="ramka sled"></div>

<div class="dolu">
  <div class="ramka">
    <span class="broiach" id="imeTab"></span>
    <span class="lenta"><i id="lenta"></i></span>
    <span class="broiach" id="broiach">0 / 30</span>
    <button class="izchisti" id="izchisti" type="button">Изчисти</button>
  </div>
</div>

<script>
__DANNI__
</script>
<script>
"use strict";
/* Урокът се води на дъската: никъде не се въвежда отговор. Всяка задача
   има бутон „Покажи решението“ и кръгче за отметка „решено“. Отметките
   се помнят в този браузър, за да не се губи докъде е стигнал часът. */
var $ = function(s, p){ return (p || document).querySelector(s); };
var $$ = function(s, p){
  return Array.prototype.slice.call((p || document).querySelectorAll(s));
};
function ek(t){
  return String(t).replace(/[&<>"]/g, function(c){
    return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'})[c];
  });
}

var KLYUCH = 'tla-urok-5-drobi';
var S = {};
try { S = JSON.parse(localStorage.getItem(KLYUCH) || '{}') || {}; } catch(e){ S = {}; }
function zapazi(){
  try { localStorage.setItem(KLYUCH, JSON.stringify(S)); } catch(e){}
}

var sega = 0;
function zadachiNa(tab){
  return tab.niva.reduce(function(a, n){ return a.concat(n.zadachi); }, []);
}
function resheni(tab){
  return zadachiNa(tab).filter(function(z){ return S[z.id]; }).length;
}
var VSICHKI = DANNI.tabove.reduce(function(a, t){
  return a + zadachiNa(t).length; }, 0);

function risuvaiTabove(){
  $('#tabove').innerHTML = DANNI.tabove.map(function(t, i){
    return '<button class="tab-b" type="button" role="tab" data-t="' + i + '" '
      + 'aria-selected="' + (i === sega) + '">'
      + '<span class="znak">' + ek(t.znak) + '</span>'
      + '<span>' + ek(t.kratko) + '</span>'
      + '<span class="broi">' + resheni(t) + '/' + zadachiNa(t).length + '</span>'
      + '</button>';
  }).join('');
  $$('#tabove .tab-b').forEach(function(b){
    b.addEventListener('click', function(){
      sega = +b.dataset.t;
      risuvai();
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  });
}

function risuvaiTqlo(){
  var t = DANNI.tabove[sega];
  $('#sudurjanie').innerHTML =
    '<section class="ideq">'
    + '<h2>' + ek(t.ime) + '</h2>'
    + '<p>' + ek(t.ideya) + '</p>'
    + '<ul class="pravila">' + t.pravila.map(function(p){
        return '<li>' + ek(p) + '</li>'; }).join('') + '</ul>'
    + '</section>'
    + t.niva.map(function(n, ni){
        var gotovi = n.zadachi.filter(function(z){ return S[z.id]; }).length;
        return '<section class="nivo">'
          + '<div class="nivo__red">'
          +   '<h3 class="nivo__ime">' + ek(n.ime) + '</h3>'
          +   '<span class="znachka znachka--' + (ni + 1) + '">ниво ' + (ni + 1)
          +     ' · ' + gotovi + ' от ' + n.zadachi.length + '</span>'
          + '</div>'
          + '<p class="nivo__opis">' + ek(n.opis) + '</p>'
          + '<div class="zadachi">' + n.zadachi.map(function(z, zi){
              return '<article class="zad' + (S[z.id] ? ' reshena' : '') + '" '
                +   'id="z-' + z.id + '">'
                + '<div class="zad__n">Задача ' + (zi + 1) + '</div>'
                + '<p class="izraz">' + z.ekran + ' =</p>'
                + '<button class="pokaji" type="button" data-p="' + z.id + '" '
                +   'aria-expanded="false" aria-controls="r-' + z.id + '">'
                +   'Покажи решението</button>'
                + '<div class="reshenie" id="r-' + z.id + '" hidden>'
                +   '<div class="otg">' + z.otgovor_ekran + '</div>'
                +   '<p class="stupki">' + ek(z.reshenie) + '</p>'
                + '</div>'
                + '<button class="otmetka" type="button" data-o="' + z.id + '" '
                +   'aria-pressed="' + (S[z.id] ? 'true' : 'false') + '" '
                +   'title="Отметни като решена" aria-label="Отметни като решена">'
                +   '✓</button>'
                + '</article>';
            }).join('') + '</div>'
          + '</section>';
      }).join('')
    + (DANNI.tabove.reduce(function(a, x){ return a + resheni(x); }, 0) === VSICHKI
       ? '<div class="kraj"><h2>Сладкарницата е изядена!</h2>'
         + '<p>И двата таба са минати — дробите се събират под общ знаменател, '
         + 'умножават се направо и се делят с обръщане.</p></div>'
       : '');

  $$('.pokaji').forEach(function(b){
    b.addEventListener('click', function(){ pokaji(b); });
  });
  $$('.otmetka').forEach(function(b){
    b.addEventListener('click', function(){ otmetni(b.dataset.o); });
  });
}

function pokaji(b){
  var kutiq = $('#r-' + b.dataset.p);
  if(!kutiq) return;
  var otvoreno = !kutiq.hidden;
  kutiq.hidden = otvoreno;
  b.setAttribute('aria-expanded', String(!otvoreno));
  b.textContent = otvoreno ? 'Покажи решението' : 'Скрий решението';
}

function otmetni(id){
  if(S[id]) delete S[id]; else S[id] = 1;
  zapazi();
  risuvaiTabove();
  risuvaiTqlo();
  osveji();
}

function osveji(){
  var t = DANNI.tabove[sega];
  var vsi = DANNI.tabove.reduce(function(a, x){ return a + resheni(x); }, 0);
  $('#lenta').style.width = Math.round(100 * vsi / VSICHKI) + '%';
  $('#broiach').textContent = vsi + ' / ' + VSICHKI;
  $('#imeTab').textContent = t.kratko;
}

function risuvai(){ risuvaiTabove(); risuvaiTqlo(); osveji(); }

$('#izchisti').addEventListener('click', function(){
  S = {}; zapazi(); risuvai();
});

risuvai();
</script>
"""


def otgovor_ekran(otg: str) -> str:
    """Отговорът „1 5/12“ → същата дроб, изчертана на два реда."""
    import re
    m = re.fullmatch(r'(\d+)\s+(\d+)/(\d+)', otg.strip())
    if m:
        return izobrazi('mx(%s,%s,%s)' % m.groups(), True)
    m = re.fullmatch(r'(\d+)/(\d+)', otg.strip())
    if m:
        return izobrazi('%s/%s' % m.groups(), True)
    return otg


def danni():
    tabove = []
    for t in TABOVE:
        tabove.append({
            'kod': t['kod'], 'ime': t['ime'], 'kratko': t['kratko'],
            'znak': t['znak'], 'ideya': t['ideya'], 'pravila': t['pravila'],
            'niva': [
                {'ime': n['ime'], 'opis': n['opis'], 'zadachi': [
                    {'id': z['id'], 'ekran': izobrazi(z['mat'], True),
                     'otgovor': z['otgovor'],
                     'otgovor_ekran': otgovor_ekran(z['otgovor']),
                     'reshenie': z['reshenie']}
                    for z in n['zadachi']]}
                for n in t['niva']
            ],
        })
    return {'tabove': tabove}


def main() -> None:
    d = danni()
    blok = 'var DANNI = ' + json.dumps(d, ensure_ascii=False, indent=1) + ';'
    stranica = (STRANICA.replace('__TORTI__', tortichki(), 1)
                        .replace('__DANNI__', blok, 1))
    IZHOD.parent.mkdir(parents=True, exist_ok=True)
    IZHOD.write_text(stranica, encoding='utf-8')
    broi = sum(len(n['zadachi']) for t in d['tabove'] for n in t['niva'])
    print('%s · табове: %d · задачи: %d · %.1f KB' % (
        IZHOD.name, len(d['tabove']), broi,
        len(stranica.encode('utf-8')) / 1024))


if __name__ == '__main__':
    main()
