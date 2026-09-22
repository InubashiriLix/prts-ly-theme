local M = {}

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
        -- The production mark is a diamond frame with a central bar and
        -- registration ticks, rather than a generic enclosing diamond.
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
        ctx:text(3, b.h-6, "R.I. / TERMINAL 01", C.muted)
    end
end

return M
