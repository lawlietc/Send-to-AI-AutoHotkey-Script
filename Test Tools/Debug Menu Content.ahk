; AutoHotkey V2 Script
; 调试自定义菜单功能

#SingleInstance Force

; 全局变量声明
ConfigFile := A_ScriptDir . "\Config.ini"
MenuCount := 0
MenuItems := Map()  ; 存储菜单项配置

; 初始化：读取配置文件
LoadMenuConfig()

; 测试热键：Ctrl+L - 加载并显示菜单配置
^L::
{
    LoadMenuConfig()
    ShowMenuInfo()
}

; 测试热键：Ctrl+T - 测试菜单项执行
^T::
{
    ; 设置测试文本到剪贴板
    A_Clipboard := "这是一段测试文本，用于验证菜单功能。"
    MsgBox("已设置测试文本到剪贴板，现在将执行第一个菜单项。", "测试", 0x40)
    
    ; 执行第一个菜单项
    ExecuteMenuItem(1)
}

; 加载菜单配置
LoadMenuConfig()
{
    ; 清空现有菜单项
    MenuItems.Clear()
    MenuCount := 0
    
    ; 检查配置文件是否存在
    if !FileExist(ConfigFile) {
        MsgBox("配置文件不存在: " . ConfigFile, "错误", 0x10)
        return
    }
    
    ; 使用UTF-8编码读取整个INI文件内容
    try {
        fileContent := FileRead(ConfigFile, "UTF-8")
        
        ; 解析INI内容获取菜单数量
        menuCountPattern := "s)\[MenuSettings\][\s\S]*?MenuCount=([^\r\n]*)"
        RegExMatch(fileContent, menuCountPattern, &menuCountMatch)
        MenuCount := menuCountMatch[1] ? Integer(menuCountMatch[1]) : 0
        
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
                Name: "",
                Content: "",
                NewChat: true,
                SendEnter: true
            }
            
            ; 获取菜单项名称
            namePattern := "s)\[" . sectionName . "\][\s\S]*?Name=([^\r\n]*)"
            RegExMatch(fileContent, namePattern, &nameMatch)
            menuItem.Name := nameMatch[1] ? nameMatch[1] : "菜单项" . itemIndex
            
            ; 获取菜单项内容
            contentPattern := "s)\[" . sectionName . "\][\s\S]*?Content=([^\r\n]*)"
            RegExMatch(fileContent, contentPattern, &contentMatch)
            menuItem.Content := contentMatch[1] ? contentMatch[1] : ""
            
            ; 获取新建对话设置
            newChatPattern := "s)\[" . sectionName . "\][\s\S]*?NewChat=([^\r\n]*)"
            RegExMatch(fileContent, newChatPattern, &newChatMatch)
            newChatValue := newChatMatch[1] ? newChatMatch[1] : "1"
            menuItem.NewChat := (newChatValue = "1") ? true : false
            
            ; 获取发送回车设置
            sendEnterPattern := "s)\[" . sectionName . "\][\s\S]*?SendEnter=([^\r\n]*)"
            RegExMatch(fileContent, sendEnterPattern, &sendEnterMatch)
            sendEnterValue := sendEnterMatch[1] ? sendEnterMatch[1] : "1"
            menuItem.SendEnter := (sendEnterValue = "1") ? true : false
            
            ; 如果正则匹配失败，回退到IniRead
            if (menuItem.Name = "菜单项" . itemIndex) {
                menuItem.Name := IniRead(ConfigFile, sectionName, "Name", "菜单项" . itemIndex)
                menuItem.Content := IniRead(ConfigFile, sectionName, "Content", "")
                newChatValue := IniRead(ConfigFile, sectionName, "NewChat", "1")
                menuItem.NewChat := (newChatValue = "1") ? true : false
                sendEnterValue := IniRead(ConfigFile, sectionName, "SendEnter", "1")
                menuItem.SendEnter := (sendEnterValue = "1") ? true : false
            }
            
            ; 添加到菜单项集合
            MenuItems[itemIndex] := menuItem
        }
    } catch {
        ; 如果FileRead失败，回退到IniRead
        try {
            MenuCount := IniRead(ConfigFile, "MenuSettings", "MenuCount", 0)
            
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
        } catch Error {
            MsgBox("加载菜单配置失败: " . Error.Message, "错误", 0x10)
            MenuCount := 0
        }
    }
}

; 显示菜单信息
ShowMenuInfo()
{
    info := "菜单项数量: " . MenuCount . "`n`n"
    
    for index, menuItem in MenuItems {
        info .= "菜单项 " . index . ":`n"
        info .= "  名称: " . menuItem.Name . "`n"
        info .= "  内容: " . menuItem.Content . "`n"
        info .= "  新建对话: " . (menuItem.NewChat ? "是" : "否") . "`n"
        info .= "  发送回车: " . (menuItem.SendEnter ? "是" : "否") . "`n`n"
    }
    
    MsgBox(info, "菜单配置信息", 0x40)
}

; 执行菜单项
ExecuteMenuItem(itemIndex)
{
    ; 检查菜单项是否存在
    if (!MenuItems.Has(itemIndex)) {
        MsgBox("菜单项不存在: " . itemIndex, "错误", 0x10)
        return
    }
    
    ; 获取菜单项配置
    menuItem := MenuItems[itemIndex]
    
    ; 调试输出
    OutputDebug("执行菜单项: " . menuItem.Name)
    
    ; 获取剪贴板内容
    clipboardText := A_Clipboard
    
    ; 处理内容拼接
    finalText := ""
    if (menuItem.Content = "") {
        ; 如果内容为空，直接使用剪贴板内容
        finalText := clipboardText
        OutputDebug("内容为空，使用剪贴板内容: " . clipboardText)
    } else {
        ; 替换{text}变量
        finalText := StrReplace(menuItem.Content, "{text}", clipboardText)
        OutputDebug("内容模板: " . menuItem.Content)
        OutputDebug("替换后内容: " . finalText)
    }
    
    ; 显示结果
    MsgBox("原始剪贴板内容: " . clipboardText . "`n`n最终内容: " . finalText, "内容处理结果", 0x40)
    
    ; 将最终内容复制到剪贴板
    A_Clipboard := finalText
    Sleep(100) ; 短暂延迟确保复制完成
}