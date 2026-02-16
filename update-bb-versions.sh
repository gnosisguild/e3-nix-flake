#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:?Usage: $0 <version>}"
VERSIONS_FILE="bb.versions.json"
PLATFORMS=("amd64-linux" "arm64-linux" "amd64-darwin" "arm64-darwin")
BASE_URL="https://github.com/AztecProtocol/aztec-packages/releases/download/v${VERSION}"

# Ensure versions.json exists
if [ ! -f "$VERSIONS_FILE" ]; then
  echo '{}' > "$VERSIONS_FILE"
fi

hashes="{}"
for plat in "${PLATFORMS[@]}"; do
  url="${BASE_URL}/barretenberg-${plat}.tar.gz"
  echo "Prefetching ${plat}..."
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
