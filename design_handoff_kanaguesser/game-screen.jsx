// Game screen — drawing, reveal, mark correct/wrong
function GameScreen({
  mode,            // 'learn' | 'challenge'
  phase,           // 'normal' | 'recovery'
  recoveryPass,    // number (1..N)
  totalRecoveryPasses,
  currentPlayer,   // 1 | 2 (challenge mode)
  progress,        // array of 'pending'|'correct'|'wrong' (length == total turns)
  turnIndex,
  turn,            // { romaji, char, script }
  onAnswer,        // (correct: boolean) => void
  onExit,
}) {
  const [revealed, setRevealed] = React.useState(false);
  const [clearKey, setClearKey] = React.useState(0);
  const [strokes, setStrokes] = React.useState(0);

  React.useEffect(() => {
    setRevealed(false);
    setClearKey(k => k + 1);
    setStrokes(0);
  }, [turnIndex, phase, currentPlayer]);

  const headerLabel = mode === 'challenge'
    ? `Giocatore ${currentPlayer}`
    : phase === 'recovery'
      ? `Ripasso ${recoveryPass}/${totalRecoveryPasses}`
      : 'KanaGuesser';

  return (
    <div style={{ position:'absolute', inset:0, background:'#F6EFC7' }}>
      <KanaBackground />

      {/* Top bar — under status bar */}
      <div style={{
        position:'absolute', top: 56, left: 0, right: 0, zIndex: 3,
        padding: '10px 16px',
        display:'flex', alignItems:'center', gap: 12,
      }}>
        <button onClick={onExit} style={{
          width: 36, height: 36, borderRadius: 18, border:'none',
          background:'rgba(255,255,255,0.85)', cursor:'pointer',
          display:'flex', alignItems:'center', justifyContent:'center',
          boxShadow:'0 2px 6px rgba(0,0,0,0.06)',
          backdropFilter:'blur(8px)', WebkitBackdropFilter:'blur(8px)',
        }}>
          <svg width="12" height="12" viewBox="0 0 12 12">
            <path d="M1 1l10 10M11 1L1 11" stroke="#3A3A3A" strokeWidth="2" strokeLinecap="round"/>
          </svg>
        </button>
        <div style={{flex:1, textAlign:'center'}}>
          <div style={{
            fontSize: 13, color:'#7A7468', fontWeight: 600, letterSpacing: 0.3,
            textTransform: 'uppercase',
          }}>{headerLabel}</div>
          <div style={{
            fontSize: 17, fontWeight: 800, color:'#0F0F0F', letterSpacing:-0.4,
            marginTop: 1,
          }}>
            {turnIndex + 1} <span style={{color:'#9A9483',fontWeight:600}}>/ {progress.length}</span>
          </div>
        </div>
        <div style={{ width: 36 }}/>
      </div>

      {/* Progress segments */}
      <div style={{
        position:'absolute', top: 134, left: 16, right: 16, zIndex: 3,
        display:'flex', gap: 4,
      }}>
        {progress.map((s, i) => (
          <div key={i} style={{
            flex: 1, height: 6, borderRadius: 3,
            background: s === 'correct' ? '#34C15E'
                      : s === 'wrong'   ? '#FF5C5C'
                      : i === turnIndex ? 'rgba(15,15,15,0.35)'
                      : 'rgba(15,15,15,0.12)',
            transition:'background 250ms',
          }}/>
        ))}
      </div>

      {/* Prompt card */}
      <div style={{
        position:'absolute', top: 162, left: 16, right: 16, zIndex: 3,
      }}>
        <div style={{
          background:'#fff', borderRadius: 20, padding: '22px 20px 26px',
          boxShadow:'0 4px 16px rgba(40,30,10,0.08)',
          textAlign:'center',
        }}>
          <div style={{
            fontSize: 13, color:'#8A8575', fontWeight: 600,
            textTransform:'uppercase', letterSpacing: 0.6,
          }}>
            Disegna il carattere
          </div>
          <div style={{
            marginTop: 10, fontSize: 68, fontWeight: 900,
            color:'#0F0F0F', letterSpacing: -2, lineHeight: 1,
            fontFamily:'"Inter", -apple-system, system-ui',
          }}>{turn.romaji}</div>
          <div style={{
            marginTop: 8, fontSize: 13, color:'#9A9483',
            textTransform:'capitalize',
          }}>{turn.script}</div>
        </div>
      </div>

      {/* Bottom area — draw OR reveal */}
      <div style={{
        position:'absolute', bottom: 40, left: 0, right: 0, zIndex: 3,
        display:'flex', flexDirection:'column', alignItems:'center', gap: 16,
      }}>
        {!revealed ? (
          <>
            <DrawCanvas
              width={340} height={340}
              clearSignal={clearKey}
              onStrokesChange={setStrokes}
            />
            <div style={{ display:'flex', gap: 10, width: 340 }}>
              <ActionButton
                flex
                variant="secondary"
                onClick={() => setClearKey(k => k + 1)}
                disabled={strokes === 0}
                icon={
                  <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                    <path d="M14 4l-1.3 9.3a1 1 0 01-1 .7H4.3a1 1 0 01-1-.7L2 4M6 7v4M10 7v4M1 4h14M5 4V2.5A1.5 1.5 0 016.5 1h3A1.5 1.5 0 0111 2.5V4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
                  </svg>
                }
              >Cancella</ActionButton>
              <ActionButton
                flex
                variant="primary"
                onClick={() => setRevealed(true)}
                disabled={strokes === 0}
                icon={
                  <svg width="18" height="14" viewBox="0 0 18 14" fill="none">
                    <path d="M1 7s3-5.5 8-5.5S17 7 17 7s-3 5.5-8 5.5S1 7 1 7z" stroke="currentColor" strokeWidth="1.5"/>
                    <circle cx="9" cy="7" r="2.2" stroke="currentColor" strokeWidth="1.5"/>
                  </svg>
                }
              >Mostra risposta</ActionButton>
            </div>
          </>
        ) : (
          <RevealPanel turn={turn} onAnswer={onAnswer}/>
        )}
      </div>
    </div>
  );
}

