# Handoff: KanaGuesser — iOS App

## Overview
KanaGuesser è un'app iOS per imparare hiragana e katakana. L'utente vede un romaji (es. "ka"), disegna a mano il carattere corrispondente su una canvas, poi rivela la risposta corretta e si auto-valuta. Due modalità:
- **Impara** (singolo): 10 turni + 3 round di ripasso sui caratteri sbagliati
- **Sfida** (2 giocatori): i giocatori si alternano su 10 turni ciascuno; vince chi ne indovina di più

## About the Design Files
I file in questa cartella sono **riferimenti di design creati in HTML/React (Babel standalone)** — prototipi che mostrano l'aspetto e il comportamento previsti, **non** codice di produzione da copiare direttamente. Il compito è **ricreare questi design nell'ambiente dell'app di destinazione** (SwiftUI / UIKit se iOS nativo, oppure React Native) usando i pattern e le librerie già esistenti in quel codebase. Se non esiste ancora un codebase, scegli il framework più adatto (per un'app iOS nativa: **SwiftUI**).

## Fidelity
**High-fidelity**. Colori, tipografia, spaziature, radii, ombre e interazioni sono definitive. Replica pixel-perfect il più possibile, adattando le primitive native del framework scelto.

## Target Platform
- **iOS**, portrait only
- Design frame di riferimento: **402 × 874 px** (iPhone 15/16 logical size)
- Safe area: 59pt top (status bar + Dynamic Island), 34pt bottom (home indicator)

## Design Tokens

### Colors
| Token | Hex | Uso |
|---|---|---|
| `bg.cream` | `#F6EFC7` | Sfondo principale con kana pattern |
| `bg.creamDark` | `#F5EFD8` | Bottom sheet impostazioni |
| `bg.divider` | `#EFEADA` / `#E8E2CC` | Divisori, bordi sottili |
| `text.primary` | `#0F0F0F` | Titoli, valori |
| `text.secondary` | `#6A6458` | Testo normale |
| `text.tertiary` | `#8A8575` | Caption, labels uppercase |
| `text.muted` | `#9A9483` | Testo disattivato |
| `kana.pattern` | `#9A957A` opacity 0.18–0.40 | Caratteri di sfondo |
| `accent.blue` | `#1E7BFF` (primary), `#4F99FF` (light) | Icona "Impara" |
| `accent.blueBg` | `#DCEBFF` | Sfondo icona Impara |
| `accent.orange` | `#FF8A3C`, `#FFA867` | Icona "Sfida", vincitore |
| `accent.orangeBg` | `#FFE6D1` | Sfondo icona Sfida |
| `success` | `#34C15E` / `#34C759` | Corretto, toggle on |
| `success.bg` | `#E7F7EC` / `#BFE5CB` | Card carattere corretto |
| `danger` | `#FF5C5C` | Sbagliato |
| `danger.bg` | `#FFE8E8` / `#F8C7C7` | Card carattere sbagliato |
| `surface.card` | `#FFFFFF` | Card, sheet, pulsanti secondari |
| `surface.pill` | `rgba(255,255,255,0.85)` + blur(8px) | Bottoni circolari su sfondo kana |

### Typography
Font principale: **Inter** (pesi 500/600/700/800/900)
Font giapponese per display caratteri: **"Hiragino Mincho ProN", "Yu Mincho", "Noto Serif JP", serif** (weight 600)
Font giapponese per pattern sfondo: **"Hiragino Sans", "Yu Gothic", "Noto Sans JP"** (weight 500)

Scala:
- **Display title** (KanaGuesser home): 44px / weight 900 / letter-spacing -1.5
- **Hero score** (risultati): 36–42px / 900 / -1 to -1.2
- **Romaji prompt**: 68px / 900 / -2 (Inter)
- **Revealed kana**: 210px / 600 serif
- **Section title**: 22px / 800 / -0.5
- **Card title**: 19px / 700 / -0.3
- **Body**: 16px / 500
- **Caption**: 13–15px / 500–600
- **Label uppercase**: 12–13px / 600 / letter-spacing 0.6, uppercase

### Spacing & Radii
- Card radius: **16–20px**; bottom sheet: **24px top**
- Button radius: **14px** (primario) / **10px** (stepper) / **999px** (pill/toggle)
- Icon chip circle: **46×46** radius 23; small circle button: **32–44** radius half
- Segment (progress): height **6px**, radius **3px**, gap **4px**
- Standard padding: 16px orizzontale (container), 14–22px interno card

### Shadows
- Card soft: `0 2px 10px rgba(40,30,10,0.08)`
- Card lifted: `0 4px 16px rgba(40,30,10,0.08)`
- Bottom sheet: `0 -10px 40px rgba(0,0,0,0.15)`
- Pill glass: `0 2px 8px rgba(0,0,0,0.08)` + `backdrop-filter: blur(8px)`
- Primary button: `0 2px 8px rgba(0,0,0,0.18)`

