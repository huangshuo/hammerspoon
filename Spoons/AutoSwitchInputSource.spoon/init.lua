--- === AutoSwitchInputSource ===
---
--- 为不同app切换指定的输入法, 并配置是否强制ANSI符号(英文标点)
---

local obj = {}
obj.__index = obj

-- 插件信息
obj.name = "AutoSwitchInputSource"
obj.version = "1.0"
obj.author = "huangshuo <huangshuo.me@gmail.com>"
obj.homepage = "https://github.com/huangshuo/hammerspoon"
obj.license = "Apache License 2.0 - https://www.apache.org/licenses/LICENSE-2.0"

--- 全局变量
---
--- AutoSwitchInputSource.setting
--- Variable
--- app的输入法设置
---
--- Notes:
---
--- setting.global.defaultInput = 全局默认输入法(layout/method/sourceID)
--- setting.global.forceAnsi = 全局设置是否强制使用ANSI字符
---
--- setting.custom: key = app的标识符(name/path/bundleID)
--- setting.custom: value.defaultInput = 该app的默认输入法(layout/method/sourceID)
--- setting.custom: value.forceAnsi = 是否强制使用ANSI字符
obj.setting = {
  global = {
    defaultInput = "Shuangpin - Simplified",
    forceAnsi = false
  },
  custom = {
    ['iTerm2'] = {defaultInput = 'ABC', forceAnsi = true},
    ['/Applications/Visual Studio Code.app'] = {defaultInput = 'ABC', forceAnsi = true},
    ['org.hammerspoon.Hammerspoon'] = {defaultInput = 'com.apple.keylayout.ABC', forceAnsi = false}
  }
}
---
--- AutoSwitchInputSource.logger
--- Variable
--- 内置日志对象，可通过设置默认日志级别获取日志信息(hs.logger)
obj.logger = hs.logger.new(obj.name, "debug")

--- 本地变量
---
--- 监控应用的watcher对象(hs.application.watcher)
local appWatcher = nil
--- 监控按键按下或修饰键按下时间的eventtap对象(hs.eventtap)
local eventTap = nil
--- 是否使用ANSI-US-Standard字符
local useAnsi = obj.setting.global.forceAnsi
--- 字符转换映射
local ansiMapping = {
  [0x32] = {original= "`", shift = "~",},
  -- 1~=
  [0x12] = {original = "", shift = "!"},
  [0x13] = {original = "", shift = "@"},
  [0x14] = {original = "", shift = "#"},
  [0x15] = {original = "",  shift = "$"},
  [0x17] = {original = "", shift = "%"},
  [0x16] = {original = "", shift = "^"},
  [0x1a] = {original = "", shift = "&"},
  [0x1c] = {original = "", shift = "*"},
  [0x19] = {original = "", shift = "("},
  [0x1d] = {original = "", shift = ")"},
  [0x1b] = {original = "", shift = "_"},
  [0x18] = {original = "", shift = "+"},

  [0x21] = {original = "[", shift = "{"},
  [0x1e] = {original = "]", shift = "}",},
  [0x2a] = {original = "\\", shift = "|",},
  [0x29] = {original = ";", shift = ":",},
  [0x27] = {original = "\'", shift = '\"',},
  [0x2b] = {original = ",", shift = "<",},
  [0x2f] = {original = ".", shift = ">",},
  [0x2c] = {original = "/", shift = "?",},
}

--- 本地方法
---
--- switchInputSourceTo(inputFlag)
--- Method
--- 切换输入法
---
--- Parameters:
--- * inputFlag - 目标输入法(method/layout/sourceID)
---
--- Returns:
--- * None
local function switchInputSourceTo(inputFlag)
  -- 当前输入法与配置的输入法不同则切换输入法
  if inputFlag ~= hs.keycodes.currentSourceID() and
  inputFlag ~= hs.keycodes.currentMethod() and inputFlag ~= hs.keycodes.currentLayout()
  then
    -- inputFlag为layout
    if hs.fnutils.contains(hs.keycodes.methods(), inputFlag) then
      hs.keycodes.setMethod(inputFlag)
    -- inputFlag为method
    elseif hs.fnutils.contains(hs.keycodes.layouts(), inputFlag) then
      hs.keycodes.setLayout(inputFlag)
    -- 不为layout/method时通过sourceID设置输入法
    elseif not hs.keycodes.currentSourceID(inputFlag) then
      obj.logger:w("inputSource "..inputFlag.." not enabled.")
    end
  end
