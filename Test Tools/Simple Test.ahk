; 简单测试脚本 - 直接测试INI文件读取
#SingleInstance Force

; 配置文件路径
ConfigFile := A_ScriptDir . "\Config.ini"

; 检查文件是否存在
if !FileExist(ConfigFile) {
    MsgBox("配置文件不存在: " . ConfigFile, "错误", 0x10)
    ExitApp
}

; 读取当前配置ID
CurrentConfigID := IniRead(ConfigFile, "Settings", "CurrentConfig", 1)
MsgBox("读取到的CurrentConfigID: " . CurrentConfigID)

; 读取配置数量
ConfigCount := IniRead(ConfigFile, "Settings", "ConfigCount", 2)
MsgBox("读取到的ConfigCount: " . ConfigCount)

; 读取配置1
AppName1 := IniRead(ConfigFile, "Config1", "AppName", "默认名称")
AppURL1 := IniRead(ConfigFile, "Config1", "AppURL", "默认URL")
MsgBox("配置1:`nAppName: " . AppName1 . "`nAppURL: " . AppURL1)

; 读取配置2
AppName2 := IniRead(ConfigFile, "Config2", "AppName", "默认名称")
AppURL2 := IniRead(ConfigFile, "Config2", "AppURL", "默认URL")
MsgBox("配置2:`nAppName: " . AppName2 . "`nAppURL: " . AppURL2)

; 读取当前配置
sectionName := "Config" . CurrentConfigID
CurrentAppName := IniRead(ConfigFile, sectionName, "AppName", "默认名称")
CurrentAppURL := IniRead(ConfigFile, sectionName, "AppURL", "默认URL")
MsgBox("当前配置 (" . CurrentConfigID . "):`nAppName: " . CurrentAppName . "`nAppURL: " . CurrentAppURL)