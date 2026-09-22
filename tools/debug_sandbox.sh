#!/usr/bin/env bash
#
# 本地预览 Ly 主题，不需要重启系统。
#
#   ./tools/debug_sandbox.sh           # 组装沙盒并在终端模拟器里预览
#   ./tools/debug_sandbox.sh --check   # 只做语法校验，不启动
#
# 沙盒目录默认 /tmp/lytest，可用环境变量覆盖：SANDBOX=/tmp/xxx ./tools/debug_sandbox.sh
#
# 说明：
#   ly-dm -c <dir>  覆盖的是「配置目录」，Ly 会在其中找 config.lua，
#                   以及 lang/ 等支持文件。所以先把 src/ 复制成沙盒，
#                   再把 src/ 里缺失的系统文件补齐，避免污染 /etc/ly。
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/src"
SANDBOX="${SANDBOX:-/tmp/lytest}"

CHECK_ONLY=0
[[ "${1:-}" == "--check" ]] && CHECK_ONLY=1

# ── 1. 组装沙盒 ────────────────────────────────────────────────
echo "[1/3] 组装沙盒 -> $SANDBOX"
rm -rf "$SANDBOX"
mkdir -p "$SANDBOX"
cp -a "$SRC"/. "$SANDBOX"/

# config.lua uses /etc/ly paths for a real installation.  Redirect the paths
# which Ly resolves at runtime so this preview exercises the copied animation
# and helper files, rather than anything installed on the host.
sed -i \
    -e "s|lua_animation_file = \"/etc/ly/|lua_animation_file = \"$SANDBOX/|" \
    -e "s|custom_sessions = \"/etc/ly/|custom_sessions = \"$SANDBOX/|" \
    -e "s|save_file_dir = \"/etc/ly\"|save_file_dir = \"$SANDBOX\"|" \
    -e "s|setup_cmd = \"/etc/ly/|setup_cmd = \"$SANDBOX/|" \
    -e "s|start_cmd = \"/etc/ly/|start_cmd = \"$SANDBOX/|" \
    "$SANDBOX/config.lua"

# 补齐 src/ 里没有、但运行时需要的支持文件
for name in lang custom-sessions example.lua example.dur; do
    [[ -e "$SRC/$name" ]] && continue
    if   [[ -e "/etc/ly/$name" ]]; then cp -a "/etc/ly/$name" "$SANDBOX/"
    elif [[ -e "$ROOT/ly/$name" ]]; then cp -a "$ROOT/ly/$name" "$SANDBOX/"
    fi
done

# ── 2. 语法校验 ────────────────────────────────────────────────
echo "[2/3] 校验配置语法"
ly-dm --validate-config "$SANDBOX/config.lua"

if [[ "$CHECK_ONLY" == 1 ]]; then
    echo "仅校验模式，结束。"
    exit 0
fi

# ── 3. 启动预览 ────────────────────────────────────────────────
# 在终端模拟器里运行，认证不会成功，但 UI / 动画 / 配色都能看；Ctrl+C 退出。
echo "[3/3] 启动预览（Ctrl+C 退出）"
exec sudo ly-dm -c "$SANDBOX"
