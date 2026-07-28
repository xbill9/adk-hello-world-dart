#!/usr/bin/env bash

if (return 0 2>/dev/null); then
  IS_SOURCED=true
else
  IS_SOURCED=false
fi

if [[ "$IS_SOURCED" == "false" ]]; then
  set -euo pipefail
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
cd "$SCRIPT_DIR"

dart pub get

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created .env from .env.example. Add your credentials before running the agent."
else
  echo "Kept the existing .env file."
fi

if [[ "$IS_SOURCED" == "true" ]] && [[ -f set_env.sh ]]; then
  # shellcheck disable=SC1091
  source ./set_env.sh
fi

echo "Setup complete. Run: dart run bin/server.dart or ./run.sh"
