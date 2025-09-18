mod middleware;

use std::env;
use std::net::SocketAddr;

use axum::{routing::get, Router};

use crate::middleware::logging;

async fn root_handler() -> &'static str {
    logging::log_request_info("GET", "/");
    tron::greeting()
}

async fn health_handler() -> &'static str {
    logging::log_request_info("GET", "/health");
    "OK"
}

#[tokio::main]
async fn main() {
    let port: u16 = env::var("PORT").ok().and_then(|s| s.parse().ok()).unwrap_or(8080);
    let addr = SocketAddr::from(([0, 0, 0, 0], port));

    let app = Router::new().route("/", get(root_handler)).route("/health", get(health_handler));

    println!("Listening on {}", addr);
    let listener = tokio::net::TcpListener::bind(addr).await.expect("failed to bind");
    axum::serve(listener, app).await.expect("server failed");
}
