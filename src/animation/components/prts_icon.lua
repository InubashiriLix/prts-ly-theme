local M = {}

local function registration_mark(ctx, e, C)
    -- The in-game mark is not a plain RI monogram: a small geometric
    -- Rhodes Island device sits behind the horizontal nameplate.  These
    -- terminal-safe pixels preserve that silhouette without external assets.
    local dark = C.ink
    local muted = C.muted
    ctx:cell(e.x - 4, e.y - 2, 0x2588, muted)
    ctx:cell(e.x + 3, e.y - 2, 0x2588, muted)
    ctx:cell(e.x - 3, e.y - 1, 0x2588, dark)
    ctx:cell(e.x + 2, e.y - 1, 0x2588, dark)
    ctx:cell(e.x - 3, e.y + 1, 0x2588, dark)
    ctx:cell(e.x + 2, e.y + 1, 0x2588, dark)
    ctx:cell(e.x - 4, e.y + 2, 0x2588, muted)
    ctx:cell(e.x + 3, e.y + 2, 0x2588, muted)
end

function M.draw(ctx, b, t, C)
    if b.mode == "compact" then return end
    local e, points = b.emblem, {}
    -- Cells are approximately 1:2: double the horizontal radius.
    for side = 0, 3 do
        for n = 0, e.radius - 1 do
            local x, y
            if side == 0 then x, y = 2*n, -e.radius+n
            elseif side == 1 then x, y = 2*(e.radius-n), n
            elseif side == 2 then x, y = -2*n, e.radius-n
            else x, y = -2*(e.radius-n), -n end
            points[#points+1] = {x, y}
        end
    end
    local count = math.floor(#points * t.emblem)
    local highlight = math.floor(t.seconds * 3 * t.speed) % #points + 1
    for i = 1, count do
        local p = points[i]
        local color = t.ready and t.moving and i == highlight and C.orange or C.ink
        ctx:cell(e.x+p[1], e.y+p[2], 0x2588, color)
        ctx:cell(e.x+p[1]+1, e.y+p[2], 0x2588, color)
    end
    if t.emblem > 0.9 then
        -- The production mark is a diamond frame with an inner device and a
        -- central Rhodes Island nameplate, rather than a generic diamond.
        if e.radius >= 5 then registration_mark(ctx, e, C) end
        ctx:rule(e.x-5, e.y, 11, C.ink)
        ctx:text(e.x, e.y-3, "|", C.muted)
        ctx:text(e.x, e.y+3, "|", C.muted)
        if e.radius >= 5 then
            ctx:text(e.x-3, e.y-1, "RHODES", C.bold)
            ctx:text(e.x-3, e.y+1, "ISLAND", C.bold)
        else
            ctx:text(e.x-1, e.y, "RI", C.bold)
        end
    end
    if b.mode == "full" and t.ready then
        ctx:cell(3, b.h-6, 0x25B3, C.muted)
        ctx:text(5, b.h-6, "CONNECTION: REQUEST 0000", C.muted)
    end
end

return M
