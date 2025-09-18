use axum::{body::Body, http::Request, routing::get, Router};
use tower::ServiceExt;
use tron::greeting;

#[tokio::test]
async fn post_to_root_returns_405() {
    let app = Router::new()
        .route("/", get(|| async { greeting() }))
        .route("/health", get(|| async { "OK" }));

    let req = Request::builder()
        .method("POST")
        .uri("/")
        .body(Body::empty())
        .unwrap();

    let resp = app.oneshot(req).await.unwrap();
    assert_eq!(resp.status().as_u16(), 405);
}

#[tokio::test]
async fn unknown_path_returns_404() {
    let app = Router::new()
        .route("/", get(|| async { greeting() }))
        .route("/health", get(|| async { "OK" }));

    let req = Request::builder()
        .method("GET")
        .uri("/does-not-exist")
        .body(Body::empty())
        .unwrap();

    let resp = app.oneshot(req).await.unwrap();
    assert_eq!(resp.status().as_u16(), 404);
}
