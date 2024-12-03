use std::process::{Command};
use std::sync::{Arc, Mutex};
use warp::Filter;
use serde::{Deserialize, Serialize};

const LISTEN_PORT: u16 = 47890;

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct StartParams {
    pub path: String,
    pub arg: String,
}

pub struct ProcessManager {
    process: Arc<Mutex<Option<std::process::Child>>>,
}

impl ProcessManager {
    pub fn new() -> Self {
        ProcessManager {
            process: Arc::new(Mutex::new(None)),
        }
    }

    pub fn start(&self, start_params: StartParams) {
        self.stop();
        let mut process = self.process.lock().unwrap();
        *process = Some(Command::new(&start_params.path)
            .arg(&start_params.arg)
            .spawn().unwrap());
    }

    pub fn stop(&self) {
        let mut process = self.process.lock().unwrap();
        if let Some(mut child) = process.take() {
            let _ = child.kill();
            let _ = child.wait();
        }
        *process = None;
    }
}

pub async fn run_service() -> anyhow::Result<()> {
    let process_manager = Arc::new(ProcessManager::new());

    let api_ping = warp::get()
        .and(warp::path("ping"))
        .map(|| "2024121");

    let api_start = warp::post()
        .and(warp::path("start"))
        .and(warp::body::json())
        .map({
            let process_manager = Arc::clone(&process_manager);
            move |start_params: StartParams| {
                let process_manager = Arc::clone(&process_manager);
                process_manager.start(start_params);
                ""
            }
        });

    let api_stop = warp::post()
        .and(warp::path("stop"))
        .map({
            let process_manager = Arc::clone(&process_manager);
            move || {
                let process_manager = Arc::clone(&process_manager);
                process_manager.stop();
                ""
            }
        });

    warp::serve(
        api_ping.or(api_start.or(api_stop))
    )
        .run(([127, 0, 0, 1], LISTEN_PORT))
        .await;

    Ok(())
}