local M = {}
local elapsed, previous = 0, nil

function M.sample(now, options)
    if previous then
        -- ly.clock is wall time: tolerate backward corrections and pauses.
        elapsed = elapsed + math.min(0.25, math.max(0, (now - previous) / 1000000))
    end
    previous = now
    local speed = math.max(0.1, tonumber(options.scan_speed) or 1.0)
    local t = options.entrance and elapsed or elapsed + 2.4
    if options.reduced_motion then t = 2.4 end
    local function phase(start, duration)
        local p = math.min(1, math.max(0, (t - start) / duration))
        return 1 - (1 - p) ^ 3
    end
    return {
        seconds = t, speed = speed, rules = phase(0, 0.6), emblem = phase(0.6, 1),
        panels = phase(1.6, 0.8), ready = t >= 2.4,
        moving = not options.reduced_motion,
        density = options.density or "balanced",
        accent_mode = options.accent_mode or "orange",
        pulse = options.reduced_motion and 1 or (0.65 + 0.35 * math.sin(t * 1.5)),
    }
end

return M
