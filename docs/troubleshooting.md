# 故障排查

## 登录时 `permission denied`

Ly 需要读取并穿越 `/etc/ly`、`animation`、`lang`、`custom-sessions`，并执行
`setup.sh` 与 `startup.sh`。用安装器重新部署，它会在复制前执行：

```sh
sudo ./tools/install.sh
namei -l /etc/ly/animation/anime.lua
sudo -u nobody test -r /etc/ly/config.lua
sudo -u nobody test -x /etc/ly/setup.sh
```

不要把动画文件设为 root 私有的 0700；目录需要至少 0755，普通文件需要可读，
两个启动脚本需要可执行。安装器会保留带时间戳的备份。

## 动画加载失败

```sh
./tools/debug_sandbox.sh --check
python3 tools/test_build.py
python3 tools/build.py
luajit tools/test_animation.lua build/animation/anime.lua
```

如果出现 `unknown embedded module`，检查 `modules.txt`；如果出现 `lua animation failed`，
先查看 Ly 日志，再确认安装目标中的 `lua_animation_file` 指向 `animation/anime.lua`。

## KMSCON 黑屏或字体未变化

图形会话占用 DRM 时，`trial` 可能只能启动 kmscon 而不能启动 Ly。用
`sudo ./tools/kmscon.sh status` 检查服务，确认 `/etc/kmscon/kmscon.conf` 的字体，
必要时直接 `enable` 后重启。回滚执行 `sudo ./tools/kmscon.sh disable` 后重启。
