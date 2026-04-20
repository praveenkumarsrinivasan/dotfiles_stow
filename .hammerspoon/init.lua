-- init.lua — Hammerspoon config (managed via dotfiles / stow)
--
-- Stow symlinks ~/.hammerspoon/ → ~/dotfiles/.hammerspoon/, so this file
-- and its siblings are Hammerspoon's canonical config location.

local switcher = require("ghostty_switcher")

-- Hotkey: ⌥G → fuzzy Ghostty window/tab switcher.
hs.hotkey.bind({"alt"}, "g", function()
  switcher.show()
end)

-- Auto-reload on edits to any .lua file in this directory.
hs.pathwatcher.new(hs.configdir, function(files)
  for _, f in ipairs(files) do
    if f:sub(-4) == ".lua" then
      hs.reload()
      return
    end
  end
end):start()

hs.alert.show("Ghostty switcher ready — ⌥G")
