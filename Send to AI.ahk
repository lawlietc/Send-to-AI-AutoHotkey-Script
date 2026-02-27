; AutoHotkey V2 Script
; 多配置版本的"发送到AI"脚本
; 支持多个AI应用配置，可通过配置文件管理

#SingleInstance Force

; 全局变量声明 - 在AHK v2中，全局变量需要在函数中声明为global
ConfigFile := A_ScriptDir . "\Config.ini"
ConfigFileUTF8 := A_ScriptDir . "\Test Tools\Config_UTF8.ini"  ; UTF-8 BOM版本的配置文件
CurrentConfigID := 1
CurrentAppName := ""
CurrentProcessName := ""

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
    if (CurrentAppName = "") {
        LoadCurrentConfig()
    }
    
    ; 复制选中内容
    Send("^c")
    Sleep(300) ; 增加延迟确保复制完成
    
    ; 激活目标应用
    windowID := FindMatchingWindow(CurrentAppName, CurrentProcessName)
    
    ; 激活目标应用
    if (windowID > 0) {
        ; 如果找到匹配的窗口，激活它
        WinActivate("ahk_id " . windowID)
    } else {
        ; 显示更详细的错误信息
        errorMsg := "未找到匹配的应用窗口。"
        if (CurrentProcessName) {
            errorMsg .= "`n`n查找条件:`n窗口标题包含: " . CurrentAppName . "`n进程名: " . CurrentProcessName
        } else {
            errorMsg .= "`n`n查找条件:`n窗口标题包含: " . CurrentAppName . "`n进程名: (未配置)"
        }
        errorMsg .= "`n`n提示: 请确保应用已启动，或检查配置是否正确。"
        MsgBox(errorMsg, "警告", 0x30)
        return
    }
    
    Sleep(100) ; 短暂延迟确保切换完成
    
    ; 执行快捷键操作
    Send("^k") ; 按下 Ctrl+K
    Sleep(100) ; 短暂延迟确保操作完成
    Send("!1") ; 按下 Alt+1
    Sleep(100) ; 短暂延迟确保操作完成
    Send("^v") ; 按下 Ctrl+V 粘贴内容
    Sleep(100) ; 短暂延迟确保粘贴完成
    Send("{Enter}") ; 按下 Enter 键
}

; 连接数组元素为字符串
StrJoin(arr, delimiter)
{
    result := ""
    for index, value in arr {
        if (index > 1) {
            result .= delimiter
        }
        result .= value
    }
    return result
}

; 从SelectApp字符串中获取所有APP的名称
GetAppNamesFromSelectApp(selectAppString)
{
    ; 声明全局变量
    global ConfigFile
    
    ; 解析SelectApp字符串，支持逗号分隔的多个APP编号
    appIndices := []
    
    ; 尝试按逗号分隔
    if (InStr(selectAppString, ",")) {
        Loop Parse, selectAppString, ","
        {
            try {
                appIndex := Integer(Trim(A_LoopField))
                if (appIndex > 0) {
                    appIndices.Push(appIndex)
                }
            } catch {
                ; 忽略无效的数字
            }
        }
    } else {
        ; 如果没有逗号，尝试作为单个数字处理
        try {
            appIndex := Integer(Trim(selectAppString))
            if (appIndex > 0) {
                appIndices.Push(appIndex)
            }
        } catch {
            ; 忽略无效的数字
        }
    }
    
    ; 检查是否有有效的APP编号
    if (appIndices.Length = 0) {
        return ""
    }
    
    ; 获取所有APP的名称
    appNames := []
    for index, appIndex in appIndices {
        ; 获取APP配置
        appConfig := GetAppConfig(appIndex)
        
        if (appConfig.AppName != "") {
            appNames.Push(appConfig.AppName)
        }
    }
    
    ; 如果没有有效的APP名称，返回空字符串
    if (appNames.Length = 0) {
        return ""
    }
    
    ; 将APP名称用顿号连接
    return StrJoin(appNames, "、")
}

