#!/usr/bin/env bash
# Compile and run an isolated, non-authenticating Ly preview. Ctrl+C exits.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ $# -gt 1 || ( $# -eq 1 && "$1" != --check ) ]]; then
    echo "Usage: $0 [--check]" >&2
    exit 2
fi
# Never delete a caller-selected path. Each run owns a fresh subdirectory.
SANDBOX="${SANDBOX:-/tmp/prts-ly-preview}"
mkdir -p "$SANDBOX"
PREVIEW="$(mktemp -d "$SANDBOX/run.XXXXXX")"
python3 "$ROOT/tools/build.py" --output "$PREVIEW" --preview
ly-dm --validate-config "$PREVIEW/config.lua"
echo "Preview configuration: $PREVIEW"
if [[ "${1:-}" == --check ]]; then exit 0; fi
if [[ ! -t 0 || ! -t 1 ]]; then
    echo "Run in a terminal, or use tools/capture_preview.py for PTY recording." >&2
    exit 1
fi
exec ly-dm -c "$PREVIEW"
