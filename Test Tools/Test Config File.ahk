; 简单测试配置切换功能
; AutoHotkey V2 Script

#SingleInstance Force

; 全局变量
ConfigFile := A_ScriptDir . "\..\Config.ini"

; 测试函数
TestConfigFile()
{
    ; 读取当前配置
    currentConfig := IniRead(ConfigFile, "Settings", "CurrentConfig", "1")
    MsgBox("当前配置ID: " . currentConfig, "当前配置", 0x40)
    
    ; 尝试写入新配置
    newConfig := "2"
    IniWrite(newConfig, ConfigFile, "Settings", "CurrentConfig")
    
    ; 再次读取确认
    updatedConfig := IniRead(ConfigFile, "Settings", "CurrentConfig", "1")
    MsgBox("更新后配置ID: " . updatedConfig, "更新后配置", 0x40)
    
    ; 恢复原始配置
    IniWrite(currentConfig, ConfigFile, "Settings", "CurrentConfig")
    MsgBox("已恢复原始配置ID: " . currentConfig, "恢复配置", 0x40)
}

; 运行测试
TestConfigFile()