; 处理单个应用的操作
ProcessSingleApp(appName, processName, newChat, sendEnter)
{
    ; 使用新的窗口查找逻辑
    windowID := FindMatchingWindow(appName, processName)
    
    ; 激活目标应用
    if (windowID > 0) {
        ; 如果找到匹配的窗口，激活它
        WinActivate("ahk_id " . windowID)
    } else {
        ; 显示更详细的错误信息
        errorMsg := "未找到匹配的应用窗口。"
        if (processName) {
            errorMsg .= "`n`n查找条件:`n窗口标题包含: " . appName . "`n进程名: " . processName
        } else {
            errorMsg .= "`n`n查找条件:`n窗口标题包含: " . appName . "`n进程名: (未配置)"
        }
        errorMsg .= "`n`n提示: 请确保应用已启动，或检查配置是否正确。"
        MsgBox(errorMsg, "警告", 0x30)
        return
    }
    
    Sleep(100) ; 短暂延迟确保切换完成
    
    ; 根据配置执行不同的操作
    if (newChat) {
        Send("^k") ; 按下 Ctrl+K
        Sleep(100) ; 短暂延迟确保操作完成
    }
    
    Send("!1") ; 按下 Alt+1
    Sleep(100) ; 短暂延迟确保操作完成
    Send("^v") ; 按下 Ctrl+V 粘贴内容
    Sleep(100) ; 短暂延迟确保粘贴完成
    
    if (sendEnter) {
        Send("{Enter}") ; 按下 Enter 键
    }
}

; 处理多个应用的操作
ProcessMultipleApps(selectAppString, newChat, sendEnter)
{
    ; 声明全局变量
    global ConfigFile
    
    ; 解析SelectApp字符串，支持逗号分隔的多个APP编号
    appIndices := []
    
    ; 尝试按逗号分隔
    if (InStr(selectAppString, ",")) {
        Loop Parse, selectAppString, ","
        {
            try {
                appIndex := Integer(Trim(A_LoopField))
                if (appIndex > 0) {
                    appIndices.Push(appIndex)
                }
            } catch {
                ; 忽略无效的数字
            }
        }
    } else {
        ; 如果没有逗号，尝试作为单个数字处理
        try {
            appIndex := Integer(Trim(selectAppString))
            if (appIndex > 0) {
                appIndices.Push(appIndex)
            }
        } catch {
            ; 忽略无效的数字
        }
    }
    
    ; 检查是否有有效的APP编号
    if (appIndices.Length = 0) {
        MsgBox("警告: SelectApp值 '" . selectAppString . "' 不包含有效的APP编号，将使用当前配置。", "配置警告", 0x30)
        return
    }
    
    ; 循环处理每个APP
    for index, appIndex in appIndices {
        ; 获取APP配置
        appConfig := GetAppConfig(appIndex)
        
        if (appConfig.AppName != "") {
            ; 处理当前APP
            ProcessSingleApp(appConfig.AppName, appConfig.ProcessName, newChat, sendEnter)
            
            ; 如果不是最后一个APP，添加延迟
            if (index < appIndices.Length) {
                Sleep(500) ; 在切换到下一个APP前添加延迟
            }
        } else {
            MsgBox("警告: 找不到SelectApp指定的配置 " . appIndex . "，将跳过此配置。", "配置警告", 0x30)
        }
    }
}

; 获取指定APP编号的配置
GetAppConfig(appIndex)
{
    ; 声明全局变量
    global ConfigFile
    
    ; 初始化返回对象
    appConfig := {AppName: "", ProcessName: ""}
    
    ; 读取指定配置的应用信息
    sectionName := "Config" . appIndex
    
    ; 使用三级读取机制：UTF-8编码 → 默认编码 → IniRead
    try {
        ; 尝试使用UTF-8编码读取
        fileContent := FileRead(ConfigFile, "UTF-8")
        
        ; 使用正则表达式匹配AppName和ProcessName
        appNamePattern := "s)\[" . sectionName . "\][\s\S]*?AppName=([^\r\n]*)"
        processNamePattern := "s)\[" . sectionName . "\][\s\S]*?ProcessName=([^\r\n]*)"
        
        ; 匹配AppName
        match := ""
        if RegExMatch(fileContent, appNamePattern, &match) {
            appConfig.AppName := Trim(match[1])
        }
        
        ; 匹配ProcessName
        match := ""
        if RegExMatch(fileContent, processNamePattern, &match) {
            appConfig.ProcessName := Trim(match[1])
        }
        
        ; 如果UTF-8编码读取失败，尝试默认编码
        if (appConfig.AppName = "") {
            fileContent := FileRead(ConfigFile)
            
            ; 匹配AppName
            match := ""
            if RegExMatch(fileContent, appNamePattern, &match) {
                appConfig.AppName := Trim(match[1])
            }
            
            ; 匹配ProcessName
            match := ""
            if RegExMatch(fileContent, processNamePattern, &match) {
                appConfig.ProcessName := Trim(match[1])
            }
        }
        
        ; 如果仍然失败，回退到IniRead方法
        if (appConfig.AppName = "") {
            appConfig.AppName := IniRead(ConfigFile, sectionName, "AppName", "")
            appConfig.ProcessName := IniRead(ConfigFile, sectionName, "ProcessName", "")
        }
    } catch {
        ; 如果出现异常，直接使用IniRead方法
        appConfig.AppName := IniRead(ConfigFile, sectionName, "AppName", "")
        appConfig.ProcessName := IniRead(ConfigFile, sectionName, "ProcessName", "")
    }
    
    return appConfig
}



