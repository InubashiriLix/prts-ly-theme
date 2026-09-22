local M = {}

function M.new(layout, colors)
    local ctx = { layout = layout, colors = colors }
    function ctx:allowed(x, y)
        local b, s = self.layout, self.layout.safe
        return x >= 0 and x < b.w and y >= 1 and y < b.h - 1
            and not (x >= s.x and x < s.x + s.w and y >= s.y and y < s.y + s.h)
    end
    function ctx:cell(x, y, char, fg, bg)
        x, y = math.floor(x), math.floor(y)
        if self:allowed(x, y) then
            ly.putCell(char, fg or self.colors.ink, bg or self.colors.paper, x, y)
        end
    end
    function ctx:text(x, y, text, fg, bg)
        -- ASCII copy only; geometry uses explicit Unicode codepoints.
        for i = 1, #text do self:cell(x + i - 1, y, string.byte(text, i), fg, bg) end
    end
    function ctx:rule(x, y, width, fg, bg)
        for i = 0, math.max(0, math.floor(width)) - 1 do
            self:cell(x + i, y, 0x2500, fg, bg)
        end
    end
    function ctx:bar(x, y, width, text, fg, bg)
        for i = 0, width - 1 do self:cell(x + i, y, 32, fg, bg) end
        self:text(x + 1, y, string.sub(text, 1, math.max(0, width - 2)), fg, bg)
    end
    function ctx:background()
        -- Explicit repaint prevents trails in both Ly and the test renderer.
        for y = 1, self.layout.h - 2 do
            for x = 0, self.layout.w - 1 do self:cell(x, y, 32) end
        end
    end
    return ctx
end

return M
