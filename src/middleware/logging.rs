use std::time::SystemTime;
use std::net::TcpStream;

/// Log a basic request line (method and path) and timestamp to stdout.
///
/// This is a minimal, side-effect-only helper used by the simple TCP server.
/// It reads the request bytes up to the first CRLF and attempts to extract a
/// method and path for logging. If parsing fails, it logs the raw request
/// start. This must not change the response body.
pub fn log_request(stream: &TcpStream, request_bytes: &[u8]) {
    let ts = SystemTime::now();
    let prefix = match request_bytes.splitn(2, |b| *b == b'\r').next() {
        Some(line) => line,
        None => request_bytes,
    };

    // Try to parse "METHOD /path HTTP/1.1"
    let parts: Vec<&[u8]> = prefix.split(|b| *b == b' ').collect();
    let method = parts.get(0).map(|s| String::from_utf8_lossy(s)).unwrap_or_else(|| "UNKNOWN".into());
    let path = parts.get(1).map(|s| String::from_utf8_lossy(s)).unwrap_or_else(|| "UNKNOWN".into());

    println!("[{}] {} {}", humantime::format_rfc3339(ts), method, path);
}
