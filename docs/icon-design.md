# PRTS 图标设计说明

当前徽记采用《明日方舟》PRTS / Rhodes Island 终端画面的结构语言重新绘制，
不直接复制官方位图：

- 顶部是 PRTS Analysis OS 字标，而不是把 Rhodes Island 徽记误称为 PRTS 图标。
- 主徽记是横向展开的菱形框，适应终端字符约 1:2 的宽高比例。
- 中心横线、上下竖向定位标记和内部 `RHODES / ISLAND` 排版对应 PRTS 终端画面中
  反复出现的注册线与罗德岛识别标记。
- 橙色只用于连接状态、扫描点和警示条；黑色结构保持稳定，避免图标看起来像随机 HUD。

参考画面包括官方 [Doctor’s Notes 终端](https://x.com/ArknightsEN/status/1854780899780616656)、
[PRTS Connection 界面](https://arknights.wikiru.jp/?PRTS) 与
[Analysis OS 启动画面](https://ecywang.com/pic/prts%E5%9B%BE%E6%A0%87/)，以及
[mashirozx/arknights-ui](https://github.com/mashirozx/arknights-ui) 的加载器、半透明面板和高对比强调色。
这里只借鉴布局语言和动画节奏，不打包该项目的逆向游戏贴图；仓库作者也注明那些素材仅供学习使用。

## 修改图标

图标绘制在 `src/animation/components/prts_icon.lua`，不应编辑 `build/` 中的生成文件。
使用 `ctx:cell`、`ctx:text` 和 `ctx:rule`，这样所有坐标都会经过登录框避让和边界裁剪。

`layout.lua` 会按终端宽度选择徽记半径。80×24 以下只保留 `RI` 中心标记，40×15
以下隐藏装饰，确保 Ly 的登录字段可用。
