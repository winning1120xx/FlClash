use std::sync::{Arc};
use crate::service::service::ProcessManager;

pub async fn start(process_manager: Arc<ProcessManager>, path: String) -> Result<impl warp::Reply, warp::Rejection> {
    let port = process_manager.start(path).await;
    Ok(port.to_string())
}

pub async fn stop(process_manager: Arc<ProcessManager>) -> Result<impl warp::Reply, warp::Rejection> {
    process_manager.stop().await;
    Ok("".to_string())
}