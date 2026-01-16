#!/usr/bin/env bash

# Change directory to script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || { echo "Could not cd to $SCRIPT_DIR"; exit 1; }

docker compose run --rm ansible
