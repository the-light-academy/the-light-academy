#!/usr/bin/env python3
"""Сглобява uroci/urok_6_stepeni_uravneniq.html — урокът за 6. клас.

Две теми в два таба: „Степенуване“ и „Уравнения и цели изрази“.
Задачите стоят в scripts/urok6/, а проверката (scripts/check_urok6.py)
ги пресмята наново със sympy.

Урокът се води на дъската: никъде не се въвежда отговор. Всяка задача
има кръгче за отметка „решено“ и бутон, който показва отговора заедно с
решението — чак след като сте я решили.

    /usr/bin/python3.13 scripts/build_urok6.py
"""
import json
import pathlib
import sys

KOREN = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(KOREN / 'scripts'))

from urok6 import stepeni, uravneniq                      # noqa: E402

SLUG = 'urok-6-stepeni-uravneniq'
IZHOD = KOREN / 'uroci/urok_6_stepeni_uravneniq.html'
TABOVE = [stepeni, uravneniq]

NACHALO = ('/* ДАННИ:НАЧАЛО — пише ги scripts/build_urok6.py; '
           'задачите са в scripts/urok6/ */')
KRAI = '/* ДАННИ:КРАЙ */'

GLAVA = """<!DOCTYPE html>
<html lang="bg">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Степенуване · Уравнения и цели изрази — 6. клас · The Light Academy</title>
<meta name="description" content="Интерактивен урок по математика за 6. клас: степенуване и уравнения с цели изрази. Задачите се решават на дъската, всяка се отмята като решена, а отговорът се показва след това." />
<link rel="icon" href="../favicon.ico" sizes="any" />
<link rel="apple-touch-icon" sizes="180x180" href="../apple-touch-icon.png" />
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
</head>
<body>
<style>
@import url('https://fonts.googleapis.com/css2?family=Fredoka:wght@500;600;700&family=Nunito:wght@400;600;700;800&display=swap');

/* =====================================================================
   УРОК ЗА 6. КЛАС — Степенуване · Уравнения и цели изрази
   ---------------------------------------------------------------------
   Две теми, два таба, един урок. Водят се на дъската: никъде не се
   въвежда отговор. Всяка задача има кръгче за отметка „решено“ и бутон,
   който показва отговора заедно с решението — чак когато поискаш.

   Отметките се помнят в този браузър (localStorage), за да не се губи
   докъде сте стигнали между два часа.

   Задачите стоят в scripts/urok6/ и се вграждат тук от
   scripts/build_urok6.py. Проверяват се от scripts/check_urok6.py,
   който ги пресмята НАНОВО със sympy — условието на екрана и сметката
   зад него са един и същ низ.
   ===================================================================== */
:root{
  --ink:#16233F; --ink-soft:#55658A;
  --paper:#FFFDF7; --paper-raised:#FFFFFF;
  --grid:#EFE3CC;
  --accent:#F7AD19; --accent-ink:#925A08; --accent-soft:#FDF0D5;
  --pencil:#1B2E52; --pencil-soft:#E7ECF6;
  --success:#16603A; --success-soft:#E3F3EA;
  --zvezda:#8E4BC4; --zvezda-soft:#F3E8FB;
  --shadow:222 40% 20%;
}
*,*::before,*::after{box-sizing:border-box}
body{
  margin:0; background:var(--paper); color:var(--ink);
  font-family:'Nunito',system-ui,sans-serif; font-size:17px; line-height:1.55;
  -webkit-text-size-adjust:100%;
}
h1,h2,h3{font-family:'Fredoka',system-ui,sans-serif; margin:0}
button{font:inherit; cursor:pointer}
[hidden]{display:none !important}
.wrap{max-width:900px; margin:0 auto; padding:0 clamp(12px,4vw,24px) 110px}

/* ── шапка ──────────────────────────────────────────────────────── */
.top{background:var(--pencil); color:#fff; padding:18px 0 0}
.top .wrap{padding-bottom:0}
.top__red{display:flex; align-items:center; gap:12px; flex-wrap:wrap}
.top__back{color:#BFD0EE; text-decoration:none; font-weight:700; font-size:14px}
.top__back:hover{color:#fff}
.top h1{font-size:clamp(24px,5vw,34px); margin:10px 0 4px; line-height:1.1}
.top__pod{color:#BFD0EE; font-size:15px; max-width:62ch; margin-bottom:14px}
.tabove{display:flex; gap:8px}
.tab{border:none; background:rgba(255,255,255,.1); color:#DCE6F7;
  padding:11px 20px; border-radius:14px 14px 0 0; font-weight:800; font-size:16px;
  font-family:'Fredoka',sans-serif; transition:.15s}
.tab:hover{background:rgba(255,255,255,.18); color:#fff}
.tab.ima{background:var(--paper); color:var(--ink)}
.tab__n{font-size:12px; opacity:.75; margin-left:7px; font-family:'Nunito',sans-serif}

/* ── напредък ───────────────────────────────────────────────────── */
.napredak{display:flex; align-items:center; gap:12px; margin:18px 0 6px}
.lenta{flex:1; height:10px; border-radius:999px; background:var(--pencil-soft); overflow:hidden}
.lenta i{display:block; height:100%; width:0; border-radius:999px;
  background:linear-gradient(90deg,var(--accent),#7ED3B2); transition:width .4s}
.napredak b{font-size:14px; color:var(--ink-soft); white-space:nowrap}
.nulirai{border:1px solid var(--grid); background:#fff; color:var(--ink-soft);
  border-radius:999px; padding:6px 14px; font-size:13px; font-weight:700}
.nulirai:hover{border-color:var(--accent); color:var(--accent-ink)}

/* ── раздел ─────────────────────────────────────────────────────── */
.razdel{background:var(--paper-raised); border:1px solid var(--grid); border-radius:20px;
  padding:18px clamp(14px,3vw,22px); margin:16px 0;
  box-shadow:0 10px 30px hsl(var(--shadow) / .06)}
.razdel.zvezda{border-color:#DCC4F0; background:linear-gradient(#FDFAFF,#fff)}
.razdel__top{display:flex; align-items:flex-start; gap:12px; flex-wrap:wrap}
.razdel__n{width:40px; height:40px; border-radius:13px; display:grid; place-items:center;
  background:var(--pencil); color:#fff; font-family:'Fredoka',sans-serif;
  font-size:19px; font-weight:700; flex:none}
.razdel.zvezda .razdel__n{background:var(--zvezda)}
.razdel__ime{font-family:'Fredoka',sans-serif; font-size:21px; line-height:1.15}
.razdel__broi{margin-left:auto; font-size:13px; font-weight:800; color:var(--ink-soft);
  background:var(--pencil-soft); border-radius:999px; padding:4px 12px}
.razdel__ideq{margin:12px 0 0; color:var(--ink-soft); font-size:15.5px}
/* Формулите вървят с основния шрифт: моноширинният няма истински горни
   индекси и 2⁵ се разпада на „2 ⁵“, а минусът става тире. */
.pravilo{margin:12px 0 4px; padding:11px 15px; border-radius:14px;
  background:var(--accent-soft); border:1px dashed var(--accent);
  font-size:16px; letter-spacing:.01em;
  color:var(--accent-ink); font-weight:800}
.razdel.zvezda .pravilo{background:var(--zvezda-soft); border-color:#C89AE6; color:#6B2E96}

/* ── задача ─────────────────────────────────────────────────────── */
.zadachi{display:grid; gap:10px; margin-top:14px}
.zad{position:relative; border:1px solid var(--grid); border-radius:16px;
  padding:14px 58px 14px 16px; background:#FBF8F1; transition:.15s}
.zad.reshena{background:var(--success-soft); border-color:#BBE3CC}
.zad__n{font-size:13px; font-weight:800; color:var(--ink-soft)}
.zad__uslovie{font-size:23px; font-weight:800; color:var(--pencil); margin:4px 0 0;
  line-height:1.45; word-break:break-word; letter-spacing:.01em}
.zad__uslovie.dulag{font-size:17px; font-weight:600;
  line-height:1.5; color:var(--ink); letter-spacing:0}
.zad__dolu{display:flex; align-items:center; gap:10px; flex-wrap:wrap; margin-top:10px}
.pokaji{border:1.5px solid var(--pencil-soft); background:#fff; color:var(--pencil);
  border-radius:999px; padding:6px 16px; font-size:13.5px; font-weight:800}
.pokaji:hover{border-color:var(--accent); color:var(--accent-ink)}
.otg{margin-top:10px; padding:12px 15px; border-radius:14px; background:#fff;
  border:1px solid var(--grid)}
.otg__r{font-size:21px; font-weight:800; color:var(--success)}
.otg__k{margin:7px 0 0; font-size:15px; color:var(--ink-soft)}
.otg__k b{color:var(--ink)}

/* кръгчето за отметка */
.otmetka{position:absolute; top:12px; right:12px; width:40px; height:40px;
  border-radius:50%; border:2px solid var(--grid); background:#fff;
  color:#C3CBD9; display:grid; place-items:center; font-size:20px; font-weight:800;
  transition:.15s}
.otmetka:hover{border-color:var(--accent); color:var(--accent-ink)}
.otmetka.ima{border-color:#5FB98A; background:var(--success-soft); color:var(--success)}

/* ── долната лента ──────────────────────────────────────────────── */
.dolu{position:fixed; left:0; right:0; bottom:0; z-index:40; padding:10px 12px;
  background:rgba(255,253,247,.94); backdrop-filter:blur(10px);
  border-top:1px solid var(--grid)}
.dolu__in{max-width:900px; margin:0 auto; display:flex; align-items:center; gap:12px}
.dolu__t{font-weight:800}
.dolu__p{flex:1}

@media (max-width:620px){
  .zad{padding-right:52px}
  .zad__uslovie{font-size:18px}
  .tab{padding:10px 14px; font-size:15px}
  .razdel__broi{margin-left:0}
}
@media print{
  .tabove,.dolu,.otmetka,.pokaji,.nulirai{display:none !important}
  .razdel{break-inside:avoid; box-shadow:none}
  .otg{display:block !important}
}
@media (prefers-reduced-motion:reduce){*{animation:none !important; transition:none !important}}
</style>

<header class="top">
  <div class="wrap">
    <div class="top__red">
      <a class="top__back" href="../portal.html">← към профила</a>
      <span style="color:#56688C">·</span>
      <span style="color:#BFD0EE;font-size:14px;font-weight:700">Математика · 6. клас</span>
    </div>
    <h1>Степенуване &amp; Уравнения</h1>
    <p class="top__pod">Два таба, две теми. Задачите се решават на дъската — тук
      само отмяташ кои са готови и поглеждаш отговора, когато поискаш.</p>
    <div class="tabove" id="tabove"></div>
  </div>
</header>

<div class="wrap">
  <div class="napredak">
    <div class="lenta"><i id="lenta"></i></div>
    <b id="broiach">0 / 0</b>
    <button class="nulirai" id="bNulirai">Изчисти отметките</button>
  </div>
  <div id="sudurjanie"></div>
</div>

<div class="dolu">
  <div class="dolu__in">
    <span class="dolu__t" id="doluTema"></span>
    <span class="dolu__p"></span>
    <span class="dolu__t" id="doluBroi"></span>
  </div>
</div>

<script>
__DANNI__
</script>
<script>
"use strict";
/* =====================================================================
   Двигателят: два таба, отметки и показване на отговора.
   Нищо не се въвежда — урокът се води на дъската.
   ===================================================================== */
const $ = (s, p) => (p || document).querySelector(s);
const $$ = (s, p) => Array.prototype.slice.call((p || document).querySelectorAll(s));
function ek(t){
  return String(t).replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
}

const KLYUCH = 'tla-' + UROK.slug;
let tabSega = 0;
let S = {};
try { S = JSON.parse(localStorage.getItem(KLYUCH) || '{}') || {}; } catch(e) { S = {}; }
function zapazi(){
  try { localStorage.setItem(KLYUCH, JSON.stringify(S)); } catch(e) {}
}

function vsichkiZadachi(t){
  return t.razdeli.reduce((a, r) => a.concat(r.zadachi), []);
}
function reshenivT(t){
  return vsichkiZadachi(t).filter(z => S[z.id]).length;
}

/* ── рисуване ───────────────────────────────────────────────────── */
function risuvaiTabove(){
  $('#tabove').innerHTML = UROK.tabove.map(function(t, i){
    return '<button class="tab' + (i === tabSega ? ' ima' : '') + '" data-t="' + i + '">'
      + ek(t.ime)
      + '<span class="tab__n">' + reshenivT(t) + '/' + vsichkiZadachi(t).length + '</span>'
      + '</button>';
  }).join('');
  $$('#tabove .tab').forEach(function(b){
    b.addEventListener('click', function(){
      tabSega = +b.dataset.t;
      risuvai();
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  });
}

function risuvaiTqlo(){
  const t = UROK.tabove[tabSega];
  $('#sudurjanie').innerHTML = t.razdeli.map(function(r, ri){
    const reshenи = r.zadachi.filter(z => S[z.id]).length;
    return '<section class="razdel' + (r.zvezda ? ' zvezda' : '') + '" id="r-' + r.kod + '">'
      + '<div class="razdel__top">'
      +   '<div class="razdel__n">' + (ri + 1) + '</div>'
      +   '<div><div class="razdel__ime">' + ek(r.ime) + '</div></div>'
      +   '<span class="razdel__broi">' + reshenи + ' / ' + r.zadachi.length + '</span>'
      + '</div>'
      + '<p class="razdel__ideq">' + ek(r.ideya) + '</p>'
      + '<div class="pravilo">' + ek(r.pravilo) + '</div>'
      + '<div class="zadachi">' + r.zadachi.map(function(z, zi){
          const dulag = (z.vid === 'tekst');
          return '<div class="zad' + (S[z.id] ? ' reshena' : '') + '" id="z-' + z.id + '">'
            + '<div class="zad__n">Задача ' + (zi + 1) + '</div>'
            + '<p class="zad__uslovie' + (dulag ? ' dulag' : '') + '">' + ek(z.izraz) + '</p>'
            + '<div class="zad__dolu">'
            +   '<button class="pokaji" data-p="' + z.id + '">Покажи отговора</button>'
            + '</div>'
            + '<div class="otg" id="o-' + z.id + '" hidden></div>'
            + '<button class="otmetka' + (S[z.id] ? ' ima' : '') + '" data-o="' + z.id + '" '
            +   'title="Отметни като решена" aria-label="Отметни като решена">✓</button>'
            + '</div>';
        }).join('') + '</div>'
      + '</section>';
  }).join('');

  $$('.otmetka').forEach(function(b){
    b.addEventListener('click', function(){ otmetni(b.dataset.o); });
  });
  $$('.pokaji').forEach(function(b){
    b.addEventListener('click', function(){ pokaji(b.dataset.p, b); });
  });
}

/* Отметката се вдига и сваля: ако сте я отметнали по погрешка, връща се. */
function otmetni(id){
  if(S[id]) delete S[id]; else S[id] = 1;
  zapazi();
  const zad = $('#z-' + id), b = $('.otmetka[data-o="' + id + '"]');
  if(zad) zad.classList.toggle('reshena', !!S[id]);
  if(b) b.classList.toggle('ima', !!S[id]);
  osveji();
  risuvaiTabove();
  osvejiBroiNaRazdeli();
}

function pokaji(id, but){
  const z = namiri(id);
  const kutiq = $('#o-' + id);
  if(!z || !kutiq) return;
  if(!kutiq.hidden){ kutiq.hidden = true; but.textContent = 'Покажи отговора'; return; }
  kutiq.innerHTML = '<div class="otg__r">' + ek(z.otgovor) + '</div>'
    + '<p class="otg__k"><b>Как се стига дотам:</b> ' + ek(z.reshenie) + '</p>';
  kutiq.hidden = false;
  but.textContent = 'Скрий отговора';
}

function namiri(id){
  for(const t of UROK.tabove)
    for(const r of t.razdeli)
      for(const z of r.zadachi)
        if(z.id === id) return z;
  return null;
}

function osvejiBroiNaRazdeli(){
  const t = UROK.tabove[tabSega];
  t.razdeli.forEach(function(r){
    const el = $('#r-' + r.kod + ' .razdel__broi');
    if(el) el.textContent = r.zadachi.filter(z => S[z.id]).length + ' / ' + r.zadachi.length;
  });
}

function osveji(){
  const t = UROK.tabove[tabSega];
  const vsichki = vsichkiZadachi(t).length, gotovi = reshenivT(t);
  $('#lenta').style.width = (vsichki ? Math.round(100 * gotovi / vsichki) : 0) + '%';
  $('#broiach').textContent = gotovi + ' / ' + vsichki;
  $('#doluTema').textContent = t.ime;
  const obshto = UROK.tabove.reduce((a, x) => a + vsichkiZadachi(x).length, 0);
  const vsi = UROK.tabove.reduce((a, x) => a + reshenivT(x), 0);
  $('#doluBroi').textContent = 'Общо решени: ' + vsi + ' / ' + obshto;
}

function risuvai(){
  risuvaiTabove();
  risuvaiTqlo();
  osveji();
}

$('#bNulirai').addEventListener('click', function(){
  if(!confirm('Да изчистя ли всички отметки за този урок?')) return;
  S = {}; zapazi(); risuvai();
});

risuvai();
</script>
</body>
</html>
"""


