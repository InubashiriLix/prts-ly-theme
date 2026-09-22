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
# mktemp creates 0700, and some source directories are not traversable.
# The greeter executes /etc/ly/setup.sh as the logging-in user, so the
# installed tree must stay readable and traversable for everyone.
chmod -R a+rX "$STAGE"
if [[ -e "$TARGET" ]]; then
    BACKUP="$(mktemp -d "${TARGET}.backup-$(date +%Y%m%d-%H%M%S).XXXXXX")"
    cp -a "$TARGET/." "$BACKUP/"
    echo "Existing configuration backed up to: $BACKUP"
fi
mkdir -p "$TARGET"
cp -a "$STAGE/." "$TARGET/"
# `cp -a` copies the staging directory's own mode onto TARGET; force the
# deployed root back to a traversable mode so it is not 0700 root-only.
chmod 0755 "$TARGET"
if [[ ! -r "$TARGET/setup.sh" || ! -x "$TARGET/setup.sh" ]]; then
    echo "Installed $TARGET/setup.sh is not readable/executable by the greeter." >&2
    exit 1
fi
echo "PRTS Analysis OS installed in $TARGET (staged build retained at $STAGE)"