; 自定义菜单功能：Win+F2 - 显示自定义菜单
#F2::
{
    ShowCustomMenu()
}

; 主功能函数：Win+F3 - 简化流程（不包含Ctrl+K）
#F3::
{
    ; 确保配置已加载
    if (CurrentAppName = "") {
        LoadCurrentConfig()
    }
    SendToAI("simple")
}

; 重新加载配置：Win+F10 - 重新加载配置文件
#F10::
{
    LoadCurrentConfig(false)  ; 不显示第一个弹窗
    LoadMenuConfig()  ; 重新加载菜单配置
    
    ; 构建合并后的信息内容
    infoText := "配置已重新加载。`n`n"
    infoText .= "配置文件: " . ConfigFile . "`n"
    infoText .= "配置ID: " . CurrentConfigID . "`n"
    infoText .= "应用名称: " . CurrentAppName . "`n"
    
    ; 添加进程名信息（如果存在）
    if (CurrentProcessName) {
        infoText .= "进程名: " . CurrentProcessName . "`n"
    }
    
    ; 添加菜单项数量
    infoText .= "菜单项数量: " . MenuCount
    
    MsgBox(infoText, "配置重载", 0x40)
}

; 打开配置文件：Win+F9 - 打开Config.ini文件
#F9::
{
    ; 检查配置文件是否存在
    if !FileExist(ConfigFile) {
        MsgBox("配置文件不存在: " . ConfigFile, "错误", 0x10)
        return
    }
    
    ; 使用默认程序打开配置文件
    try {
        Run(ConfigFile)
    } catch {
        MsgBox("无法打开配置文件: " . ConfigFile, "错误", 0x10)
    }
}

; 获取窗口信息：Win+F11 - 显示当前活动窗口的标题和进程名
#F11::
{
    ; 获取当前活动窗口的ID
    activeWindowID := WinGetID("A")
    
    ; 获取窗口标题
    windowTitle := WinGetTitle("ahk_id " . activeWindowID)
    
    ; 获取窗口进程名
    processName := WinGetProcessName("ahk_id " . activeWindowID)
    
    ; 获取窗口类名
    windowClass := WinGetClass("ahk_id " . activeWindowID)
    
    ; 显示窗口信息
    infoText := "窗口信息:`n`n"
    infoText .= "窗口标题: " . windowTitle . "`n"
    infoText .= "进程名: " . processName . "`n"
    infoText .= "窗口类名: " . windowClass . "`n"
    infoText .= "窗口ID: " . activeWindowID . "`n"
    infoText .= "`n提示: 使用进程名和窗口标题组合可以更精确地识别应用。"
    
    MsgBox(infoText, "窗口信息", 0x40)
}

; 核心功能函数
SendToAI(mode)
{
    ; 确保配置已加载
    if (CurrentAppName = "") {
        LoadCurrentConfig()
    }
    
    Send("^c") ; 按下 Ctrl+C 复制选中内容
    Sleep(100) ; 短暂延迟确保复制完成
    
    ; 使用新的窗口查找逻辑
    windowID := FindMatchingWindow(CurrentAppName, CurrentProcessName)
    
    ; 激活目标应用
    if (windowID > 0) {
        ; 如果找到匹配的窗口，激活它
        WinActivate("ahk_id " . windowID)
    } else {
        ; 显示更详细的错误信息
        errorMsg := "未找到匹配的应用窗口。"
        if (CurrentProcessName) {
            errorMsg .= "`n`n查找条件:`n窗口标题包含: " . CurrentAppName . "`n进程名: " . CurrentProcessName
        } else {
            errorMsg .= "`n`n查找条件:`n窗口标题包含: " . CurrentAppName . "`n进程名: (未配置)"
        }
        errorMsg .= "`n`n提示: 请确保应用已启动，或检查配置是否正确。"
        MsgBox(errorMsg, "警告", 0x30)
        return
    }
    
    Sleep(100) ; 短暂延迟确保切换完成
    
    ; 根据模式执行不同的操作
    if (mode = "full") {
        Send("^k") ; 按下 Ctrl+K
        Sleep(100) ; 短暂延迟确保操作完成
    }
    
    Send("!1") ; 按下 Alt+1
    Sleep(100) ; 短暂延迟确保操作完成
    Send("^v") ; 按下 Ctrl+V 粘贴内容
    Sleep(100) ; 短暂延迟确保粘贴完成
    Send("{Enter}") ; 按下 Enter 键
}

