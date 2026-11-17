#!/usr/bin/env python3
"""Сглобява artefakti/urok_6_grad_stepeni.html — урокът „Градът на степените“.

Интерактивен урок по математика за 6. клас в три етапа: умножение на
степени, деление на степени и уравнения с дроби. Всеки етап върви от
лесни към трудни, а всяка задача има бутон „Покажи решението“.

Страницата е направена като АРТЕФАКТ: няма свои <html>, <head> и <body>
— те идват от самия артефакт при качването. Затова файлът започва със
заглавието и стила. Отваря се и направо в браузър: той сам дописва обвивката.

Задачите стоят в scripts/grad6/zadachi.py, изразите се изчертават от
scripts/grad6/izraz.py, а scripts/check_grad6.py ги пресмята наново със
sympy и чете екрана назад.

    /usr/bin/python3.13 scripts/build_grad6.py
"""
import json
import pathlib
import sys

KOREN = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from grad6.zadachi import ETAPI                     # noqa: E402
from grad6.izraz import izobrazi                    # noqa: E402

IZHOD = KOREN / 'artefakti/urok_6_grad_stepeni.html'

STRANICA = r"""<title>Градът на степените</title>
<meta name="claude:viewport-fit-sides" content="cover" />
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Fredoka:wght@500;600;700&family=Nunito:wght@400;600;700;800&display=swap" />
<style>
/* Разположение: една колона — шапка със силует на града, лента с трите
   етапа, после етажите на етапа един под друг. Всяка задача е картичка
   с едър израз и бутон, който отваря решението под него. */
:root{
  --mastilo:#15233D;        /* основен текст */
  --mastilo-blqdo:#56678C;  /* второстепенен текст */
  --hartiq:#FFFCF5;         /* фон на страницата */
  --karta:#FFFFFF;          /* фон на картичките */
  --ramka:#EADFC9;          /* тънките линии */
  --zlato:#E8921B;          /* акцентът — уличните лампи */
  --zlato-meko:#FDF0D7;
  --nebe:#1B3358;           /* нощното небе в шапката */
  --silueti:#0A1322;        /* сградите пред небето */
  --zeleno:#15663D;         /* решено */
  --zeleno-meko:#E2F2E9;
  --lila:#7C3FB4;           /* трудното ниво */
  --lila-meko:#F2E9FB;
  --senka:214 38% 22%;
}
@media (prefers-color-scheme: dark){
  :root:not([data-theme="light"]){
    --mastilo:#E8EFFA; --mastilo-blqdo:#9FB2D0;
    --hartiq:#0D1726; --karta:#16233A; --ramka:#2A3A58;
    --zlato:#F7B23F; --zlato-meko:#3A2C12;
    --nebe:#0A1322; --silueti:#243C64;
    --zeleno:#7BD7A6; --zeleno-meko:#13301F;
    --lila:#C79BEE; --lila-meko:#2A1C3C;
    --senka:214 60% 4%;
    color-scheme: dark;
  }
}
:root[data-theme="dark"]{
  --mastilo:#E8EFFA; --mastilo-blqdo:#9FB2D0;
  --hartiq:#0D1726; --karta:#16233A; --ramka:#2A3A58;
  --zlato:#F7B23F; --zlato-meko:#3A2C12;
  --nebe:#0A1322; --silueti:#243C64;
  --zeleno:#7BD7A6; --zeleno-meko:#13301F;
  --lila:#C79BEE; --lila-meko:#2A1C3C;
  --senka:214 60% 4%;
  color-scheme: dark;
}
*,*::before,*::after{ box-sizing:border-box }
body{
  margin:0; background:var(--hartiq); color:var(--mastilo);
  font-family:'Nunito',system-ui,-apple-system,sans-serif;
  font-size:18px; line-height:1.55; -webkit-text-size-adjust:100%;
  overflow-x:hidden;
}
/* лентата над залепената навигация, за да не прозира съдържание */
body::before{
  content:""; position:fixed; inset:0 0 auto; height:env(safe-area-inset-top, 0px);
  z-index:10; background:var(--nebe);
}
h1,h2,h3{ font-family:'Fredoka',system-ui,sans-serif; margin:0; text-wrap:balance }
button{ font:inherit; cursor:pointer }
i{ font-style:italic }
[hidden]{ display:none !important }

.ramka{
  max-width:860px; margin:0 auto;
  padding-left:max(16px, env(safe-area-inset-left, 0px));
  padding-right:max(16px, env(safe-area-inset-right, 0px));
}

/* ── шапка ─────────────────────────────────────────────────────── */
.shapka{ background:var(--nebe); color:#F4F8FF; position:relative; overflow:hidden }
.shapka .ramka{ padding-block:22px 0; position:relative; z-index:2 }
.shapka h1{ font-size:clamp(28px,7.4vw,44px); line-height:1.05; margin-bottom:8px }
.shapka h1 em{ color:var(--zlato); font-style:normal }
.shapka p{ margin:0 0 16px; color:#B9CCEA; font-size:clamp(16px,4.2vw,18px); max-width:54ch }
.nadpis{ font-size:14px; font-weight:800; letter-spacing:.08em; text-transform:uppercase;
  color:#89A6D0 }
.silueti{ display:block; width:100%; height:auto; margin-top:4px }

/* ── лентата с етапите ─────────────────────────────────────────── */
.etapi{ position:sticky; top:env(safe-area-inset-top, 0px); z-index:9;
  background:var(--nebe); }
.etapi .ramka{ display:flex; gap:8px; padding-block:0; flex-wrap:wrap }
.etap-b{ border:none; background:rgba(255,255,255,.1); color:#CFE0F7;
  padding:12px 16px; border-radius:16px 16px 0 0; font-family:'Fredoka',sans-serif;
  font-size:clamp(15px,4.1vw,19px); font-weight:600; min-height:52px;
  display:flex; align-items:center; gap:9px; transition:background .15s, color .15s }
.etap-b:hover{ background:rgba(255,255,255,.18); color:#fff }
.etap-b[aria-selected="true"]{ background:var(--hartiq); color:var(--mastilo) }
.etap-b .znak{ font-family:'Fredoka',sans-serif; font-size:19px; color:var(--zlato) }
.etap-b[aria-selected="true"] .znak{ color:var(--zlato) }
.etap-b .broi{ font-family:'Nunito',sans-serif; font-size:13px; font-weight:800; opacity:.85 }

/* ── идеята на етапа ───────────────────────────────────────────── */
.ideq{ background:var(--karta); border:1px solid var(--ramka); border-radius:20px;
  padding:18px clamp(14px,3.4vw,22px); margin:20px 0 6px;
  box-shadow:0 10px 28px hsl(var(--senka) / .07) }
.ideq h2{ font-size:clamp(20px,5.2vw,25px); margin-bottom:8px }
.ideq p{ margin:0; color:var(--mastilo-blqdo); font-size:clamp(16px,4.2vw,18px) }
.pravila{ display:flex; flex-wrap:wrap; gap:9px; margin-top:14px; padding:0; list-style:none }
.pravila li{ background:var(--zlato-meko); border:1.5px dashed var(--zlato);
  color:var(--zlato); border-radius:999px; padding:9px 16px; font-weight:800;
  font-size:clamp(16px,4.3vw,20px); letter-spacing:.01em }

/* ── етаж (ниво) ───────────────────────────────────────────────── */
.etaj{ margin-top:26px }
.etaj__red{ display:flex; align-items:baseline; gap:12px; flex-wrap:wrap; margin-bottom:4px }
.etaj__ime{ font-family:'Fredoka',sans-serif; font-size:clamp(20px,5.2vw,26px) }
.znachka{ font-size:13px; font-weight:800; letter-spacing:.06em; text-transform:uppercase;
  border-radius:999px; padding:5px 12px; background:var(--zeleno-meko); color:var(--zeleno) }
.znachka--2{ background:var(--zlato-meko); color:var(--zlato) }
.znachka--3{ background:var(--lila-meko); color:var(--lila) }
.etaj__opis{ margin:0 0 12px; color:var(--mastilo-blqdo); font-size:clamp(15.5px,4vw,17px) }

/* ── задача ────────────────────────────────────────────────────── */
.zadachi{ display:grid; gap:12px }
.zad{ position:relative; background:var(--karta); border:1px solid var(--ramka);
  border-radius:18px; padding:14px 64px 14px clamp(14px,3.4vw,18px);
  transition:background .15s, border-color .15s }
.zad.reshena{ background:var(--zeleno-meko); border-color:var(--zeleno) }
.zad__n{ font-size:13.5px; font-weight:800; letter-spacing:.05em; text-transform:uppercase;
  color:var(--mastilo-blqdo) }
.izraz{ font-size:clamp(25px,6.6vw,34px); font-weight:700; line-height:1.5;
  margin:8px 0 0; letter-spacing:.01em; overflow-wrap:break-word }
.izraz sup{ font-size:.58em; vertical-align:super; line-height:0 }
.frac{ display:inline-flex; flex-direction:column; align-items:center;
  vertical-align:middle; text-align:center; margin:0 .2em }
.frac .chis{ padding:0 .3em .06em; border-bottom:.075em solid currentColor }
.frac .znam{ padding:.06em .3em 0 }
.pokaji{ margin-top:12px; border:2px solid var(--zlato); background:var(--zlato-meko);
  color:var(--zlato); border-radius:999px; padding:11px 20px; font-weight:800;
  font-size:16px; min-height:46px }
.pokaji:hover{ filter:brightness(1.04) }
.reshenie{ margin-top:12px; background:var(--hartiq); border:1px solid var(--ramka);
  border-radius:14px; padding:14px 16px }
.reshenie .otg{ font-family:'Fredoka',sans-serif; font-size:clamp(21px,5.4vw,27px);
  color:var(--zeleno); line-height:1.4 }
.reshenie .stupki{ margin:8px 0 0; color:var(--mastilo-blqdo);
  font-size:clamp(16px,4.2vw,18px) }
.otmetka{ position:absolute; top:12px; right:12px; width:46px; height:46px;
  border-radius:50%; border:2px solid var(--ramka); background:var(--karta);
  color:var(--ramka); display:grid; place-items:center; font-size:22px; font-weight:800;
  line-height:1; transition:.15s }
.otmetka:hover{ border-color:var(--zlato); color:var(--zlato) }
.otmetka[aria-pressed="true"]{ border-color:var(--zeleno); background:var(--zeleno-meko);
  color:var(--zeleno) }

/* ── долната лента ─────────────────────────────────────────────── */
.dolu{ position:fixed; left:0; right:0; bottom:0; z-index:8;
  background:color-mix(in srgb, var(--hartiq) 92%, transparent);
  backdrop-filter:blur(10px); border-top:1px solid var(--ramka);
  padding-bottom:env(safe-area-inset-bottom, 0px) }
.dolu .ramka{ display:flex; align-items:center; gap:12px; padding-block:10px }
.lenta{ flex:1; min-width:90px; height:10px; border-radius:999px;
  background:var(--ramka); overflow:hidden }
.lenta i{ display:block; height:100%; width:0; border-radius:999px;
  background:linear-gradient(90deg, var(--zlato), var(--zeleno)); transition:width .35s }
.broiach{ font-weight:800; font-size:15.5px; white-space:nowrap;
  font-variant-numeric:tabular-nums }
.izchisti{ border:1.5px solid var(--ramka); background:transparent;
  color:var(--mastilo-blqdo); border-radius:999px; padding:8px 14px;
  font-size:14px; font-weight:700; min-height:40px }
.izchisti:hover{ border-color:var(--zlato); color:var(--zlato) }

.kraj{ margin:22px 0 0; padding:22px; border-radius:20px; text-align:center;
  background:var(--zeleno-meko); border:2px solid var(--zeleno) }
.kraj h2{ font-size:clamp(22px,5.6vw,28px); color:var(--zeleno); margin-bottom:6px }
.kraj p{ margin:0 auto; max-width:48ch; color:var(--mastilo) }

:focus-visible{ outline:3px solid var(--zlato); outline-offset:2px }
@media (prefers-reduced-motion: reduce){ *{ transition:none !important } }
.sled{ height:96px }
</style>

<header class="shapka">
  <div class="ramka">
    <div class="nadpis">Математика · 6. клас</div>
    <h1>Градът на <em>степените</em></h1>
    <p>Три етапа, по три етажа всеки — от лесните задачи към трудните.
      Всяка задача си носи решението: натискаш бутона и то се отваря.</p>
  </div>
  <svg class="silueti" viewBox="0 0 860 70" preserveAspectRatio="none" aria-hidden="true">
    <g fill="var(--silueti)" opacity=".85">
      <rect x="0" y="34" width="70" height="36" /><rect x="78" y="22" width="52" height="48" />
      <rect x="138" y="40" width="64" height="30" /><rect x="210" y="16" width="46" height="54" />
      <rect x="264" y="38" width="74" height="32" /><rect x="346" y="26" width="48" height="44" />
      <rect x="402" y="44" width="68" height="26" /><rect x="478" y="20" width="44" height="50" />
      <rect x="530" y="36" width="72" height="34" /><rect x="610" y="28" width="50" height="42" />
      <rect x="668" y="46" width="66" height="24" /><rect x="742" y="24" width="48" height="46" />
      <rect x="798" y="38" width="62" height="32" />
    </g>
    <g fill="var(--zlato)" opacity=".95">
      <rect x="92" y="32" width="6" height="7" /><rect x="106" y="32" width="6" height="7" />
      <rect x="92" y="46" width="6" height="7" /><rect x="222" y="28" width="6" height="7" />
      <rect x="236" y="28" width="6" height="7" /><rect x="222" y="44" width="6" height="7" />
      <rect x="360" y="38" width="6" height="7" /><rect x="374" y="38" width="6" height="7" />
      <rect x="490" y="32" width="6" height="7" /><rect x="504" y="32" width="6" height="7" />
      <rect x="490" y="48" width="6" height="7" /><rect x="624" y="40" width="6" height="7" />
      <rect x="638" y="40" width="6" height="7" /><rect x="754" y="36" width="6" height="7" />
      <rect x="768" y="36" width="6" height="7" /><rect x="754" y="50" width="6" height="7" />
    </g>
  </svg>
</header>

<nav class="etapi" aria-label="Етапи">
  <div class="ramka" id="etapi" role="tablist"></div>
</nav>

<main class="ramka" id="sudurjanie"></main>
<div class="ramka sled"></div>

<div class="dolu">
  <div class="ramka">
    <span class="broiach" id="imeEtap"></span>
    <span class="lenta"><i id="lenta"></i></span>
    <span class="broiach" id="broiach">0 / 45</span>
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

var KLYUCH = 'tla-urok-6-grad-stepeni';
var S = {};
try { S = JSON.parse(localStorage.getItem(KLYUCH) || '{}') || {}; } catch(e){ S = {}; }
function zapazi(){
  try { localStorage.setItem(KLYUCH, JSON.stringify(S)); } catch(e){}
}

var sega = 0;
function zadachiNa(etap){
  return etap.niva.reduce(function(a, n){ return a.concat(n.zadachi); }, []);
}
function resheni(etap){
  return zadachiNa(etap).filter(function(z){ return S[z.id]; }).length;
}
var VSICHKI = DANNI.etapi.reduce(function(a, e){ return a + zadachiNa(e).length; }, 0);

function risuvaiEtapi(){
  $('#etapi').innerHTML = DANNI.etapi.map(function(e, i){
    return '<button class="etap-b" type="button" role="tab" data-e="' + i + '" '
      + 'aria-selected="' + (i === sega) + '">'
      + '<span class="znak">' + ek(e.znak) + '</span>'
      + '<span>' + ek(e.kratko) + '</span>'
      + '<span class="broi">' + resheni(e) + '/' + zadachiNa(e).length + '</span>'
      + '</button>';
  }).join('');
  $$('#etapi .etap-b').forEach(function(b){
    b.addEventListener('click', function(){
      sega = +b.dataset.e;
      risuvai();
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  });
}

function risuvaiTqlo(){
  var e = DANNI.etapi[sega];
  $('#sudurjanie').innerHTML =
    '<section class="ideq">'
    + '<h2>' + ek(e.ime) + '</h2>'
    + '<p>' + ek(e.ideya) + '</p>'
    + '<ul class="pravila">' + e.pravila.map(function(p){
        return '<li>' + p + '</li>'; }).join('') + '</ul>'
    + '</section>'
    + e.niva.map(function(n, ni){
        var gotovi = n.zadachi.filter(function(z){ return S[z.id]; }).length;
        return '<section class="etaj">'
          + '<div class="etaj__red">'
          +   '<h3 class="etaj__ime">' + ek(n.ime) + '</h3>'
          +   '<span class="znachka znachka--' + (ni + 1) + '">етаж ' + (ni + 1)
          +     ' · ' + gotovi + ' от ' + n.zadachi.length + '</span>'
          + '</div>'
          + '<p class="etaj__opis">' + ek(n.opis) + '</p>'
          + '<div class="zadachi">' + n.zadachi.map(function(z, zi){
              return '<article class="zad' + (S[z.id] ? ' reshena' : '') + '" '
                +   'id="z-' + z.id + '">'
                + '<div class="zad__n">Задача ' + (zi + 1) + '</div>'
                + '<p class="izraz">' + z.ekran + '</p>'
                + '<button class="pokaji" type="button" data-p="' + z.id + '" '
                +   'aria-expanded="false" aria-controls="r-' + z.id + '">'
                +   'Покажи решението</button>'
                + '<div class="reshenie" id="r-' + z.id + '" hidden>'
                +   '<div class="otg">' + z.otgovor + '</div>'
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
    + (resheni(DANNI.etapi[0]) + resheni(DANNI.etapi[1]) + resheni(DANNI.etapi[2])
        === VSICHKI
       ? '<div class="kraj"><h2>Целият град е минат!</h2>'
         + '<p>И трите етапа са готови — степените се умножават, делят и '
         + 'уравненията с дроби вече не хапят.</p></div>'
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
  risuvaiEtapi();
  risuvaiTqlo();
  osveji();
}

function osveji(){
  var e = DANNI.etapi[sega];
  var vsi = DANNI.etapi.reduce(function(a, x){ return a + resheni(x); }, 0);
  $('#lenta').style.width = Math.round(100 * vsi / VSICHKI) + '%';
  $('#broiach').textContent = vsi + ' / ' + VSICHKI;
  $('#imeEtap').textContent = e.kratko;
}

function risuvai(){ risuvaiEtapi(); risuvaiTqlo(); osveji(); }

$('#izchisti').addEventListener('click', function(){
  S = {}; zapazi(); risuvai();
});

risuvai();
</script>
"""


