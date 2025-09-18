# Contracts for Devcontainer With Rust Toolchain And Hello World

This directory contains the contract describing the expected behavior of the starter application and a contract test script that runs the app inside the dev image and asserts the expected output.

Contract: `hello-run` - Running the app must produce exactly the string `Hello world` on stdout and exit with code 0.

Test script: `contracts/tests/test_hello_run.sh` - executes the contract test in a container.
