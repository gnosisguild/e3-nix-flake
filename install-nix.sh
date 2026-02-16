#!/usr/bin/env bash
set -euo pipefail

if ! command -v nix &> /dev/null; then
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install --no-confirm
fi

echo "Nix installed."
