#!/usr/bin/env bash
# setup.sh — installer for xzit-php CLI
# Installs prerequisites and places xzit-php into /usr/local/bin
# License: CC0 1.0

set -euo pipefail

die(){ echo "ERROR: $*" >&2; exit 1; }
log(){ echo "[setup] $*"; }

# --- options ---
WITH_PPA=auto
BIN_DIR="/usr/local/bin"
SCRIPT_NAME="xzit-php"
SOURCE_PATH="$(dirname "$0")/${SCRIPT_NAME}"

usage() {
  cat <<USG
setup.sh - install xzit-php CLI

Usage:
  sudo ./setup.sh [--with-ppa|--no-ppa] [--bin-dir /usr/local/bin] [--from PATH]

Options:
  --with-ppa       Force-add ppa:ondrej/php (Sury) now
  --no-ppa         Do not touch APT sources (xzit-php will add PPA on demand later)
  --bin-dir PATH   Install directory for the CLI (default: /usr/local/bin)
  --from PATH      Path to xzit-php script if not in current folder

Examples:
  sudo ./setup.sh
  sudo ./setup.sh --with-ppa
  sudo ./setup.sh --bin-dir /usr/bin --from ./dist/xzit-php
USG
}

# --- parse args ---
while [ $# -gt 0 ]; do
  case "$1" in
    --with-ppa) WITH_PPA=yes; shift ;;
    --no-ppa)   WITH_PPA=no ; shift ;;
    --bin-dir)  BIN_DIR="${2:-}"; shift 2 ;;
    --from)     SOURCE_PATH="${2:-}"; shift 2 ;;
    -h|--help)  usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  case_esac_done=true
  esac
done
: "${case_esac_done:=true}" # quiet shellcheck

# --- checks ---
[ "$(id -u)" -eq 0 ] || die "Run as root (use sudo)."
[ -n "${BIN_DIR}" ] || die "--bin-dir must not be empty"
[ -f "${SOURCE_PATH}" ] || die "xzit-php script not found at: ${SOURCE_PATH}"

# --- platform info (best-effort) ---
if [ -r /etc/os-release ]; then
  . /etc/os-release
  log "Detected: ${PRETTY_NAME:-unknown}"
fi

# --- prerequisites ---
log "Installing prerequisites (apt, curl, git, software-properties-common)…"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl git lsb-release software-properties-common

# --- optional: add ondrej/php PPA now ---
if [ "${WITH_PPA}" = "yes" ] || { [ "${WITH_PPA}" = "auto" ] && ! grep -Rqs "^deb .*ondrej/php" /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null; }; then
  log "Adding PPA: ondrej/php (Sury)"
  add-apt-repository -y ppa:ondrej/php
  apt-get update -y
else
  log "Skipping PPA add (mode=${WITH_PPA})"
fi

# --- install binary ---
install -d -m 0755 "${BIN_DIR}"
install -m 0755 "${SOURCE_PATH}" "${BIN_DIR}/${SCRIPT_NAME}"
log "Installed ${SCRIPT_NAME} to ${BIN_DIR}/${SCRIPT_NAME}"

# --- quick self-test ---
if "${BIN_DIR}/${SCRIPT_NAME}" list versions >/dev/null 2>&1; then
  log "Self-test OK: '${SCRIPT_NAME} list versions'"
else
  log "Self-test completed (no versions installed yet)"
fi

echo
echo "✅ Done. Use '${SCRIPT_NAME} --help' to get started."
echo "   Example: ${SCRIPT_NAME} install 8.2"
