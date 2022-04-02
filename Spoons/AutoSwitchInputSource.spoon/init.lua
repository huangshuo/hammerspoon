--- === AutoSwitchInputSource ===
---
--- 为不同app切换指定的输入法
---

local obj = {}
obj.__index = obj

-- 插件信息
obj.name = "AutoSwitchInputSource"
obj.version = "0.1"
obj.author = "Huang Shuo <hs.chn@qq.com>"
obj.homepage = "https://github.com/huangshuo/hammerspoon"
obj.license = "Apache License 2.0 - https://www.apache.org/licenses/LICENSE-2.0"

-- 用户配置变量

--- AutoSwitchInputSource.default
--- Variable
--- 系统默认输入法
obj.default = "ABC"

--- AutoSwitchInputSource.mapping
--- Variable
--- app的默认输入法(app的name/title/path/bundleID)
obj.mapping = {
  {"iTerm2", "Shuangpin - Simplified"},
  {"/Applications/Visual Studio Code.app", "Shuangpin - Simplified"},
  {"org.hammerspoon.Hammerspoon", "Shuangpin - Simplified"},
}

--- AutoSwitchInputSource.logger
--- Variable
--- 内置日志对象，可通过设置默认日志级别获取日志信息(hs.logger)
obj.logger = hs.logger.new("AutoSwitchInputSource", "debug")

--- 内部变量
--- 监控应用的watcher对象(hs.application.watcher)
local applicationWatcher = nil

--- AutoSwitchInputSource:switchInputSourceForAppFlag(appFlag)
--- Method
--- 为app切换指定的输入法
---
--- Parameters:
--- * appFlag - app的name/path/bundleID(string), 为nil时切换obj.default设置的输入法
---
--- Returns:
--- * AutoSwitchInputSource对象
function obj:switchInputSourceForAppFlag(appFlag)
  local target = nil
  -- 使用默认输入法
  if appFlag == nil then
    target = self.default
  else
    -- 获取app默认输入法
    for index, appMapping in pairs(self.mapping)
    do
      if appMapping[1] == appFlag then 
        target = appMapping[2]
        break
      end
    end
  end
  -- 切换输入法
  local current = hs.keycodes.currentSourceID()
  if target ~= hs.keycodes.currentSourceID() and
    target ~= hs.keycodes.currentMethod() and target ~= hs.keycodes.currentLayout()
  then
    -- self.logger:d("需要切换输入法: appFlag="..appFlag.." current="..current.." target="..target)
    self:switchInputSourceToInputFlag(target)
  -- else
  --   self.logger:d("不需要切换输入法: appFlag="..appFlag.." current="..current.." target="..target)
  end
  return self
end

--- AutoSwitchInputSource:switchInputSourceToInputFlag(inputFlag)
--- Method
--- 切换指定的输入法
---
--- Parameters:
--- * inputFlag - 目标输入法(method/layout/sourceID), 不指定时切换默认输入法(string)
---
--- Returns:
--- * AutoSwitchInputSource对象
function obj:switchInputSourceToInputFlag(inputFlag)
  inputFlag = inputFlag or self.default
  local switched = false
  for index, flag in pairs(hs.keycodes.methods())
  do
    -- self.logger:d("flag in methods: "..flag)
    if flag == inputFlag then
      -- self.logger:d("found method: "..flag)
      switched = hs.keycodes.setMethod(inputFlag)
      -- if switched then
      --   self.logger:d("切换成功, method = "..inputFlag)
      -- end
      break
    end
  end
  if not switched then
    for index, flag in pairs(hs.keycodes.layouts())
    do
      -- self.logger:d("flag in layouts: "..flag)
      if flag == inputFlag then
        -- self.logger:d("found layout: "..flag)
        switched = hs.keycodes.setLayout(inputFlag)
        -- if switched then
        --   self.logger:d("切换成功, layout = "..inputFlag)
        -- end
        break
      end
    end
  end
  if not switched then
    -- self.logger:d("no method or method found")
    switched = hs.keycodes.currentSourceID(inputFlag)
  end
  if not switched then
    self.logger:e("输入法切换失败, 请检查mapping")
  end
  return self
end

--- findAppFlagInMapping(appFlag)
--- Method
--- 查找mapping中是否有目标appFlag
---
--- Parameters:
--- * appFlag - app的name/path/bundleID(string)
---
--- Returns:
--- * 存在则返回appFlag, 不存在则返回nil
local function findAppFlagInMapping(appFlag)
  -- obj.logger:d("查找appFlag = "..appFlag)
  for index, appMapping in pairs(obj.mapping)
    do
      if appMapping[1] == appFlag then
        -- obj.logger:d("appFlag = "..appFlag.." found.")
        return appFlag
      end
    end
  return nil
end

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
  applicationWatcher = hs.application.watcher.new(
    function(appName, eventType, app)
      if (eventType == hs.application.watcher.activated) then
        local appFlag = findAppFlagInMapping(appName)
        if not appFlag then
          -- obj.logger:d("name not found.")
          appFlag = findAppFlagInMapping(app:path())
        end
        if not appFlag then
          -- obj.logger:d("path not found.")
          appFlag = findAppFlagInMapping(app:bundleID())
        end
        if not appFlag then
          -- obj.logger:d(appName.."未设置mapping, 切换至使用默认输入法")
          obj:switchInputSourceToInputFlag(obj.default)
        else
          obj:switchInputSourceForAppFlag(appFlag)
        end
      end
    end)
  applicationWatcher:start()
  return self
end

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
  if applicationWatcher == nil then
    self.logger:d("AutoSwitchInputSource已停止")
  else
    applicationWatcher:stop()
    applicationWatcher = nil
  end
end

return obj