def danni():
    tabove = []
    for m in TABOVE:
        tabove.append({
            'kod': m.RAZDELI[0]['kod'][:2],
            'ime': m.IME,
            'podnaslov': m.PODNASLOV,
            'razdeli': [
                {'kod': r['kod'], 'ime': r['ime'], 'ideya': r['ideya'],
                 'pravilo': r['pravilo'], 'zvezda': bool(r.get('zvezda')),
                 'zadachi': [
                     {'id': z['id'], 'vid': z['vid'], 'izraz': z['izraz'],
                      'otgovor': z['otgovor'], 'reshenie': z['reshenie']}
                     for z in r['zadachi']
                 ]}
                for r in m.RAZDELI
            ],
        })
    return {'slug': SLUG, 'tabove': tabove}


def main() -> None:
    blok = 'const UROK = ' + json.dumps(danni(), ensure_ascii=False, indent=1) + ';'
    stranica = GLAVA.replace('__DANNI__', NACHALO + '\n' + blok + '\n' + KRAI, 1)
    IZHOD.write_text(stranica, encoding='utf-8')

    broi = sum(len(r['zadachi']) for t in danni()['tabove'] for r in t['razdeli'])
    print('{} · табове: {} · задачи: {} · {} знака'.format(
        IZHOD.name, len(TABOVE), broi, len(stranica)))


if __name__ == '__main__':
    main()
