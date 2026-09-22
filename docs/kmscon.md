# 字体与 KMSCON

主题的构图依赖终端字形，但 **Ly 本身没有字体选项**：登录界面的字体由它所在的
虚拟终端决定。

- `ly@tty1.service`：内核控制台，只能用 `/etc/vconsole.conf` 里的点阵字体，
  默认 `FONT=ter-v28n`（Tera Term 28px），观感与 `docs/previews/` 明显不同。
- `ly-kmsconvt@tty1.service`：KMSCON VT，支持任意 TrueType 字体，可与预览接近。

预览图是用 `fc-match monospace` 的 TrueType 字体渲染的，所以想要一致的观感，
应该切到 KMSCON，而不是换点阵字体。

## 一键脚本

```sh
sudo ./tools/kmscon.sh status     # 查看当前状态
sudo ./tools/kmscon.sh trial      # 先在 tty3 试跑，不动正在使用的 tty
sudo ./tools/kmscon.sh enable     # 正式切到 tty1 的 KMSCON
sudo ./tools/kmscon.sh disable    # 回滚到内核控制台
```

`trial` 会用 `Ctrl+Alt+F3` 查看；`enable`/`disable` 只改 systemd 配置，
重启（或手动 `systemctl restart`）后生效。

> **`trial` 在图形会话运行时通常起不来。** kmscon 是 KMS/DRM 控制台，需要独占
> 显卡（GPU）。只要还有 Wayland/X11 会话（例如 niri）持有 DRM master，新启动的
> kmscon 就拿不到 GPU，表现为 systemd 显示 `active (running)`、但只剩一个
> `(kmscon)` 主进程而没有 `ly-dm` 登录子进程，切过去就是黑屏。这不是按键问题。
> 第一次切换建议直接 `enable` 后重启，让 kmscon 在启动早期、图形会话之前拿到 GPU。

判断是按键问题还是 kmscon 问题，可以用 `chvt` 绕过键盘强制切换：

```sh
sudo chvt 3    # 强制切到 tty3（试跑的 kmscon）
sudo chvt 2    # 强制切到 tty2（开机就在的 kmscon）
```

## 脚本做了什么

1. 写入 `/etc/systemd/system/ly-kmsconvt@.service.d/10-font.conf`：

   ```ini
   [Service]
   ExecStart=
   ExecStart=/usr/bin/kmscon --term=linux --vt=%I --login -- /usr/bin/ly-dm --use-kmscon-vt
   ```

   Arch 的 `ly-kmsconvt@.service` 硬编码了 `--font-engine unifont`，
   会忽略 `/etc/kmscon/kmscon.conf` 的 `font-name`。清空后用不带该参数的版本，
   让 kmscon 走 freetype/pango 并读取配置文件。

2. `systemctl disable ly@tty1 && systemctl enable ly-kmsconvt@tty1`。

## 字体与字号

在 `/etc/kmscon/kmscon.conf` 中调整，改完重启 KMSCON 或重新登录：

```ini
font-name=JetBrainsMono Nerd Font
font-size=18
```

主题用到的字形只有 `█ U+2588` 与 `─ U+2500`，JetBrainsMono Nerd Font 已包含，
无需担心缺字。

`font-size=18` 在 2560×1440 上约 230×80 格，比预览的 120×40 更空；
调到 `22`～`28` 更接近预览构图。

## 前置

`/etc/ly` 必须是可被普通用户穿越的目录，否则登录时会 `permission denied`：

```sh
sudo chmod 755 /etc/ly /etc/ly/lang /etc/ly/custom-sessions
```

## 已知问题与回滚

上游 KMSCON 支持仍是基础实现（见 [ly#886](https://codeberg.org/fairyglade/ly/issues/886)），
X11 会话从 KMSCON 启动存在已知问题（[ly#1034](https://codeberg.org/fairyglade/ly/issues/1034)）。
Wayland 会话走 `kmscon-launch-gui`；`ly-kmsconvt@.service` 自带
`OnFailure=ly@%i.service` 兜底，启动失败会退回普通控制台。

若真彩色发灰，可去掉 drop-in 里的 `--term=linux`，改用 `kmscon.conf` 的
`term=xterm-256color`。回滚用 `sudo ./tools/kmscon.sh disable` 后重启。
