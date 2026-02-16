#!/usr/bin/env bash
set -euo pipefail

if ! command -v nix &> /dev/null; then
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install --no-confirm
fi
echo "Nix installed."

# Allow bwrap (used by steam-run/buildFHSEnv) to create user namespaces
# Required on Ubuntu 24.04+ which restricts unprivileged user namespaces via AppArmor
if [ -f /proc/sys/kernel/apparmor_restrict_unprivileged_userns ]; then
  cat > /etc/apparmor.d/bwrap <<'EOF'
abi <abi/4.0>,
include <tunables/global>
profile bwrap /nix/store/**/bwrap flags=(unconfined) {
  userns,
}
EOF
  apparmor_parser -r /etc/apparmor.d/bwrap
  echo "AppArmor profile for bwrap installed."
fi
