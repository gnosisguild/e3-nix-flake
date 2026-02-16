#!/usr/bin/env bash

# Run this update script when publishing a new version combination

set -euo pipefail

ENCLAVE_VERSION="${1:?Usage: $0 <enclave-version> <bb-version>}"
BB_VERSION="${2:?Usage: $0 <enclave-version> <bb-version>}"

DEP_LOCK_FILE="./versions/dep.lock.json"
BB_VERSIONS_FILE="./versions/bb.versions.json"
ENCLAVE_VERSIONS_FILE="./versions/enclave.versions.json"

BB_PLATFORMS=("amd64-linux" "arm64-linux" "amd64-darwin" "arm64-darwin")
ENCLAVE_PLATFORMS=("linux-x86_64" "macos-aarch64")

BB_BASE_URL="https://github.com/AztecProtocol/aztec-packages/releases/download/v${BB_VERSION}"
ENCLAVE_BASE_URL="https://github.com/gnosisguild/enclave/releases/download/v${ENCLAVE_VERSION}"

# Ensure JSON files exist
for f in "$DEP_LOCK_FILE" "$BB_VERSIONS_FILE" "$ENCLAVE_VERSIONS_FILE"; do
  [ -f "$f" ] || echo '{}' > "$f"
done

# Prefetch barretenberg
echo "=== Fetching barretenberg ${BB_VERSION} ==="
bb_hashes="{}"
for plat in "${BB_PLATFORMS[@]}"; do
  url="${BB_BASE_URL}/barretenberg-${plat}.tar.gz"
  echo "Prefetching ${plat}..."
  sri=$(nix-prefetch-url --type sha256 "$url" 2>/dev/null)
  sri_hash=$(nix hash to-sri --type sha256 "$sri")
  bb_hashes=$(echo "$bb_hashes" | jq --arg p "$plat" --arg h "$sri_hash" '. + {($p): $h}')
  echo "  ${plat}: ${sri_hash}"
done

# Prefetch enclave
echo ""
echo "=== Fetching enclave ${ENCLAVE_VERSION} ==="
enclave_hashes="{}"
for plat in "${ENCLAVE_PLATFORMS[@]}"; do
  url="${ENCLAVE_BASE_URL}/enclave-${plat}.tar.gz"
  echo "Prefetching ${plat}..."
  sri=$(nix-prefetch-url --type sha256 "$url" 2>/dev/null)
  sri_hash=$(nix hash to-sri --type sha256 "$sri")
  enclave_hashes=$(echo "$enclave_hashes" | jq --arg p "$plat" --arg h "$sri_hash" '. + {($p): $h}')
  echo "  ${plat}: ${sri_hash}"
done

# Update bb.versions.json
jq --arg v "$BB_VERSION" --argjson h "$bb_hashes" '. + {($v): $h}' "$BB_VERSIONS_FILE" \
  > "${BB_VERSIONS_FILE}.tmp" && mv "${BB_VERSIONS_FILE}.tmp" "$BB_VERSIONS_FILE"
echo ""
echo "Updated ${BB_VERSIONS_FILE} with ${BB_VERSION}"

# Update enclave.versions.json
jq --arg v "$ENCLAVE_VERSION" --argjson h "$enclave_hashes" '. + {($v): $h}' "$ENCLAVE_VERSIONS_FILE" \
  > "${ENCLAVE_VERSIONS_FILE}.tmp" && mv "${ENCLAVE_VERSIONS_FILE}.tmp" "$ENCLAVE_VERSIONS_FILE"
echo "Updated ${ENCLAVE_VERSIONS_FILE} with ${ENCLAVE_VERSION}"

# Update dep.lock.json
jq --arg ev "$ENCLAVE_VERSION" --arg bv "$BB_VERSION" '. + {($ev): {bb: $bv}}' "$DEP_LOCK_FILE" \
  > "${DEP_LOCK_FILE}.tmp" && mv "${DEP_LOCK_FILE}.tmp" "$DEP_LOCK_FILE"
echo "Updated ${DEP_LOCK_FILE}: enclave ${ENCLAVE_VERSION} -> bb ${BB_VERSION}"

# Update template/flake.nix
sed -i.bak 's/\(e3\.packages\.\${system}\.\)"[0-9.]*"/\1"'"${ENCLAVE_VERSION}"'"/' "$TEMPLATE_FLAKE_FILE" && rm -f "${TEMPLATE_FLAKE_FILE}.bak"
echo "Updated ${TEMPLATE_FLAKE_FILE} with enclave ${ENCLAVE_VERSION}"

echo ""
echo "Done!"
