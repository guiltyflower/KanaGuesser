// Main app — orchestrates screens and game state
function App() {
  const [screen, setScreen] = React.useState('home'); // home | game | results
  const [settingsOpen, setSettingsOpen] = React.useState(false);
  const [settings, setSettings] = React.useState({
    hiragana: true, katakana: true,
    rounds: 10, recoveryPasses: 3,
    sounds: true, haptics: true,
  });

  // Game state
  const [mode, setMode] = React.useState('learn');
  const [phase, setPhase] = React.useState('normal'); // normal | recovery | done
  const [recoveryPass, setRecoveryPass] = React.useState(0);

  // Challenge
  const [challengeTurn, setChallengeTurn] = React.useState(1); // 1 | 2 | 'final'
  const [p1Score, setP1Score] = React.useState(0);
  const [p2Score, setP2Score] = React.useState(0);

  // Current turn sequence
  const [turns, setTurns] = React.useState([]); // [{romaji,char,script}]
  const [turnIndex, setTurnIndex] = React.useState(0);
  const [progress, setProgress] = React.useState([]); // pending|correct|wrong
  const [results, setResults] = React.useState([]);

  // Recovery tracking (learn mode): per-char attempts across recovery passes
  const [recoveryState, setRecoveryState] = React.useState(null);
  // { items: [{char,romaji,script, attempts:[bool,...], lastCorrect, correctCount}], learned: Set(romaji+char) }

  const startGame = (m) => {
    setMode(m);
    setPhase('normal');
    setRecoveryPass(0);
    setChallengeTurn(1);
    setP1Score(0);
    setP2Score(0);
    startRound();
    setScreen('game');
  };

  const startRound = () => {
    const pool = buildKanaPool({ hiragana: settings.hiragana, katakana: settings.katakana });
    const picked = pickRandom(pool, settings.rounds);
    setTurns(picked);
    setTurnIndex(0);
    setProgress(picked.map(() => 'pending'));
    setResults([]);
  };

  const onAnswer = (correct) => {
    // record for this turn
    const newProgress = progress.slice();
    newProgress[turnIndex] = correct ? 'correct' : 'wrong';
    setProgress(newProgress);
    const newResults = [...results, { turn: turns[turnIndex], correct }];
    setResults(newResults);

    // recovery attempt tracking
    if (phase === 'recovery' && recoveryState) {
      const key = turns[turnIndex].script + '-' + turns[turnIndex].romaji + '-' + turns[turnIndex].char;
      const items = recoveryState.items.map(it => {
        const iKey = it.script + '-' + it.romaji + '-' + it.char;
        if (iKey !== key) return it;
        return {
          ...it,
          attempts: [...it.attempts, correct],
          lastCorrect: correct,
          correctCount: it.correctCount + (correct ? 1 : 0),
        };
      });
      setRecoveryState({ ...recoveryState, items });
    }

    if (turnIndex < turns.length - 1) {
      setTurnIndex(turnIndex + 1);
    } else {
      // end of round — go to results
      finishRound(newResults);
    }
  };

  const finishRound = (roundResults) => {
    if (mode === 'challenge') {
      if (challengeTurn === 1) {
        setP1Score(roundResults.filter(r => r.correct).length);
      } else {
        setP2Score(roundResults.filter(r => r.correct).length);
      }
    }
    setScreen('results');
  };

  const onContinue = () => {
    // Challenge flow
    if (mode === 'challenge') {
      if (challengeTurn === 1) {
        setChallengeTurn(2);
        startRound();
        setScreen('game');
        return;
      }
      if (challengeTurn === 2) {
        setChallengeTurn('final');
        // stay on results (shows final)
        return;
      }
    }

    // Learn flow
    if (phase === 'normal') {
      // Set up recovery if there are wrongs
      const wrongs = results.filter(r => !r.correct).map(r => r.turn);
      if (wrongs.length === 0) {
        setPhase('done');
        return;
      }
      const items = wrongs.map(t => ({
        ...t, attempts: [], lastCorrect: false, correctCount: 0,
      }));
      setRecoveryState({ items, learned: [] });
      startRecoveryPass(1, items);
      return;
    }

    if (phase === 'recovery') {
      // Determine learned: correctCount >= 2 AND lastCorrect
      const learned = recoveryState.items.filter(it => it.correctCount >= 2 && it.lastCorrect);
      const learnedKeys = new Set(learned.map(it => it.script+'-'+it.romaji+'-'+it.char));
      // update learned list
      const updated = { ...recoveryState,
        learned: [...new Set([...(recoveryState.learned||[]), ...Array.from(learnedKeys)])] };
      setRecoveryState(updated);

      if (recoveryPass < settings.recoveryPasses) {
        startRecoveryPass(recoveryPass + 1, recoveryState.items);
      } else {
        setPhase('done');
      }
    }
  };

  const startRecoveryPass = (passNum, items) => {
    setRecoveryPass(passNum);
    setPhase('recovery');
    const picked = shuffle(items).map(it => ({ romaji: it.romaji, char: it.char, script: it.script }));
    setTurns(picked);
    setTurnIndex(0);
    setProgress(picked.map(() => 'pending'));
    setResults([]);
    setScreen('game');
  };

  const onHome = () => {
    setScreen('home');
  };

  const onRestart = () => {
    startGame(mode);
  };

  return (
    <>
      {screen === 'home' && (
        <HomeScreen
          onStart={startGame}
          onOpenSettings={() => setSettingsOpen(true)}
        />
      )}
      {screen === 'game' && turns.length > 0 && (
        <GameScreen
          mode={mode}
          phase={phase}
          recoveryPass={recoveryPass}
          totalRecoveryPasses={settings.recoveryPasses}
          currentPlayer={challengeTurn === 'final' ? 2 : challengeTurn}
          progress={progress}
          turnIndex={turnIndex}
          turn={turns[turnIndex]}
          onAnswer={onAnswer}
          onExit={onHome}
        />
      )}
      {screen === 'results' && (
        <ResultsScreen
          mode={mode}
          phase={phase}
          recoveryPass={recoveryPass}
          totalRecoveryPasses={settings.recoveryPasses}
          results={results}
          learnedCount={recoveryState ? (recoveryState.learned?.length || 0) : 0}
          onContinue={onContinue}
          onHome={onHome}
          onRestart={onRestart}
          challengeTurn={challengeTurn}
          player1Score={p1Score}
          player2Score={p2Score}
        />
      )}

      {settingsOpen && (
        <SettingsScreen
          settings={settings}
          onChange={setSettings}
          onClose={() => setSettingsOpen(false)}
        />
      )}
    </>
  );
}

Object.assign(window, { App });
