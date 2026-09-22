#!/usr/bin/env bash
# Install the PRTS theme into Ly's configuration directory.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-/etc/ly}"

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run as root: sudo $0 [Ly configuration directory]" >&2
    exit 1
fi

if ! command -v ly-dm >/dev/null 2>&1; then
    echo "ly-dm was not found; install Ly 1.5 or newer first." >&2
    exit 1
fi

if [[ -e "$TARGET/config.lua" ]]; then
    BACKUP="${TARGET}.backup-$(date +%Y%m%d-%H%M%S)"
    cp -a "$TARGET" "$BACKUP"
    echo "Existing Ly configuration backed up to: $BACKUP"
fi

mkdir -p "$TARGET"
cp -a "$ROOT/src/." "$TARGET/"
# Keep alternate targets self-contained.  The source configuration intentionally
# names /etc/ly so a normal installation needs no generated file.
if [[ "$TARGET" != "/etc/ly" ]]; then
    sed -i "s|lua_animation_file = \"/etc/ly/|lua_animation_file = \"$TARGET/|" \
        "$TARGET/config.lua"
fi
ly-dm --validate-config "$TARGET/config.lua"
echo "PRTS Ly theme installed in $TARGET"
