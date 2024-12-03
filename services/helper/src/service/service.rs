use std::collections::VecDeque;
use std::io;
use std::io::BufRead;
use std::process::{Command, Stdio};
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
    logs: Arc<Mutex<VecDeque<String>>>,
}

impl ProcessManager {
    pub fn new() -> Self {
        ProcessManager {
            process: Arc::new(Mutex::new(None)),
            logs: Arc::new(Mutex::new(VecDeque::with_capacity(200))),
        }
    }

    fn log_message(&self, message: String) {
        let mut log_buffer = self.logs.lock().unwrap();
        if log_buffer.len() == 100 {
            log_buffer.pop_front();
        }
        log_buffer.push_back(format!("{}\n", message));
    }

    pub fn start(&self, start_params: StartParams) {
        self.stop();
        let mut process = self.process.lock().unwrap();

        *process = Some(
            Command::new(&start_params.path)
                .stderr(Stdio::piped())
                .arg(&start_params.arg)
                .spawn()
                .expect("Failed to spawn process")
        );

        if let Some(ref mut child) = *process {
            let stderr = child.stderr.take().unwrap();
            let reader = io::BufReader::new(stderr);
            for line in reader.lines() {
                match line {
                    Ok(output) => {
                        self.log_message(output)
                    }
                    Err(_) => {
                        break;
                    }
                }
            }
        }
    }

    pub fn stop(&self) {
        let mut process = self.process.lock().unwrap();
        if let Some(mut child) = process.take() {
            let _ = child.kill();
            let _ = child.wait();
        }
        *process = None;
    }

    pub fn get_logs(&self) -> Vec<String> {
        let log_buffer = self.logs.lock().unwrap();
        log_buffer.iter().cloned().collect()
    }
}

pub async fn run_service() -> anyhow::Result<()> {
    let process_manager = Arc::new(ProcessManager::new());

    let api_ping = warp::get()
        .and(warp::path("ping"))
        .map(|| "2024124");

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

    let api_logs = warp::get()
        .and(warp::path("logs"))
        .map({
            let process_manager = Arc::clone(&process_manager);
            move || {
                let process_manager = Arc::clone(&process_manager);
                warp::reply::json(&process_manager.get_logs())
            }
        });

    warp::serve(
        api_ping
            .or(api_start)
            .or(api_stop)
            .or(api_logs)
    )
        .run(([127, 0, 0, 1], LISTEN_PORT))
        .await;

    Ok(())
}