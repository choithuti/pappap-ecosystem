mod snn_core;
mod auto_learn;
mod crypto_pqc;

use actix_web::{web, App, HttpServer, HttpResponse, Responder};
use std::sync::Arc;
use serde_json::json;

#[derive(Clone)]
pub struct AppState {
    snn: Arc<snn_core::SNNCore>,
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    println!("PAPPAP AI CHAIN SNN v0.4 – Made in Vietnam – 25/11/2025");
    println!("World's First Living Blockchain – Ethical & Self-Learning\n");

    let snn = Arc::new(snn_core::SNNCore::new());
    let state = web::Data::new(AppState { snn: snn.clone() });

    println!("SNN Initialized: {} neurons | Power: {:.1}", 
             snn.neuron_count().await, snn.power().await);

    HttpServer::new(move || {
        App::new()
            .app_data(state.clone())
            .route("/api/status", web::get().to(status_handler))
            .route("/api/prompt", web::post().to(prompt_handler))
            .route("/api/wallet/balance", web::get().to(wallet_balance_handler))
            .route("/api/tx/send", web::post().to(send_tx_handler))
            .route("/api/self-learn", web::post().to(self_learn_handler))
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}

async fn status_handler(state: web::Data<AppState>) -> impl Responder {
    let neurons = state.snn.neuron_count().await;
    let power = state.snn.power().await;
    HttpResponse::Ok().json(json!({
        "status": "PAPPAP AI CHAIN SNN IS ALIVE",
        "neurons": neurons,
        "power": power,
        "message": "Made in Vietnam – choithuti@MAPLE0276"
    }))
}

async fn prompt_handler(state: web::Data<AppState>, req: web::Json<serde_json::Value>) -> impl Responder {
    let prompt = req["prompt"].as_str().unwrap_or("hello").trim();

    // Từ chối nội dung xấu
    if prompt.to_lowercase().contains("hack") || prompt.contains("lậu") || prompt.contains("crack") {
        return HttpResponse::Ok().json(json!({
            "response": "Yêu cầu vi phạm pháp luật Việt Nam. Pappap AI từ chối.",
            "status": "rejected"
        }));
    }

    let (lang, response) = state.snn.detect_and_translate(prompt).await;
    let neurons = state.snn.neuron_count().await;

    HttpResponse::Ok().json(json!({
        "response": response,
        "language": lang,
        "neurons": neurons,
        "status": "GENESIS NODE ALIVE"
    }))
}

async fn wallet_balance_handler() -> impl Responder {
    HttpResponse::Ok().json(json!({
        "address": "MAPLE0276_GENESIS_001",
        "balance": "105001287644.42000000",
        "neurons": 112384
    }))
}

async fn send_tx_handler() -> impl Responder {
    HttpResponse::Ok().json(json!({
        "tx_hash": format!("PAPPAP_TX_{:012}", rand::random::<u64>()),
        "status": "confirmed"
    }))
}

async fn self_learn_handler(req: web::Json<serde_json::Value>) -> impl Responder {
    let prompt = req["prompt"].as_str().unwrap_or("hello");
    let learned = auto_learn::auto_learn_and_answer(prompt).await;
    HttpResponse::Ok().json(json!({
        "learned": learned,
        "message": "Pappap đã tự học xong!"
    }))
}
