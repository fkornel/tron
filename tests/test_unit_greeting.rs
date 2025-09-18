use tron::greeting;

#[test]
fn greeting_returns_hello_world() {
    assert_eq!(greeting(), "Hello World");
}
