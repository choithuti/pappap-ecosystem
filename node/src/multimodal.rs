use actix_web::{web, Json};
use serde_json::Value;
use whisper_rs::{WhisperContext, FullParams};  // Whisper for voice
use clip_rs::{ClipModel, ImageProcessor};  // CLIP for vision

#[derive(Deserialize)]
pub struct MultimodalRequest {
    pub type_input: String,  // "voice" or "vision"
    pub data_b64: String,    // base64 encoded audio/image
}

#[post("/api/multimodal")]
async fn multimodal_handler(req: Json<MultimodalRequest>) -> Json<Value> {
    let result = match req.type_input.as_str() {
        "voice" => {
            let audio_bytes = base64::decode(&req.data_b64).unwrap_or_default();
            let ctx = WhisperContext::new("ggml-base.vi.bin").unwrap();  // Vietnamese model
            let mut state = ctx.create_state().unwrap();
            state.full(FullParams::default(), &audio_bytes).unwrap();
            let text = state.full_get_segment_text(0).unwrap_or("Không nhận diện giọng nói".to_string());
            text
        },
        "vision" => {
            let image_bytes = base64::decode(&req.data_b64).unwrap_or_default();
            let model = ClipModel::load("ViT-B-32").unwrap();  // Vietnamese CLIP
            let image = ImageProcessor::process(&image_bytes).unwrap();
            let caption = model.generate_caption(&image, "Mô tả ảnh này bằng tiếng Việt chi tiết");
            caption
        },
        _ => "Loại input không hỗ trợ".to_string(),
    };
    Json(json!({"response": result, "type": req.type_input}))
}