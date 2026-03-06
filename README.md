# 发送到 AI - 多配置版本

这是一个 AutoHotkey V2 脚本，支持多个 AI 应用配置，可以通过配置文件管理和切换不同的 AI 应用。

## 功能特点

1. **多配置支持**：支持配置多个 AI 应用，如豆包、ZAI 等
2. **精确应用识别**：支持通过窗口标题和进程名精确识别应用，解决同名应用问题
3. **配置切换**：通过快捷键或菜单快速切换不同配置
4. **灵活操作**：提供完整流程和简化流程两种操作模式
5. **自定义菜单**：支持创建自定义菜单项，实现文本预处理和不同操作流程
6. **窗口信息获取**：提供 Win+F11 快捷键获取当前活动窗口的详细信息，便于配置应用识别规则
7. **菜单项指定应用**：通过 SelectApp 字段为每个菜单项指定特定应用配置，无需频繁切换当前配置
8. **自定义快捷键**：支持为每个应用配置不同的快捷键（Ctrl+K/Ctrl+T/Ctrl+N）
9. **自定义延迟**：支持为每个应用配置快捷键按下后的延迟时间，适配不同应用的响应速度

## 快捷键说明

- **Win+F1**：完整流程 - 复制选中内容 → 激活当前配置的应用 → 快捷键（Ctrl+K/Ctrl+T/Ctrl+N，可配置）→ 定位输入框 → 粘贴 → 回车
- **Win+F2**：显示自定义菜单 - 选择菜单项执行对应的文本处理流程
- **Win+F3**：简化流程 - 复制选中内容 → 激活当前配置的应用 → 定位输入框 → 粘贴 → 回车
- **Win+F10**：重新加载配置文件
- **Win+F11**：获取窗口信息 - 显示当前活动窗口的标题、进程名、窗口类名和窗口 ID，用于精确配置应用识别规则