## Screens

### 1. Home (`home-screen.jsx`)
**Layout** (top-to-bottom, absolutely positioned su full-bleed `KanaBackground`):
- Settings button pill top:66 right:20 (44×44, icona gear #4A4A4A)
- Title block top:230, center: "KanaGuesser" 44/900/-1.5, subtitle "Scegli una modalità" 15px #5A5A50 marginTop:10
- Mode cards top:360, left/right:16, gap 12:
  - **Impara**: icona libro aperto blu (#1E7BFF/#4F99FF) in chip #DCEBFF, titolo "Impara", subtitle "Allenati da solo"
  - **Sfida**: icona 2 persone arancio (#FF8A3C/#FFA867) in chip #FFE6D1, titolo "Sfida", subtitle "2 giocatori a turni"
  - Ogni card: padding 16px 18px, gap 14, chevron destro 10×16 #B8B5A8

**Background pattern**: griglia 7×12 di kana random (mix hiragana/katakana) con `color: #9A957A`, `opacity: 0.18–0.40`, `rotate: -15° to +15°`, `fontSize: 36–68px`. Overlay gradiente verticale leggero per calmare il pattern.

### 2. Settings (bottom sheet — `settings-screen.jsx`)
Sheet `#F5EFD8`, radius 24/24/0/0, slide-up animation 260ms cubic-bezier(0.2,0.9,0.3,1).
- Grabber 40×5 rgba(0,0,0,0.2) centrato
- Header: titolo "Impostazioni" 22/800 + X close 32×32
- Sezioni (label uppercase 12/600 #8A8575):
  - **SILLABARI**: toggle Hiragana, toggle Katakana (almeno uno sempre attivo)
  - **PARTITA**: stepper "Turni per round" (5–20, step 5), stepper "Ripassi caratteri sbagliati" (1–5)
  - **PREFERENZE**: toggle Suoni, toggle Vibrazione
- Toggle iOS style: 51×31, thumb 27×27 bianco, on=#34C759 off=#E3DEC8
- Stepper: container #EFEADA radius 10, bottoni +/− 28×26 bianchi

### 3. Game (`game-screen.jsx`)
**Struttura verticale fissa** su sfondo kana:
- **Top bar** (top:56): X close 36×36 (sinistra) + label centrale (es. "KANAGUESSER" / "RIPASSO 1/3" / "GIOCATORE 1" 13/600 uppercase) + contatore "N / 10" 17/800
- **Progress segments** (top:134): N barrette flex, height 6, radius 3, gap 4. Stati: `correct`→#34C15E, `wrong`→#FF5C5C, current→rgba(0,0,0,0.35), pending→rgba(0,0,0,0.12)
- **Prompt card** (top:162): bianca, radius 20, padding 22 20 26, centrata:
  - Label uppercase "Disegna il carattere"
  - Romaji grande: 68/900/-2
  - Label script ("hiragana" / "katakana") 13 #9A9483 capitalize
- **Bottom area** (bottom:40): stack di 2 stati alternativi:
  - **Disegno**: canvas 340×340 bianca radius 18 con guide tratteggiate (#E8E4D0 4 6) a croce. Sotto, 2 bottoni flex:1 height 52:
    - "Cancella" (secondary #fff con bordo #E8E2CC) — icona cestino, disabled se 0 tratti
    - "Mostra risposta" (primary #0F0F0F testo bianco) — icona occhio, disabled se 0 tratti
  - **Rivelata**: card 340×340 che mostra il kana corretto (Mincho 210/600), chip inferiore con romaji (#F6EFC7 padding 4/12 radius 999). Sotto 2 bottoni:
    - "Sbagliato" (danger #FF5C5C) — icona X
    - "Corretto" (success #34C15E) — icona check

**Drawing canvas behavior**:
- Pennello ink nero `#1a1a1a` width 9–11 (leggera varianza), lineCap/Join `round`
- Al `pointerdown` disegna un pallino di 4.5 raggio (start dot)
- Conta i tratti (stroke count); usato per abilitare i bottoni
- `clearSignal` (counter che incrementa) resetta la canvas

### 4. Results / Pass / Final (`results-screen.jsx`)
**Learn — Round/Recovery summary** (scrollable):
- Header uppercase ("ROUND COMPLETATO" / "RIPASSO N/M" / "ALLENAMENTO COMPLETATO")
- Hero: "X su Y" 36/900 + sottotitolo ("1 da ripassare" / "Perfetto!")
- **ScoreRing**: SVG 140×140, stroke 12, track #EFE8CE, arco success #34C15E, percentuale 36/900 al centro + "X/Y" 12/600
- **Grid caratteri** 5-col: card aspect-1 radius 12 verde (#E7F7EC) o rossa (#FFE8E8), carattere 28 Mincho + romaji 10, mini-badge check/X in alto a destra 14×14
- CTA: primario ("Inizia ripasso" / "Continua ripasso" / "Vedi riepilogo" / "Nuovo round") + secondario "Torna alla home"

**Challenge — Pass screen**: card centrata con "Turno concluso", "Giocatore 1: X/10", box cream con "Passa il dispositivo al Giocatore 2" 22/800 #FF8A3C, CTA "Inizia turno giocatore 2"

**Challenge — Final**: "Vince il Giocatore N" 42/900 (o "Pareggio!"), 2 `PlayerScoreCard` affiancate (bordo arancio 2px + badge "VINCITORE" sul vincitore), CTA "Rivincita" + "Torna alla home"

## Interactions & State

### State (app.jsx)
```
screen: 'home' | 'game' | 'results'
settingsOpen: bool
settings: { hiragana, katakana, rounds, recoveryPasses, sounds, haptics }
mode: 'learn' | 'challenge'
phase: 'normal' | 'recovery' | 'done'
recoveryPass: number (1..N)
challengeTurn: 1 | 2 | 'final'
p1Score, p2Score: number
turns: Kana[]
turnIndex: number
progress: ('pending'|'correct'|'wrong')[]
results: { turn, correct }[]
recoveryState: { items: { char, romaji, script, attempts:bool[], lastCorrect, correctCount }[], learned: string[] }
```

### Game flow — Learn mode
1. Start → estrai `rounds` (10) caratteri random dal pool filtrato da `settings.hiragana/katakana`
2. Per ogni turno: user disegna → "Mostra risposta" → reveal → Corretto/Sbagliato → aggiorna `progress[turnIndex]`, avanza
3. Fine round → Results con ring. Se ci sono sbagliati → bottone "Inizia ripasso"
4. Recovery: ripete i caratteri sbagliati `settings.recoveryPasses` volte (default 3), ordine casuale ogni volta
5. Un carattere è **imparato** se `correctCount ≥ 2 && lastCorrect === true` alla fine del ciclo
6. Dopo l'ultimo pass → schermata "Allenamento completato" con `learnedCount`

### Game flow — Challenge mode
1. P1 gioca 10 turni → PassScreen (score + "Passa il dispositivo")
2. P2 gioca 10 turni → Final (vincitore / pareggio). **Nessun ripasso.**

### Animations
- Bottom sheet: slide-up 260ms cubic-bezier(0.2,0.9,0.3,1), overlay fade-in 180ms
- Progress segments: background transition 250ms
- ScoreRing arc: stroke-dasharray transition 500ms
- Button press: `transform: scale(0.97)` on `:active`

## Assets
- **Nessun asset binario**: tutte le icone sono SVG inline (vedi sorgente); caratteri giapponesi sono glyph da font di sistema
- Font: Inter + Noto Serif JP + Noto Sans JP via Google Fonts
- Per iOS nativo: usare `SF Pro Display` come fallback Inter, e `Hiragino Mincho ProN` / `Hiragino Sans` (già incluse in iOS)

## Kana Database
Vedi `kana-data.jsx`: 46 hiragana + 46 katakana (gojuon base, no dakuten/handakuten/yōon). Ogni entry: `{ romaji, char, script }`.

## Files in this handoff
- `index.html` — entry point + setup React/Babel + montaggio dentro `IOSDevice`
- `ios-frame.jsx` — frame iPhone di anteprima (**solo per demo**, non portare nel target)
- `app.jsx` — orchestratore di stato e flow
- `home-screen.jsx` — Home + ModeCard
- `settings-screen.jsx` — Sheet impostazioni + Toggle + Stepper
- `game-screen.jsx` — Gioco + DrawCanvas wrapper + RevealPanel + ActionButton
- `draw-canvas.jsx` — Canvas drawing primitive
- `results-screen.jsx` — Results + ScoreRing + PassScreen + ChallengeFinal + PlayerScoreCard
- `background.jsx` — Kana pattern background (da riprodurre staticamente o come SwiftUI Canvas/View)
- `kana-data.jsx` — Database romaji↔char per entrambi i sillabari

## Suggerimenti implementativi per SwiftUI
- Usa `PKCanvasView` (PencilKit) per il disegno invece di canvas HTML
- `Color(hex:)` extension per i token
- Ring: `Circle().trim(from:0, to:pct).stroke(...)` con animazione
- Bottom sheet: `.sheet(isPresented:) { }` con `.presentationDetents([.medium])`
- Persistenza settings: `@AppStorage`
- Random character pick: `Array.randomElement()` / `.shuffled().prefix(n)`
