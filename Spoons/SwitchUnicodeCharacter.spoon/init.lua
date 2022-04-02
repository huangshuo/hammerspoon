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
  {"·", "`"},
  {"【", "["},
  {"】", "]"},
  {"、", "\\"},
  {"；", ";"},
  {"‘", "\'"},
  {"’", "\'"},
  {"，", ","},
  {"。", "."},
  {"～", "~"},
  {"！", "!"},
  {"¥", "$"},
  {"（", "("},
  {"）", ")"},
  {"——", "_"},
  {"「", "{"},
  {"」", "}"},
  {"｜", "|"},
  {"：", ":"},
  {"“", '\"'},
  {"”", '\"'},
  {"《", "<"},
  {"》", ">"},
  {"？", "?"},
}

--- SwitchUnicodeCharacter.logger
--- Variable
--- 内置日志对象，可通过设置默认日志级别获取日志信息(hs.logger)
obj.logger = hs.logger.new("SwitchUnicodeCharacter", "debug")

--- 内部变量
--- 监控按键的eventtap对象(hs.eventtap)
local eventTap = nil

-- findUnicodeCharacterInMapping(character)
--- Method
--- 查找mapping中是否有目标Unicode字符
---
--- Parameters:
--- * character - Unicode字符(string)
---
--- Returns:
--- * 存在则返回要转换的Unicode字符, 不存在则返回nil
local function findUnicodeCharacterInMapping(character)
  for index, charMapping in pairs(obj.mapping)
  do
    if charMapping[1] == character then
      -- obj.logger:d("from "..character.." to "..charMapping[2])
      return charMapping[2]
    end
  end
  return nil
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
  eventTap = hs.eventtap.new({hs.eventtap.event.types['keyDown']},
    function(event)
      local source = event:getCharacters()
      -- self.logger:d(source)
      local target = findUnicodeCharacterInMapping(source)
      if target then
        -- self.logger:d(source.." found")
        event:setUnicodeString(target)
      else
          -- self.logger:d(source.."  not found")
      end
    end)
  eventTap:start()
  return self
end

return obj