function RevealPanel({ turn, onAnswer }) {
  return (
    <>
      <div style={{
        width: 340, height: 340, borderRadius: 20,
        background:'#fff',
        boxShadow:'0 4px 16px rgba(40,30,10,0.08), inset 0 0 0 1px rgba(0,0,0,0.04)',
        display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center',
        position:'relative', overflow:'hidden',
      }}>
        <div style={{
          position:'absolute', top: 14, left: 0, right: 0, textAlign:'center',
          fontSize: 12, fontWeight: 600, color:'#8A8575',
          textTransform:'uppercase', letterSpacing: 0.6,
        }}>Risposta corretta</div>
        <div style={{
          fontSize: 210, lineHeight: 1,
          fontFamily:'"Hiragino Mincho ProN", "Yu Mincho", "Noto Serif JP", serif',
          fontWeight: 600, color:'#0F0F0F', marginTop: 6,
        }}>{turn.char}</div>
        <div style={{
          position:'absolute', bottom: 16, left: 0, right: 0, textAlign:'center',
          fontSize: 15, color:'#6A6458', fontWeight: 500,
        }}>
          <span style={{
            background:'#F6EFC7', padding:'4px 12px', borderRadius: 999,
            fontFamily:'"Inter", -apple-system, system-ui', fontWeight: 700,
            color:'#0F0F0F',
          }}>{turn.romaji}</span>
        </div>
      </div>
      <div style={{ display:'flex', gap: 10, width: 340 }}>
        <ActionButton flex variant="danger" onClick={() => onAnswer(false)}
          icon={<svg width="14" height="14" viewBox="0 0 14 14"><path d="M1 1l12 12M13 1L1 13" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"/></svg>}
        >Sbagliato</ActionButton>
        <ActionButton flex variant="success" onClick={() => onAnswer(true)}
          icon={<svg width="16" height="14" viewBox="0 0 16 14"><path d="M1 7l5 5L15 1" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/></svg>}
        >Corretto</ActionButton>
      </div>
    </>
  );
}

function ActionButton({ children, onClick, variant, flex, icon, disabled }) {
  const styles = {
    primary:   { bg:'#0F0F0F',  fg:'#fff' },
    secondary: { bg:'#fff',     fg:'#0F0F0F', border:'1px solid #E8E2CC' },
    success:   { bg:'#34C15E',  fg:'#fff' },
    danger:    { bg:'#FF5C5C',  fg:'#fff' },
  }[variant];
  return (
    <button onClick={onClick} disabled={disabled} style={{
      flex: flex ? 1 : undefined,
      height: 52, borderRadius: 14,
      background: styles.bg, color: styles.fg,
      border: styles.border || 'none',
      fontSize: 16, fontWeight: 600,
      fontFamily:'-apple-system, system-ui',
      display:'flex', alignItems:'center', justifyContent:'center', gap: 8,
      cursor: disabled ? 'default' : 'pointer',
      opacity: disabled ? 0.4 : 1,
      boxShadow: variant === 'primary' ? '0 2px 8px rgba(0,0,0,0.18)' : '0 1px 3px rgba(0,0,0,0.06)',
      transition:'transform 120ms',
    }}>
      {icon}{children}
    </button>
  );
}

Object.assign(window, { GameScreen });