; 读取当前配置
LoadCurrentConfig(showMessage := false)
{
    ; 声明全局变量
    global ConfigFile, CurrentConfigID, CurrentAppName, CurrentProcessName
    
    ; 检查配置文件是否存在
    if !FileExist(ConfigFile) {
        MsgBox("配置文件不存在: " . ConfigFile, "错误", 0x10)
        ExitApp
    }
    
    ; 尝试使用不同编码读取整个INI文件内容
    try {
        ; 首先尝试使用UTF-8编码
        fileContent := FileRead(ConfigFile, "UTF-8")
        
        ; 解析INI内容获取当前配置ID
        configIDPattern := "s)\[Settings\][\s\S]*?CurrentConfig=([^\r\n]*)"
        RegExMatch(fileContent, configIDPattern, &configIDMatch)
        CurrentConfigID := configIDMatch[1] ? configIDMatch[1] : "1"
        
        ; 解析INI内容获取当前配置的应用名称
        sectionName := "Config" . CurrentConfigID
        
        ; 获取AppName
        appNamePattern := "s)\[" . sectionName . "\][\s\S]*?AppName=([^\r\n]*)"
        RegExMatch(fileContent, appNamePattern, &appNameMatch)
        CurrentAppName := appNameMatch[1] ? appNameMatch[1] : "豆包"
        
        ; 获取ProcessName
        processNamePattern := "s)\[" . sectionName . "\][\s\S]*?ProcessName=([^\r\n]*)"
        RegExMatch(fileContent, processNamePattern, &processNameMatch)
        CurrentProcessName := processNameMatch[1] ? processNameMatch[1] : ""
        
        ; 如果正则匹配失败，尝试使用默认编码
        if (CurrentAppName = "" || CurrentAppName = "豆包" && InStr(fileContent, "AppName=豆包") = 0) {
            fileContent := FileRead(ConfigFile)
            
            ; 重新解析
            RegExMatch(fileContent, configIDPattern, &configIDMatch)
            CurrentConfigID := configIDMatch[1] ? configIDMatch[1] : "1"
            
            sectionName := "Config" . CurrentConfigID
            RegExMatch(fileContent, appNamePattern, &appNameMatch)
            CurrentAppName := appNameMatch[1] ? appNameMatch[1] : "豆包"
            RegExMatch(fileContent, processNamePattern, &processNameMatch)
            CurrentProcessName := processNameMatch[1] ? processNameMatch[1] : ""
        }
        
        ; 如果仍然失败，回退到IniRead
        if (CurrentAppName = "") {
            CurrentConfigID := IniRead(ConfigFile, "Settings", "CurrentConfig", "1")
            sectionName := "Config" . CurrentConfigID
            CurrentAppName := IniRead(ConfigFile, sectionName, "AppName", "豆包")
            CurrentProcessName := IniRead(ConfigFile, sectionName, "ProcessName", "")
        }
    } catch {
        ; 如果FileRead失败，回退到IniRead
        CurrentConfigID := IniRead(ConfigFile, "Settings", "CurrentConfig", "1")
        sectionName := "Config" . CurrentConfigID
        CurrentAppName := IniRead(ConfigFile, sectionName, "AppName", "豆包")
        CurrentProcessName := IniRead(ConfigFile, sectionName, "ProcessName", "")
    }
    
    ; 根据参数决定是否显示调试信息
    if (showMessage) {
        processInfo := CurrentProcessName ? "进程名: " . CurrentProcessName : "进程名: (未配置)"
        MsgBox("配置加载完成:`n`n配置文件: " . ConfigFile . "`n配置ID: " . CurrentConfigID . "`n应用名称: " . CurrentAppName . "`n" . processInfo, "配置加载", 0x40)
    }
}

