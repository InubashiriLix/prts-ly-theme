# 验证记录

日期：2026-09-23。Ly：`1.6.0-dev.29+60be7ad`。

## 检查范围

- 构建：显式模块清单、缺失依赖报错、模块缓存、循环依赖报错。
- 部署：带空格和引号的目标路径、预览配置隔离、安装前校验、既有配置备份。
- 受限 Lua：移除 `io/package/require/loadfile` 等宿主能力后执行生成文件。
- 绘制：每个尺寸覆盖入场和待机；断言整数坐标、颜色范围、屏幕边界、中央表单避让、边缘快捷键避让。
- 动画：关闭入场、减少动效、时钟回退、运行中改变尺寸。
- PRTS 图标：完整 Rhodes Island 菱形、中心横线、上下注册标记和小尺寸 RI 标记。
- 原生状态：右上角 clock/tty、底部版本标签、F8 诊断命令配置校验。
- 实际 Ly PTY：120×40、100×30、80×24、60×20、40×15；另测 120×40 → 60×20 的运行时缩放。

## 证据的含义

`previews/` 中 PNG 和 GIF 是 pyte 解析实际 Ly 输出后用 Pillow 渲染的终端画面，
不是桌面截图。对应 asciicast 可直接回放。图中登录框、会话字段及错误提示均由
真实 Ly 产生；预览禁用用户名记忆和自动登录，没有录入密码。

PTY 缺少 Linux 控制台锁定键 ioctl，Ly 显示 `failed to get lock state`。
本环境不存在 `/dev/tty0` 和 `/dev/vcs`，因此 **Linux VT 实机尚未验证**。
不能从 PTY 验证推断控制台字体、Unicode 字形及真彩色表现完全一致。

## Linux VT 人工验收

在空闲 Linux 虚拟控制台登录普通用户后运行 `./tools/debug_sandbox.sh`；
不要启动安装到系统的 greeter。确认：白底黑字对比、方块和线条字形、
橙色强调、表单可见、Ctrl+C 退出后终端恢复。预览仍使用临时配置目录。
若控制台配色或字形退化，记录终端类型、字体和 Ly 版本后再调整兼容方案。

## 复现

```sh
python3 tools/test_build.py
python3 tools/build.py
luajit tools/test_animation.lua build/animation/anime.lua
./tools/debug_sandbox.sh --check
python3 tools/capture_preview.py --size 100x30 --gif --output build/capture-100x30
python3 tools/capture_preview.py --size 120x40 --resize 60x20 --seconds 5 --output build/capture-resize
```

实际认证、登录成功后动画和系统服务重启不属于此次视觉验证。
本次实现没有安装到 `/etc/ly`；权限回归测试使用临时目标目录完成。
