; AutoHotkey V2 Script
; 测试自定义菜单功能
; 验证Win+F3菜单显示和菜单项执行

#SingleInstance Force

; 导入主脚本中的函数
#Include ..\Send to AI.ahk

; 测试函数：测试菜单配置加载
TestMenuConfigLoad()
{
    ; 声明全局变量
    global MenuCount, MenuItems
    
    ; 调用加载菜单配置函数
    LoadMenuConfig()
    
    ; 显示加载结果
    result := "菜单配置加载测试结果:`n`n"
    result .= "菜单项数量: " . MenuCount . "`n`n"
    
    ; 显示每个菜单项的配置
    for index, menuItem in MenuItems {
        result .= "菜单项 " . index . ":`n"
        result .= "  名称: " . menuItem.Name . "`n"
        result .= "  内容: " . (menuItem.Content = "" ? "(空)" : menuItem.Content) . "`n"
        result .= "  新建对话: " . (menuItem.NewChat ? "是" : "否") . "`n"
        result .= "  发送回车: " . (menuItem.SendEnter ? "是" : "否") . "`n`n"
    }
    
    MsgBox(result, "菜单配置加载测试", 0x40)
}

; 测试函数：测试菜单显示
TestMenuDisplay()
{
    ; 声明全局变量
    global MenuCount, MenuItems
    
    ; 先加载菜单配置
    LoadMenuConfig()
    
    ; 检查菜单项数量
    if (MenuCount <= 0) {
        MsgBox("未配置菜单项，无法测试菜单显示", "测试失败", 0x10)
        return
    }
    
    ; 显示提示
    MsgBox("即将显示自定义菜单。`n`n请测试菜单项选择和执行。", "菜单显示测试", 0x40)
    
    ; 显示菜单
    ShowCustomMenu()
}

; 测试函数：测试菜单项执行
TestMenuItemExecution()
{
    ; 声明全局变量
    global MenuCount, MenuItems
    
    ; 先加载菜单配置
    LoadMenuConfig()
    
    ; 检查菜单项数量
    if (MenuCount <= 0) {
        MsgBox("未配置菜单项，无法测试菜单项执行", "测试失败", 0x10)
        return
    }
    
    ; 让用户选择要测试的菜单项
    itemList := ""
    for index, menuItem in MenuItems {
        itemList .= index . ": " . menuItem.Name . "`n"
    }
    
    InputResult := InputBox("请输入要测试的菜单项编号 (1-" . MenuCount . "):`n`n" . itemList, "菜单项执行测试")
    
    ; 检查用户输入
    if (InputResult.Result = "Cancel") {
        return
    }
    
    itemIndex := Integer(InputResult.Value)
    
    ; 检查菜单项是否存在
    if (itemIndex < 1 || itemIndex > MenuCount) {
        MsgBox("无效的菜单项编号: " . itemIndex, "测试失败", 0x10)
        return
    }
    
    ; 显示测试提示
    menuItem := MenuItems[itemIndex]
    result := "即将测试菜单项执行:`n`n"
    result .= "菜单项: " . menuItem.Name . "`n"
    result .= "内容: " . (menuItem.Content = "" ? "(空，直接发送剪贴板内容)" : menuItem.Content) . "`n"
    result .= "新建对话: " . (menuItem.NewChat ? "是" : "否") . "`n"
    result .= "发送回车: " . (menuItem.SendEnter ? "是" : "否") . "`n`n"
    result .= "请先复制一些文本到剪贴板，然后点击确定继续。"
    
    MsgBox(result, "菜单项执行测试", 0x40)
    
    ; 执行菜单项
    ExecuteMenuItem(itemIndex)
}

; 主测试函数
RunAllTests()
{
    ; 显示测试开始提示
    MsgBox("开始测试自定义菜单功能...`n`n测试将包括:`n1. 菜单配置加载`n2. 菜单显示`n3. 菜单项执行", "测试开始", 0x40)
    
    ; 测试菜单配置加载
    TestMenuConfigLoad()
    
    ; 测试菜单显示
    TestMenuDisplay()
    
    ; 测试菜单项执行
    TestMenuItemExecution()
    
    ; 显示测试完成提示
    MsgBox("自定义菜单功能测试完成！`n`n请检查各项功能是否正常工作。", "测试完成", 0x40)
}

; 热键绑定：Ctrl+T - 运行所有测试
^T::RunAllTests()

; 热键绑定：Ctrl+1 - 测试菜单配置加载
^1::TestMenuConfigLoad()

; 热键绑定：Ctrl+2 - 测试菜单显示
^2::TestMenuDisplay()

; 热键绑定：Ctrl+3 - 测试菜单项执行
^3::TestMenuItemExecution()

; 显示使用说明
MsgBox("自定义菜单功能测试脚本已启动！`n`n热键绑定:`nCtrl+T: 运行所有测试`nCtrl+1: 测试菜单配置加载`nCtrl+2: 测试菜单显示`nCtrl+3: 测试菜单项执行`n`n请按热键开始测试。", "测试脚本", 0x40)