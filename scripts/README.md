# Template preprocessing

Generates `kana_templates.json` (consumed at runtime by `KanaTemplate.loadBundled()`) starting from KanjiVG SVG sources.

## Setup

1. Clone KanjiVG (needs to be done only once):
   ```sh
   git clone https://github.com/KanjiVG/kanjivg.git
   ```
2. Install the Python dependency:
   ```sh
   pip install svgpathtools
   ```

## Run

From this `scripts/` directory:

```sh
python3 kanjivg_to_templates.py path/to/kanjivg/kanji ../KanaGuesser/kana_templates.json
```

The generated JSON lands in `KanaGuesser/`. Xcode's file-system-synchronized group picks it up automatically — add it to the app target's "Copy Bundle Resources" phase if needed (should be automatic with synchronized groups).

## Tweaking

- `N_POINTS` (top of the script) controls sampling density per stroke. Must match `ValidationConfig.samplePoints` on the Swift side — currently `32` on both sides. If you change one, change the other (and rebuild).
- Normalization keeps aspect ratio and centers on the longer side. If you ever notice systematic bias between tall vs wide kana, this is the place to revisit.

## License

KanjiVG © Ulrich Apel et al., licensed **CC BY-SA 3.0**. The generated `kana_templates.json` is a derivative work and must be redistributed under the same (or compatible) license, with attribution.

See `TODO.md` for the pending in-app attribution screen.
