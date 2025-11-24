import { useState, useEffect } from 'react';

export default function Home() {
  const [status, setStatus] = useState({});
  const [prompt, setPrompt] = useState('');
  const [response, setResponse] = useState('');

  useEffect(() => {
    fetch('/api/status').then(r => r.json()).then(setStatus);
  }, []);

  const sendPrompt = async () => {
    const res = await fetch('/api/prompt', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({prompt})
    });
    const data = await res.json();
    setResponse(data.response);
    if (data.tts) {
      new Audio(data.tts).play();
    }
  };

  return (
    <div style={{fontFamily: 'system-ui', textAlign: 'center', padding: '50px', background: '#000', color: '#0f0'}}>
      <h1>PAPPAP AI CHAIN SNN</h1>
      <p>World's First Living Blockchain – Made in Vietnam</p>
      <h2>Neurons: {status.neurons || '...'}</h2>
      <p>Status: {status.status || 'Loading...'}</p>
      <div style={{margin: '30px'}}>
        <input value={prompt} onChange={e=>setPrompt(e.target.value)} placeholder="Hỏi Pappap..." style={{padding: '10px', width: '300px'}} />
        <button onClick={sendPrompt} style={{padding: '10px 20px'}}>Gửi</button>
      </div>
      {response && <p><strong>Pappap:</strong> {response}</p>}
    </div>
  );
}