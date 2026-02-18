#!/usr/bin/env bash
set -euo pipefail
# Install pinned Swift toolchain to /opt/swift if missing
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-323487-323496/calculator_frontend"
SWIFT_VERSION="5.9.4"
BASE_DIR="https://download.swift.org"
RELEASE_INDEX="${BASE_DIR}/swift-${SWIFT_VERSION}-release/"
INSTALL_DIR="/opt/swift"
TMP=$(mktemp -d)
cd "$TMP"
# minimal runtime deps
sudo apt-get update -qq && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends curl ca-certificates libatomic1 >/dev/null
# if already installed and matches version, exit
if [ -x "${INSTALL_DIR}/usr/bin/swift" ]; then
  INSTALLED=$(${INSTALL_DIR}/usr/bin/swift --version 2>/dev/null || true)
  INST_VER=$(printf "%s" "$INSTALLED" | awk '/Swift version/ {print $3; exit}') || true
  if [ "$INST_VER" = "$SWIFT_VERSION" ]; then
    echo "swift ${SWIFT_VERSION} already installed in ${INSTALL_DIR}"
    rm -rf "$TMP" && exit 0
  fi
fi
# canonical tarball name for Ubuntu 24.04
TARBALL_CAND="swift-${SWIFT_VERSION}-RELEASE-ubuntu24.04.tar.gz"
TARBALL_URL="${RELEASE_INDEX}${TARBALL_CAND}"
# ensure tarball exists
if ! curl -sfI "$TARBALL_URL" >/dev/null; then
  echo "ERROR: swift tarball not found at ${TARBALL_URL}" >&2
  rm -rf "$TMP" && exit 2
fi
# download tarball and SHA256SUMS
curl --retry 3 --retry-delay 2 -fsS -O "$TARBALL_URL"
curl --retry 3 --retry-delay 2 -fsS -O "${RELEASE_INDEX}SHA256SUMS" || true
if [ ! -f "SHA256SUMS" ]; then
  echo "ERROR: SHA256SUMS not available at ${RELEASE_INDEX}" >&2
  rm -rf "$TMP" && exit 3
fi
# write checksum file in 'sha256  filename' format and verify
CHECKSUM_FILE="${TMP}/${TARBALL_CAND}.sha256"
grep "${TARBALL_CAND}" SHA256SUMS | awk '{print $1 "  " $2}' > "$CHECKSUM_FILE" || true
if [ ! -s "$CHECKSUM_FILE" ]; then
  echo "ERROR: checksum entry for ${TARBALL_CAND} not found in SHA256SUMS" >&2
  rm -rf "$TMP" && exit 4
fi
sha256sum -c "$CHECKSUM_FILE" || { echo "ERROR: checksum mismatch for ${TARBALL_CAND}" >&2; rm -rf "$TMP"; exit 5; }
# atomic extract to INSTALL_DIR
EXTRACT_DIR="${TMP}/swift-extract"
mkdir -p "$EXTRACT_DIR"
tar -xzf "$TARBALL_CAND" -C "$EXTRACT_DIR" --strip-components=1
sudo rm -rf "${INSTALL_DIR}.old" || true
if [ -d "$INSTALL_DIR" ]; then sudo mv "$INSTALL_DIR" "${INSTALL_DIR}.old"; fi
sudo mv "$EXTRACT_DIR" "$INSTALL_DIR"
sudo rm -rf "${INSTALL_DIR}.old" || true
# persist environment for future shells
sudo tee /etc/profile.d/swift.sh >/dev/null <<'EOF'
# Swift toolchain
export PATH=/opt/swift/usr/bin:${PATH}
export CI=true
export DEBIAN_FRONTEND=noninteractive
EOF
sudo chmod +x /etc/profile.d/swift.sh
# make available in current process
export PATH=/opt/swift/usr/bin:${PATH}
# validate binaries
command -v swift >/dev/null 2>&1 || { echo "ERROR: swift not on PATH" >&2; rm -rf "$TMP"; exit 6; }
SWOUT=$(swift --version 2>/dev/null || true)
SWPARSED=$(printf "%s" "$SWOUT" | awk '/Swift version/ {print $3; exit}') || true
if [ "$SWPARSED" != "$SWIFT_VERSION" ]; then
  echo "WARNING: swift --version returned '$SWOUT' (expected ${SWIFT_VERSION})" >&2
fi
command -v swiftc >/dev/null 2>&1 || { echo "ERROR: swiftc not found" >&2; rm -rf "$TMP"; exit 7; }
# ensure swift package helper is callable (best-effort)
swift package --help >/dev/null 2>&1 || true
rm -rf "$TMP"
echo "swift toolchain installed"
