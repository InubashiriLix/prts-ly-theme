local M = {}

function M.measure(w, h)
    -- Wider/taller than Ly's 37x11 form (input_len=20).
    -- Recomputed every frame; all drawing uses the same exclusion zone.
    local cx, cy = math.floor(w / 2), math.floor(h / 2)
    local mode = "compact"
    if w >= 100 and h >= 30 then mode = "full"
    elseif w >= 80 and h >= 24 then mode = "medium" end
    return {
        w = w, h = h, mode = mode,
        safe = { x = cx - 21, y = cy - 7, w = 43, h = 15 },
        emblem = { x = math.floor((cx - 23) / 2), y = cy - 1,
                   radius = math.max(1, math.min(7, math.floor((cx-27)/4))) },
        right = cx + 24,
    }
end

return M
