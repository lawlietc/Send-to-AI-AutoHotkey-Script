// ==UserScript==
// @name         豆包功能加强脚本
// @namespace    http://tampermonkey.net/
// @version      1.1
// @description  为豆包网页添加快捷键定位输入框和自动深色模式功能
// @author       AI Assistant & alikia2x
// @match        https://*.doubao.com/*
// @grant        GM_registerMenuCommand
// @grant        GM_setValue
// @grant        GM_getValue
// @license MIT
// ==/UserScript==

(function() {
    'use strict';

    // 获取深色模式开关状态，默认为启用
    let darkModeEnabled = GM_getValue('darkModeEnabled', true);

    // 功能1: 快捷键定位输入框
    function initInputFocusShortcut() {
        // 添加键盘事件监听
        document.addEventListener('keydown', function(event) {
            // 检查是否按下了 Ctrl+M 组合键
            if (event.ctrlKey && event.key === 'm') {
                event.preventDefault(); // 阻止默认行为

                // 定位输入框 - 使用 data-testid="chat_input_input" 属性
                const inputElement = document.querySelector('textarea[data-testid="chat_input_input"]');

                if (inputElement) {
                    // 聚焦到输入框
                    inputElement.focus();

                    // 可选：添加一个视觉反馈，如短暂高亮
                    inputElement.style.transition = 'box-shadow 0.3s';
                    inputElement.style.boxShadow = '0 0 5px rgba(66, 153, 225, 0.5)';

                    // 0.5秒后移除高亮效果
                    setTimeout(() => {
                        inputElement.style.boxShadow = '';
                    }, 500);
                } else {
                    console.log('未找到豆包输入框');
                }
            }
        });
    }

    // 功能2: 自动深色模式
    function initAutoDarkMode() {
        let darkModeInterval;

        function detectColorScheme() {
            if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
                return 'dark';
            }
            return 'light';
        }

        function setDataTheme(theme) {
            document.documentElement.setAttribute('data-theme', theme);
        }

        function startDarkMode() {
            // 初始设置主题
            setDataTheme(detectColorScheme());

            // 定期检查系统主题变化
            darkModeInterval = setInterval(() => setDataTheme(detectColorScheme()), 16);

            // 监听系统主题变化
            if (window.matchMedia) {
                const colorSchemeQuery = window.matchMedia('(prefers-color-scheme: dark)');
                if (colorSchemeQuery.addEventListener) {
                    colorSchemeQuery.addEventListener('change', (e) => {
                        setDataTheme(e.matches ? 'dark' : 'light');
                    });
                } else if (colorSchemeQuery.addListener) {
                    // 兼容旧版浏览器
                    colorSchemeQuery.addListener((e) => {
                        setDataTheme(e.matches ? 'dark' : 'light');
                    });
                }
            }
        }

        function stopDarkMode() {
            // 清除定时器
            if (darkModeInterval) {
                clearInterval(darkModeInterval);
            }

            // 恢复浅色模式
            setDataTheme('light');
        }

        // 根据开关状态启动或停止深色模式
        if (darkModeEnabled) {
            startDarkMode();
        } else {
            stopDarkMode();
        }

        // 返回控制函数，以便菜单命令可以调用
        return {
            start: startDarkMode,
            stop: stopDarkMode
        };
    }

    // 注册菜单命令
    function registerMenuCommands(darkModeController) {
        // 深色模式开关菜单项
        GM_registerMenuCommand(
            darkModeEnabled ? "禁用深色模式" : "启用深色模式",
            function() {
                darkModeEnabled = !darkModeEnabled;
                GM_setValue('darkModeEnabled', darkModeEnabled);

                if (darkModeEnabled) {
                    darkModeController.start();
                    console.log("豆包深色模式已启用");
                } else {
                    darkModeController.stop();
                    console.log("豆包深色模式已禁用");
                }

                // 刷新菜单以更新显示文本
                location.reload();
            }
        );
    }

    // 初始化所有功能
    function initAllFeatures() {
        initInputFocusShortcut();
        const darkModeController = initAutoDarkMode();
        registerMenuCommands(darkModeController);
    }

    // 当DOM加载完成后初始化功能
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initAllFeatures);
    } else {
        initAllFeatures();
    }
})();