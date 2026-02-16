#!/usr/bin/env bash
set -euo pipefail

# Install Determinate Nix (installer handles already-installed case)
if ! command -v nix &> /dev/null; then
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install --no-confirm
fi

# Source nix in current shell if not already available
if ! command -v nix &> /dev/null; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Install direnv and nix-direnv if not already present
command -v direnv &> /dev/null || nix profile install nixpkgs#direnv
nix profile list | grep -q nix-direnv || nix profile install nixpkgs#nix-direnv

# Hook direnv into bash
grep -qF 'eval "$(direnv hook bash)"' ~/.bashrc 2>/dev/null || \
  echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

# Configure direnv to use nix-direnv
mkdir -p ~/.config/direnv
DIRENVRC='source $HOME/.nix-profile/share/nix-direnv/direnvrc'
grep -qF "$DIRENVRC" ~/.config/direnv/direnvrc 2>/dev/null || \
  echo "$DIRENVRC" >> ~/.config/direnv/direnvrc

echo "Done. Run: source ~/.bashrc"
