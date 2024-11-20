use std::io;
use std::io::BufRead;
use std::process::{Command, Stdio};
use std::sync::Arc;
use bytes::Bytes;
use tokio::sync::{mpsc, Mutex};
use warp::Filter;
use crate::service::hub::{start, stop};

const LISTEN_PORT: u16 = 47890;

pub struct ProcessManager {
    process: Arc<Mutex<Option<std::process::Child>>>,
}

impl ProcessManager {
    pub fn new() -> Self {
        ProcessManager {
            process: Arc::new(Mutex::new(None)),
        }
    }

    pub async fn start(&self, path: String) -> String {
        self.stop().await;
        let (tx, mut rx) = mpsc::channel::<String>(1);
        let mut process = self.process.lock().await;
        *process = Some(Command::new(path)
            .stdout(Stdio::piped())
            .spawn().unwrap());
        if let Some(ref mut child) = *process {
            let stdout = child.stdout.take().unwrap();
            let reader = io::BufReader::new(stdout);
            for line in reader.lines() {
                match line {
                    Ok(output) => {
                        if let Some(port) = output.split("[port]: ").nth(1) {
                            let port = port.trim().to_string();
                            tx.send(port).await.unwrap();
                            break;
                        }
                    }
                    Err(_) => {
                        tx.send(String::new()).await.unwrap();
                        break;
                    }
                }
            }
        } else {
            tx.send(String::new()).await.unwrap();
        }
        rx.recv().await.unwrap_or_else(|| String::new())
    }

    pub async fn stop(&self) {
        let mut process = self.process.lock().await;
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
        .map(||"");

    let api_start = warp::post()
        .and(warp::path("start"))
        .and(warp::body::bytes())
        .and_then({
            let process_manager = Arc::clone(&process_manager);
            move |body: Bytes| {
                let process_manager = Arc::clone(&process_manager);
                let path = String::from_utf8_lossy(&body).to_string();
                start(process_manager, path)
            }
        });

    let api_stop = warp::post()
        .and(warp::path("stop"))
        .and_then({
            let process_manager = Arc::clone(&process_manager);
            move || {
                let process_manager = Arc::clone(&process_manager);
                stop(process_manager)
            }
        });

    warp::serve(
        api_ping.or(api_start.or(api_stop))
    )
        .run(([127, 0, 0, 1], LISTEN_PORT))
        .await;

    Ok(())
}