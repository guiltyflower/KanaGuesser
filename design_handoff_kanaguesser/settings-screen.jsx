// Settings screen — sheet-style modal
function SettingsScreen({ settings, onChange, onClose }) {
  const toggleSet = (key) => {
    const next = { ...settings, [key]: !settings[key] };
    // at least one must be enabled
    if (!next.hiragana && !next.katakana) return;
    onChange(next);
  };

  return (
    <div style={{
      position:'absolute', inset:0, zIndex: 50,
      background:'rgba(0,0,0,0.25)',
      backdropFilter:'blur(2px)', WebkitBackdropFilter:'blur(2px)',
      display:'flex', alignItems:'flex-end',
      animation:'fadeIn 180ms ease',
    }}>
      <div style={{
        width:'100%', background:'#F5EFD8', borderRadius:'24px 24px 0 0',
        padding: '14px 0 40px',
        boxShadow:'0 -10px 40px rgba(0,0,0,0.15)',
        animation:'slideUp 260ms cubic-bezier(0.2,0.9,0.3,1)',
      }}>
        {/* grabber */}
        <div style={{
          width: 40, height: 5, background:'rgba(0,0,0,0.2)',
          borderRadius: 3, margin:'0 auto 14px',
        }}/>

        <div style={{
          display:'flex', alignItems:'center', justifyContent:'space-between',
          padding:'0 20px 18px',
        }}>
          <div style={{ fontSize: 22, fontWeight: 800, color:'#0F0F0F', letterSpacing:-0.5 }}>
            Impostazioni
          </div>
          <button onClick={onClose} style={{
            width: 32, height: 32, borderRadius: 16, border:'none',
            background:'rgba(0,0,0,0.06)', cursor:'pointer',
            display:'flex', alignItems:'center', justifyContent:'center',
          }}>
            <svg width="14" height="14" viewBox="0 0 14 14"><path d="M1 1l12 12M13 1L1 13" stroke="#3A3A3A" strokeWidth="2" strokeLinecap="round"/></svg>
          </button>
        </div>

        <SettingsSection title="SILLABARI">
          <SettingRow
            title="Hiragana"
            subtitle="あ い う え お"
            checked={settings.hiragana}
            onToggle={() => toggleSet('hiragana')}
          />
          <SettingDivider/>
          <SettingRow
            title="Katakana"
            subtitle="ア イ ウ エ オ"
            checked={settings.katakana}
            onToggle={() => toggleSet('katakana')}
          />
        </SettingsSection>

        <SettingsSection title="PARTITA">
          <SettingRow
            title="Turni per round"
            subtitle="Quanti caratteri disegnare"
            trailing={<Stepper value={settings.rounds} onChange={(v) => onChange({...settings, rounds:v})} min={5} max={20} step={5}/>}
          />
          <SettingDivider/>
          <SettingRow
            title="Ripassi dei caratteri sbagliati"
            subtitle="Volte per memorizzare"
            trailing={<Stepper value={settings.recoveryPasses} onChange={(v) => onChange({...settings, recoveryPasses:v})} min={1} max={5}/>}
          />
        </SettingsSection>

        <SettingsSection title="PREFERENZE">
          <SettingRow
            title="Suoni"
            subtitle="Feedback audio"
            checked={settings.sounds}
            onToggle={() => onChange({...settings, sounds:!settings.sounds})}
          />
          <SettingDivider/>
          <SettingRow
            title="Vibrazione"
            subtitle="Feedback aptico"
            checked={settings.haptics}
            onToggle={() => onChange({...settings, haptics:!settings.haptics})}
          />
        </SettingsSection>
      </div>
    </div>
  );
}

function SettingsSection({ title, children }) {
  return (
    <div style={{ padding:'4px 16px 18px' }}>
      <div style={{
        fontSize: 12, color:'#8A8575', fontWeight: 600, letterSpacing: 0.6,
        padding:'6px 8px 8px',
      }}>{title}</div>
      <div style={{
        background:'#fff', borderRadius: 14,
        boxShadow:'0 1px 4px rgba(40,30,10,0.06)',
        overflow:'hidden',
      }}>{children}</div>
    </div>
  );
}

function SettingDivider() {
  return <div style={{ height: 1, background:'#EFEADA', marginLeft: 16 }}/>;
}

function SettingRow({ title, subtitle, checked, onToggle, trailing }) {
  return (
    <div style={{
      display:'flex', alignItems:'center', gap: 12,
      padding: '12px 14px', minHeight: 54,
    }}>
      <div style={{flex:1, minWidth:0}}>
        <div style={{ fontSize: 16, fontWeight: 500, color:'#0F0F0F' }}>{title}</div>
        {subtitle && <div style={{ fontSize: 13, color:'#8A8575', marginTop: 2 }}>{subtitle}</div>}
      </div>
      {trailing}
      {onToggle !== undefined && <Toggle checked={checked} onToggle={onToggle}/>}
    </div>
  );
}

function Toggle({ checked, onToggle }) {
  return (
    <button onClick={onToggle} style={{
      width: 51, height: 31, borderRadius: 16, border:'none', padding: 2,
      background: checked ? '#34C759' : '#E3DEC8', cursor:'pointer',
      display:'flex', alignItems:'center',
      transition:'background 180ms', flexShrink:0,
    }}>
      <div style={{
        width: 27, height: 27, borderRadius:'50%', background:'#fff',
        boxShadow:'0 2px 4px rgba(0,0,0,0.15)',
        transform: checked ? 'translateX(20px)' : 'translateX(0)',
        transition:'transform 180ms',
      }}/>
    </button>
  );
}

function Stepper({ value, onChange, min, max, step = 1 }) {
  return (
    <div style={{
      display:'flex', alignItems:'center', gap: 2,
      background:'#EFEADA', borderRadius: 10, padding: 3,
    }}>
      <button onClick={() => onChange(Math.max(min, value - step))} style={stepBtn}>–</button>
      <div style={{
        minWidth: 30, textAlign:'center', fontSize: 15, fontWeight: 600, color:'#0F0F0F',
      }}>{value}</div>
      <button onClick={() => onChange(Math.min(max, value + step))} style={stepBtn}>+</button>
    </div>
  );
}

const stepBtn = {
  width: 28, height: 26, border:'none', borderRadius: 7, background:'#fff',
  fontSize: 18, fontWeight: 500, color:'#0F0F0F', cursor:'pointer',
  display:'flex', alignItems:'center', justifyContent:'center',
  boxShadow:'0 1px 2px rgba(0,0,0,0.06)',
};

Object.assign(window, { SettingsScreen });
