# 发送到AI - 多配置版本

这是一个AutoHotkey V2脚本，支持多个AI应用配置，可以通过配置文件管理和切换不同的AI应用。

## 功能特点

1. **多配置支持**：支持配置多个AI应用，如豆包、ZAI等
2. **精确应用识别**：支持通过窗口标题和进程名精确识别应用，解决同名应用问题
3. **配置切换**：通过快捷键或菜单快速切换不同配置
4. **灵活操作**：提供完整流程和简化流程两种操作模式
5. **自定义菜单**：支持创建自定义菜单项，实现文本预处理和不同操作流程
6. **窗口信息获取**：提供Win+F11快捷键获取当前活动窗口的详细信息，便于配置应用识别规则
7. **菜单项指定应用**：通过SelectApp字段为每个菜单项指定特定应用配置，无需频繁切换当前配置

## 快捷键说明

- **Win+F1**：完整流程 - 复制选中内容 → 激活当前配置的应用 → Ctrl+K → 定位输入框 → 粘贴 → 回车
- **Win+F2**：显示自定义菜单 - 选择菜单项执行对应的文本处理流程
- **Win+F3**：简化流程 - 复制选中内容 → 激活当前配置的应用 → 定位输入框 → 粘贴 → 回车
- **Win+F10**：重新加载配置文件
- **Win+F11**：获取窗口信息 - 显示当前活动窗口的标题、进程名、窗口类名和窗口ID，用于精确配置应用识别规则