def danni():
    etapi = []
    for e in ETAPI:
        drobi = (e['kod'] == 'e3')
        etapi.append({
            'kod': e['kod'], 'ime': e['ime'], 'kratko': e['kratko'],
            'znak': e['znak'], 'ideya': e['ideya'], 'pravila': e['pravila'],
            'niva': [
                {'ime': n['ime'], 'opis': n['opis'], 'zadachi': [
                    {'id': z['id'], 'ekran': izobrazi(z['mat'], drobi),
                     'otgovor': z['otgovor'], 'reshenie': z['reshenie']}
                    for z in n['zadachi']]}
                for n in e['niva']
            ],
        })
    return {'etapi': etapi}


def main() -> None:
    d = danni()
    blok = 'var DANNI = ' + json.dumps(d, ensure_ascii=False, indent=1) + ';'
    stranica = STRANICA.replace('__DANNI__', blok, 1)
    IZHOD.parent.mkdir(parents=True, exist_ok=True)
    IZHOD.write_text(stranica, encoding='utf-8')
    broi = sum(len(n['zadachi']) for e in d['etapi'] for n in e['niva'])
    print('%s · етапи: %d · задачи: %d · %.1f KB' % (
        IZHOD.name, len(d['etapi']), broi,
        len(stranica.encode('utf-8')) / 1024))


if __name__ == '__main__':
    main()
