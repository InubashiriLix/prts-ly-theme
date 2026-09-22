-- 这是一个示例函数，可用于任何支持颜色的选项，
-- 让它返回一个随机颜色。
function getRandomColor()
    math.randomseed()

    local r = math.random(0, 255)
    local g = math.random(0, 255)
    local b = math.random(0, 255)

    local col = b
    col = bit.bor(col, bit.lshift(g, 8))
    col = bit.bor(col, bit.lshift(r, 16))

    return col
end

ly = {
    -- Ly 支持带样式的 24 位真彩色，因此每个颜色都是一个 32 位数值。
    -- 格式为 0xSSRRGGBB，其中 SS 为样式，RR 为红，GG 为绿，BB 为蓝。
    -- 可用的样式选项如下：
    -- TB_BOLD      0x01000000
    -- TB_UNDERLINE 0x02000000
    -- TB_REVERSE   0x04000000
    -- TB_ITALIC    0x08000000
    -- TB_BLINK     0x10000000
    -- TB_HI_BLACK  0x20000000
    -- TB_BRIGHT    0x40000000
    -- TB_DIM       0x80000000
    -- 在代码中，你可以用按位或运算符（|）来叠加样式，
    -- 在 Lua 里则用 bit.bor(x, y) 计算 x | y。
    -- 注意：如果想使用终端的默认颜色值，可以用特殊值 0x00000000。
    -- 这也意味着，如果你想用黑色，就*必须*使用样式选项 TB_HI_BLACK
    --（使用该选项时 RGB 值会被忽略）。

    -- 认证时是否允许空密码
    allow_empty_password = true,

    -- 当前启用的动画
    -- none     -> 无
    -- doom     -> PSX DOOM 火焰
    -- matrix   -> CMatrix（黑客帝国）
    -- colormix -> 颜色混合着色器
    -- gameoflife -> 约翰·康威的生命游戏
    -- dur -> .dur 文件格式（https://github.com/cmang/durdraw/tree/master）
    -- lua -> 用 LuaJIT 编写的自定义动画
    animation = "lua",

    -- 每帧动画之间的延迟（毫秒）
    animation_frame_delay = 30,

    -- 一段时间后停止动画
    -- 0 -> 一直运行
    -- 1..2e12 -> 运行这么多秒后停止动画
    animation_timeout_sec = 0,

    -- 用于遮蔽密码的字符
    -- 既可以直接输入 UTF-8 字符（如 *），也可以使用 UTF-32 码点
    --（例如用 0x2022 表示圆点）
    -- 若为 null，则完全隐藏密码
    -- 注意：想使用 # 需要像这样转义：\#
    asterisk = '*',

    -- 触发特殊动画前允许的认证失败次数…… ;)
    -- 若为 0，则永不播放该动画
    auth_fails = 10,

    -- 自动登录配置
    -- 该功能允许 Ly 无需输入密码即自动登录某个用户。
    -- 重要：必须同时设置 auto_login_user 和 auto_login_session 才会生效。
    -- 自动登录只在启动时执行一次 —— 注销后不会再次触发。

    -- 用于自动登录的 PAM 服务名
    -- 默认服务（ly-autologin）使用 pam_permit 允许无密码登录
    -- 程序会自动选用与平台匹配的 PAM 配置（ly-autologin）
    auto_login_service = "ly-autologin",

    -- 自动启动的会话名称
    -- 要查找可用的会话名，可以查看以下目录中的 .desktop 文件：
    --   - /usr/share/xsessions/（X11 会话）
    --   - /usr/share/wayland-sessions/（Wayland 会话）
    -- 可使用不带 .desktop 后缀的文件名、文件内的 Name 字段，或 DesktopNames 字段的值
    -- 示例："i3"、"sway"、"gnome"、"plasma"、"xfce"
    -- 若为 null，则禁用自动登录
    auto_login_session = nil,

    -- 要自动登录的用户名
    -- 必须是系统上的有效用户
    -- 若为 null，则禁用自动登录
    auto_login_user = nil,

    -- 在左上角显示电量的电池标识
    -- 主电池通常是 BAT0 或 BAT1
    -- 若为 null，则不显示电池状态
    -- 在 FreeBSD 上不使用（那里改用 sysctl）
    battery_id = nil,

    -- 背景色
    bg = 0x00E5E7E6,

    -- 更改大时钟的状态与语言
    -- none -> 禁用（默认）
    -- en   -> 英文
    -- fa   -> 波斯文
    bigclock = "none",

    -- 让大时钟使用 12 小时制。
    bigclock_12hr = false,

    -- 让大时钟显示秒数。
    bigclock_seconds = false,

    -- 主框背景是否填充
    -- 设为 false 会使其透明
    blank_box = true,

    -- 边框前景色
    border_fg = 0x001B2023,

    -- 相对于屏幕末端的水平位置
    -- 默认：0.5
    box_position_h = 0.5,

    -- 相对于屏幕底部的垂直位置
    -- 默认：0.5
    box_position_v = 0.5,

    -- 显示在主框顶部的标题
    -- 若为 null，则不显示
    box_title = " P R T S  //  AUTHORIZATION ",

    -- 降低亮度命令
    brightness_down_cmd = "/usr/bin/brightnessctl -q -n s 10%-",

    -- 降低亮度快捷键
    -- 若为 null，则禁用该快捷键且不显示提示
    brightness_down_key = "F5",

    -- 提高亮度命令
    brightness_up_cmd = "/usr/bin/brightnessctl -q -n s +10%",

    -- 提高亮度快捷键
    -- 若为 null，则禁用该快捷键且不显示提示
    brightness_up_key = "F6",

    -- 认证失败时清空已输入的密码
    clear_password = false,

    -- 右上角时钟的格式字符串（参见 strftime 规范）。示例：%c
    -- 若为 null，则不显示时钟
    clock = nil,

    -- CMatrix 动画前景色
    cmatrix_fg = 0x0000FF00,

    -- CMatrix 动画字符头部颜色
    cmatrix_head_col = 0x01FFFFFF,

    -- CMatrix 动画的最小码点。使用 16 位整数
    -- 例如要用日文字符，可以设为 0x3000
    cmatrix_min_codepoint = 0x21,

    -- CMatrix 动画的最大码点。使用 16 位整数
    -- 例如要用日文字符，可以设为 0x30FF
    cmatrix_max_codepoint = 0x7B,

    -- 颜色混合动画的第一种颜色
    colormix_col1 = 0x00FF0000,

    -- 颜色混合动画的第二种颜色
    colormix_col2 = 0x000000FF,

    -- 颜色混合动画的第三种颜色
    colormix_col3 = 0x20000000,

    -- 屏幕四角自定义
    -- 关键字：
    -- shutdown -> 关机快捷键
    -- restart  -> 重启快捷键
    -- britup   -> 提高亮度快捷键
    -- britdown -> 降低亮度快捷键
    -- password -> 切换密码可见性的快捷键
    -- clock    -> 时钟（格式由 'clock' 选项定义）
    -- tty      -> 当前 TTY 编号
    -- battery  -> 电池电量百分比
    -- version  -> Ly 版本字符串
    -- numlock  -> NumLock 状态
    -- capslock -> CapsLock 状态
    -- labels   -> 所有自定义信息标签（lbl:）
    -- binds    -> 所有自定义快捷键提示（cmd:）
    -- lbl:名称 -> 指定的自定义信息标签
    -- cmd:按键 -> 指定的自定义快捷键提示
    --
    -- 如果使用会把多个标签归为一组的关键字（如 labels、binds），
    -- 它们会被水平排列
    --
    -- 另外，书写顺序决定垂直堆叠顺序（第一项位于边缘）
    -- 若各项之间用逗号分隔，则会水平排列
    -- 同一个角上可以同时存在水平和垂直排列的项

    -- 左下角
    corner_bottom_left = "version",

    -- 右下角
    corner_bottom_right = "lbl:prts",

    -- 左上角
    corner_top_left = "shutdown,restart,password",

    -- 右上角
    corner_top_right = "clock",

    -- 对于自定义快捷键：每行自定义快捷键在换行前的字符数上限。
    -- 若为 null，则默认使用终端宽度。
    custom_bind_width = nil,

    -- 自定义会话目录
    -- 可以指定多个目录，
    -- 例如 /etc/ly/custom-sessions:/usr/share/custom-sessions
    custom_sessions = "/etc/ly/custom-sessions",

    -- 启动时默认激活的输入框
    -- 可用输入框：info_line、session、login、password
    default_input = "login",

    -- DOOM 动画火焰高度（1 到 9）
    doom_fire_height = 6,

    -- DOOM 动画火焰扩散（0 到 4）
    doom_fire_spread = 2,

    -- DOOM 动画自定义顶部颜色（低强度火焰）
    doom_top_color = 0x009F2707,

    -- DOOM 动画自定义中部颜色（中强度火焰）
    doom_middle_color = 0x00C78F17,

    -- DOOM 动画自定义底部颜色（高强度火焰）
    doom_bottom_color = 0x00FFFFFF,

    -- Dur 文件路径
    dur_file_path = "/etc/ly/example.dur",

    -- Dur 文件对齐方式
    -- 通过下面的标志，可以轻松地按方向对齐并居中 dur 文件
    -- 可用值：topleft、topcenter、topright、centerleft、center、centerright、bottomleft、bottomcenter、bottomright
    dur_offset_alignment = "center",

    -- Dur 在 x 方向的偏移（该值会加到由对齐方式确定的位置上，支持负数）
    dur_x_offset = 0,

    -- Dur 在 y 方向的偏移（该值会加到由对齐方式确定的位置上，支持负数）
    dur_y_offset = 0,

    -- 设置显示管理器边缘的留白（对曲面显示器很有用）
    edge_margin = 0,

    -- 错误信息背景色
    error_bg = 0x00E5E7E6,

    -- 错误信息前景色
    -- 默认是红色加粗
    error_fg = 0x01B83F00,

    -- pam_faillock 模块的计数目录（如存在）
    -- 用于在登录尝试失败次数过多后判断账号是否被锁定
    -- 若该目录不存在，认证时将不检查锁定状态
    faillock_tally_dir = "/var/run/faillock",

    -- 前景色
    fg = 0x001B2023,

    -- 渲染真彩色（如果支持）
    -- 若为 false，则输出使用八色模式
    -- 八色模式的全部颜色代码：
    -- TB_DEFAULT              0x0000
    -- TB_BLACK                0x0001
    -- TB_RED                  0x0002
    -- TB_GREEN                0x0003
    -- TB_YELLOW               0x0004
    -- TB_BLUE                 0x0005
    -- TB_MAGENTA              0x0006
    -- TB_CYAN                 0x0007
    -- TB_WHITE                0x0008
    -- 若关闭真彩色，样式选项仍然有效。颜色始终是 32 位数值，
    -- 样式位于最高字节。
    -- 注意：若使用 dur_file 动画选项，而 dur 文件的颜色范围保存为 256
    -- 且该选项被禁用，则该文件不会被绘制。
    full_color = true,

    -- 生命游戏熵注入间隔（0 = 禁用，>0 = 每 N 代注入一次熵）
    -- 0 -> 纯粹的康威生命游戏（最终会趋于稳定）
    -- 10 -> 每 10 代注入一次熵（推荐，可持续活动）
    -- 50+ -> 更少的熵注入，演化更自然
    gameoflife_entropy_interval = 10,

    -- 生命游戏动画前景色
    gameoflife_fg = 0x0000FF00,

    -- 生命游戏帧延迟（越小越快，越大越慢）
    -- 1-3 -> 非常快
    -- 6 -> 默认的流畅速度
    -- 10+ -> 更慢、更从容
    gameoflife_frame_delay = 6,

    -- 生命游戏初始细胞密度（0.0 到 1.0）
    -- 0.1 -> 稀疏、活动很少
    -- 0.4 -> 活动均衡（推荐）
    -- 0.7+ -> 密集、混乱
    gameoflife_initial_density = 0.4,

    -- 设置细胞诞生所需的邻居数量集合。
    -- 该字符串中每个 0 到 8 的数字都成为诞生条件之一。
    -- 示例："3" 表示细胞在有 3 个邻居时诞生
    gameoflife_param_birth = "3",

    -- 设置细胞存活所需的邻居数量集合。
    -- 该字符串中每个 0 到 8 的数字都成为存活条件之一。
    -- 示例："23" 表示细胞在有 2 或 3 个邻居时存活
    gameoflife_param_survival = "23",

    -- 设置始终抢占焦点的 TTY。
    -- 当你同时在多个 TTY 上启动 Ly 时，这有助于获得确定的行为。
    -- 若为 null，Ly 会始终尝试抢占它所在 TTY 的焦点，
    -- 即使启动了多个实例也是如此。
    grab_focus_tty = nil,

    -- 移除主框边框
    hide_borders = false,

    -- 在一定时间内无输入时执行的命令
    -- 若为 null，则不执行任何命令
    inactivity_cmd = nil,

    -- 经过多少秒后执行命令
    inactivity_delay = 0,

    -- 信息行上显示的初始文本
    -- 若为 null，信息行默认显示主机名
    initial_info_text = "IDENTIFY YOURSELF, DOCTOR.",

    -- 输入框长度。20 可让 Ly 自身的主框落入 40 列的救援 TTY。
    input_len = 20,

    -- 当前语言
    -- 可用语言位于 /etc/ly/lang/
    lang = "en",

    -- 登录时执行的命令
    -- 若为 null，则不执行任何命令
    -- 重要：代码本身必须以 `exec "$@"` 结尾，否则无法启动会话！
    -- 你也可以在其中设置环境变量，它们会一直保留到注销
    login_cmd = nil,

    -- login.defs 文件的路径（用于列出系统上的所有本地用户
    -- —— 仅 Linux）
    login_defs_path = "/etc/login.defs",

    -- 注销时执行的命令
    -- 若为 null，则不执行任何命令
    -- 重要：该命令执行时会话已经终止，
    -- 因此无需在末尾添加 `exec "$@"`
    logout_cmd = nil,

    -- 使用 Lua 动画选项时指向的 Lua 文件
    lua_animation_file = "/etc/ly/animation/anime.lua",

    -- 通用日志文件路径
    -- 若为 null，则改用 syslog
    ly_log = "/var/log/ly.log",

    -- 主框水平外边距
    margin_box_h = 3,

    -- 主框垂直外边距
    margin_box_v = 1,

    -- 启动时开启/关闭 NumLock
    numlock = false,

    -- 默认 PATH
    -- 若为 null，Ly 不设置 PATH
    path = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",

    -- 指定用于重启的快捷键
    -- 若为 null，则禁用该快捷键且不显示提示
    restart_key = "F2",

    -- 保存文件的绝对目录
    -- 若为 null，则不保存也不加载当前的桌面环境和登录信息
    save_file_dir = "/etc/ly",

    -- 服务名（设为 ly 以使用随附的 pam 配置文件）
    service_name = "ly",

    -- 会话日志文件路径
    -- 其中会包含 Wayland 会话的 stdout 和 stderr
    -- 默认保存在用户主目录下
    -- 重要：受技术限制，X11、shell 会话以及通过 KMSCON 启动的会话
    -- 不受支持，也就是说这些会话不会产生日志。
    -- 若为 null，则不创建会话日志
    session_log = ".local/state/ly-session.log",

    -- 安装/启动前执行的命令（setup command）
    setup_cmd = "/etc/ly/setup.sh",

    -- 是否在会话列表中显示 shell 会话
    -- 若为 false，则隐藏该会话
    shell = true,

    -- 指定用于显示密码的快捷键
    -- 若为 null，则禁用该快捷键且不显示提示
    show_password_key = "F7",

    -- 指定用于关机的快捷键
    -- 若为 null，则禁用该快捷键且不显示提示
    shutdown_key = "F1",

    -- 启动 Ly 时执行的命令（在接管 TTY 之前）
    -- 如何更改默认 TTY 配色，可参考下方路径中的文件示例
    start_cmd = "/etc/ly/startup.sh",

    -- 将会话名居中显示。
    text_in_center = false,

    -- 若为 true，用户需要手动输入用户名，而不是从检测到的用户列表中选择
    type_username = false,

    -- 默认 vi 模式
    -- normal   -> 普通模式
    -- insert   -> 插入模式
    vi_default_mode = "normal",

    -- 启用 vi 键位绑定
    vi_mode = false,

    -- Wayland 桌面环境
    -- 可以指定多个目录，
    -- 例如 /usr/share/wayland-sessions:/usr/local/share/wayland-sessions
    -- 若为 null，则不显示 Wayland 会话
    waylandsessions = "/usr/share/wayland-sessions",

    -- Xorg 服务器命令
    -- 添加 -quiet 参数可隐藏服务器的启动日志
    x_cmd = "/usr/bin/X",

    -- Xorg 虚拟终端号
    -- 主要用于 FreeBSD，因为在那些系统上选择当前 TTY 会引发问题
    -- 若为 null，则选择当前 TTY
    x_vt = nil,

    -- Xorg xauthority 编辑工具
    xauth_cmd = "/usr/bin/xauth",

    -- xinitrc
    -- 若为 null，则隐藏 xinitrc 会话
    xinitrc = "~/.xinitrc",

    -- Xorg 桌面环境
    -- 可以指定多个目录，
    -- 例如 /usr/share/xsessions:/usr/local/share/xsessions
    -- 若为 null，则不显示 X11 会话
    xsessions = "/usr/share/xsessions",

    -- 自定义命令与标签：
    -- 下面的示例给出了设置自定义命令和标签的框架。
    -- 除非注明可选，否则选项均为必填。

    -- 以 '-- --' 开头的注释用于文档说明。
    -- 以 '--' 开头的注释用于注释掉示例代码。

    -- custom_commands = {
    --     -- 声明一个绑定到 F8 的命令。
    --     binding = "F8",
    --     -- 在 Ly 中显示的命令名称。
    --     -- 注意："$brightness_up" 中的 "$" 会从指定的语言文件中取出对应字符串，
    --     -- 并替换为代表 "brightness_up" 的值。
    --     -- 你可以在 /etc/ly/lang 下任意语言文件中查看键的列表。
    --     name = "custom command $brightness_up",
    --     cmd = "touch /tmp/ly.gaming",
    -- },

    custom_labels = {
        label = "prts",
        cmd = "printf 'PRTS // ANALYSIS OS'",
        refresh = 0,
    }
}
