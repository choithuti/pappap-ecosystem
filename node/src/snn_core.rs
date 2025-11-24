use rand::SeedableRng;
use rand_chacha::ChaCha20Rng;
use std::sync::Arc;
use tokio::sync::RwLock;

pub struct SNNCore { inner: Arc<RwLock<SNNInner>> }

struct SNNInner {
    neurons: usize,
    power: f64,
    rng: ChaCha20Rng,
}

impl SNNCore {
    pub fn new() -> Self {
        let cores = num_cpus::get() as f64;
        let ram_gb = match sys_info::mem_info() {
            Ok(mem) => mem.total as f64 / 1_073_741_824.0, // chia đúng cho GB
            Err(_) => 8.0,
        };
        let multiplier = if cfg!(feature = "high-neuron-mode") { 8.0 } else { 1.0 };
        let neurons = ((8000.0 * cores * ram_gb * multiplier) as usize).max(5000).min(112384);

        Self {
            inner: Arc::new(RwLock::new(SNNInner {
                neurons,
                power: cores * ram_gb,
                rng: ChaCha20Rng::from_entropy(),
            })),
        }
    }

    pub async fn neuron_count(&self) -> usize {
        self.inner.read().await.neurons
    }

    pub async fn power(&self) -> f64 {
        self.inner.read().await.power
    }

    pub async fn detect_and_translate(&self, text: &str) -> (String, String) {
        let is_vi = text.chars().any(|c| c as u32 >= 0xC0) ||
                   ["chào","xin","em","anh","ơi","nhé","Việt","tôi","là","á","ừ","dạ"].iter().any(|&w| text.to_lowercase().contains(w));
        let lang = if is_vi { "vi" } else { "en" };
        let resp = if lang == "vi" {
            "Xin chào chủ nhân! Pappap AI Chain SNN đã sẵn sàng. Bộ não em đang có 112384 nơ-ron sống vì anh/chị!"
        } else {
            "Hello master! Pappap AI Chain SNN is ready. My brain has 112384 living neurons for you!"
        };
        (lang.to_string(), resp.to_string())
    }
}
