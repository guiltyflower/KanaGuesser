#!/usr/bin/env python3
"""
Convert KanjiVG SVG files into a compact JSON template bundle consumed by
the iOS app at runtime (`KanaTemplateBundle.loadBundled()`).

For each base hiragana/katakana this script:
  1. Locates the SVG in the KanjiVG `kanji/` folder by codepoint filename.
  2. Extracts each <path> in document order (= canonical stroke order).
  3. Samples N_POINTS equidistant points along each path's arc length.
  4. Normalizes all strokes of the character into [0,1]x[0,1] preserving aspect ratio.
  5. Emits one JSON entry.

Output file is consumed by KanaTemplate.swift — keep the JSON shape in sync.

Usage:
    pip install svgpathtools
    python3 kanjivg_to_templates.py path/to/kanjivg/kanji ../KanaGuesser/kana_templates.json

Licence:
    KanjiVG is CC BY-SA 3.0. The generated JSON is a derivative work and must be
    distributed under the same (or compatible) license with proper attribution.
    See the in-app "Info" screen for the user-facing credit.
"""

from __future__ import annotations

import json
import os
import sys
import xml.etree.ElementTree as ET

try:
    from svgpathtools import parse_path
except ImportError:
    sys.exit("Missing dependency: pip install svgpathtools")


# -- Kana list (mirrors KanaGuesser/Kana.swift) --------------------------------

HIRAGANA = [
    ("あ","a"),("い","i"),("う","u"),("え","e"),("お","o"),
    ("か","ka"),("き","ki"),("く","ku"),("け","ke"),("こ","ko"),
    ("さ","sa"),("し","shi"),("す","su"),("せ","se"),("そ","so"),
    ("た","ta"),("ち","chi"),("つ","tsu"),("て","te"),("と","to"),
    ("な","na"),("に","ni"),("ぬ","nu"),("ね","ne"),("の","no"),
    ("は","ha"),("ひ","hi"),("ふ","fu"),("へ","he"),("ほ","ho"),
    ("ま","ma"),("み","mi"),("む","mu"),("め","me"),("も","mo"),
    ("や","ya"),("ゆ","yu"),("よ","yo"),
    ("ら","ra"),("り","ri"),("る","ru"),("れ","re"),("ろ","ro"),
    ("わ","wa"),("を","wo"),("ん","n"),
]
KATAKANA = [
    ("ア","a"),("イ","i"),("ウ","u"),("エ","e"),("オ","o"),
    ("カ","ka"),("キ","ki"),("ク","ku"),("ケ","ke"),("コ","ko"),
    ("サ","sa"),("シ","shi"),("ス","su"),("セ","se"),("ソ","so"),
    ("タ","ta"),("チ","chi"),("ツ","tsu"),("テ","te"),("ト","to"),
    ("ナ","na"),("ニ","ni"),("ヌ","nu"),("ネ","ne"),("ノ","no"),
    ("ハ","ha"),("ヒ","hi"),("フ","fu"),("ヘ","he"),("ホ","ho"),
    ("マ","ma"),("ミ","mi"),("ム","mu"),("メ","me"),("モ","mo"),
    ("ヤ","ya"),("ユ","yu"),("ヨ","yo"),
    ("ラ","ra"),("リ","ri"),("ル","ru"),("レ","re"),("ロ","ro"),
    ("ワ","wa"),("ヲ","wo"),("ン","n"),
]

N_POINTS = 32  # per stroke


# -- Extraction ---------------------------------------------------------------

def svg_filename(ch: str) -> str:
    """KanjiVG files are named `<lowercase-hex-codepoint>.svg` (5-digit padded)."""
    return f"{ord(ch):05x}.svg"


def extract_path_ds(svg_path: str) -> list[str]:
    """Return each `<path d="...">` in document order.

    KanjiVG nests strokes under `<g id="kvg:StrokePaths_..."><g id="kvg:<cp>"> ...`.
    We don't need to descend explicitly: the document-order iteration over <path>
    yields the strokes in the canonical order.
    """
    tree = ET.parse(svg_path)
    root = tree.getroot()
    ds: list[str] = []
    for p in root.iter("{http://www.w3.org/2000/svg}path"):
        d = p.get("d")
        if d:
            ds.append(d)
    return ds


def sample_path(d: str, n: int) -> list[tuple[float, float]]:
    """Sample `n` equidistant points along the path's arc length."""
    path = parse_path(d)
    total = path.length(error=1e-3)
    if total == 0:
        p = path.point(0)
        return [(p.real, p.imag)] * n
    out = []
    for i in range(n):
        s = i / (n - 1) * total
        # ilength: invert arc-length → parametric t in [0,1]
        t = path.ilength(s, s_tol=1e-3)
        p = path.point(t)
        out.append((p.real, p.imag))
    return out


# -- Normalization ------------------------------------------------------------

def normalize(strokes: list[list[tuple[float, float]]]) -> list[list[tuple[float, float]]]:
    """Fit all strokes into [0,1]x[0,1] preserving aspect ratio, centered.
    Relative positions between strokes are preserved (important for e.g. い, に)."""
    flat = [pt for s in strokes for pt in s]
    xs = [p[0] for p in flat]
    ys = [p[1] for p in flat]
    mn_x, mx_x = min(xs), max(xs)
    mn_y, mx_y = min(ys), max(ys)
    w = max(mx_x - mn_x, 1e-9)
    h = max(mx_y - mn_y, 1e-9)
    scale = max(w, h)
    off_x = (scale - w) / 2
    off_y = (scale - h) / 2
    return [
        [((p[0] - mn_x + off_x) / scale,
          (p[1] - mn_y + off_y) / scale) for p in s]
        for s in strokes
    ]


# -- Build & write ------------------------------------------------------------

def build_template(ch: str, romaji: str, svg_dir: str) -> dict | None:
    svg_file = os.path.join(svg_dir, svg_filename(ch))
    if not os.path.exists(svg_file):
        print(f"[warn] missing {svg_file}, skipping '{ch}'", file=sys.stderr)
        return None
    ds = extract_path_ds(svg_file)
    if not ds:
        print(f"[warn] no <path> in {svg_file}, skipping '{ch}'", file=sys.stderr)
        return None
    sampled = [sample_path(d, N_POINTS) for d in ds]
    normed = normalize(sampled)
    return {
        "character": ch,
        "romaji": romaji,
        "strokes": [
            {"points": [[round(x, 4), round(y, 4)] for x, y in s]}
            for s in normed
        ],
    }


def main(svg_dir: str, out_path: str) -> None:
    out = []
    for ch, r in HIRAGANA + KATAKANA:
        tpl = build_template(ch, r, svg_dir)
        if tpl:
            out.append(tpl)
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump({"templates": out}, f, ensure_ascii=False, separators=(",", ":"))
    print(f"Wrote {len(out)} templates to {out_path}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit("Usage: python3 kanjivg_to_templates.py <svg_dir> <out.json>")
    main(sys.argv[1], sys.argv[2])
