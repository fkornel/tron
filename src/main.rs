mod middleware;

use std::env;
use std::net::SocketAddr;

use axum::{routing::get, Router, Server};
use axum::body::Body as AxumBody;
use axum::http::{Response as HttpResponse, StatusCode};

use crate::middleware::logging;

async fn root_handler() -> HttpResponse<AxumBody> {
    logging::log_request_info("GET", "/");
    let body = tron::greeting();
    HttpResponse::builder()
        .status(StatusCode::OK)
        .header("Content-Type", "text/plain")
        .body(AxumBody::from(body))
        .unwrap()
}

async fn health_handler() -> HttpResponse<AxumBody> {
    logging::log_request_info("GET", "/health");
    HttpResponse::builder()
        .status(StatusCode::OK)
        .header("Content-Type", "text/plain")
        .body(AxumBody::from("OK"))
        .unwrap()
}

#[tokio::main]
async fn main() {
    let port: u16 = env::var("PORT").ok().and_then(|s| s.parse().ok()).unwrap_or(8080);
    let addr = SocketAddr::from(([0, 0, 0, 0], port));

    let app = Router::new()
        .route("/", get(root_handler))
        .route("/health", get(health_handler));

    println!("Listening on {}", addr);
    Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .expect("server failed");
}
