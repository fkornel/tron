use axum::{Router, routing::get, response::IntoResponse, http::HeaderMap};
use axum::Server;

#[tokio::main]
async fn main() {
    let port: u16 = std::env::var("PORT").ok().and_then(|s| s.parse().ok()).unwrap_or(8080);
    let addr = std::net::SocketAddr::from(([0, 0, 0, 0], port));

    let app = Router::new()
        .route("/", get(root_handler))
        .route("/health", get(health_handler));

    // Use hyper::Server::bind to run the axum app
    hyper::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .expect("server failed");
}

async fn root_handler() -> impl IntoResponse {
    let mut headers = HeaderMap::new();
    headers.insert("Content-Type", "text/plain; charset=utf-8".parse().unwrap());
    (headers, tron::greeting().to_string())
}

async fn health_handler() -> impl IntoResponse {
    (axum::http::StatusCode::OK, "OK")
}
