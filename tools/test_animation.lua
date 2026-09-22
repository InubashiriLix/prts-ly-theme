-- Exercise the shipped bundle, with only Ly's available standard libraries.
local path = assert(arg[1], "usage: luajit tools/test_animation.lua BUNDLE")
local chunk = assert(loadfile(path))
local now, count = 0, 0
local env = {
    assert=assert, error=error, ipairs=ipairs, pairs=pairs, tostring=tostring,
    tonumber=tonumber, type=type, math=math, string=string, table=table, bit=bit,
}
local w, h
env.ly = { clock=function() return now end }
env.ly.putCell = function(char, fg, bg, x, y)
    assert(x == math.floor(x) and y == math.floor(y), "fractional coordinate")
    assert(x >= 0 and x < w and y >= 1 and y < h-1, "out of bounds/corner overwrite")
    local cx, cy = math.floor(w/2), math.floor(h/2)
    assert(not (x >= cx-21 and x < cx+22 and y >= cy-7 and y < cy+8), "login overlap")
    for _, value in ipairs({char, fg, bg}) do
        assert(value >= 0 and value <= 4294967295 and value == math.floor(value))
    end
    count = count + 1
end
for _, size in ipairs({{120,40},{100,30},{80,24},{60,20},{40,15},{20,8},{1,1},{101,31}}) do
    w, h = size[1], size[2]
    env.ly.width, env.ly.height = w, h
    now = 0
    setfenv(chunk, env)() -- Replay the entrance for every size.
    for i = 0, 180 do
        now = now + 33333
        env.draw()
    end
    now = now - 1000000
    env.draw()
    -- Exercise an already running animation across a resize, too.
    w, h = 60, 20
    env.ly.width, env.ly.height = w, h
    now = now + 33000
    env.draw()
end
assert(count > 0)
print("PASS: restricted runtime, entrance/idle, resize, tiny sizes, clock regression, login exclusion")
