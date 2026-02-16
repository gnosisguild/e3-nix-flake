#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:?Usage: $0 <version>}"
VERSIONS_FILE="enclave.versions.json"
PLATFORMS=("linux-x86_64" "macos-aarch64")
BASE_URL="https://github.com/gnosisguild/enclave/releases/download/v${VERSION}"

# Ensure versions.json exists
if [ ! -f "$VERSIONS_FILE" ]; then
  echo '{}' > "$VERSIONS_FILE"
fi

hashes="{}"
for plat in "${PLATFORMS[@]}"; do
  url="${BASE_URL}/enclave-${plat}.tar.gz"
  echo "Prefetching ${plat}..."
  echo ${url}
  sri=$(nix-prefetch-url --unpack --type sha256 "$url" 2>/dev/null)
  # Convert to SRI hash
  sri_hash=$(nix hash to-sri --type sha256 "$sri")
  hashes=$(echo "$hashes" | jq --arg p "$plat" --arg h "$sri_hash" '. + {($p): $h}')
  echo "  ${plat}: ${sri_hash}"
done

# Merge into versions.json
jq --arg v "$VERSION" --argjson h "$hashes" '. + {($v): $h}' "$VERSIONS_FILE" \
  > "${VERSIONS_FILE}.tmp" && mv "${VERSIONS_FILE}.tmp" "$VERSIONS_FILE"

echo ""
echo "Updated ${VERSIONS_FILE} with ${VERSION}"
