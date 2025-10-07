#!/usr/bin/env bash
set -euo pipefail
: "${REPO_WIN_PATH:?Set REPO_WIN_PATH in .env}"
: "${RUNNER:?Set RUNNER in .env}"

cd "$REPO_WIN_PATH"
chmod +x "./$RUNNER"
"./$RUNNER"
