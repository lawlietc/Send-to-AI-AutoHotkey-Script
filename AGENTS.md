# AGENTS.md

## 项目概述

AutoHotkey V2 脚本「Send to AI」，将选中内容一键发送到 AI 应用。exe 通过 GitHub Release 发布，不进 git。

## 上游脚本同步规则（push 前必做）

`Resource/AI-Web-Script.user.js` 是 [lawlietc/AI-Website-Script](https://github.com/lawlietc/AI-Website-Script) 仓库同名文件的同步副本。

每次 `git push` 之前，先检查上游是否有更新：

```bash
gh api "repos/lawlietc/AI-Website-Script/commits?path=AI-Web-Script.user.js&per_page=1" --jq '.[0].sha[0:8]'
```

若结果与本文件记录的「当前同步基准」不同，则重新拷贝并提交：

```bash
gh api "repos/lawlietc/AI-Website-Script/contents/AI-Web-Script.user.js?ref=main" --jq '.content' | base64 -d > Resource/AI-Web-Script.user.js
```

然后更新下方的「当前同步基准」，随本次改动一起提交。

- 当前同步基准：`d1f9dcc3`（脚本版本 v1.2，同步于 2026-10-13）

## exe 编译

使用本机 Ahk2Exe 静默编译（Git Bash 会错误转换 `/in` 等参数，必须经 .bat + `cmd //c` 调起）：

```bat
"D:\Users\lawli\AppData\Local\Programs\AutoHotkey\Compiler\Ahk2Exe.exe" /in "Send to AI.ahk" /out "Release\Send to AI v<版本>.exe" /bin "D:\Users\lawli\AppData\Local\Programs\AutoHotkey\v2\AutoHotkey64.exe"
```

## 发布流程

发布物为整合 zip（不再单独分发裸 exe），包名注明平台：`Send-to-AI-v<版本>-windows-x64.zip`。

1. 编译新 exe 到 `Release/`（该目录不进 git）
2. 建暂存目录 `build_pkg/Send to AI v<版本>/`，放入：exe、`Config.ini`（默认配置）、`使用说明.txt`（UTF-8 BOM + CRLF）、`AI-Web-Script.user.js`
3. 用 .NET `[IO.Compression.ZipFile]::CreateFromDirectory` 打包（勿用 Compress-Archive，中文文件名编码有问题），经 .ps1 文件调 PowerShell 执行
4. `gh release create v<版本> "Release/Send-to-AI-v<版本>-windows-x64.zip" --title "Send to AI v<版本>" --notes-file <notes.md>`
5. 发布说明中必须写明：下载 zip 解压整包运行，勿单独拷出 exe（依赖同目录 Config.ini）
