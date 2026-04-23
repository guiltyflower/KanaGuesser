// Drawing canvas for practicing kana with brush/ink style
function DrawCanvas({ width = 340, height = 340, onStrokesChange, clearSignal }) {
  const canvasRef = React.useRef(null);
  const drawingRef = React.useRef(false);
  const lastRef = React.useRef(null);
  const strokesRef = React.useRef(0);

  React.useEffect(() => {
    const c = canvasRef.current;
    if (!c) return;
    const dpr = window.devicePixelRatio || 1;
    c.width = width * dpr;
    c.height = height * dpr;
    const ctx = c.getContext('2d');
    ctx.scale(dpr, dpr);
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
    ctx.strokeStyle = '#1a1a1a';
    ctx.lineWidth = 10;
  }, [width, height]);

  // external clear signal
  React.useEffect(() => {
    const c = canvasRef.current;
    if (!c) return;
    const ctx = c.getContext('2d');
    ctx.clearRect(0,0,c.width,c.height);
    strokesRef.current = 0;
    onStrokesChange && onStrokesChange(0);
  }, [clearSignal]);

  const pos = (e) => {
    const c = canvasRef.current;
    const r = c.getBoundingClientRect();
    const t = e.touches && e.touches[0];
    const x = (t ? t.clientX : e.clientX) - r.left;
    const y = (t ? t.clientY : e.clientY) - r.top;
    return { x: x * (width / r.width), y: y * (height / r.height) };
  };

  const start = (e) => {
    e.preventDefault();
    drawingRef.current = true;
    const p = pos(e);
    lastRef.current = p;
    const ctx = canvasRef.current.getContext('2d');
    ctx.beginPath();
    ctx.arc(p.x, p.y, 4.5, 0, Math.PI * 2);
    ctx.fillStyle = '#1a1a1a';
    ctx.fill();
    strokesRef.current += 1;
    onStrokesChange && onStrokesChange(strokesRef.current);
  };

  const move = (e) => {
    if (!drawingRef.current) return;
    e.preventDefault();
    const p = pos(e);
    const last = lastRef.current;
    const ctx = canvasRef.current.getContext('2d');
    // brush variation via small line width jitter
    ctx.lineWidth = 9 + Math.random() * 2;
    ctx.beginPath();
    ctx.moveTo(last.x, last.y);
    ctx.lineTo(p.x, p.y);
    ctx.stroke();
    lastRef.current = p;
  };

  const end = () => {
    drawingRef.current = false;
    lastRef.current = null;
  };

  return (
    <div style={{
      width, height, borderRadius: 18, background: '#fff',
      boxShadow: 'inset 0 0 0 1px rgba(0,0,0,0.06), 0 2px 8px rgba(0,0,0,0.04)',
      position: 'relative', overflow: 'hidden',
      touchAction: 'none',
    }}>
      {/* faint guide cross */}
      <svg width={width} height={height} style={{position:'absolute',inset:0,pointerEvents:'none'}}>
        <line x1={width/2} y1={16} x2={width/2} y2={height-16} stroke="#E8E4D0" strokeWidth="1" strokeDasharray="4 6"/>
        <line x1={16} y1={height/2} x2={width-16} y2={height/2} stroke="#E8E4D0" strokeWidth="1" strokeDasharray="4 6"/>
      </svg>
      <canvas
        ref={canvasRef}
        style={{ width, height, display: 'block', position: 'relative', zIndex: 1 }}
        onMouseDown={start} onMouseMove={move} onMouseUp={end} onMouseLeave={end}
        onTouchStart={start} onTouchMove={move} onTouchEnd={end}
      />
    </div>
  );
}

Object.assign(window, { DrawCanvas });