end
---
--- getInputSetting(appFlag)
--- Method
--- 查找appFlag对应的输入法设置
--- inputSetting.defaultInput = 该app的默认输入法(layout/method/sourceID)
--- inputSetting.forceAnsi = 该app是否强制使用ANSI字符
---
--- Parameters:
--- * target - app的name/path/bundleID
---
--- Returns:
--- * 存在则返回对应的输入法设置, 不存在则返回nil
local function getInputSetting(target)
  for appFlag, inputSetting in pairs(obj.setting.custom)
    do
      if target == appFlag then
        -- obj.logger:d(appFlag..">>>")
        return inputSetting
      end
    end
  return nil
end
---
--- autoSwitchInputSource(appName, eventType, app)
--- Method
--- appWatcher事件触发时执行的方法
---
--- Parameters:
--- * appName - 触发事件的app的名称
--- * eventType - 触发事件类型(hs.application.watcher.activated/deactivated/launched/launching/hidden/unhidden/terminated)
--- * app - app对象(hs.application)
---
--- Returns:
--- * None
local function autoSwitchInputSource(appName, eventType, app)
  if eventType == hs.application.watcher.activated then
    -- 通过app的name查找
    local setting = getInputSetting(appName)
    if setting == nil then
      -- 通过path查找
      setting = getInputSetting(app:path())
      if setting == nil then
        -- 通过bundleID查找
        setting = getInputSetting(app:bundleID())
      end
    end
    if not setting then
      -- 该app无用户设置时使用全局默认设置
      setting = obj.setting.global
    end
    obj.logger:i(appName..">>>defaultInput="..setting.defaultInput..", forceAnsi="..tostring(setting.forceAnsi))
    -- 切换目标输入法
    switchInputSourceTo(setting.defaultInput)
    -- 当前app是否强制使用ANSI字符
    useAnsi = setting.forceAnsi
  end
end
---
--- forceANSIUSCharacter(keyEvent)
--- Method
--- 对按键事件强制使用ANSI US标准字符
---
--- Parameters:
--- * keyEvent - 按键事件
---
--- Returns:
--- * 返回强制使用的ANSI字符
local function forceANSIUSCharacter(keyEvent)
  if useAnsi then
    local source = keyEvent:getKeyCode()
    -- 查找ansi字符映射
    for code, char in pairs(ansiMapping)
    do
      if code == source then
        local flags = keyEvent:getFlags()
        -- 无修饰键
        if next(flags) == nil and char.original then
          -- obj.logger:d("no shift")
          keyEvent:setUnicodeString(char.original)
        -- 修饰键中仅按下shift
        elseif flags:containExactly({'shift'}) then
          -- obj.logger:d("shift")
          keyEvent:setUnicodeString(char.shift)
        end
        break
      end
    end
  end
end

---全局方法
---
--- AutoSwitchInputSource:start()
--- Method
--- 启动方法
---
--- Parameters:
--- * None
---
--- Returns:
--- * AutoSwitchInputSource对象
function obj:start()
  appWatcher = hs.application.watcher.new(autoSwitchInputSource):start()
  eventTap = hs.eventtap.new({hs.eventtap.event.types['keyDown'],
    hs.eventtap.event.types['flagsChanged']}, forceANSIUSCharacter):start()
  return self
end
---
--- AutoSwitchInputSource:stop()
--- Method
--- 停止方法
---
--- Parameters:
--- * None
---
--- Returns:
--- * AutoSwitchInputSource对象
function obj:stop()
  appWatcher:stop()
  eventTap:stop()
  return self
end


return obj
