// Results screen — end of round
function ResultsScreen({
  mode,
  phase,
  recoveryPass,
  totalRecoveryPasses,
  results,         // array of { turn, correct }
  learnedCount,    // during recovery: how many have been learned (recuperato)
  onContinue,      // continue to recovery / next pass
  onHome,
  onRestart,
  // Challenge summary
  challengeTurn,   // 1 | 2 | 'final'
  player1Score,
  player2Score,
}) {
  const correctCount = results.filter(r => r.correct).length;
  const total = results.length;

  // Challenge: after P1, show "Pass to P2"
  if (mode === 'challenge' && challengeTurn === 1) {
    return <PassScreen player={1} score={correctCount} total={total} onContinue={onContinue}/>;
  }

  // Challenge: final winner
  if (mode === 'challenge' && challengeTurn === 'final') {
    return <ChallengeFinal p1={player1Score} p2={player2Score} total={total} onHome={onHome} onRestart={onRestart}/>;
  }

  // Learn mode summaries
  const isRecoveryResult = phase === 'recovery';
  const isFinalLearn = phase === 'done';
  const wrongCount = total - correctCount;

  return (
    <div style={{ position:'absolute', inset:0, background:'#F6EFC7' }}>
      <KanaBackground />
      <div style={{
        position:'absolute', inset:0, overflowY:'auto',
        padding:'120px 20px 40px', zIndex: 3,
      }}>
        <div style={{ textAlign:'center' }}>
          <div style={{
            fontSize: 13, color:'#8A8575', fontWeight: 600,
            textTransform:'uppercase', letterSpacing: 0.6,
          }}>
            {isFinalLearn ? 'Allenamento completato'
              : isRecoveryResult ? `Ripasso ${recoveryPass}/${totalRecoveryPasses}`
              : 'Round completato'}
          </div>
          <div style={{
            marginTop: 8, fontSize: 36, fontWeight: 900, color:'#0F0F0F',
            letterSpacing: -1, lineHeight: 1.05,
            fontFamily:'"Inter", -apple-system, system-ui',
          }}>
            {isFinalLearn ? 'Ottimo lavoro!'
              : `${correctCount} su ${total}`}
          </div>
          {!isFinalLearn && (
            <div style={{ marginTop: 8, fontSize: 15, color:'#6A6458' }}>
              {correctCount === total ? 'Perfetto!' :
               wrongCount === 1 ? '1 da ripassare' :
               `${wrongCount} da ripassare`}
            </div>
          )}
          {isFinalLearn && (
            <div style={{ marginTop: 10, fontSize: 15, color:'#6A6458' }}>
              {learnedCount} caratter{learnedCount===1?'e':'i'} recuperat{learnedCount===1?'o':'i'}
            </div>
          )}
        </div>

        {/* Score ring */}
        <div style={{ display:'flex', justifyContent:'center', marginTop: 24 }}>
          <ScoreRing correct={correctCount} total={total}/>
        </div>

        {/* Character grid */}
        <div style={{
          marginTop: 28, background:'#fff', borderRadius: 18,
          padding: 14, boxShadow:'0 2px 10px rgba(40,30,10,0.08)',
        }}>
          <div style={{
            fontSize: 12, color:'#8A8575', fontWeight: 600,
            textTransform:'uppercase', letterSpacing: 0.6,
            padding:'4px 6px 10px',
          }}>I tuoi caratteri</div>
          <div style={{
            display:'grid', gridTemplateColumns:'repeat(5, 1fr)', gap: 8,
          }}>
            {results.map((r, i) => (
              <div key={i} style={{
                aspectRatio:'1', borderRadius: 12,
                background: r.correct ? '#E7F7EC' : '#FFE8E8',
                border: r.correct ? '1px solid #BFE5CB' : '1px solid #F8C7C7',
                display:'flex', flexDirection:'column',
                alignItems:'center', justifyContent:'center', gap: 2,
                position:'relative',
              }}>
                <div style={{
                  fontSize: 28, lineHeight: 1, color:'#0F0F0F',
                  fontFamily:'"Hiragino Mincho ProN", "Noto Serif JP", serif',
                  fontWeight: 600,
                }}>{r.turn.char}</div>
                <div style={{ fontSize: 10, color:'#6A6458', fontWeight: 600 }}>{r.turn.romaji}</div>
                <div style={{
                  position:'absolute', top: 4, right: 4,
                  width: 14, height: 14, borderRadius: 7,
                  background: r.correct ? '#34C15E' : '#FF5C5C',
                  display:'flex', alignItems:'center', justifyContent:'center',
                }}>
                  {r.correct
                    ? <svg width="8" height="7" viewBox="0 0 8 7"><path d="M1 4l2 2 4-5" stroke="#fff" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" fill="none"/></svg>
                    : <svg width="7" height="7" viewBox="0 0 7 7"><path d="M1 1l5 5M6 1L1 6" stroke="#fff" strokeWidth="1.6" strokeLinecap="round"/></svg>
                  }
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* CTA */}
        <div style={{ marginTop: 24, display:'flex', flexDirection:'column', gap: 10 }}>
          {isFinalLearn ? (
            <>
              <ActionButton variant="primary" onClick={onRestart}>Nuovo round</ActionButton>
              <ActionButton variant="secondary" onClick={onHome}>Torna alla home</ActionButton>
            </>
          ) : (
            <>
              <ActionButton variant="primary" onClick={onContinue}>
                {wrongCount > 0
                  ? (isRecoveryResult
                      ? (recoveryPass < totalRecoveryPasses ? 'Continua ripasso' : 'Vedi riepilogo')
                      : 'Inizia ripasso')
                  : 'Continua'}
              </ActionButton>
              <ActionButton variant="secondary" onClick={onHome}>Torna alla home</ActionButton>
            </>
          )}
        </div>
      </div>
    </div>
  );
}

function ScoreRing({ correct, total }) {
  const pct = total ? correct / total : 0;
  const size = 140, stroke = 12, r = (size - stroke) / 2;
  const circ = 2 * Math.PI * r;
  return (
    <div style={{ position:'relative', width: size, height: size }}>
      <svg width={size} height={size}>
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="#EFE8CE" strokeWidth={stroke}/>
        <circle
          cx={size/2} cy={size/2} r={r} fill="none"
          stroke="#34C15E" strokeWidth={stroke} strokeLinecap="round"
          strokeDasharray={`${circ * pct} ${circ}`}
          transform={`rotate(-90 ${size/2} ${size/2})`}
          style={{ transition:'stroke-dasharray 500ms' }}
        />
      </svg>
      <div style={{
        position:'absolute', inset:0, display:'flex',
        flexDirection:'column', alignItems:'center', justifyContent:'center',
      }}>
        <div style={{
          fontSize: 36, fontWeight: 900, color:'#0F0F0F', letterSpacing:-1,
          fontFamily:'"Inter", -apple-system, system-ui',
        }}>{Math.round(pct * 100)}<span style={{fontSize:18, color:'#8A8575'}}>%</span></div>
        <div style={{ fontSize: 12, color:'#8A8575', fontWeight: 600, marginTop: 2 }}>
          {correct} / {total}
        </div>
      </div>
    </div>
  );
}

function PassScreen({ player, score, total, onContinue }) {
  return (
    <div style={{ position:'absolute', inset:0, background:'#F6EFC7' }}>
      <KanaBackground />
      <div style={{
        position:'absolute', inset:0, display:'flex', flexDirection:'column',
        alignItems:'center', justifyContent:'center', zIndex: 3, padding:'0 24px',
      }}>
        <div style={{
          background:'#fff', borderRadius: 22, padding:'32px 24px',
          boxShadow:'0 4px 20px rgba(40,30,10,0.1)', textAlign:'center',
          width:'100%', maxWidth: 360,
        }}>
          <div style={{
            fontSize: 13, color:'#8A8575', fontWeight: 600,
            textTransform:'uppercase', letterSpacing: 0.6,
          }}>Turno concluso</div>
          <div style={{
            marginTop: 6, fontSize: 32, fontWeight: 900, color:'#0F0F0F',
            letterSpacing:-0.8, fontFamily:'"Inter", -apple-system, system-ui',
          }}>Giocatore {player}: {score}/{total}</div>
          <div style={{
            marginTop: 22, padding:'18px 16px', borderRadius: 14,
            background:'#F6EFC7',
          }}>
            <div style={{
              fontSize: 14, color:'#6A6458',
            }}>Passa il dispositivo al</div>
            <div style={{
              marginTop: 4, fontSize: 22, fontWeight: 800, color:'#FF8A3C',
              letterSpacing:-0.4,
            }}>Giocatore {player === 1 ? 2 : 1}</div>
          </div>
          <div style={{ marginTop: 22 }}>
            <ActionButton variant="primary" onClick={onContinue}>
              Inizia turno giocatore {player === 1 ? 2 : 1}
            </ActionButton>
          </div>
        </div>
      </div>
    </div>
  );
}

function ChallengeFinal({ p1, p2, total, onHome, onRestart }) {
  const winner = p1 === p2 ? 0 : (p1 > p2 ? 1 : 2);
  return (
    <div style={{ position:'absolute', inset:0, background:'#F6EFC7' }}>
      <KanaBackground />
      <div style={{
        position:'absolute', inset:0, overflowY:'auto',
        padding:'100px 20px 40px', zIndex: 3,
      }}>
        <div style={{ textAlign:'center' }}>
          <div style={{
            fontSize: 13, color:'#8A8575', fontWeight: 600,
            textTransform:'uppercase', letterSpacing: 0.6,
          }}>Sfida completata</div>
          <div style={{
            marginTop: 10, fontSize: 42, fontWeight: 900, color:'#0F0F0F',
            letterSpacing:-1.2, lineHeight: 1,
            fontFamily:'"Inter", -apple-system, system-ui',
          }}>
            {winner === 0 ? 'Pareggio!' : `Vince il\nGiocatore ${winner}`}
          </div>
        </div>

        <div style={{ marginTop: 30, display:'flex', gap: 10 }}>
          <PlayerScoreCard player={1} score={p1} total={total} winner={winner === 1}/>
          <PlayerScoreCard player={2} score={p2} total={total} winner={winner === 2}/>
        </div>

        <div style={{ marginTop: 30, display:'flex', flexDirection:'column', gap: 10 }}>
          <ActionButton variant="primary" onClick={onRestart}>Rivincita</ActionButton>
          <ActionButton variant="secondary" onClick={onHome}>Torna alla home</ActionButton>
        </div>
      </div>
    </div>
  );
}

function PlayerScoreCard({ player, score, total, winner }) {
  return (
    <div style={{
      flex: 1, background:'#fff', borderRadius: 18, padding:'18px 14px',
      textAlign:'center',
      boxShadow: winner ? '0 4px 16px rgba(255,138,60,0.3), inset 0 0 0 2px #FF8A3C'
                        : '0 2px 8px rgba(40,30,10,0.08)',
      position:'relative',
    }}>
      {winner && (
        <div style={{
          position:'absolute', top: -10, left:'50%', transform:'translateX(-50%)',
          background:'#FF8A3C', color:'#fff',
          fontSize: 10, fontWeight: 800, letterSpacing: 0.6,
          padding:'4px 10px', borderRadius: 999, textTransform:'uppercase',
        }}>Vincitore</div>
      )}
      <div style={{ fontSize: 12, color:'#8A8575', fontWeight: 600,
        textTransform:'uppercase', letterSpacing: 0.6 }}>
        Giocatore {player}
      </div>
      <div style={{
        marginTop: 6, fontSize: 40, fontWeight: 900, color:'#0F0F0F',
        letterSpacing:-1, lineHeight: 1,
        fontFamily:'"Inter", -apple-system, system-ui',
      }}>{score}</div>
      <div style={{ marginTop: 2, fontSize: 13, color:'#8A8575' }}>/ {total}</div>
    </div>
  );
}

Object.assign(window, { ResultsScreen });
