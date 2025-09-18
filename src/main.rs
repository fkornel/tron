mod middleware;

use std::env;
use std::net::SocketAddr;

use axum::{
    routing::get,
    Router,
    http::{Request, StatusCode, Response},
    response::IntoResponse,
};
use hyper::Body;

use crate::middleware::logging;

async fn root_handler(req: Request<Body>) -> impl IntoResponse {
    logging::log_request_info(req.method().as_str(), req.uri().path());
    let body = tron::greeting();
    let resp = Response::builder()
        .status(StatusCode::OK)
        .header("Content-Type", "text/plain")
        .body(Body::from(body))
        .unwrap();
    resp
}

async fn health_handler(req: Request<Body>) -> impl IntoResponse {
    logging::log_request_info(req.method().as_str(), req.uri().path());
    let resp = Response::builder()
        .status(StatusCode::OK)
        .header("Content-Type", "text/plain")
        .body(Body::from("OK"))
        .unwrap();
    resp
}

#[tokio::main]
async fn main() {
    let port: u16 = env::var("PORT").ok().and_then(|s| s.parse().ok()).unwrap_or(8080);
    let addr = SocketAddr::from(([0, 0, 0, 0], port));

    let app = Router::new()
        .route("/", get(root_handler))
        .route("/health", get(health_handler));

    println!("Listening on {}", addr);
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .expect("server failed");
}
