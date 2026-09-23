#!/usr/bin/env bash
# Install the current build and restart the active Ly service on one VT.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-/etc/ly}"

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo "Run as root: sudo $0 [Ly configuration directory]" >&2
    exit 1
fi
if [[ "$TARGET" != "/etc/ly" ]]; then
    echo "Hot reload is intended for /etc/ly; use install.sh for alternate targets." >&2
    exit 2
fi

graphical_session_on_tty1() {
    command -v loginctl >/dev/null 2>&1 || return 1
    while read -r session _uid _user _seat tty _rest; do
        [[ "$tty" == "tty1" ]] || continue
        case "$(loginctl show-session "$session" -p Type --value 2>/dev/null || true)" in
            wayland|x11) return 0 ;;
        esac
    done < <(loginctl list-sessions --no-legend 2>/dev/null || true)
    return 1
}

had_graphical_session=0
if graphical_session_on_tty1; then
    had_graphical_session=1
    echo "Active graphical session detected on tty1; files will be installed without restarting Ly." >&2
    echo "Log out/reboot, then run this script again from a non-graphical shell to hot-reload safely." >&2
fi

bash "$ROOT/tools/install.sh" "$TARGET"

if [[ "$had_graphical_session" -eq 1 ]]; then
    exit 4
fi

active_unit=""
for unit in ly-kmsconvt@tty1.service ly@tty1.service; do
    if systemctl is-active --quiet "$unit"; then
        active_unit="$unit"
        break
    fi
done
if [[ -z "$active_unit" ]]; then
    echo "No active Ly service found on tty1; installed files but did not restart a service." >&2
    exit 3
fi

echo "Restarting $active_unit; the current tty1 session will be replaced."
systemctl restart "$active_unit"
systemctl is-active --quiet "$active_unit"
ly-dm --validate-config "$TARGET/config.lua"
test -r "$TARGET/animation/anime.lua"
test -x "$TARGET/setup.sh"
test -x "$TARGET/startup.sh"
echo "PRTS theme hot-loaded on tty1 via $active_unit"
