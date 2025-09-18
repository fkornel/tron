use std::time::SystemTime;

/// Log a basic request line (method and path) and timestamp to stdout.
/// This helper is HTTP-aware and used by the axum-based server.
pub fn log_request_info(method: &str, path: &str) {
    let ts = SystemTime::now();
    println!("[{}] {} {}", humantime::format_rfc3339(ts), method, path);
}
