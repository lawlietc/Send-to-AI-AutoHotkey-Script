; AutoHotkey V2 测试剪贴板操作
; 测试不同的剪贴板复制方法

; 方法1：直接赋值
OutputDebug("测试方法1：直接赋值")
A_Clipboard := "测试文本1"
Sleep(500)
OutputDebug("剪贴板内容1: " . A_Clipboard)

; 方法2：使用ClipWait
OutputDebug("测试方法2：使用ClipWait")
A_Clipboard := "测试文本2"
if ClipWait(2) {
    OutputDebug("剪贴板内容2: " . A_Clipboard)
} else {
    OutputDebug("ClipWait超时")
}

; 方法3：使用StrCopy
OutputDebug("测试方法3：使用StrCopy")
StrCopy("测试文本3")
Sleep(500)
OutputDebug("剪贴板内容3: " . A_Clipboard)

MsgBox("剪贴板测试完成，请查看DebugView或检查剪贴板内容", "测试完成", 0x40)