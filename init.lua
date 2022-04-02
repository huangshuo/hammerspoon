-- Spoons

hs.loadSpoon("AutoSwitchInputSource")
spoon.AutoSwitchInputSource.default = "Shuangpin - Simplified"
spoon.AutoSwitchInputSource.mapping = {
  {"iTerm2", "ABC"},
  {"/Applications/Visual Studio Code.app", "ABC"},
  {"org.hammerspoon.Hammerspoon", "ABC"},
  {"Setapp", "ABC"},
  {"Dash", "ABC"},
  {"终端", "ABC"},
  {"Gitfox","ABC"}
}
spoon.AutoSwitchInputSource:start()

hs.loadSpoon("SwitchUnicodeCharacter")
spoon.SwitchUnicodeCharacter:start()

-- hs.loadSpoon("PopupTranslateSelection")
-- spoon.PopupTranslateSelection:bindHotkeys({translate_en_zh = { { "ctrl", "alt", "cmd" }, "E"}})

-- hs.loadSpoon("DeepLTranslate")
-- spoon.DeepLTranslate:bindHotkeys({translate = { { "ctrl", "alt", "cmd" }, "E"}})

-- hs.loadSpoon("TextClipboardHistory")
-- spoon.TextClipboardHistory:bindHotkeys({
--   show_clipboard = { { "ctrl", "alt", "cmd" }, "E"},
--   toggle_clipboard = { { "ctrl", "alt", "cmd" }, "E"}
-- })
-- spoon.TextClipboardHistory:start()

-- hs.loadSpoon("MenubarFlag")
-- spoon.MenubarFlag:start()