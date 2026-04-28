# TODO

- [ ] Sfida online 1v1 sull'indovinarli
- [ ] Validazione automatica della scrittura (forma + ordine + direzione dei tratti)
- [ ] **Licenza KanjiVG (CC BY-SA 3.0)** — prima di rilasciare l'app, aggiungere una schermata "Info / Licenze" con l'attribuzione. Testo suggerito: _"Stroke template data derived from KanjiVG by Ulrich Apel et al. — https://kanjivg.tagaini.net/ — licensed under CC BY-SA 3.0. The derived `kana_templates.json` must be distributed under the same license."_
- [ ] **Se cambi il nome dell'app**, aggiornarlo ovunque: wordmark `Text("KanaGuesser")` in `ContentView.swift` (MenuView), wordmark nel `LaunchScreen.storyboard`, `PRODUCT_BUNDLE_IDENTIFIER` e display name (`INFOPLIST_KEY_CFBundleDisplayName`) in `KanaGuesser.xcodeproj/project.pbxproj`, nome del target/cartella/scheme Xcode, README.md, eventuale `MARKETING_VERSION` se rilevante.
- [x] ~~Heatmap nel cheatsheet~~ — implementata come pagina separata `KanaStatsView` apribile da Settings, per non sporcare la cheatsheet di sola consultazione.
