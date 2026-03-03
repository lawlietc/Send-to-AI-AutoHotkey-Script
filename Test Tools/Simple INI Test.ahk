#SingleInstance Force

; 直接测试INI文件读取
configFile := A_ScriptDir . "\Config.ini"

; 读取当前配置ID
currentConfig := IniRead(configFile, "Settings", "CurrentConfig", "1")

; 读取配置数量
configCount := IniRead(configFile, "Settings", "ConfigCount", "1")

; 读取当前配置的应用名称和URL
appName := IniRead(configFile, "Config" . currentConfig, "AppName", "")
appURL := IniRead(configFile, "Config" . currentConfig, "AppURL", "")

; 显示结果
MsgBox("配置文件路径: " . configFile . "`n`n当前配置ID: " . currentConfig . "`n配置数量: " . configCount . "`n应用名称: " . appName . "`n应用URL: " . appURL, "INI文件读取测试", 0x40)