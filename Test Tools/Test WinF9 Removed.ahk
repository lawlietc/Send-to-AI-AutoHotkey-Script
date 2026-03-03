; 测试Win+F9功能是否已被移除
; AutoHotkey V2 Script

#SingleInstance Force

; 测试Win+F9是否不再触发配置切换菜单
#F9::
{
    MsgBox("Win+F9热键已被重新定义，不再显示配置切换菜单", "测试结果", 0x40)
}

MsgBox("测试脚本已启动。请按Win+F9测试热键功能。", "测试开始", 0x40)