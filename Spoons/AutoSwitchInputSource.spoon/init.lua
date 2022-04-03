--- === AutoSwitchInputSource ===
---
--- 为不同app切换指定的输入法
---

local obj = {}
obj.__index = obj

-- 插件信息
obj.name = "AutoSwitchInputSource"
obj.version = "0.1"
obj.author = "huangshuo <huangshuo.me@gmail.com>"
obj.homepage = "https://github.com/huangshuo/hammerspoon"
obj.license = "Apache License 2.0 - https://www.apache.org/licenses/LICENSE-2.0"

-- 用户配置变量

--- AutoSwitchInputSource.default
--- Variable
--- 系统默认输入法
obj.default = "Shuangpin - Simplified"

--- AutoSwitchInputSource.mapping
--- Variable
--- app的默认输入法
--- Notes: key = app的name/path/bundleID, value = 输入法layout/method/sourceID
obj.mapping = {
  -- name <--> layout
  ['iTerm2'] = 'ABC',
  -- path <--> layout
  ['/Applications/Visual Studio Code.app'] = 'ABC',
  -- name <--> method
  ['Google Chrome'] = 'Shuangpin - Simplified',
  -- bundleID <--> sourceID
  ['org.hammerspoon.Hammerspoon'] = 'com.apple.keylayout.ABC',
}

--- AutoSwitchInputSource.logger
--- Variable
--- 内置日志对象，可通过设置默认日志级别获取日志信息(hs.logger)
obj.logger = hs.logger.new(obj.name, "debug")

--- 内部变量
--- 监控应用的watcher对象(hs.application.watcher)
local appWatcher = nil

--- switchInputSourceTo(inputFlag)
--- Method
--- 切换输入法
---
--- Parameters:
--- * inputFlag - 目标输入法(method/layout), 为空时切换obj.default设置的输入法
---
--- Returns:
--- * None
local function switchInputSourceTo(inputFlag)
  inputFlag = inputFlag or obj.default
  -- 切换输入法
  if inputFlag ~= hs.keycodes.currentSourceID() and
  inputFlag ~= hs.keycodes.currentMethod() and inputFlag ~= hs.keycodes.currentLayout()
  then
    if hs.fnutils.contains(hs.keycodes.methods(), inputFlag) then
      hs.keycodes.setMethod(inputFlag)
    elseif hs.fnutils.contains(hs.keycodes.layouts(), inputFlag) then
      hs.keycodes.setLayout(inputFlag)
    elseif not hs.keycodes.currentSourceID(inputFlag) then
      obj.logger:w("inputSource "..inputFlag.." not enabled.")
    end
  end
end

--- findTargetInputSourceInMapping(appFlag)
--- Method
--- 查找appFlag对应的输入法(layout/method)
---
--- Parameters:
--- * target - app的name/path/bundleID(string)
---
--- Returns:
--- * 存在则返回对应的输入法(layout/method), 不存在则返回nil
local function findTargetInputSourceInMapping(target)
  for appFlag, inputFlag in pairs(obj.mapping)
    do
      if target == appFlag then
        -- obj.logger:d(appFlag..">>>")
        return inputFlag
      end
    end
  return nil
end

--- autoSwitchInputSource(appName, eventType, app)
--- Method
--- appWatcher事件触发时执行的方法
--- Parameters:
--- * appName - 触发事件的app的名称
--- * eventType - 触发事件类型(hs.application.watcher.activated/deactivated/launched/launching/hidden/unhidden/terminated)
--- * app - app对象(hs.application)
local function autoSwitchInputSource(appName, eventType, app)
  if eventType == hs.application.watcher.activated then
    local target = findTargetInputSourceInMapping(appName)
    if target == nil then
      target = findTargetInputSourceInMapping(app:path())
      if target == nil then
        target = findTargetInputSourceInMapping(app:bundleID())
      end
    end
    if target then
      -- obj.logger:d(appName..">>>"..target)
      switchInputSourceTo(target)
    else
      -- obj.logger:d(appName..">>> default = "..obj.default)
      switchInputSourceTo(obj.default)
    end
  end
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
  appWatcher = hs.application.watcher.new(autoSwitchInputSource)
  appWatcher:start()
  self.logger:i(obj.name.." started.")
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
  if appWatcher ~= nil then
    appWatcher:stop()
    self.logger:i(obj.name.." stopped.")
  end
  return self
end

return obj
