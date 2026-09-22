#!/usr/bin/env bash
# Build and validate first; preserve a backup before installing.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="$(realpath -m -- "${1:-/etc/ly}")"
if [[ $# -gt 1 || "$TARGET" == / || "$TARGET" == "$ROOT" || "$TARGET" == "$ROOT/src" ]]; then
    echo "Usage: $0 [dedicated Ly configuration directory]" >&2
    exit 2
fi
command -v ly-dm >/dev/null || { echo "Install Ly with Lua animation support first." >&2; exit 1; }
STAGE="$(mktemp -d /tmp/prts-ly-install.XXXXXX)"
python3 "$ROOT/tools/build.py" --output "$STAGE" --runtime-dir "$TARGET"
ly-dm --validate-config "$STAGE/config.lua"
# Run the bundled animation with a mock host before touching the target.
luajit "$ROOT/tools/test_animation.lua" "$STAGE/animation/anime.lua"
if [[ -e "$TARGET" ]]; then
    BACKUP="$(mktemp -d "${TARGET}.backup-$(date +%Y%m%d-%H%M%S).XXXXXX")"
    cp -a "$TARGET/." "$BACKUP/"
    echo "Existing configuration backed up to: $BACKUP"
fi
mkdir -p "$TARGET"
cp -a "$STAGE/." "$TARGET/"
echo "PRTS Analysis OS installed in $TARGET (staged build retained at $STAGE)"
