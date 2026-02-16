#!/usr/bin/env bash
set -euo pipefail

if ! command -v nix &> /dev/null; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

command -v direnv &> /dev/null || nix profile install nixpkgs#direnv
nix profile list | grep -q nix-direnv || nix profile add nixpkgs#nix-direnv

grep -qF 'eval "$(direnv hook bash)"' ~/.bashrc 2>/dev/null || \
  echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

mkdir -p ~/.config/direnv
DIRENVRC='source $HOME/.nix-profile/share/nix-direnv/direnvrc'
grep -qF "$DIRENVRC" ~/.config/direnv/direnvrc 2>/dev/null || \
  echo "$DIRENVRC" >> ~/.config/direnv/direnvrc

echo "Done. Run: source ~/.bashrc"