; 查找匹配的窗口
FindMatchingWindow(appName, processName := "")
{
    ; 如果没有提供进程名，使用原来的方法
    if (processName = "") {
        return WinExist(appName)
    }
    
    ; 遍历所有窗口
    windows := WinGetList()
    
    ; 遍历所有窗口
    for window in windows {
        ; 获取窗口标题
        title := WinGetTitle(window)
        
        ; 获取窗口进程名
        process := WinGetProcessName(window)
        
        ; 检查窗口标题是否包含应用名（不区分大小写）
        titleMatch := InStr(title, appName, false) > 0
        
        ; 检查进程名是否完全匹配（不区分大小写）
        processMatch := (process = processName) || (StrLower(process) = StrLower(processName))
        
        ; 如果两个条件都满足，返回窗口ID
        if (titleMatch && processMatch) {
            return window
        }
    }
    
    ; 没有找到匹配的窗口
    return 0
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
        return
    }
    
    ; 尝试使用不同编码读取整个INI文件内容
    try {
        ; 首先尝试使用UTF-8编码
        fileContent := FileRead(ConfigFile, "UTF-8")
        
        ; 解析INI内容获取菜单数量
        menuCountPattern := "s)\[MenuSettings\][\s\S]*?MenuCount=([^\r\n]*)"
        RegExMatch(fileContent, menuCountPattern, &menuCountMatch)
        MenuCount := menuCountMatch[1] ? Integer(menuCountMatch[1]) : 0
        
        ; 如果没有菜单配置，返回
        if (MenuCount <= 0) {
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
                SendEnter: true,
                SelectApp: ""  ; 新增SelectApp字段，默认为空字符串
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
            newChatValue := newChatMatch[1] !== "" ? newChatMatch[1] : "1"
            menuItem.NewChat := (newChatValue = "1") ? true : false
            
            ; 获取发送回车设置
            sendEnterPattern := "s)\[" . sectionName . "\][\s\S]*?SendEnter=([^\r\n]*)"
            RegExMatch(fileContent, sendEnterPattern, &sendEnterMatch)
            sendEnterValue := sendEnterMatch[1] !== "" ? sendEnterMatch[1] : "1"
            menuItem.SendEnter := (sendEnterValue = "1") ? true : false
            
            ; 获取SelectApp设置
            selectAppPattern := "s)\[" . sectionName . "\][\s\S]*?SelectApp=([^\r\n]*)"
            RegExMatch(fileContent, selectAppPattern, &selectAppMatch)
            menuItem.SelectApp := selectAppMatch[1] ? selectAppMatch[1] : ""
            
            ; 如果正则匹配失败，尝试使用默认编码
            if (menuItem.Name = "菜单项" . itemIndex) {
                fileContent := FileRead(ConfigFile)
                
                ; 重新解析菜单项
                RegExMatch(fileContent, namePattern, &nameMatch)
                menuItem.Name := nameMatch[1] ? nameMatch[1] : "菜单项" . itemIndex
                RegExMatch(fileContent, contentPattern, &contentMatch)
                menuItem.Content := contentMatch[1] ? contentMatch[1] : ""
                RegExMatch(fileContent, newChatPattern, &newChatMatch)
                newChatValue := newChatMatch[1] !== "" ? newChatMatch[1] : "1"
                menuItem.NewChat := (newChatValue = "1") ? true : false
                RegExMatch(fileContent, sendEnterPattern, &sendEnterMatch)
                sendEnterValue := sendEnterMatch[1] !== "" ? sendEnterMatch[1] : "1"
                menuItem.SendEnter := (sendEnterValue = "1") ? true : false
                RegExMatch(fileContent, selectAppPattern, &selectAppMatch)
                menuItem.SelectApp := selectAppMatch[1] ? selectAppMatch[1] : ""
            }
            
            ; 如果仍然失败，回退到IniRead
            if (menuItem.Name = "菜单项" . itemIndex) {
                     menuItem.Name := IniRead(ConfigFile, sectionName, "Name", "菜单项" . itemIndex)
                     menuItem.Content := IniRead(ConfigFile, sectionName, "Content", "")
                     newChatValue := IniRead(ConfigFile, sectionName, "NewChat", "1")
                     menuItem.NewChat := (newChatValue = "1") ? true : false
                     sendEnterValue := IniRead(ConfigFile, sectionName, "SendEnter", "1")
                     menuItem.SendEnter := (sendEnterValue = "1") ? true : false
                     menuItem.SelectApp := IniRead(ConfigFile, sectionName, "SelectApp", "")  ; 新增SelectApp字段读取
                 }
            
            ; 添加到菜单项集合
            MenuItems[itemIndex] := menuItem
        }
    } catch {
        ; 如果FileRead失败，回退到IniRead
        try {
            MenuCount := IniRead(ConfigFile, "MenuSettings", "MenuCount", 0)
            
            if (MenuCount <= 0) {
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
                    SendEnter: (IniRead(ConfigFile, sectionName, "SendEnter", "1") = "1") ? true : false,
                    SelectApp: IniRead(ConfigFile, sectionName, "SelectApp", "")  ; 新增SelectApp字段读取
                }
                
                ; 添加到菜单项集合
                MenuItems[itemIndex] := menuItem
            }
        } catch Error {
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
    ; 声明全局变量和函数
    global MenuCount, MenuItems, ConfigFile, GetAppNamesFromSelectApp
    
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
        
        ; 如果菜单项配置了SelectApp，则显示对应的AppName
        if (menuItem.SelectApp != "") {
            ; 获取所有APP的名称
            appNames := GetAppNamesFromSelectApp(menuItem.SelectApp)
            
            ; 如果成功获取APP名称，则添加到菜单项标题后
            if (appNames != "") {
                menuText := menuText . "（" . appNames . "）"
            }
        }
        
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
    global MenuItems, CurrentAppName, CurrentProcessName, ConfigFile
    
    ; 检查菜单项是否存在
    if (!MenuItems.Has(itemIndex)) {
        MsgBox("菜单项不存在: " . itemIndex, "错误", 0x10)
        return
    }
    
    ; 获取菜单项配置
    menuItem := MenuItems[itemIndex]
    
    ; 确保配置已加载
    if (CurrentAppName = "") {
        LoadCurrentConfig()
    }
    
    ; 复制选中内容
    Send("^c")
    Sleep(300) ; 增加延迟确保复制完成
    
    ; 获取剪贴板内容
    clipboardText := A_Clipboard
    
    ; 处理内容拼接
    finalText := ""
    if (menuItem.Content = "") {
        ; 如果内容为空，直接使用剪贴板内容
        finalText := clipboardText
    } else {
        ; 替换{text}变量
        finalText := StrReplace(menuItem.Content, "{text}", clipboardText)
    }
    
    ; 将最终内容复制到剪贴板
    ; 方法1: 尝试使用直接赋值（AutoHotkey V2的标准方法）
    try {
        A_Clipboard := ""  ; 清空剪贴板
        Sleep(50)
        A_Clipboard := finalText  ; 直接赋值
        Sleep(100)
        
        ; 验证剪贴板内容
        If (A_Clipboard = finalText) {
            ; 成功
        } Else {
            ; 备用方法：使用ClipboardAll
            A_Clipboard := finalText
            Sleep(100)
        }
    } catch as e {
        ; 备用方法：直接赋值
        A_Clipboard := finalText
        Sleep(100)
    }
    Sleep(100) ; 增加延迟确保复制完成
    
    ; 检查菜单项是否指定了SelectApp
    if (menuItem.SelectApp != "") {
        ; 处理多个APP的情况
        ProcessMultipleApps(menuItem.SelectApp, menuItem.NewChat, menuItem.SendEnter)
    } else {
        ; 使用当前配置的应用
        ProcessSingleApp(CurrentAppName, CurrentProcessName, menuItem.NewChat, menuItem.SendEnter)
    }
}

; 使用说明：
; 1. Win+F1: 复制选中内容 -> 激活当前配置的应用 -> Ctrl+K -> Alt+1 -> 粘贴 -> 回车
; 2. Win+F2: 显示自定义菜单，选择菜单项执行对应的文本处理流程
; 3. Win+F3: 复制选中内容 -> 激活当前配置的应用 -> Alt+1 -> 粘贴 -> 回车
; 4. Win+F10: 重新加载配置文件
;
; 配置文件说明：
; 配置文件位于脚本同目录下的Config.ini
; 可以通过修改Config.ini文件添加更多配置
; 每个配置包含AppName（应用名称）
;
; 自定义菜单配置说明：
; 在Config.ini中添加MenuSettings和MenuItem配置
; 每个菜单项包含Name（显示名称）、Content（内容模板，支持{text}变量）、NewChat（是否新建对话）和SendEnter（是否发送回车）