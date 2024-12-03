mod windows;
mod service;

#[cfg(not(windows))]
use crate::service::service::run_service;

#[cfg(not(windows))]
use tokio::runtime::Runtime;

#[cfg(not(windows))]
pub fn main() {
    if let Ok(rt) = Runtime::new() {
        rt.block_on(async {
            let _ = run_service().await;
        });
    }
}

#[cfg(windows)]
use windows_service::Result;
#[cfg(windows)]
use crate::service::windows::start_service;

#[cfg(windows)]
pub fn main() -> Result<()> {
    start_service()
}