## 额外说明
- 定位输入框：模拟按下 Alt+1，定位到网页的第一个输入框，需另外安装脚本实现
- [聚焦第一个文本输入框](https://greasyfork.org/zh-CN/scripts/504564)

## 配置文件说明

配置文件位于脚本同目录下的 `Config.ini`，格式如下：

```ini
[Settings]
CurrentConfig=1  ; 当前使用的配置 ID
ConfigCount=2    ; 总配置数量

[Config1]
AppName=豆包
ProcessName=msedge.exe  ; 进程名，用于精确识别应用
ShortcutKey=1           ; 快捷键配置（1=Ctrl+K, 2=Ctrl+T, 3=Ctrl+N，默认为 1）
ShortcutDelay=100       ; 快捷键延迟时间（单位：毫秒，默认为 100）

[Config2]
AppName=ZAI
ProcessName=msedge.exe  ; 进程名，用于精确识别应用
ShortcutKey=1
ShortcutDelay=100

[MenuSettings]
MenuCount=4      ; 自定义菜单项数量

[MenuItem1]
Name=翻译成英文
Content=请将以下内容翻译成英文：\n{text}
NewChat=1        ; 是否新建对话 (1=是，0=否)
SendEnter=1      ; 是否发送回车 (1=是，0=否)
```

### 应用配置字段说明

每个 `[ConfigX]` 节包含以下字段：

- **AppName**（必填）：应用窗口标题中包含的关键词，用于识别和激活目标应用
- **ProcessName**（可选）：应用进程名，用于更精确地识别应用，特别是同名应用
- **ShortcutKey**（可选）：快捷键配置，控制新建对话时使用的快捷键
  - `1` = Ctrl+K（默认）
  - `2` = Ctrl+T
  - `3` = Ctrl+N
- **ShortcutDelay**（可选）：快捷键按下后的延迟时间（单位：毫秒）
  - 默认值：100ms
  - 用于适配不同应用的响应速度
  - 如果应用响应较慢，可以增加此值（如 200、500、1000 等）

### ShortcutKey 快捷键配置说明

不同 AI 应用可能使用不同的快捷键来新建对话：
- **Ctrl+K**：大多数 AI 应用使用此快捷键（如豆包、Kimi 等）
- **Ctrl+T**：部分应用使用（如 Qwen）
- **Ctrl+N**：少数应用使用（如 Gemini）

### ShortcutDelay 延迟配置说明

延迟时间控制的是快捷键按下后到执行下一步操作之间的等待时间：
- 如果设置太短：应用可能还没准备好接收输入，导致操作失败
- 如果设置太长：操作会显得卡顿，影响用户体验
- 建议根据实际应用响应速度进行调整：
  - 本地应用或响应快的应用：100-150ms
  - 网页版 AI 应用：150-300ms
  - 响应较慢的应用：300-1000ms

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

Win+F11 快捷键可以获取当前活动窗口的详细信息，包括：

- **窗口标题**：显示在窗口标题栏的文本
- **进程名**：运行该窗口的可执行文件名
- **窗口类名**：窗口的类标识符
- **窗口 ID**：系统分配的唯一窗口标识符

### 使用场景

1. **精确配置应用识别规则**：当多个应用有相似或相同的窗口标题时，可以通过进程名进行区分
2. **调试窗口识别问题**：当脚本无法正确激活目标窗口时，可以使用此功能获取准确信息
3. **了解应用窗口属性**：帮助开发者了解目标应用的窗口属性

### 配置示例

使用 Win+F11 获取信息后，可以更新配置文件：

```ini
[Config1]
AppName=豆包  ; 窗口标题中包含的关键词
ProcessName=msedge.exe  ; 精确的进程名
```

### 技术说明

- 窗口 ID 是系统分配的唯一标识符，格式为十六进制数字
- 进程名是可执行文件的名称，不包含路径
- 窗口类名是应用程序注册的窗口类，对于某些特定应用可能有用

## 自定义菜单功能

### 功能概述

自定义菜单功能允许您创建多个预设的文本处理模板，每个菜单项可以：

- 定义自定义提示词模板
- 设置是否新建对话
- 控制是否自动发送回车

### 配置说明

在 `Config.ini` 文件中添加 `[MenuSettings]` 和 `[MenuItemX]` 节：

- **MenuCount**：自定义菜单项的总数量
- **Name**：菜单项显示名称
- **Content**：内容模板，支持`{text}` 变量替换为选中的文本
- **NewChat**：是否执行 Ctrl+K 新建对话（1=是，0=否）
- **SendEnter**：是否自动发送回车（1=是，0=否）
- **SelectApp**：指定使用哪个配置的应用（可选，为空则使用当前配置）

#### SelectApp 字段说明

`SelectApp` 字段允许您为每个菜单项指定使用哪个配置的应用，而不受当前配置影响：

- 当 `SelectApp` 为空或未设置时，使用当前配置（`CurrentConfig` 指定的配置）
- 当 `SelectApp` 设置为数字时（如"1"、"2"等），使用对应编号的配置
- 当 `SelectApp` 设置为多个数字（如"8,5"）时，按顺序发送到多个应用配置
- 这使得您可以为不同的 AI 应用创建专门的菜单项，无需频繁切换当前配置

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
AppName=千问
ProcessName=chrome.exe

[MenuSettings]
MenuCount=3

[MenuItem1]
Name=发送到 ChatGPT(当前配置)
Content=请分析以下内容：{text}
NewChat=1
SendEnter=1
SelectApp=  ; 为空，使用当前配置

[MenuItem2]
Name=发送到 Claude(指定配置 2)
Content=请总结以下内容：{text}
NewChat=1
SendEnter=1
SelectApp=2  ; 使用 Config2 的配置

[MenuItem3]
Name=发送到千问 (指定配置 3)
Content=请翻译以下内容：{text}
NewChat=0
SendEnter=1
SelectApp=3  ; 使用 Config3 的配置

[MenuItem4]
Name=新对话，发送
Content=
NewChat=1
SendEnter=1
SelectApp=8,5  ; 按顺序发送到 Config8 和 Config5 的配置
```

### 使用方法

1. 按 Win+F3 打开自定义菜单
2. 选择所需的菜单项
3. 脚本将自动处理选中的文本并发送到 AI 应用

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
Content=请总结以下内容的要点：请用简洁的语言列出 3-5 个关键点:{text}
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

1. 确保已安装 AutoHotkey V2
2. 运行 `Send to AI.ahk` 脚本
3. 使用 Win+F10 重新加载配置文件（如需要）
4. 选中任意文本，按 Win+F1 或 Win+F3 发送到 AI 应用
5. 对于自定义处理流程，可按 Win+F2 打开自定义菜单，选择预设的文本处理模板
6. 使用 Win+F11 获取当前活动窗口的详细信息，帮助精确配置应用识别规则

## 注意事项

1. 确保 Edge 浏览器已正确安装
2. 应用名称应与窗口标题匹配，以便正确激活窗口
3. 如果某些 AI 应用需要特定的操作序列，可能需要调整脚本中的按键顺序
4. 使用 ProcessName 字段可以更精确地识别应用，特别是对于同名应用
5. 使用 Win+F11 获取窗口信息，可以帮助您更准确地配置 AppName 和 ProcessName
6. 根据应用响应速度调整 ShortcutDelay 值，确保操作成功率
7. 不同 AI 应用可能使用不同的快捷键，请通过测试确定正确的 ShortcutKey 值

## 故障排除

1. **配置文件不存在错误**：确保 `Config.ini` 文件与脚本在同一目录下
2. **无法激活窗口**：检查 `AppName` 是否与实际窗口标题匹配，或使用 `ProcessName` 字段进行更精确的匹配
3. **Edge 浏览器启动失败**：确保 Edge 浏览器已正确安装并可正常运行
4. **同名应用识别问题**：使用 Win+F11 获取窗口信息，通过 ProcessName 字段区分同名应用
5. **语法错误警告**：确保使用 AutoHotkey V2 语法，脚本已修复所有 V1/V2 语法混用问题

## 文件说明

- `Send to AI.ahk`: 主要的 AutoHotkey 脚本文件，支持多配置功能和自定义菜单
- `Send to AI with debug.ahk`: 包含调试输出的脚本版本，用于问题排查
- `Config.ini`: 配置文件，存储 AI 应用的配置信息和自定义菜单设置
- `Config Manager.ahk`: 配置管理工具，提供图形界面管理配置
- `README.md`: 本说明文件

## 版本历史

- v1.0：初始版本，支持单个 AI 应用
- v1.1：添加 Ctrl+M 步骤
- v1.5：实现多配置系统，支持多个 AI 应用配置
- v2.0：添加自定义菜单功能，支持文本预处理和多种操作流程
- v2.1：添加 Win+F11 窗口信息获取功能，支持 ProcessName 字段精确识别应用，修复 AutoHotkey V2 语法问题
- v2.2：新增 SelectApp 字段功能，允许为每个菜单项指定特定应用配置，无需频繁切换当前配置
- v2.3：新增 ShortcutKey 和 ShortcutDelay 配置字段
  - 支持为每个应用自定义快捷键（Ctrl+K/Ctrl+T/Ctrl+N）
  - 支持为每个应用自定义快捷键延迟时间，适配不同应用的响应速度
