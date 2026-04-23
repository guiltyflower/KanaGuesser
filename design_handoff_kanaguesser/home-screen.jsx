// Home screen — matches reference: KanaGuesser title, two mode cards, settings button
function HomeScreen({ onStart, onOpenSettings }) {
  return (
    <div style={{ position:'absolute', inset:0 }}>
      <KanaBackground />
      {/* settings button top right */}
      <button
        onClick={onOpenSettings}
        style={{
          position:'absolute', top: 66, right: 20,
          width: 44, height: 44, borderRadius: 22,
          background: 'rgba(255,255,255,0.85)',
          border: 'none',
          boxShadow: '0 2px 8px rgba(0,0,0,0.08)',
          display:'flex', alignItems:'center', justifyContent:'center',
          cursor:'pointer', zIndex: 5,
          backdropFilter:'blur(8px)',
          WebkitBackdropFilter:'blur(8px)',
        }}>
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
          <path d="M19.43 12.98a7.99 7.99 0 000-1.96l2.11-1.65a.5.5 0 00.12-.64l-2-3.46a.5.5 0 00-.61-.22l-2.49 1a7.52 7.52 0 00-1.69-.98l-.38-2.65A.5.5 0 0014 2h-4a.5.5 0 00-.5.42l-.38 2.65c-.61.25-1.17.58-1.69.98l-2.49-1a.5.5 0 00-.61.22l-2 3.46a.5.5 0 00.12.64l2.11 1.65a8 8 0 000 1.96l-2.11 1.65a.5.5 0 00-.12.64l2 3.46c.14.24.43.33.68.22l2.49-1c.52.4 1.08.73 1.69.98l.38 2.65a.5.5 0 00.5.42h4a.5.5 0 00.5-.42l.38-2.65c.61-.25 1.17-.58 1.69-.98l2.49 1c.25.1.54.02.68-.22l2-3.46a.5.5 0 00-.12-.64l-2.11-1.65zM12 15.5A3.5 3.5 0 1115.5 12 3.5 3.5 0 0112 15.5z" fill="#4A4A4A"/>
        </svg>
      </button>

      {/* title + subtitle */}
      <div style={{
        position:'absolute', top: 230, left: 0, right: 0,
        textAlign:'center', padding: '0 24px', zIndex: 2,
      }}>
        <h1 style={{
          margin:0, fontFamily:'"Inter", -apple-system, system-ui',
          fontWeight: 900, fontSize: 44, letterSpacing: -1.5,
          color:'#0F0F0F', lineHeight: 1,
        }}>KanaGuesser</h1>
        <div style={{
          marginTop: 10, fontSize: 15, color:'#5A5A50',
          fontFamily:'-apple-system, system-ui',
        }}>Scegli una modalità</div>
      </div>

      {/* mode cards */}
      <div style={{
        position:'absolute', top: 360, left: 16, right: 16,
        display:'flex', flexDirection:'column', gap: 12, zIndex: 2,
      }}>
        <ModeCard
          onClick={() => onStart('learn')}
          icon={
            <svg width="26" height="26" viewBox="0 0 24 24" fill="none">
              <path d="M4 4.5A1.5 1.5 0 015.5 3H11v17H5.5A1.5 1.5 0 014 18.5v-14z" fill="#1E7BFF"/>
              <path d="M20 4.5A1.5 1.5 0 0018.5 3H13v17h5.5a1.5 1.5 0 001.5-1.5v-14z" fill="#4F99FF"/>
              <path d="M11 3v17M6 7h3M6 10h3M6 13h3M15 7h3M15 10h3M15 13h3" stroke="#fff" strokeWidth="1.2" strokeLinecap="round" opacity="0.8"/>
            </svg>
          }
          iconBg="#DCEBFF"
          title="Impara"
          subtitle="Allenati da solo"
        />
        <ModeCard
          onClick={() => onStart('challenge')}
          icon={
            <svg width="26" height="26" viewBox="0 0 24 24" fill="none">
              <circle cx="8.5" cy="8" r="3.2" fill="#FF8A3C"/>
              <circle cx="16" cy="9" r="2.6" fill="#FF8A3C"/>
              <path d="M3 18c0-2.8 2.5-5 5.5-5s5.5 2.2 5.5 5v2H3v-2z" fill="#FF8A3C"/>
              <path d="M13 18.5c0-2.3 1.8-4.2 4-4.2s4 1.9 4 4.2V20h-8v-1.5z" fill="#FFA867"/>
            </svg>
          }
          iconBg="#FFE6D1"
          title="Sfida"
          subtitle="2 giocatori a turni"
        />
      </div>
    </div>
  );
}

function ModeCard({ icon, iconBg, title, subtitle, onClick }) {
  return (
    <button onClick={onClick} style={{
      width:'100%', background:'#fff', borderRadius: 16,
      border:'none', padding: '16px 18px',
      display:'flex', alignItems:'center', gap: 14,
      boxShadow:'0 2px 10px rgba(40,30,10,0.08)',
      cursor:'pointer', textAlign:'left',
    }}>
      <div style={{
        width: 46, height: 46, borderRadius: 23,
        background: iconBg, display:'flex',
        alignItems:'center', justifyContent:'center', flexShrink:0,
      }}>{icon}</div>
      <div style={{flex:1, minWidth:0}}>
        <div style={{
          fontSize: 19, fontWeight: 700, color:'#0F0F0F',
          fontFamily:'-apple-system, system-ui', letterSpacing:-0.3,
        }}>{title}</div>
        <div style={{
          fontSize: 14, color:'#7A7A72', marginTop: 2,
          fontFamily:'-apple-system, system-ui',
        }}>{subtitle}</div>
      </div>
      <svg width="10" height="16" viewBox="0 0 10 16" fill="none">
        <path d="M1.5 1.5L8 8l-6.5 6.5" stroke="#B8B5A8" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
      </svg>
    </button>
  );
}

Object.assign(window, { HomeScreen });
