#![cfg_attr(all(not(debug_assertions), target_os = "windows"), windows_subsystem = "windows")]

use tauri::Manager;
use reqwest;

#[tauri::command]
async fn get_node_status() -> Result<serde_json::Value, String> {
    let client = reqwest::Client::new();
    let res = client.get("http://127.0.0.1:8080/api/status")
        .send()
        .await
        .map_err(|e| e.to_string())?;
    let json = res.json().await.map_err(|e| e.to_string())?;
    Ok(json)
}

#[tauri::command]
async fn send_prompt(prompt: String) -> Result<serde_json::Value, String> {
    let client = reqwest::Client::new();
    let res = client.post("http://127.0.0.1:8080/api/prompt")
        .header("Content-Type", "application/json")
        .body(format!(r#"{{"prompt":"{}"}}"#, prompt))
        .send()
        .await
        .map_err(|e| e.to_string())?;
    let json = res.json().await.map_err(|e| e.to_string())?;
    Ok(json)
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![get_node_status, send_prompt])
        .run(tauri::generate_context!())
        .expect("error while running Pappap Desktop Wallet");
}