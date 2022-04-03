# hammerspoon
Hammerspoon自用
- AutoSwitchInputSource
  - 为不同的app设置默认输入法，当切换至app时自动切换目标输入法
    - app可通过名称, 文件路径, 及bundleID指定
    - 输入法可指定为layout或method或sourceID(均用英文表示, 不确定时可调用hs.keycodes.currentLayout()/hs.keycodes.currentMethod()/hs.keycodes.currentSourceID()查看)
  - 设置app是否强制使用ANSI US Standard字符(英文标点)