-- Entry point. Edit components, not the generated build/animation/anime.lua.
local C = require("theme.color")
local options = require("theme.options")
local canvas = require("core.canvas")
local layout = require("core.layout")
local timeline = require("core.timeline")
local emblem = require("components.prts_icon")
local panels = require("components.panels")

function draw()
    local bounds = layout.measure(ly.width, ly.height)
    local time = timeline.sample(ly.clock(), options)
    local ctx = canvas.new(bounds, C)
    ctx:background()
    panels.draw(ctx, bounds, time, C)
    emblem.draw(ctx, bounds, time, C)
end
