--- === SwitchUnicodeCharacter ===
---
--- 转换Unicode字符
---

local obj = {}
obj.__index = obj

-- 插件信息
obj.name = "SwitchUnicodeCharacter"
obj.version = "0.1"
obj.author = "Huang Shuo <hs.chn@qq.com>"
obj.homepage = "https://github.com/huangshuo/hammerspoon"
obj.license = "Apache License 2.0 - https://www.apache.org/licenses/LICENSE-2.0"

--

--- SwtichUnicodeCharacter.mapping
--- Variable
--- Unicode字符转换映射
obj.mapping = {
  -- ["`"] = 0x32, ["1"] = 0x12, ["2"] = 0x13,
  -- ["3"] = 0x14, ["4"] = 0x15, ["5"] = 0x17,
  -- ["6"] = 0x16, ["7"] = 0x1a, ["8"] = 0x1c,
  -- ["9"] = 0x19, ["0"] = 0x1d, ["-"] = 0x1b,
  -- ["="] = 0x18, ["["]  = 0x21, ["]"] = 0x1e,
  -- ["\\"] = 0x2a, [";"] = 0x29, ["'"] = 0x27,
  -- [","] = 0x2b, ["."] = 0x2f, ["/"] = 0x2c,

  [0x32] = {['original'] = "`", ['shift'] = "~",},
  [0x12] = {['original'] = "1", ['shift'] = "!"},
  [0x13] = {['original'] = "2", ['shift'] = "@"},
  [0x14] = {['original'] = "3", ['shift'] = "#"},
  [0x15] = {['original'] = "4", ['shift'] = "$"},
  [0x17] = {['original'] = "5", ['shift'] = "%"},
  [0x16] = {['original'] = "6", ['shift'] = "^"},
  [0x1a] = {['original'] = "7", ['shift'] = "&"},
  [0x1c] = {['original'] = "8", ['shift'] = "*"},
  [0x19] = {['original'] = "9", ['shift'] = "("},
  [0x1d] = {['original'] = "0", ['shift'] = ")"},
  [0x1b] = {['original'] = "-", ['shift'] = "_"},
  [0x18] = {['original'] = "=", ['shift'] = "+"},
  [0x21] = {['original'] = "[", ['shift'] = "{"},
  [0x1e] = {['original'] = "]", ['shift'] = "}",},
  [0x2a] = {['original'] = "\\", ['shift'] = "|",},
  [0x29] = {['original'] = ";", ['shift'] = ":",},
  [0x27] = {['original'] = "\'", ['shift'] = '\"',},
  [0x2b] = {['original'] = ",", ['shift'] = "<",},
  [0x2f] = {['original'] = ".", ['shift'] = ">",},
  [0x2c] = {['original'] = "/", ['shift'] = "?",},

  -- [0x32] = "`", [0x12] = "1", [0x13] = "2",
  -- [0x14] = "3", [0x15] = "4", [0x17] = "5",
  -- [0x16] = "6", [0x1a] = "7", [0x1c] = "8",
  -- [0x19] = "9", [0x1d] = "0", [0x1b] = "-",
  -- [0x18] = "=", [0x21]  = "[", [0x1e] = "]",
  -- [0x2a] = "\\", [0x29] = ";", [0x27] = "'",
  -- [0x2b] = ",", [0x2f] = ".", [0x2c] = "/",

  -- ["pad0"] = 0x52, ["pad1"] = 0x53, ["pad2"] = 0x54,
  -- ["pad3"] = 0x55, ["pad4"] = 0x56, ["pad5"] = 0x57,
  -- ["pad6"] = 0x58, ["pad7"] = 0x59, ["pad8"] = 0x5b,
  -- ["pad9"] = 0x5c, ["padclear"] = 0x47, ["pad."] = 0x41,
  -- ["pad/"] = 0x4b, ["padenter"] = 0x4c,  ["pad="]     = 0x51,
  -- ["pad-"] = 0x4e, ["pad*"] = 0x43, ["pad+"] = 0x45
}

--- SwitchUnicodeCharacter.logger
--- Variable
--- 内置日志对象，可通过设置默认日志级别获取日志信息(hs.logger)
obj.logger = hs.logger.new("SwitchUnicodeCharacter", "debug")

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
      if next(flags) == nil then
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
--- * None
function obj:stop()
  if eventTap == nil then
    self.logger:d("SwitchUnicodeCharacter已停止")
  else
    eventTap:stop()
    eventTap = nil
  end
end

return obj
