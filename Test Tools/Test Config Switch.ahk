; 测试配置切换功能
; AutoHotkey V2 Script

#SingleInstance Force

; 包含主脚本的函数
#Include Send to AI.ahk

; 测试函数
TestConfigSwitch()
{
    ; 显示当前配置
    MsgBox("当前配置: " . CurrentAppName . " (ID: " . CurrentConfigID . ")", "当前配置", 0x40)
    
    ; 测试切换到配置1
    SwitchConfig(1)
    Sleep(1000)
    
    ; 测试切换到配置2
    SwitchConfig(2)
    Sleep(1000)
    
    ; 测试切换到配置3
    SwitchConfig(3)
    Sleep(1000)
    
    ; 显示最终配置
    MsgBox("最终配置: " . CurrentAppName . " (ID: " . CurrentConfigID . ")", "最终配置", 0x40)
}

; 运行测试
TestConfigSwitch()