## 额外说明
- 定位输入框：模拟按下Alt+1，定位到网页的第一个输入框，需另外安装脚本实现
- [聚焦第一个文本输入框](https://greasyfork.org/zh-CN/scripts/504564)

## 配置文件说明

配置文件位于脚本同目录下的`Config.ini`，格式如下：

```ini
[Settings]
CurrentConfig=1  ; 当前使用的配置ID
ConfigCount=2    ; 总配置数量

[Config1]
AppName=豆包
ProcessName=msedge.exe  ; 进程名，用于精确识别应用

[Config2]
AppName=ZAI
ProcessName=msedge.exe  ; 进程名，用于精确识别应用

[MenuSettings]
MenuCount=3      ; 自定义菜单项数量

[MenuItem1]
Name=翻译成英文
Content=请将以下内容翻译成英文：\n{text}
NewChat=1        ; 是否新建对话 (1=是, 0=否)
SendEnter=1      ; 是否发送回车 (1=是, 0=否)

[MenuItem2]
Name=代码优化
Content=请优化以下代码：\n```text\n{text}\n```
NewChat=1
SendEnter=1

[MenuItem3]
Name=新对话，不发送
Content=
NewChat=1
SendEnter=0
```

## 窗口信息获取功能

### 功能概述

Win+F11快捷键可以获取当前活动窗口的详细信息，包括：

- **窗口标题**：显示在窗口标题栏的文本
- **进程名**：运行该窗口的可执行文件名
- **窗口类名**：窗口的类标识符
- **窗口ID**：系统分配的唯一窗口标识符

### 使用场景

1. **精确配置应用识别规则**：当多个应用有相似或相同的窗口标题时，可以通过进程名进行区分
2. **调试窗口识别问题**：当脚本无法正确激活目标窗口时，可以使用此功能获取准确信息
3. **了解应用窗口属性**：帮助开发者了解目标应用的窗口属性

### 配置示例

使用Win+F11获取信息后，可以更新配置文件：

```ini
[Config1]
AppName=豆包  ; 窗口标题中包含的关键词
ProcessName=msedge.exe  ; 精确的进程名
```

### 技术说明

- 窗口ID是系统分配的唯一标识符，格式为十六进制数字
- 进程名是可执行文件的名称，不包含路径
- 窗口类名是应用程序注册的窗口类，对于某些特定应用可能有用

## 自定义菜单功能

### 功能概述

自定义菜单功能允许您创建多个预设的文本处理模板，每个菜单项可以：

- 定义自定义提示词模板
- 设置是否新建对话
- 控制是否自动发送回车

### 配置说明

在`Config.ini`文件中添加`[MenuSettings]`和`[MenuItemX]`节：

- **MenuCount**：自定义菜单项的总数量
- **Name**：菜单项显示名称
- **Content**：内容模板，支持`{text}`变量替换为选中的文本
- **NewChat**：是否执行Ctrl+K新建对话（1=是，0=否）
- **SendEnter**：是否自动发送回车（1=是，0=否）
- **SelectApp**：指定使用哪个配置的应用（可选，为空则使用当前配置）

#### SelectApp字段说明

`SelectApp`字段允许您为每个菜单项指定使用哪个配置的应用，而不受当前配置影响：

- 当`SelectApp`为空或未设置时，使用当前配置（`CurrentConfig`指定的配置）
- 当`SelectApp`设置为数字时（如"1"、"2"等），使用对应编号的配置
- 这使得您可以为不同的AI应用创建专门的菜单项，无需频繁切换当前配置

#### 配置示例

```ini
[Settings]
CurrentConfig=1
ConfigCount=3

[Config1]
AppName=ChatGPT
ProcessName=chrome.exe

[Config2]
AppName=Claude
ProcessName=chrome.exe

[Config3]
AppName=文心一言
ProcessName=chrome.exe

[MenuSettings]
MenuCount=3

[MenuItem1]
Name=发送到ChatGPT(当前配置)
Content=请分析以下内容：{text}
NewChat=1
SendEnter=1
SelectApp=  ; 为空，使用当前配置

[MenuItem2]
Name=发送到Claude(指定配置2)
Content=请总结以下内容：{text}
NewChat=1
SendEnter=1
SelectApp=2  ; 使用Config2的配置

[MenuItem3]
Name=发送到文心一言(指定配置3)
Content=请翻译以下内容：{text}
NewChat=0
SendEnter=1
SelectApp=3  ; 使用Config3的配置
```

### 使用方法

1. 按Win+F3打开自定义菜单
2. 选择所需的菜单项
3. 脚本将自动处理选中的文本并发送到AI应用

### 常用模板示例

#### 翻译类

```ini
Name=翻译成英文
Content=请将以下内容翻译成英文：\n{text}
NewChat=1
SendEnter=1
```

#### 文本总结类

```ini
Name=总结要点
Content=请总结以下内容的要点：请用简洁的语言列出3-5个关键点:{text}
NewChat=1
SendEnter=1
```

#### 仅新建对话

```ini
Name=新对话，不发送
Content=
NewChat=1
SendEnter=0
```

## 使用方法

1. 确保已安装AutoHotkey V2
2. 运行`Send to AI.ahk`脚本
3. 使用Win+F10重新加载配置文件（如需要）
4. 选中任意文本，按Win+F1或Win+F3发送到AI应用
5. 对于自定义处理流程，可按Win+F2打开自定义菜单，选择预设的文本处理模板
6. 使用Win+F11获取当前活动窗口的详细信息，帮助精确配置应用识别规则

## 注意事项

1. 确保Edge浏览器已正确安装
2. 应用名称应与窗口标题匹配，以便正确激活窗口
3. 如果某些AI应用需要特定的操作序列，可能需要调整脚本中的按键顺序
4. 使用ProcessName字段可以更精确地识别应用，特别是对于同名应用
5. 使用Win+F11获取窗口信息，可以帮助您更准确地配置AppName和ProcessName

## 故障排除

1. **配置文件不存在错误**：确保`Config.ini`文件与脚本在同一目录下
2. **无法激活窗口**：检查`AppName`是否与实际窗口标题匹配，或使用`ProcessName`字段进行更精确的匹配
3. **Edge浏览器启动失败**：确保Edge浏览器已正确安装并可正常运行
4. **同名应用识别问题**：使用Win+F11获取窗口信息，通过ProcessName字段区分同名应用
5. **语法错误警告**：确保使用AutoHotkey V2语法，脚本已修复所有V1/V2语法混用问题

## 文件说明

- `Send to AI.ahk`: 主要的AutoHotkey脚本文件，支持多配置功能和自定义菜单
- `Send to AI with debug.ahk`: 包含调试输出的脚本版本，用于问题排查
- `Config.ini`: 配置文件，存储AI应用的配置信息和自定义菜单设置
- `Config Manager.ahk`: 配置管理工具，提供图形界面管理配置
- `README.md`: 本说明文件

## 版本历史

- v1.0：初始版本，支持单个AI应用
- v1.1：添加Ctrl+M步骤
- v1.5：实现多配置系统，支持多个AI应用配置
- v2.0：添加自定义菜单功能，支持文本预处理和多种操作流程
- v2.1：添加Win+F11窗口信息获取功能，支持ProcessName字段精确识别应用，修复AutoHotkey V2语法问题
- v2.2：新增SelectApp字段功能，允许为每个菜单项指定特定应用配置，无需频繁切换当前配置