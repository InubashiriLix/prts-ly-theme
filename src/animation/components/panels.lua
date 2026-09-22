local M = {}

local letters = {
    -- 5x5 display glyphs: cleaner counters and a shared baseline than the
    -- original 4x5 shapes, while remaining legible on small TTYs.
    {"11110", "10001", "11110", "10000", "10000"}, -- P
    {"11110", "10001", "11110", "10100", "10010"}, -- R
    {"11111", "00100", "00100", "00100", "00100"}, -- T
    {"01111", "10000", "01110", "00001", "11110"}, -- S
}

local function wordmark(ctx, t, C)
    for i, glyph in ipairs(letters) do
        for row = 1, 5 do
            for col = 1, 5 do
                local x = 7 + (i-1)*6 + col-1
                if glyph[row]:sub(col,col) == "1" and x <= 7+23*t.rules then
                    ctx:cell(x, row, 0x2588, C.ink)
                end
            end
        end
    end
end

local function accent(C, mode)
    return mode == "cyan" and C.cyan or C.orange
end

local function micro_panel(ctx, x, y, width, title, value, C, highlight)
    ctx:text(x, y, title, C.muted)
    ctx:rule(x, y + 1, width, C.grid)
    ctx:bar(x, y + 2, width, value, C.white, highlight and C.ink or C.muted)
end

local function telemetry(ctx, b, t, C, highlight)
    if b.mode ~= "full" or t.density == "sparse" then return end
    -- Use the otherwise empty margins as a quiet instrument readout.  The
    -- center exclusion zone belongs to Ly's native login form.
    micro_panel(ctx, 3, 8, 25, "MEMORY / 04", "ARCHIVE  86%", C, false)
    micro_panel(ctx, 3, 29, 25, "LINK / PRIESTESS", t.ready and "AWAKE  100%" or "WAKING  ...", C, t.ready)
    ctx:text(3, 33, "NODES  04   CACHE  12", C.muted)
    ctx:cell(27, 33, 0x25A0, highlight)

    micro_panel(ctx, b.right, 29, b.w - b.right - 3,
        "SYNCHRONIZATION", t.ready and "STABLE  98.4" or "NEGOTIATING", C, t.ready)
    ctx:text(b.right, 33, "R.I. // ANALYSIS CHANNEL", C.muted)
end

function M.draw(ctx, b, t, C)
    local highlight = accent(C, t.accent_mode)
    if b.mode == "compact" then
        ctx:rule(1, 1, b.w-2, C.muted)
        ctx:text(2, 2, "PRTS / ANALYSIS OS", C.bold)
        ctx:rule(1, b.h-2, b.w-2, C.muted)
        return
    end
    ctx:bar(2, 2, 3, "", highlight, highlight)
    if b.mode == "full" and t.density ~= "sparse" then
        wordmark(ctx, t, C)
        ctx:text(33, 2, "A N A L Y S I S  O S", C.bold)
        ctx:text(33, 4, "SYNTHESIZE INFORMATION", C.muted)
    else
        ctx:text(7, 2, "P R T S", C.bold)
        ctx:text(7, 3, "ANALYSIS OS", C.ink)
        ctx:text(24, 2, "SYNTHESIZE INFORMATION", C.muted)
    end
    ctx:text(b.w-17, 2, "R.I. // A-01", C.muted)
    ctx:rule(2, b.mode == "full" and 6 or 4, math.floor((b.w-4)*t.rules), C.ink)
    if b.mode == "full" then
        ctx:text(3, 7, "PRIMITIVE RHODES ISLAND TERMINAL SERVICE", C.muted)
        for x = 3, b.w-4, 8 do ctx:text(x, b.h-4, "+", C.grid) end
        local width = b.w-b.right-3
        local rows = {"> TERMINAL INTERFACE", "> DISPLAY INITIALIZED", "> AWAITING OPERATOR"}
        for i, text in ipairs(rows) do
            if t.density ~= "sparse" and (t.density == "dense" or i <= 3) then
                local reveal = math.min(1, math.max(0, t.panels*3-(i-1)))
                ctx:bar(b.right, math.floor(b.h/2)-3+(i-1)*2,
                        math.floor(width*reveal), text, C.white, C.ink)
            end
        end
        if t.ready then
            local y = math.floor(b.h/2)+4
            ctx:rule(b.right, y, width, C.grid)
            local offset = t.moving and math.floor(t.seconds*4)%math.max(1,width) or 0
            ctx:cell(b.right+offset, y, 0x2588, highlight)
            ctx:text(b.right, y+2, "IDENTIFY YOURSELF", C.muted)
        end
    end
    if t.panels > 0 then
        ctx:bar(3, b.h-3, math.floor((b.w-6)*t.panels),
                "> OPERATOR AUTHORIZATION REQUIRED", C.white, C.ink)
    end
    telemetry(ctx, b, t, C, highlight)
    ctx:rule(2, b.h-2, math.floor((b.w-4)*t.rules), C.muted)
    if t.ready then
        local pulse = math.floor(150+60*t.pulse)*65536 + 70*256 + 12
        ctx:cell(b.w-5, b.h-3, 0x2588, pulse, C.ink)
    end
end

return M
