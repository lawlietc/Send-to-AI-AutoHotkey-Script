; 测试配置加载的脚本
#SingleInstance Force
#Include "Send to AI.ahk"

; 测试快捷键：Ctrl+T
^T::
{
    ; 声明全局变量
    global CurrentConfigID, CurrentAppName, CurrentAppURL, ConfigFile
    
    ; 显示当前配置信息
    MsgBox("当前配置信息:`n`n配置ID: " . CurrentConfigID . "`n应用名称: " . CurrentAppName . "`n应用URL: " . CurrentAppURL . "`n`n配置文件路径: " . ConfigFile, "配置测试", 0x40)
    
    ; 尝试打开配置文件中的URL
    result := MsgBox("是否要测试打开配置的URL?", "URL测试", 0x21)
    if (result = "OK") {
        try {
            Run("msedge.exe --new-window `" . CurrentAppURL . `"")
            MsgBox("已尝试打开URL: " . CurrentAppURL, "测试结果", 0x40)
        } catch {
            MsgBox("打开URL失败: " . CurrentAppURL, "测试结果", 0x10)
        }
    }
}