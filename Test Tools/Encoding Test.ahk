#SingleInstance Force

; 测试中文编码处理
configFile := A_ScriptDir . "\Config.ini"
configFileUTF8 := A_ScriptDir . "\Config_UTF8.ini"

; 读取当前配置ID
try {
    CurrentConfigID := IniRead(configFile, "Settings", "CurrentConfig", "1")
} catch {
    CurrentConfigID := "1"
}
SectionName := "Config" . CurrentConfigID

; 使用FileRead读取整个文件内容，使用UTF-8编码
try {
    fileContent := FileRead(configFile, "UTF-8")
    
    ; 解析INI内容获取指定配置的AppName
    appNamePattern := "\[" . SectionName . "\][\s\S]*?AppName=([^\r\n]*)"
    RegExMatch(fileContent, appNamePattern, &appNameMatch)
    appName := appNameMatch[1] ? appNameMatch[1] : "未找到"
    
    ; 解析INI内容获取指定配置的AppURL
    urlPattern := "\[" . SectionName . "\][\s\S]*?AppURL=([^\r\n]*)"
    RegExMatch(fileContent, urlPattern, &urlMatch)
    appURL := urlMatch[1] ? urlMatch[1] : "未找到"
    
    ; 显示结果
    MsgBox("使用UTF-8编码读取的结果 (" . SectionName . "):`n`n应用名称: " . appName . "`n应用URL: " . appURL, "UTF-8编码测试", 0x40)
} catch {
    MsgBox("读取文件失败: " . configFile, "错误", 0x10)
}

; 使用传统IniRead方法对比
appName2 := IniRead(configFile, SectionName, "AppName", "未找到")
appURL2 := IniRead(configFile, SectionName, "AppURL", "未找到")

; 显示对比结果
MsgBox("使用IniRead读取的结果 (" . SectionName . "):`n`n应用名称: " . appName2 . "`n应用URL: " . appURL2, "IniRead方法测试", 0x40)

; 测试UTF-8 BOM文件读取（如果存在）
if FileExist(configFileUTF8) {
    try {
        appNameUTF8 := IniRead(configFileUTF8, SectionName, "AppName", "未找到")
        appURLUTF8 := IniRead(configFileUTF8, SectionName, "AppURL", "未找到")
        
        MsgBox("UTF-8 BOM文件读取结果 (" . SectionName . "):`n`n应用名称: " . appNameUTF8 . "`n应用URL: " . appURLUTF8, "UTF-8 BOM测试", 0x40)
    } catch {
        MsgBox("读取UTF-8 BOM文件失败", "错误", 0x10)
    }
} else {
    MsgBox("UTF-8 BOM配置文件不存在: " . configFileUTF8, "提示", 0x40)
}