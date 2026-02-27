; AutoHotkey V2 Script
; 自定义菜单功能演示脚本
; 演示如何使用Win+F3菜单功能

#SingleInstance Force

; 模拟配置文件路径
ConfigFile := A_ScriptDir . "\Config.ini"

; 模拟全局变量
MenuCount := 0
MenuItems := Map()
CurrentAppName := "Kimi"
CurrentAppURL := "https://www.kimi.com/"

; 演示菜单项执行（不实际发送到AI）
DemoExecuteMenuItem(itemIndex)
{
    ; 检查菜单项是否存在
    if (!MenuItems.Has(itemIndex)) {
        MsgBox("菜单项不存在: " . itemIndex, "错误", 0x10)
        return
    }
    
    ; 获取菜单项配置
    menuItem := MenuItems[itemIndex]
    
    ; 模拟剪贴板内容
    clipboardText := "这是一段测试文本，用于演示自定义菜单功能。"
    
    ; 处理内容拼接
    finalText := ""
    if (menuItem.Content = "") {
        ; 如果内容为空，直接使用剪贴板内容
        finalText := clipboardText
    } else {
        ; 替换{text}变量
        finalText := StrReplace(menuItem.Content, "{text}", clipboardText)
    }
    
    ; 显示处理结果
    result := "菜单项执行演示:`n`n"
    result .= "菜单项名称: " . menuItem.Name . "`n"
    result .= "原始文本: " . clipboardText . "`n`n"
    result .= "处理后的文本:`n" . finalText . "`n`n"
    result .= "执行流程:`n"
    result .= "1. 复制选中文本`n"
    result .= "2. 激活AI应用: " . CurrentAppName . "`n"
    
    if (menuItem.NewChat) {
        result .= "3. 执行Ctrl+K (新建对话)`n"
    } else {
        result .= "3. 跳过Ctrl+K (继续当前对话)`n"
    }
    
    result .= "4. 执行Ctrl+M (进入输入模式)`n"
    result .= "5. 粘贴处理后的文本`n"
    
    if (menuItem.SendEnter) {
        result .= "6. 发送回车 (提交内容)`n"
    } else {
        result .= "6. 跳过回车 (不自动提交)`n"
    }
    
    MsgBox(result, "菜单项执行演示", 0x40)
}

; 加载菜单配置函数（简化版）
LoadMenuConfig()
{
    ; 清空现有菜单项
    MenuItems.Clear()
    MenuCount := 0
    
    ; 检查配置文件是否存在
    if !FileExist(ConfigFile) {
        MsgBox("配置文件不存在，无法加载菜单配置", "错误", 0x10)
        return
    }
    
    ; 读取菜单数量
    MenuCount := IniRead(ConfigFile, "MenuSettings", "MenuCount", 0)
    
    ; 如果没有菜单配置，返回
    if (MenuCount <= 0) {
        MsgBox("未找到菜单配置或菜单数量为0", "提示", 0x30)
        return
    }
    
    ; 读取每个菜单项
    Loop MenuCount {
        itemIndex := A_Index
        sectionName := "MenuItem" . itemIndex
        
        ; 创建菜单项对象
        menuItem := {
            Name: IniRead(ConfigFile, sectionName, "Name", "菜单项" . itemIndex),
            Content: IniRead(ConfigFile, sectionName, "Content", ""),
            NewChat: (IniRead(ConfigFile, sectionName, "NewChat", "1") = "1") ? true : false,
            SendEnter: (IniRead(ConfigFile, sectionName, "SendEnter", "1") = "1") ? true : false
        }
        
        ; 添加到菜单项集合
        MenuItems[itemIndex] := menuItem
    }
    
    MsgBox("成功加载 " . MenuCount . " 个菜单项", "加载成功", 0x40)
}

; 显示菜单配置
ShowMenuConfig()
{
    ; 显示加载结果
    result := "菜单配置:`n`n"
    result .= "菜单项数量: " . MenuCount . "`n`n"
    
    ; 显示每个菜单项的配置
    for index, menuItem in MenuItems {
        result .= "菜单项 " . index . ":`n"
        result .= "  名称: " . menuItem.Name . "`n"
        result .= "  内容: " . (menuItem.Content = "" ? "(空)" : menuItem.Content) . "`n"
        result .= "  新建对话: " . (menuItem.NewChat ? "是" : "否") . "`n"
        result .= "  发送回车: " . (menuItem.SendEnter ? "是" : "否") . "`n`n"
    }
    
    MsgBox(result, "菜单配置", 0x40)
}

; 演示菜单选择
DemoMenuSelection()
{
    ; 先加载菜单配置
    LoadMenuConfig()
    
    ; 检查菜单项数量
    if (MenuCount <= 0) {
        MsgBox("未配置菜单项，无法演示菜单选择", "演示失败", 0x10)
        return
    }
    
    ; 让用户选择要演示的菜单项
    itemList := ""
    for index, menuItem in MenuItems {
        itemList .= index . ": " . menuItem.Name . "`n"
    }
    
    InputResult := InputBox("请输入要演示的菜单项编号 (1-" . MenuCount . "):`n`n" . itemList, "菜单选择演示")
    
    ; 检查用户输入
    if (InputResult.Result = "Cancel") {
        return
    }
    
    itemIndex := Integer(InputResult.Value)
    
    ; 检查菜单项是否存在
    if (itemIndex < 1 || itemIndex > MenuCount) {
        MsgBox("无效的菜单项编号: " . itemIndex, "演示失败", 0x10)
        return
    }
    
    ; 演示菜单项执行
    DemoExecuteMenuItem(itemIndex)
}

; 热键绑定：Ctrl+L - 加载菜单配置
^L::
{
    LoadMenuConfig()
}

; 热键绑定：Ctrl+S - 显示菜单配置
^S::
{
    ShowMenuConfig()
}

; 热键绑定：Ctrl+D - 演示菜单选择
^D::
{
    DemoMenuSelection()
}

; 显示使用说明
MsgBox("自定义菜单功能演示脚本已启动！`n`n热键绑定:`nCtrl+L: 加载菜单配置`nCtrl+S: 显示菜单配置`nCtrl+D: 演示菜单选择和执行`n`n请按热键开始演示。", "演示脚本", 0x40)