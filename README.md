# KanaGuesser

App iOS per allenarsi a scrivere gli alfabeti giapponesi **hiragana** e **katakana**.

Ti viene mostrato il romaji (es. `"ka"`), tu disegni il kana corrispondente sulla canvas, poi riveli la risposta e valuti tu stesso se era giusta o sbagliata.

## Modalità

### 📖 Impara
Modalità singolo giocatore.
- Round da 10 kana estratti casualmente dagli alfabeti selezionati.
- Alla fine, se hai sbagliato qualcosa, viene proposto un **ripasso** con solo i kana sbagliati (una volta).
- Schermata risultati con punteggio principale e statistiche del ripasso.

### 👥 Sfida
Modalità due giocatori, a turni sullo stesso dispositivo.
- Giocatore 1 gioca i suoi 10 kana.
- Tocca poi al Giocatore 2, con 10 kana **diversi** (estratti a nuovo per equità sul caso).
- Risultati finali con punteggi affiancati e vincitore.

## Come si gioca

1. Dalla home scegli uno o entrambi gli alfabeti (Hiragana / Katakana).
2. Scegli **Impara** o **Sfida**.
3. Leggi il romaji, disegna il kana sulla canvas (dito o Apple Pencil).
4. Premi `Mostra risposta`, confronta, poi `Giusto` / `Sbagliato`.
5. Il pulsante `X` in alto a sinistra permette di uscire in qualsiasi momento.

## Struttura del codice

```
KanaGuesser/
├── KanaGuesserApp.swift   # entry point
├── ContentView.swift      # root + menu
├── LearnView.swift        # modalità Impara + ripasso + risultati
├── MultiplayerView.swift  # modalità Sfida + ready screen + risultati
├── GameRound.swift        # round di gioco riutilizzabile
├── DrawingCanvas.swift    # PencilKit wrapper
└── Kana.swift             # modello e database dei kana
```

## Requisiti

- Xcode 26+
- iOS 26+
- Swift 5

## Build

Apri `KanaGuesser.xcodeproj` in Xcode e premi Run, oppure da terminale:

```sh
xcodebuild -project KanaGuesser.xcodeproj -scheme KanaGuesser \
  -destination 'generic/platform=iOS Simulator' -configuration Debug build
```

## TODO

- [ ] Sfida online 1v1
