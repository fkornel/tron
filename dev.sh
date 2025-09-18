#!/usr/bin/env bash
set -euo pipefail

PROG_NAME="$(basename "$0")"
TRON_IMG="${TRON_IMG:-tron-dev:001}"
DOCKERFILE="${DOCKERFILE:-Dockerfile}"
WORKDIR="${WORKDIR:-/workspace}"
DOCKER_RUN_OPTS="${DOCKER_RUN_OPTS:-}"
DOCKER_BUILD_ARGS="${DOCKER_BUILD_ARGS:-}"

usage() {
  cat <<EOF
Usage: $PROG_NAME <command> [args]

Commands:
  build         Build the dev Docker image (uses ${DOCKERFILE})
  run [args]    Run 'cargo run' inside the dev image (extra args passed to the binary)
  test [args]   Run 'cargo test' inside the dev image
  shell         Open an interactive shell in the dev image
  exec <cmd>    Run arbitrary command inside the dev image
  clean         Remove the dev image (${TRON_IMG})
  help          Show this message

Environment variables:
  TRON_IMG        image name (default: ${TRON_IMG})
  DOCKERFILE      Dockerfile path (default: ${DOCKERFILE})
  DOCKER_RUN_OPTS extra options passed to 'docker run' (default: empty)
  DOCKER_BUILD_ARGS extra args for 'docker build' (default: empty)
EOF
}

if [ "$#" -lt 1 ]; then
  usage
  exit 1
fi

cmd="$1"; shift

case "$cmd" in
  build)
    echo "Building image '$TRON_IMG' from '$DOCKERFILE'..."
    docker build -t "$TRON_IMG" -f "$DOCKERFILE" $DOCKER_BUILD_ARGS .
    ;;

  run)
    echo "Running 'cargo run' in '$TRON_IMG'..."
    if [ "$#" -gt 0 ]; then
      # pass args after -- to the binary
      docker run --rm -v "$PWD":"$WORKDIR" -w "$WORKDIR" $DOCKER_RUN_OPTS "$TRON_IMG" cargo run --quiet -- "$@"
    else
      docker run --rm -v "$PWD":"$WORKDIR" -w "$WORKDIR" $DOCKER_RUN_OPTS "$TRON_IMG" cargo run --quiet
    fi
    ;;

  test)
    echo "Running 'cargo test' in '$TRON_IMG'..."
    docker run --rm -v "$PWD":"$WORKDIR" -w "$WORKDIR" $DOCKER_RUN_OPTS "$TRON_IMG" cargo test --quiet "$@"
    ;;

  shell)
    echo "Opening shell in '$TRON_IMG'..."
    docker run --rm -it -v "$PWD":"$WORKDIR" -w "$WORKDIR" $DOCKER_RUN_OPTS --entrypoint /bin/bash "$TRON_IMG"
    ;;

  exec)
    if [ "$#" -eq 0 ]; then
      echo "exec requires a command to run"
      usage
      exit 1
    fi
    echo "Running command in '$TRON_IMG': $*"
    docker run --rm -v "$PWD":"$WORKDIR" -w "$WORKDIR" $DOCKER_RUN_OPTS "$TRON_IMG" "$@"
    ;;

  clean)
    echo "Removing image '$TRON_IMG'..."
    docker image rm -f "$TRON_IMG"
    ;;

  help|-h|--help)
    usage
    ;;

  *)
    echo "Unknown command: $cmd"
    usage
    exit 2
    ;;
esac
