#[cfg(windows)]
use std::ffi::OsString;

#[cfg(windows)]
use std::time::Duration;

#[cfg(windows)]
use tokio::runtime::Runtime;

#[cfg(windows)]
use windows_service::{
    define_windows_service,
    service::{
        ServiceControl, ServiceControlAccept, ServiceExitCode, ServiceState, ServiceStatus,
        ServiceType,
    },
    service_control_handler::{self, ServiceControlHandlerResult},
    service_dispatcher, Result,
};

#[cfg(windows)]
use crate::service::run_service;

#[cfg(windows)]
const SERVICE_TYPE: ServiceType = ServiceType::OWN_PROCESS;

#[cfg(windows)]
const SERVICE_NAME: &str = "FlClashHelperService";

#[cfg(windows)]
define_windows_service!(serveice, service_main);

#[cfg(windows)]
pub fn service_main(_arguments: Vec<OsString>) {
    if let Ok(rt) = Runtime::new() {
        rt.block_on(async {
            let _ = run_windows_service().await;
        });
    }
}

#[cfg(windows)]
async fn run_windows_service() -> anyhow::Result<()> {
    #[cfg(windows)]
    let status_handle = service_control_handler::register(
        SERVICE_NAME,
        move |event| -> ServiceControlHandlerResult {
            match event {
                ServiceControl::Interrogate => ServiceControlHandlerResult::NoError,
                ServiceControl::Stop => std::process::exit(0),
                _ => ServiceControlHandlerResult::NotImplemented,
            }
        },
    )?;

    #[cfg(windows)]
    status_handle.set_service_status(ServiceStatus {
        service_type: SERVICE_TYPE,
        current_state: ServiceState::Running,
        controls_accepted: ServiceControlAccept::STOP,
        exit_code: ServiceExitCode::Win32(0),
        checkpoint: 0,
        wait_hint: Duration::default(),
        process_id: None,
    })?;

    run_service().await
}

#[cfg(windows)]
pub fn start_service() -> Result<()> {
    service_dispatcher::start(SERVICE_NAME, serveice)
}