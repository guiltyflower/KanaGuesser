// Kana database — romaji + character for each hiragana and katakana
const HIRAGANA = [
  ['a','あ'],['i','い'],['u','う'],['e','え'],['o','お'],
  ['ka','か'],['ki','き'],['ku','く'],['ke','け'],['ko','こ'],
  ['sa','さ'],['shi','し'],['su','す'],['se','せ'],['so','そ'],
  ['ta','た'],['chi','ち'],['tsu','つ'],['te','て'],['to','と'],
  ['na','な'],['ni','に'],['nu','ぬ'],['ne','ね'],['no','の'],
  ['ha','は'],['hi','ひ'],['fu','ふ'],['he','へ'],['ho','ほ'],
  ['ma','ま'],['mi','み'],['mu','む'],['me','め'],['mo','も'],
  ['ya','や'],['yu','ゆ'],['yo','よ'],
  ['ra','ら'],['ri','り'],['ru','る'],['re','れ'],['ro','ろ'],
  ['wa','わ'],['wo','を'],['n','ん'],
];

const KATAKANA = [
  ['a','ア'],['i','イ'],['u','ウ'],['e','エ'],['o','オ'],
  ['ka','カ'],['ki','キ'],['ku','ク'],['ke','ケ'],['ko','コ'],
  ['sa','サ'],['shi','シ'],['su','ス'],['se','セ'],['so','ソ'],
  ['ta','タ'],['chi','チ'],['tsu','ツ'],['te','テ'],['to','ト'],
  ['na','ナ'],['ni','ニ'],['nu','ヌ'],['ne','ネ'],['no','ノ'],
  ['ha','ハ'],['hi','ヒ'],['fu','フ'],['he','ヘ'],['ho','ホ'],
  ['ma','マ'],['mi','ミ'],['mu','ム'],['me','メ'],['mo','モ'],
  ['ya','ヤ'],['yu','ユ'],['yo','ヨ'],
  ['ra','ラ'],['ri','リ'],['ru','ル'],['re','レ'],['ro','ロ'],
  ['wa','ワ'],['wo','ヲ'],['n','ン'],
];

// Mapping: romaji -> { hiragana, katakana }
function buildKanaPool(sets) {
  const pool = [];
  if (sets.hiragana) HIRAGANA.forEach(([r,c]) => pool.push({ romaji:r, char:c, script:'hiragana' }));
  if (sets.katakana) KATAKANA.forEach(([r,c]) => pool.push({ romaji:r, char:c, script:'katakana' }));
  return pool;
}

function shuffle(arr) {
  const a = arr.slice();
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

function pickRandom(pool, n) {
  return shuffle(pool).slice(0, n);
}

Object.assign(window, { HIRAGANA, KATAKANA, buildKanaPool, shuffle, pickRandom });
