#Requires AutoHotkey v2.0

; 测试剪贴板和内容拼接功能

; 加载配置文件
ConfigFile := A_ScriptDir . "\Config.ini"

; 测试函数
TestClipboardAndContent()
{
    ; 复制选中内容
    Send("^c")
    Sleep(500) ; 增加延迟确保复制完成
    
    ; 获取剪贴板内容
    clipboardText := A_Clipboard
    MsgBox("剪贴板内容: " . clipboardText, "剪贴板测试", 0x40)
    
    ; 测试内容拼接
    testContent := "请帮我翻译这段内容：{text}"
    finalText := StrReplace(testContent, "{text}", clipboardText)
    MsgBox("拼接后内容: " . finalText, "内容拼接测试", 0x40)
    
    ; 将最终内容复制到剪贴板
    A_Clipboard := finalText
    Sleep(200) ; 增加延迟确保复制完成
    MsgBox("已将拼接内容复制到剪贴板，请测试粘贴", "完成", 0x40)
}

; 创建测试菜单
testMenu := Menu()
testMenu.Add("测试剪贴板和内容拼接", TestClipboardAndContent)
testMenu.Add("退出", (*) => ExitApp())

; 显示菜单
testMenu.Show()