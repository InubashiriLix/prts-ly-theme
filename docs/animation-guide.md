# Ly 动画扩展指南

Ly 的 Lua 动画运行在受限 LuaJIT 环境。可用的是 `math`、`string`、`table`、`bit`
以及 `ly.width`、`ly.height`、`ly.clock()`、`ly.putCell`、`ly.putRect`、`ly.putLabel`。
动画不能读取键盘、认证结果、文件、网络或系统指标，也不能使用系统 `require`。

源码仍然可以按模块组织：`tools/build.py` 会读取 `src/animation/modules.txt`，将模块
嵌入单文件，并提供只查找内嵌模块的局部 `require`。因此扩展步骤是：

1. 在 `src/animation/components/` 或 `core/` 新建模块。
2. 在 `modules.txt` 登记模块名。
3. 在 `anime.lua` 中引入并调用组件。
4. 用 `ctx` 绘制，不直接调用 Ly API。
5. 执行 `python3 tools/test_build.py`、`luajit tools/test_animation.lua build/animation/anime.lua`。

## 可配置动效

`theme/options.lua` 支持：

```lua
return {
    entrance = true,
    reduced_motion = false,
    scan_speed = 1.0,
    density = "balanced", -- sparse / balanced / dense
    accent_mode = "orange", -- orange / cyan
}
```

这些设置改变的是视觉时间线和装饰密度，不会改变 Ly 的认证行为。想显示真实时钟、
TTY、版本或自定义标签，应使用 `config.lua` 的 `corner_*` 和 `custom_labels`。
