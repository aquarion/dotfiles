#!/bin/bash

if [[ -f "$(git root)/.github/super-linter.local.env" ]]; then
	echo "Using local super-linter env file"
	ENVFILE="--env-file $(git root)/.github/super-linter.local.env"
fi

LOG_LEVEL=${LOG_LEVEL:-"INFO"}
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

docker run \
	-e DEFAULT_BRANCH="$GIT_BRANCH" \
	-e LOG_LEVEL="$LOG_LEVEL" \
	-e SAVE_SUPER_LINTER_SUMMARY=true \
	-e RUN_LOCAL=true \
	-v "$PWD":/tmp/lint $ENVFILE \
	--platform linux/amd64 \
	ghcr.io/super-linter/super-linter:slim-latest

SCRIPT_PATH=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
if [[ ! -f "$SCRIPT_DIR/process_superlinter.sh" ]]; then
	echo "Error: process_superlinter.sh not found in $SCRIPT_DIR" >&2
	exit 1
fi

bash "$SCRIPT_DIR/process_superlinter.sh"
