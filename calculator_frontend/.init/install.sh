#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-323487-323496/calculator_frontend"
INSTALL_DIR="/opt/swift"
TMP=$(mktemp -d)
cd "$TMP"
# minimal runtime deps
sudo apt-get update -qq && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends curl ca-certificates xz-utils libatomic1 >/dev/null
# primary and fallbacks
SWIFT_PRIMARY="5.9.4"
FALLBACKS=("5.9.4" "5.9.3" "5.9.0" "5.8.5")
BASE_URL="https://download.swift.org/swift"
# if already installed and matches one of our candidates, skip
if [ -x "$INSTALL_DIR/usr/bin/swift" ]; then
  INST_VER=$($INSTALL_DIR/usr/bin/swift --version 2>/dev/null | awk '/Swift version/ {print $3; exit}' || true)
  for v in "${FALLBACKS[@]}"; do [ "$INST_VER" = "$v" ] && { echo "swift $INST_VER already installed"; rm -rf "$TMP"; exit 0; }; done
fi
SUCCESS=0
for SWIFT_VERSION in "${FALLBACKS[@]}"; do
  RELEASE_DIR="$BASE_URL/${SWIFT_VERSION}-release"
  LIST_URL="$RELEASE_DIR/"
  HTML=$(curl -fsS --retry 2 "$LIST_URL" || true)
  [ -n "$HTML" ] || continue
  TARBALL=$(printf "%s" "$HTML" | grep -oP 'swift-[^\"\'> ]+ubuntu24.04.tar.gz' | head -n1 || true)
  if [ -z "$TARBALL" ]; then
    TARBALL=$(printf "%s" "$HTML" | grep -oP 'swift-[^\"\'> ]+ubuntu24.04[^\"\'> ]*\.tar\.gz' | head -n1 || true)
  fi
  [ -n "$TARBALL" ] || continue
  TARBALL_URL="$RELEASE_DIR/$TARBALL"
  # download tarball
  curl --retry 3 --retry-delay 2 -fsS -O "$TARBALL_URL" || { rm -f "$TARBALL"; continue; }
  # grab possible checksum files
  for SUMNAME in SHA256SUMS sha256sums.txt SHA256SUMS.txt; do
    curl --retry 3 --retry-delay 2 -fsS -O "$RELEASE_DIR/$SUMNAME" || true
  done
  MATCH_LINE=$(grep -h "$TARBALL" SHA256SUMS* 2>/dev/null | head -n1 || true)
  if [ -z "$MATCH_LINE" ]; then
    rm -f "$TARBALL" SHA256SUMS* || true
    continue
  fi
  CHECKFILE="${TMP}/${TARBALL}.sha256"
  echo "$MATCH_LINE" | awk '{print $1 "  " $2}' > "$CHECKFILE"
  sha256sum -c "$CHECKFILE" >/dev/null || { rm -f "$TARBALL" SHA256SUMS* "$CHECKFILE"; continue; }
  EXTRACT_DIR="${TMP}/swift-extract"
  mkdir -p "$EXTRACT_DIR"
  tar -xzf "$TARBALL" -C "$EXTRACT_DIR" --strip-components=1
  sudo rm -rf "${INSTALL_DIR}.old" || true
  if [ -d "$INSTALL_DIR" ]; then sudo mv "$INSTALL_DIR" "${INSTALL_DIR}.old"; fi
  sudo mv "$EXTRACT_DIR" "$INSTALL_DIR"
  sudo rm -rf "${INSTALL_DIR}.old" || true
  sudo tee /etc/profile.d/swift.sh >/dev/null <<'EOF'
# Swift toolchain
export PATH=/opt/swift/usr/bin:${PATH}
export CI=true
export DEBIAN_FRONTEND=noninteractive
EOF
  sudo chmod +x /etc/profile.d/swift.sh
  export PATH=/opt/swift/usr/bin:${PATH}
  SUCCESS=1
  break
done
rm -rf "$TMP"
if [ "$SUCCESS" -ne 1 ]; then
  echo "ERROR: failed to find/verify a compatible swift toolchain. Tried: ${FALLBACKS[*]}" >&2
  exit 10
fi
command -v swift >/dev/null 2>&1 || { echo "ERROR: swift not on PATH after install" >&2; exit 11; }
command -v swiftc >/dev/null 2>&1 || { echo "ERROR: swiftc not found" >&2; exit 12; }
swift --version || true
