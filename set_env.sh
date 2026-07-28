#!/usr/bin/env bash

# Source this file only when shell commands need the values from .env.
set -a
# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/.env"
set +a
