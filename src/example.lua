-- [[
-- 这是一个使用 LuaJIT 为 Ly 编写自定义动画的示例，本例是
-- 会变色、弹跳的方块。
--
-- 你会拿到下面这个 `ly` 表：
-- {
--	height: number -- 终端高度
--	width: number -- 终端宽度
--	putCell(byte, fg, bg, x, y) -- 绘制一个单元格。
--      该函数的所有参数都是整数，
--      且必须位于无符号 32 位整数范围内：0 到 2^32-1。
--      若某个参数无法转换到该范围，就会抛出错误。
--
--      作为参考，坐标 (0,0) 绘制的是终端左上角的单元格，
--      X 轴正方向向右，Y 轴正方向向下。
--
--      参数 fg 和 bg：它们是 0xSSRRGGBB 格式的颜色，
--      其中 SS 表示样式。详见你的
--      config.ini 或 config.lua。
--
--      byte 参数可以用 string.byte 来填充。
--
--	putRect(byte, fg, bg, x, y, w, h) -- 绘制一个矩形。
--		参数与 putCell 相同，多了 w 和 h，它们同样是非负整数。
--		矩形从左上角开始绘制，参数 w 向右延伸，参数 h 向下延伸。
--
--
--  putLabel(str, fg, bg, x, y) -- 在参数 str 中绘制文本。其余参数
--  	的说明见 putCell()。
--
--  clock() -- 时间，单位为微秒。
-- }
--
-- 脚本中必须声明一个名为 `draw()` 的函数。它每一帧都会被执行。
--
-- 除了基础库之外，你还可以使用以下标准库：
-- 	bit（LuaJIT 独有的库，见 https://bitop.luajit.org/api.html）
--	math
--	string
--	table
--
--	不包含标准库 io 和 debug。
--
-- ]]

-- 建议把 FPS 和 FPS_COUNT 复制到你自己后续编写的任何 LuaJIT 动画中。
local FPS_COUNT = 40
local function FPS()
    return (1 / FPS_COUNT) * 1000000
end


local SQUARE_WIDTH = 10
local SQUARE_HEIGHT = 5

local SQUARE_COUNT = 25

local squares = {}

for i = 1, SQUARE_COUNT do
    local vx = 1
    local vy = 1
    if math.random(1, 2) == 2 then vx = -vx end
    if math.random(1, 2) == 2 then vy = -vy end
    squares[#squares + 1] = {
        x = math.random(1, ly.width - SQUARE_WIDTH),
        y = math.random(1, ly.height - SQUARE_HEIGHT),
        vx = vx,
        vy = vy,
        color = math.random(0xFFFFFF)
    }
end

local timer = ly.clock()
local perf = ly.clock()

function draw()
    -- 与其按帧推进动画，不如借助 ly.clock() 按秒推进。
    -- 在这段时间里，你可以更新动画状态。
    -- 不要在这段时间里绘制单元格，否则会出现闪烁。

    -- 如果这个判断通过，就可以更新动画
    if timer + FPS() < ly.clock() then
        for i, v in ipairs(squares) do
            v.x = v.x + v.vx
            v.y = v.y + v.vy
            if v.x == 0 then
                v.vx = 1; v.color = math.random(0xFFFFFF)
            end
            if v.x + SQUARE_WIDTH >= ly.width - 1 then
                v.vx = -1; v.color = math.random(0xFFFFFF)
            end
            if v.y == 0 then
                v.vy = 1; v.color = math.random(0xFFFFFF)
            end
            if v.y + SQUARE_HEIGHT >= ly.height - 1 then
                v.vy = -1; v.color = math.random(0xFFFFFF)
            end
        end
        timer = ly.clock()
    end


    for i, v in ipairs(squares) do
        ly.putRect(string.byte(' '), 0, v.color, v.x, v.y, SQUARE_WIDTH, SQUARE_HEIGHT)
    end

    local new_perf = ly.clock()
    local str = "FT: " .. ((new_perf - perf) / 1000) .. "ms"
    ly.putLabel(str, 0x00FFFFFF, 0, (ly.width / 2) - (string.len(str) / 2), ly.height - 1)
    perf = new_perf
end
