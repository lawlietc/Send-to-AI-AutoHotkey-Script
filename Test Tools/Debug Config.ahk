; 调试配置读取的测试脚本
#SingleInstance Force

ConfigFile := A_ScriptDir . "\Config.ini"

; 读取当前配置ID
CurrentConfigID := IniRead(ConfigFile, "Settings", "CurrentConfig", 1)
MsgBox("CurrentConfigID: " . CurrentConfigID)

; 读取配置数量
ConfigCount := IniRead(ConfigFile, "Settings", "ConfigCount", 2)
MsgBox("ConfigCount: " . ConfigCount)

; 读取当前配置的应用名称和URL
sectionName := "Config" . CurrentConfigID
CurrentAppName := IniRead(ConfigFile, sectionName, "AppName", "豆包")
CurrentAppURL := IniRead(ConfigFile, sectionName, "AppURL", "https://www.doubao.com/chat/")

MsgBox("配置 " . CurrentConfigID . ":" . "`nAppName: " . CurrentAppName . "`nAppURL: " . CurrentAppURL)

; 检查文件是否存在
MsgBox("Config.ini 文件路径: " . ConfigFile . "`n文件是否存在: " . FileExist(ConfigFile))