// Background — scattered kana in light gray on cream, matching the reference
function KanaBackground() {
  // Pre-computed to match the screenshot feel: varied kana, sizes, rotations
  const kanas = [
    'い','う','カ','キ','ア','ウ','ケ','か','き','く','ス','ソ','そ',
    'さ','し','す','ち','つ','ツ','テ','ト','ネ','ナ','た','な','に',
    'ぬ','ね','の','ハ','ヒ','フ','ヘ','ホ','マ','ミ','ム','メ','モ',
    'は','ひ','ふ','へ','ほ','ま','み','む','め','も','ヤ','ユ','ヨ',
    'や','ゆ','よ','ら','り','る','れ','ろ','ラ','リ','ル','レ','ロ',
    'ワ','ヲ','ン','わ','を','ん','e','お','え','あ',
  ];

  // seeded-ish deterministic layout using a stable hash
  const rng = (() => {
    let s = 1234;
    return () => { s = (s * 9301 + 49297) % 233280; return s / 233280; };
  })();

  const items = [];
  const cols = 7;
  const rows = 12;
  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      const jitterX = (rng() - 0.5) * 10;
      const jitterY = (rng() - 0.5) * 8;
      const size = 36 + rng() * 32;
      const rot = (rng() - 0.5) * 30;
      const ch = kanas[(r * cols + c) % kanas.length];
      const opacity = 0.18 + rng() * 0.22;
      items.push({
        ch,
        left: (c / cols) * 100 + jitterX + '%',
        top: (r / rows) * 100 + jitterY + '%',
        fontSize: size,
        rotate: rot,
        opacity,
      });
    }
  }

  return (
    <div style={{
      position: 'absolute', inset: 0, overflow: 'hidden',
      background: '#F6EFC7', // warm cream matching screenshot
    }}>
      {items.map((it, i) => (
        <div key={i} style={{
          position: 'absolute',
          left: it.left, top: it.top,
          fontSize: it.fontSize,
          transform: `rotate(${it.rotate}deg)`,
          color: '#9A957A',
          opacity: it.opacity,
          fontFamily: '"Hiragino Sans", "Yu Gothic", "Noto Sans JP", sans-serif',
          fontWeight: 500,
          userSelect: 'none',
          pointerEvents: 'none',
          whiteSpace: 'nowrap',
        }}>{it.ch}</div>
      ))}
      {/* soft overlay to calm the pattern */}
      <div style={{
        position:'absolute', inset:0,
        background:'linear-gradient(180deg, rgba(246,239,199,0.25), rgba(246,239,199,0.05) 40%, rgba(246,239,199,0.25))',
        pointerEvents:'none',
      }}/>
    </div>
  );
}

Object.assign(window, { KanaBackground });
