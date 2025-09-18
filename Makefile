SHELL := /usr/bin/env bash

# Convenience Makefile wrapping the existing dev.sh helper
# Targets: build-image, run, test, clean

TRON_IMG ?= tron-dev:001
DOCKERFILE ?= Dockerfile
WORKDIR ?= /workspace
DOCKER_BUILD_ARGS ?=
DOCKER_RUN_OPTS ?=
ARGS ?=

.PHONY: all help build-image run test clean

all: help

help:
	@echo "Usage: make <target> [ARGS=\"...\"]"
	@echo ""
	@echo "Targets:"
	@echo "  build-image    Build the development image (calls dev.sh build)"
	@echo "  run            Run 'cargo run' in the dev image (pass ARGS for the binary)"
	@echo "  test           Run 'cargo test' in the dev image (pass ARGS to cargo)"
	@echo "  clean          Remove the dev image"
	@echo ""
	@echo "Variables:"
	@echo "  TRON_IMG       image name (default: $(TRON_IMG))"
	@echo "  DOCKERFILE     Dockerfile path (default: $(DOCKERFILE))"
	@echo "  ARGS           Extra args to pass to run/test"

build-image:
	@echo "Building image '$(TRON_IMG)' from '$(DOCKERFILE)'..."
	@bash ./dev.sh build

run:
	@echo "Running 'cargo run' in '$(TRON_IMG)'..."
	@bash ./dev.sh run $(ARGS)

test:
	@echo "Running 'cargo test' in '$(TRON_IMG)'..."
	@bash ./dev.sh test $(ARGS)

clean:
	@echo "Removing image '$(TRON_IMG)'..."
	@bash ./dev.sh clean
