local mash = { "ctrl", "alt", "cmd" }

local function focusAndMaximize(appName)
  hs.application.launchOrFocus(appName)

  hs.timer.doAfter(0.15, function()
    local win = hs.window.frontmostWindow()
    if not win then return end

    win:maximize()       -- fills the screen in the current Space
    win:centerOnScreen() -- optional; harmless
  end)
end

hs.hotkey.bind(mash, "K", function() focusAndMaximize("Ghostty") end)
hs.hotkey.bind(mash, "I", function() focusAndMaximize("Slack") end)
hs.hotkey.bind(mash, "N", function() focusAndMaximize("Notion") end)
hs.hotkey.bind(mash, "P", function() focusAndMaximize("Notion Calendar") end)
hs.hotkey.bind(mash, "G", function() focusAndMaximize("Google Chrome") end)
hs.hotkey.bind(mash, "D", function() focusAndMaximize("MongoDB Compass") end)
hs.hotkey.bind(mash, "L", function() focusAndMaximize("Linear") end)
hs.hotkey.bind(mash, "B", function() focusAndMaximize("Dia") end)
hs.hotkey.bind(mash, "O", function() focusAndMaximize("Obsidian") end)
hs.hotkey.bind(mash, "C", function() focusAndMaximize("Claude") end)
hs.hotkey.bind(mash, "T", function() focusAndMaximize("Telegram") end)
hs.hotkey.bind(mash, "M", function() focusAndMaximize("Mail") end)
hs.hotkey.bind(mash, "U", function() focusAndMaximize("All Gravy") end)

local function moveFocusedToNextScreen()
  local win = hs.window.frontmostWindow()
  if not win then return end
  win:moveToScreen(win:screen():next())
  win:focus()
end

local function moveFocusedToPrevScreen()
  local win = hs.window.frontmostWindow()
  if not win then return end
  win:moveToScreen(win:screen():previous())
  win:focus()
end

hs.hotkey.bind(mash, "Right", moveFocusedToNextScreen)
hs.hotkey.bind(mash, "Left", moveFocusedToPrevScreen)
