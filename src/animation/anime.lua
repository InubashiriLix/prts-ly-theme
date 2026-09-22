-- PRTS / Rhodes Island login animation for Ly 1.5+.
-- Ly executes this file in a restricted LuaJIT environment: do not use require/io.
local WHITE = 0x00EAF6F7
local CYAN = 0x0039D5E8
local DIM = 0x00658A91
local ACCENT = 0x00F0B342
local BG = 0x00070C0E
local BOLD_CYAN = 0x0139D5E8

local TICK_US = 80000
local last_tick = ly.clock()
local frame = 0

local function label(text, color, x, y)
    -- Ly does not clip labels for us.  All copy is ASCII, so byte slicing is
    -- also character-safe here and keeps narrow VTs free from wrapping.
    x = math.max(0, x)
    if y >= 0 and y < ly.height and x < ly.width then
        ly.putLabel(string.sub(text, 1, ly.width - x), color, BG, x, y)
    end
end

local function line(char, color, x, y, width)
    x = math.max(0, x)
    width = math.min(width, ly.width - x)
    if width > 0 and y >= 0 and y < ly.height then
        ly.putRect(string.byte(char), color, BG, x, y, width, 1)
    end
end

local function draw_mark(x, y)
    -- Compact Rhodes Island-inspired triangular mark, kept clear of the login box.
    local rows = { "     /\\     ", "    /##\\    ", "   /####\\   ", "  /######\\  ", " /________\\ ", "    ||||    " }
    for i, row in ipairs(rows) do
        label(row, i == 5 and ACCENT or CYAN, x, y + i - 1)
    end
end

local function draw_hud()
    local w, h = ly.width, ly.height
    local compact = w < 80 or h < 24

    -- The login widget is centred by Ly.  On short or narrow terminals it
    -- owns nearly the whole frame, so leave it entirely undecorated instead
    -- of letting HUD strings wrap into or visually compete with the fields.
    if compact then
        line("=", CYAN, 1, 1, w - 2)
        label("P R T S", BOLD_CYAN, 2, 2)
        label("AUTHORIZATION", DIM, math.max(2, w - 15), 2)
        line("=", CYAN, 1, h - 2, w - 2)
        return
    end

    -- A normal Ly box is about 45 columns wide and 11 rows high with this
    -- configuration.  Keep a generous central exclusion zone: the Lua layer
    -- is painted after the widget, so a moving line must never cross it.
    local box_top = math.floor(h / 2) - 7
    local box_bottom = math.floor(h / 2) + 7
    local top_first, top_last = 5, box_top - 1
    local bottom_first, bottom_last = box_bottom + 1, h - 6
    local top_count = math.max(0, top_last - top_first + 1)
    local bottom_count = math.max(0, bottom_last - bottom_first + 1)
    local scan_count = top_count + bottom_count
    local scan_y = nil
    if scan_count > 0 then
        local scan_index = frame % scan_count
        if scan_index < top_count then
            scan_y = top_first + scan_index
        else
            scan_y = bottom_first + scan_index - top_count
        end
    end
    local pulse = (frame % 16) < 8 and BOLD_CYAN or CYAN

    line("=", CYAN, 2, 1, math.max(0, w - 4))
    label("P R T S", BOLD_CYAN, 3, 2)
    label("PERSONAL  RECOGNITION  TRANSMISSION  SYSTEM", DIM, 3, 3)
    label("RHODES ISLAND // NEURAL INTERFACE", pulse, math.max(3, w - 36), 2)

    draw_mark(4, 6)
    label("R H O D E S", WHITE, 3, 13)
    label("I S L A N D", WHITE, 3, 14)

    if scan_y then
        line("-", DIM, 2, scan_y, math.max(0, w - 4))
        label("// SYNCHRONIZING", DIM, math.max(3, w - 22), scan_y)
    end

    label("[ SYSTEM STATUS ]", DIM, 3, h - 6)
    label("UPLINK: STABLE", CYAN, 3, h - 5)
    label("ACCESS CHANNEL: SECURE", DIM, 3, h - 4)
    if w >= 92 and h >= 28 then
        label("OPERATOR AUTHORIZATION REQUIRED", ACCENT, math.max(3, w - 34), h - 4)
    end
    line("=", CYAN, 2, h - 2, math.max(0, w - 4))
end

function draw()
    local now = ly.clock()
    if now - last_tick >= TICK_US then
        frame = frame + 1
        last_tick = now
    end
    draw_hud()
end
