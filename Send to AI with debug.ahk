; AutoHotkey V2 Script
; 多配置版本的"发送到AI"脚本
; 支持多个AI应用配置，可通过配置文件管理

#SingleInstance Force

; 全局变量声明 - 在AHK v2中，全局变量需要在函数中声明为global
ConfigFile := A_ScriptDir . "\Config.ini"
ConfigFileUTF8 := A_ScriptDir . "\Test Tools\Config_UTF8.ini"  ; UTF-8 BOM版本的配置文件
CurrentConfigID := 1
CurrentAppName := ""
CurrentAppURL := ""

; 菜单配置全局变量
MenuCount := 0
MenuItems := Map()  ; 存储菜单项配置

; 初始化：读取配置文件
LoadCurrentConfig()
LoadMenuConfig()  ; 加载菜单配置

; 主功能函数：Win+F1 - 完整流程（包含Ctrl+K）
#F1::
{
    ; 确保配置已加载
    if (CurrentAppName = "" || CurrentAppURL = "") {
        LoadCurrentConfig()
    }
    SendToAI("full")
}

; 主功能函数：Win+F2 - 简化流程（不包含Ctrl+K）
#F2::
{
    ; 确保配置已加载
    if (CurrentAppName = "" || CurrentAppURL = "") {
        LoadCurrentConfig()
    }
    SendToAI("simple")
}

; 自定义菜单功能：Win+F3 - 显示自定义菜单
#F3::
{
    ShowCustomMenu()
}

; 重新加载配置：Win+F10 - 重新加载配置文件
#F10::
{
    LoadCurrentConfig(true)
    LoadMenuConfig()  ; 重新加载菜单配置
    MsgBox("配置已重新加载。当前配置: " . CurrentAppName . "`n菜单项数量: " . MenuCount, "配置重载", 0x40)
}

