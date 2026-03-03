; AutoHotkey V2 Script
; 简单测试自定义菜单功能

#SingleInstance Force

; 模拟配置文件路径
ConfigFile := A_ScriptDir . "\Config.ini"

; 模拟全局变量
MenuCount := 0
MenuItems := Map()

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

; 显示使用说明
MsgBox("自定义菜单功能简单测试脚本已启动！`n`n热键绑定:`nCtrl+L: 加载菜单配置`nCtrl+S: 显示菜单配置`n`n请按热键开始测试。", "测试脚本", 0x40)