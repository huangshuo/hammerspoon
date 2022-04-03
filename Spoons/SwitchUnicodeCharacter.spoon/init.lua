--- === SwitchUnicodeCharacter ===
---
--- 转换Unicode字符
---

local obj = {}
obj.__index = obj

-- 插件信息
obj.name = "SwitchUnicodeCharacter"
obj.version = "0.1"
obj.author = "huangshuo <huangshuo.me@gmail.com>"
obj.homepage = "https://github.com/huangshuo/hammerspoon"
obj.license = "Apache License 2.0 - https://www.apache.org/licenses/LICENSE-2.0"

--

--- SwtichUnicodeCharacter.mapping
--- Variable
--- Unicode字符转换映射
obj.mapping = {
  [0x32] = {['original'] = "`", ['shift'] = "~",},
  -- 1~=
  [0x12] = {['original'] = "", ['shift'] = "!"},
  [0x13] = {['original'] = "", ['shift'] = "@"},
  [0x14] = {['original'] = "", ['shift'] = "#"},
  [0x15] = {['original'] = "", ['shift'] = "$"},
  [0x17] = {['original'] = "", ['shift'] = "%"},
  [0x16] = {['original'] = "", ['shift'] = "^"},
  [0x1a] = {['original'] = "", ['shift'] = "&"},
  [0x1c] = {['original'] = "", ['shift'] = "*"},
  [0x19] = {['original'] = "", ['shift'] = "("},
  [0x1d] = {['original'] = "", ['shift'] = ")"},
  [0x1b] = {['original'] = "", ['shift'] = "_"},
  [0x18] = {['original'] = "", ['shift'] = "+"},

  [0x21] = {['original'] = "[", ['shift'] = "{"},
  [0x1e] = {['original'] = "]", ['shift'] = "}",},
  [0x2a] = {['original'] = "\\", ['shift'] = "|",},
  [0x29] = {['original'] = ";", ['shift'] = ":",},
  [0x27] = {['original'] = "\'", ['shift'] = '\"',},
  [0x2b] = {['original'] = ",", ['shift'] = "<",},
  [0x2f] = {['original'] = ".", ['shift'] = ">",},
  [0x2c] = {['original'] = "/", ['shift'] = "?",},
}

--- SwitchUnicodeCharacter.logger
--- Variable
--- 内置日志对象，可通过设置默认日志级别获取日志信息(hs.logger)
obj.logger = hs.logger.new(obj.name, "debug")

--- 内部变量
--- 监控按键的eventtap对象(hs.eventtap)
local eventTap = nil

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
  local source = keyEvent:getKeyCode()
  -- obj.logger:d(source)
  for code, char in pairs(obj.mapping)
  do
    if code == source then
      local flags = keyEvent:getFlags()
      if next(flags) == nil and char['original'] then
        -- obj.logger:d("no shift")
        keyEvent:setUnicodeString(char['original'])
      elseif flags:containExactly({'shift'}) then
        -- obj.logger:d("shift")
        keyEvent:setUnicodeString(char['shift'])
      end
      break
    end
  end
end

--- SwitchUnicodeCharacter:start()
--- Method
--- 启动方法
---
--- Parameters:
--- * None
---
--- Returns:
--- * SwitchUnicodeCharacter对象
function obj:start()
  eventTap = hs.eventtap.new({hs.eventtap.event.types['keyDown'],
    hs.eventtap.event.types['flagsChanged']}, forceANSIUSCharacter)
  eventTap:start()
  self.logger:i(obj.name.." started.")
  return self
end

--- SwitchUnicodeCharacter:stop()
--- Method
--- 停止方法
---
--- Parameters:
--- * None
---
--- Returns:
--- * SwitchUnicodeCharacter对象
function obj:stop()
  if eventTap ~= nil then
    eventTap:stop()
    self.logger:i(obj.name.." stopped.")
  end
  return self
end

return obj
