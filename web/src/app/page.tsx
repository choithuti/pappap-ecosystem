'use client';
import { useState } from 'react';

export default function Home() {
  const [msg, setMsg] = useState("Đang kết nối Genesis Node...");
  const [input, setInput] = useState("");

  const send = async () => {
    try {
      const res = await fetch("http://127.0.0.1:8080/api/prompt", {
        method: "POST",
        headers: {"Content-Type":"application/json"},
        body: JSON.stringify({prompt: input})
      });
      const data = await res.json();
      setMsg(data.response || JSON.stringify(data));
    } catch { setMsg("Node chưa chạy"); }
  };

  return (
    <main style={{padding: "40px", fontFamily: "sans-serif"}}>
      <h1 style={{fontSize: "2.5em"}}>PAPPAP AI CHAIN SNN – choithuti@MAPLE0276</h1>
      <p style={{fontSize: "1.5em", margin: "30px 0"}}>{msg}</p>
      <input value={input} onChange={e=>setInput(e.target.value)} placeholder="Nhập tin nhắn" style={{padding: "12px", fontSize: "18px", width: "400px"}}/>
      <button onClick={send} style={{padding: "12px 30px", fontSize: "18px", marginLeft: "10px"}}>Gửi</button>
    </main>
  );
}