; 核心功能函数
SendToAI(mode)
{
    ; 确保配置已加载
    if (CurrentAppName = "" || CurrentAppURL = "") {
        LoadCurrentConfig()
    }
    
    ; 调试输出
    OutputDebug("当前配置: " . CurrentAppName . ", URL: " . CurrentAppURL)
    
    Send("^c") ; 按下 Ctrl+C 复制选中内容
    Sleep(100) ; 短暂延迟确保复制完成
    
    ; 激活目标应用，如果不存在则启动
    if WinExist(CurrentAppName) {
        ; 如果有已启动的应用窗口，则激活应用窗口
        WinActivate(CurrentAppName) ; 激活已存在的窗口
        OutputDebug("已通过窗口标题激活'" . CurrentAppName . "'应用")
    } else {
        ; 如果没有启动的应用窗口，则启动Edge浏览器并打开网页应用
        try {
            ; 使用完整路径和--new-window参数强制打开新窗口
            Run("msedge.exe --new-window `" . CurrentAppURL . `"")
            OutputDebug("已启动Edge浏览器并打开" . CurrentAppName . "网页应用，URL: " . CurrentAppURL)
        } catch {
            OutputDebug("启动Edge浏览器失败，请确保Edge已正确安装")
            MsgBox("启动Edge浏览器失败，请确保Edge已正确安装", "错误", 0x10)
            return
        }
        ; 等待页面加载，增加等待时间
        Sleep(2000)
        ; 尝试等待应用窗口出现
        if WinWait(CurrentAppName, , 10) {
            WinActivate(CurrentAppName)
            OutputDebug(CurrentAppName . "页面已加载并激活")
        } else if WinWait("ahk_exe msedge.exe", , 5) {
            WinActivate("ahk_exe msedge.exe") ; 激活Edge窗口
            OutputDebug("Edge浏览器启动成功并已激活")
        } else {
            OutputDebug("Edge浏览器启动超时")
            MsgBox("Edge浏览器启动超时", "警告", 0x30)
        }
    }
    
    Sleep(100) ; 短暂延迟确保切换完成
    
    ; 根据模式执行不同的操作
    if (mode = "full") {
        Send("^k") ; 按下 Ctrl+K
        Sleep(100) ; 短暂延迟确保操作完成
    }
    
    Send("^m") ; 按下 Ctrl+M
    Sleep(100) ; 短暂延迟确保操作完成
    Send("^v") ; 按下 Ctrl+V 粘贴内容
    Sleep(100) ; 短暂延迟确保粘贴完成
    Send("{Enter}") ; 按下 Enter 键
}

; 读取当前配置
LoadCurrentConfig(showMessage := false)
{
    ; 声明全局变量
    global ConfigFile, CurrentConfigID, CurrentAppName, CurrentAppURL
    
    ; 检查配置文件是否存在
    if !FileExist(ConfigFile) {
        MsgBox("配置文件不存在: " . ConfigFile, "错误", 0x10)
        ExitApp
    }
    
    ; 使用UTF-8编码读取整个INI文件内容
    try {
        fileContent := FileRead(ConfigFile, "UTF-8")
        
        ; 解析INI内容获取当前配置ID
        configIDPattern := "s)\[Settings\][\s\S]*?CurrentConfig=([^\r\n]*)"
        RegExMatch(fileContent, configIDPattern, &configIDMatch)
        CurrentConfigID := configIDMatch[1] ? configIDMatch[1] : "1"
        
        ; 解析INI内容获取当前配置的应用名称和URL
        sectionName := "Config" . CurrentConfigID
        
        ; 获取AppName
        appNamePattern := "s)\[" . sectionName . "\][\s\S]*?AppName=([^\r\n]*)"
        RegExMatch(fileContent, appNamePattern, &appNameMatch)
        CurrentAppName := appNameMatch[1] ? appNameMatch[1] : "豆包"
        
        ; 获取AppURL
        urlPattern := "s)\[" . sectionName . "\][\s\S]*?AppURL=([^\r\n]*)"
        RegExMatch(fileContent, urlPattern, &urlMatch)
        CurrentAppURL := urlMatch[1] ? urlMatch[1] : "https://www.doubao.com/chat/"
        
        ; 如果正则匹配失败，回退到IniRead
        if (CurrentAppName = "" || CurrentAppURL = "") {
            CurrentConfigID := IniRead(ConfigFile, "Settings", "CurrentConfig", "1")
            sectionName := "Config" . CurrentConfigID
            CurrentAppName := IniRead(ConfigFile, sectionName, "AppName", "豆包")
            CurrentAppURL := IniRead(ConfigFile, sectionName, "AppURL", "https://www.doubao.com/chat/")
        }
    } catch {
        ; 如果FileRead失败，回退到IniRead
        CurrentConfigID := IniRead(ConfigFile, "Settings", "CurrentConfig", "1")
        sectionName := "Config" . CurrentConfigID
        CurrentAppName := IniRead(ConfigFile, sectionName, "AppName", "豆包")
        CurrentAppURL := IniRead(ConfigFile, sectionName, "AppURL", "https://www.doubao.com/chat/")
    }
    
    ; 根据参数决定是否显示调试信息
    if (showMessage) {
        MsgBox("配置加载完成:`n`n配置文件: " . ConfigFile . "`n配置ID: " . CurrentConfigID . "`n应用名称: " . CurrentAppName . "`n应用URL: " . CurrentAppURL, "配置加载", 0x40)
    }
    
    OutputDebug("已加载配置 " . CurrentConfigID . ": " . CurrentAppName)
}

; 加载菜单配置
LoadMenuConfig()
{
    ; 声明全局变量
    global ConfigFile, MenuCount, MenuItems
    
    ; 清空现有菜单项
    MenuItems.Clear()
    MenuCount := 0
    
    ; 检查配置文件是否存在
    if !FileExist(ConfigFile) {
        OutputDebug("配置文件不存在，无法加载菜单配置")
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
            OutputDebug("未找到菜单配置或菜单数量为0")
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
            
            ; 添加调试输出
            OutputDebug("菜单项 " . itemIndex . " Content匹配结果: " . (contentMatch[1] !== "" ? contentMatch[1] : "空值"))
            
            ; 获取新建对话设置
            newChatPattern := "s)\[" . sectionName . "\][\s\S]*?NewChat=([^\r\n]*)"
            RegExMatch(fileContent, newChatPattern, &newChatMatch)
            newChatValue := newChatMatch[1] !== "" ? newChatMatch[1] : "1"
            menuItem.NewChat := (newChatValue = "1") ? true : false
            
            ; 获取发送回车设置
            sendEnterPattern := "s)\[" . sectionName . "\][\s\S]*?SendEnter=([^\r\n]*)"
            RegExMatch(fileContent, sendEnterPattern, &sendEnterMatch)
            sendEnterValue := sendEnterMatch[1] !== "" ? sendEnterMatch[1] : "1"
            OutputDebug("菜单项 " . itemIndex . " SendEnter原始匹配结果: " . (sendEnterMatch[1] !== "" ? sendEnterMatch[1] : "空值"))
            OutputDebug("菜单项 " . itemIndex . " SendEnter转换后值: " . sendEnterValue)
            menuItem.SendEnter := (sendEnterValue = "1") ? true : false
            
            ; 如果正则匹配失败，回退到IniRead
            if (menuItem.Name = "菜单项" . itemIndex) {
                     OutputDebug("正则匹配失败，回退到IniRead方法读取菜单项 " . itemIndex)
                     menuItem.Name := IniRead(ConfigFile, sectionName, "Name", "菜单项" . itemIndex)
                     menuItem.Content := IniRead(ConfigFile, sectionName, "Content", "")
                     newChatValue := IniRead(ConfigFile, sectionName, "NewChat", "1")
                     menuItem.NewChat := (newChatValue = "1") ? true : false
                     sendEnterValue := IniRead(ConfigFile, sectionName, "SendEnter", "1")
                     menuItem.SendEnter := (sendEnterValue = "1") ? true : false
                     
                     ; 添加IniRead的调试输出
                     OutputDebug("IniRead读取菜单项 " . itemIndex . " - Name: " . menuItem.Name . ", Content: " . menuItem.Content . ", NewChat: " . newChatValue . ", SendEnter: " . sendEnterValue)
                 }
            
            ; 添加到菜单项集合
            MenuItems[itemIndex] := menuItem
            
            ; 添加详细的调试输出，包括NewChat和SendEnter参数
            OutputDebug("已加载菜单项 " . itemIndex . ": " . menuItem.Name . ", NewChat: " . menuItem.NewChat . ", SendEnter: " . menuItem.SendEnter)
        }
    } catch {
        ; 如果FileRead失败，回退到IniRead
        try {
            MenuCount := IniRead(ConfigFile, "MenuSettings", "MenuCount", 0)
            
            if (MenuCount <= 0) {
                OutputDebug("未找到菜单配置或菜单数量为0")
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
                
                OutputDebug("已加载菜单项 " . itemIndex . ": " . menuItem.Name)
            }
        } catch Error {
            OutputDebug("加载菜单配置失败: " . Error.Message)
            MenuCount := 0
        }
    }
}

; 菜单项处理函数
MenuHandler(itemIndex, *)
{
    ExecuteMenuItem(itemIndex)
}

; 显示自定义菜单
ShowCustomMenu()
{
    ; 声明全局变量
    global MenuCount, MenuItems
    
    ; 如果没有菜单项，显示提示
    if (MenuCount <= 0) {
        MsgBox("未配置自定义菜单项。`n`n请在Config.ini文件中添加MenuSettings和MenuItem配置。", "菜单提示", 0x30)
        return
    }
    
    ; 创建菜单
    customMenu := Menu()
    
    ; 添加菜单项
    Loop MenuCount {
        itemIndex := A_Index
        menuItem := MenuItems[itemIndex]
        
        ; 添加序号和名称
        menuText := itemIndex . ". " . menuItem.Name
        
        ; 创建闭包时捕获当前索引值
        currentIndex := itemIndex
        ; 添加菜单项，绑定处理函数
        customMenu.Add(menuText, MenuHandler.Bind(currentIndex))
    }
    
    ; 显示菜单
    customMenu.Show()
}

; 执行菜单项
ExecuteMenuItem(itemIndex)
{
    ; 声明全局变量
    global MenuItems, CurrentAppName, CurrentAppURL
    
    ; 检查菜单项是否存在
    if (!MenuItems.Has(itemIndex)) {
        MsgBox("菜单项不存在: " . itemIndex, "错误", 0x10)
        return
    }
    
    ; 获取菜单项配置
    menuItem := MenuItems[itemIndex]
    
    ; 确保配置已加载
    if (CurrentAppName = "" || CurrentAppURL = "") {
        LoadCurrentConfig()
    }
    
    ; 调试输出
    OutputDebug("执行菜单项: " . menuItem.Name)
    OutputDebug("菜单项内容模板: " . menuItem.Content)
    OutputDebug("菜单项NewChat设置: " . menuItem.NewChat)
    OutputDebug("菜单项SendEnter设置: " . menuItem.SendEnter)
    
    ; 复制选中内容
    Send("^c")
    Sleep(300) ; 增加延迟确保复制完成
    
    ; 获取剪贴板内容
    clipboardText := A_Clipboard
    OutputDebug("剪贴板内容: " . clipboardText)
    
    ; 处理内容拼接
    finalText := ""
    if (menuItem.Content = "") {
        ; 如果内容为空，直接使用剪贴板内容
        finalText := clipboardText
        OutputDebug("内容为空，使用剪贴板内容")
    } else {
        ; 替换{text}变量
        finalText := StrReplace(menuItem.Content, "{text}", clipboardText)
        OutputDebug("替换{text}变量后: " . finalText)
    }
    
    ; 将最终内容复制到剪贴板
    OutputDebug("准备复制内容到剪贴板: " . finalText)
    
    ; 方法1: 尝试使用直接赋值（AutoHotkey V2的标准方法）
    try {
        A_Clipboard := ""  ; 清空剪贴板
        Sleep(50)
        A_Clipboard := finalText  ; 直接赋值
        Sleep(200)
        
        ; 验证剪贴板内容
        If (A_Clipboard = finalText) {
            OutputDebug("剪贴板内容验证成功，使用直接赋值方法")
        } Else {
            OutputDebug("剪贴板内容验证失败，尝试备用方法")
            ; 备用方法：使用ClipboardAll
            A_Clipboard := finalText
            Sleep(200)
        }
    } catch as e {
        OutputDebug("剪贴板操作出错: " . e.Message)
        ; 备用方法：直接赋值
        A_Clipboard := finalText
        Sleep(200)
    }
    Sleep(200) ; 增加延迟确保复制完成
    OutputDebug("已将最终内容复制到剪贴板")
    
    ; 激活目标应用，如果不存在则启动
    if WinExist(CurrentAppName) {
        ; 如果有已启动的应用窗口，则激活应用窗口
        WinActivate(CurrentAppName)
        OutputDebug("已通过窗口标题激活'" . CurrentAppName . "'应用")
    } else {
        ; 如果没有启动的应用窗口，则启动Edge浏览器并打开网页应用
        try {
            ; 使用完整路径和--new-window参数强制打开新窗口
            Run("msedge.exe --new-window `" . CurrentAppURL . `"")
            OutputDebug("已启动Edge浏览器并打开" . CurrentAppName . "网页应用，URL: " . CurrentAppURL)
        } catch {
            OutputDebug("启动Edge浏览器失败，请确保Edge已正确安装")
            MsgBox("启动Edge浏览器失败，请确保Edge已正确安装", "错误", 0x10)
            return
        }
        ; 等待页面加载，增加等待时间
        Sleep(2000)
        ; 尝试等待应用窗口出现
        if WinWait(CurrentAppName, , 10) {
            WinActivate(CurrentAppName)
            OutputDebug(CurrentAppName . "页面已加载并激活")
        } else if WinWait("ahk_exe msedge.exe", , 5) {
            WinActivate("ahk_exe msedge.exe") ; 激活Edge窗口
            OutputDebug("Edge浏览器启动成功并已激活")
        } else {
            OutputDebug("Edge浏览器启动超时")
            MsgBox("Edge浏览器启动超时", "警告", 0x30)
        }
    }
    
    Sleep(100) ; 短暂延迟确保切换完成
    
    ; 根据配置执行不同的操作
    if (menuItem.NewChat) {
        OutputDebug("配置要求执行Ctrl+K")
        Send("^k") ; 按下 Ctrl+K
        Sleep(100) ; 短暂延迟确保操作完成
    } else {
        OutputDebug("配置不要求执行Ctrl+K")
    }
    
    Send("^m") ; 按下 Ctrl+M
    Sleep(100) ; 短暂延迟确保操作完成
    Send("^v") ; 按下 Ctrl+V 粘贴内容
    Sleep(100) ; 短暂延迟确保粘贴完成
    
    if (menuItem.SendEnter) {
        OutputDebug("配置要求执行Enter")
        Send("{Enter}") ; 按下 Enter 键
    } else {
        OutputDebug("配置不要求执行Enter")
    }
}

; 使用说明：
; 1. Win+F1: 复制选中内容 -> 激活当前配置的应用 -> Ctrl+K -> Ctrl+M -> 粘贴 -> 回车
; 2. Win+F2: 复制选中内容 -> 激活当前配置的应用 -> Ctrl+M -> 粘贴 -> 回车
; 3. Win+F3: 显示自定义菜单，选择菜单项执行对应的文本处理流程
; 4. Win+F10: 重新加载配置文件
;
; 配置文件说明：
; 配置文件位于脚本同目录下的Config.ini
; 可以通过修改Config.ini文件添加更多配置
; 每个配置包含AppName（应用名称）和AppURL（应用URL）
;
; 自定义菜单配置说明：
; 在Config.ini中添加MenuSettings和MenuItem配置
; 每个菜单项包含Name（显示名称）、Content（内容模板，支持{text}变量）、NewChat（是否新建对话）和SendEnter（是否发送回车）