hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "W", function()
  hs.notify.new({ title = "Hammerspoon", informativeText = "Hello World" }):send()
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "S", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()

  f.x = 100
  f.y = 100
  f.w = 1600
  f.h = 1013

  win:setFrame(f)
end)

function reloadConfig(files)
  doReload = false
  for _, file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
  end
end

myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")
