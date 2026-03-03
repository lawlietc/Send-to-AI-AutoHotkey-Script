; 测试配置切换功能
; AutoHotkey V2 Script

#SingleInstance Force

; 全局变量
ConfigFile := A_ScriptDir . "\..\Config.ini"
CurrentConfigID := 1
CurrentAppName := ""

; 读取当前配置
LoadCurrentConfig()
{
    ; 声明全局变量
    global ConfigFile, CurrentConfigID, CurrentAppName
    
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
    } catch {
        ; 如果FileRead失败，回退到IniRead
        CurrentConfigID := IniRead(ConfigFile, "Settings", "CurrentConfig", "1")
        sectionName := "Config" . CurrentConfigID
        CurrentAppName := IniRead(ConfigFile, sectionName, "AppName", "豆包")
    }
}

; 切换配置
SwitchConfig(configID)
{
    ; 声明全局变量
    global ConfigFile, CurrentConfigID, CurrentAppName
    
    ; 更新当前配置ID
    CurrentConfigID := configID
    
    ; 使用UTF-8编码读取整个INI文件内容
    try {
        fileContent := FileRead(ConfigFile, "UTF-8")
        
        ; 替换CurrentConfig值
        newContent := RegExReplace(fileContent, "s)(\[Settings\][\s\S]*?)CurrentConfig=[^\r\n]*", "$1CurrentConfig=" . configID)
        
        ; 写回文件
        FileDelete(ConfigFile)
        FileAppend(newContent, ConfigFile, "UTF-8")
    } catch {
        ; 如果UTF-8操作失败，回退到IniWrite
        try {
            IniWrite(configID, ConfigFile, "Settings", "CurrentConfig")
        } catch Error {
            MsgBox("配置写入失败: " . Error.Message, "错误", 0x10)
            return
        }
    }
    
    ; 重新加载配置
    LoadCurrentConfig()
    
    ; 显示提示
    MsgBox("已切换到配置 " . configID . ": " . CurrentAppName, "配置切换", 0x40)
}

; 测试函数
TestConfigSwitch()
{
    ; 读取当前配置
    LoadCurrentConfig()
    MsgBox("当前配置ID: " . CurrentConfigID . ", 应用名称: " . CurrentAppName, "当前配置", 0x40)
    
    ; 创建菜单
    configMenu := Menu()
    
    ; 添加配置选项
    Loop 3 {
        configID := A_Index
        sectionName := "Config" . configID
        
        ; 使用UTF-8读取
        try {
            fileContent := FileRead(ConfigFile, "UTF-8")
            appNamePattern := "s)\[" . sectionName . "\][\s\S]*?AppName=([^\r\n]*)"
            RegExMatch(fileContent, appNamePattern, &appNameMatch)
            appName := appNameMatch[1] ? appNameMatch[1] : "未知应用"
        } catch {
            appName := IniRead(ConfigFile, sectionName, "AppName", "未知应用")
        }
        
        ; 如果是当前配置，添加标记
        if (configID = CurrentConfigID) {
            configMenu.Add("✔ " . appName . " (配置" . configID . ")", SwitchConfig.Bind(configID))
        } else {
            configMenu.Add(appName . " (配置" . configID . ")", SwitchConfig.Bind(configID))
        }
    }
    
    ; 显示菜单
    configMenu.Show()
}

; 运行测试
TestConfigSwitch()