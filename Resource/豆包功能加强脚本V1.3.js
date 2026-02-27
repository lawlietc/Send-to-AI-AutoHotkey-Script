// ==UserScript==
// @name         豆包功能加强脚本
// @namespace    http://tampermonkey.net/
// @version      1.3
// @description  为豆包网页添加快捷键定位输入框、自动深色模式和侧边栏宽度控制功能
// @author       AI Assistant & alikia2x
// @match        https://*.doubao.com/*
// @grant        GM_registerMenuCommand
// @grant        GM_setValue
// @grant        GM_getValue
// @license MIT
// ==/UserScript==

/*
 * 使用说明：
 * 
 * 1. 快捷键功能：
 *    - 按下 Ctrl+M 快速定位到豆包输入框
 * 
 * 2. 自动深色模式：
 *    - 脚本会自动检测系统主题设置，并相应地切换豆包网页的主题
 *    - 可通过油猴菜单命令开启/关闭此功能
 * 
 * 3. 侧边栏宽度控制：
 *    - 可以缩小侧边栏宽度，仅显示图标
 *    - 可通过油猴菜单命令切换侧边栏宽度
 * 
 * 注意事项：
 * - 脚本使用了属性选择器和部分匹配来避免网页更新后随机字符导致的功能失效
 * - 如果遇到功能异常，请尝试刷新页面或检查脚本是否为最新版本
 */

(function() {
    'use strict';

    // 获取深色模式开关状态，默认为启用
    let darkModeEnabled = GM_getValue('darkModeEnabled', true);
    
    // 侧边栏缩小状态，默认为未缩小
    let sidebarMinimized = GM_getValue('sidebarMinimized', false);
    
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

    // 功能3: 侧边栏宽度控制
    function initSidebarWidthControl() {
        let minimizeButton = null;
        let originalWidth = null;
        let minimizedWidth = '56px'; // 仅显示图标的宽度
        let observer = null;
        
        // 创建缩小按钮
        function createMinimizeButton() {
            // 创建按钮元素
            minimizeButton = document.createElement('button');
            minimizeButton.className = 'sidebar-minimize-button';
            minimizeButton.title = sidebarMinimized ? '恢复侧边栏宽度' : '缩小侧边栏宽度';
            minimizeButton.style.cssText = `
                background: transparent;
                border: none;
                cursor: pointer;
                padding: 8px;
                border-radius: 4px;
                display: flex;
                align-items: center;
                justify-content: center;
                transition: background-color 0.2s;
                color: inherit;
                z-index: 1000;
                position: relative;
                margin: 8px;
                background-color: rgba(128, 128, 128, 0.1);
            `;
            
            // 添加图标
            minimizeButton.innerHTML = sidebarMinimized ? `
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M4 12h16M12 4v16"></path>
                </svg>
            ` : `
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M5 12h14M12 5v14"></path>
                </svg>
            `;
            
            // 添加点击事件
            minimizeButton.addEventListener('click', function(event) {
                event.stopPropagation();
                toggleSidebarWidth();
            });
            
            // 添加鼠标悬停效果
            minimizeButton.addEventListener('mouseenter', function() {
                this.style.backgroundColor = 'rgba(128, 128, 128, 0.2)';
            });
            
            minimizeButton.addEventListener('mouseleave', function() {
                this.style.backgroundColor = 'rgba(128, 128, 128, 0.1)';
            });
        }
        
        // 切换侧边栏宽度
        function toggleSidebarWidth() {
            const sidebar = document.querySelector('aside[data-testid="chat_siderbar"]');
            if (!sidebar) return;
            
            // 保存原始宽度（如果尚未保存）
            if (!originalWidth) {
                originalWidth = window.getComputedStyle(sidebar).width;
            }
            
            sidebarMinimized = !sidebarMinimized;
            GM_setValue('sidebarMinimized', sidebarMinimized);
            
            // 更新按钮状态
            if (minimizeButton) {
                minimizeButton.title = sidebarMinimized ? '恢复侧边栏宽度' : '缩小侧边栏宽度';
                minimizeButton.innerHTML = sidebarMinimized ? `
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M4 12h16M12 4v16"></path>
                    </svg>
                ` : `
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M5 12h14M12 5v14"></path>
                    </svg>
                `;
            }
            
            // 应用宽度变化，并添加过渡效果
            sidebar.style.transition = 'width 0.3s ease';
            sidebar.style.width = sidebarMinimized ? minimizedWidth : originalWidth;
            
            // 隐藏或显示侧边栏中的文本内容
            // 使用更稳健的选择器，避免随机字符问题
            const textElements = sidebar.querySelectorAll('[class*="title-"], [class*="section-item-title-"], [class*="text-creation-"]');
            textElements.forEach(el => {
                el.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                if (sidebarMinimized) {
                    el.style.opacity = '0';
                    el.style.transform = 'translateX(-10px)';
                } else {
                    el.style.opacity = '1';
                    el.style.transform = 'translateX(0)';
                }
            });
            
            // 隐藏或显示"豆包"标题和关闭按钮
            // 使用属性选择器和部分匹配，避免随机字符问题
            const doubaoTitle = sidebar.querySelector('[class*="title-"]');
            const closeButton = sidebar.querySelector('[data-testid="siderbar_close_btn"]');
            
            if (doubaoTitle) {
                doubaoTitle.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                if (sidebarMinimized) {
                    doubaoTitle.style.opacity = '0';
                    doubaoTitle.style.transform = 'translateX(-10px)';
                } else {
                    doubaoTitle.style.opacity = '1';
                    doubaoTitle.style.transform = 'translateX(0)';
                }
            }
            
            if (closeButton) {
                closeButton.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                if (sidebarMinimized) {
                    closeButton.style.opacity = '0';
                    closeButton.style.transform = 'translateX(-10px)';
                } else {
                    closeButton.style.opacity = '1';
                    closeButton.style.transform = 'translateX(0)';
                }
            }
            
            // 控制左侧导航元素的宽度
            // 使用属性选择器和部分匹配，避免随机字符问题
            const leftSideElement = document.querySelector('nav[data-testid="chat_route_layout_leftside_nav"]');
            if (leftSideElement) {
                leftSideElement.style.transition = 'width 0.3s ease';
                if (sidebarMinimized) {
                    leftSideElement.style.width = '60px';
                } else {
                    leftSideElement.style.width = '280px';
                }
            }
        }
        
        // 初始化按钮位置
        function initButton() {
            // 查找收起侧栏的按钮
        // 使用属性选择器和部分匹配，避免随机字符问题
        const collapseButton = document.querySelector('nav[data-testid="chat_route_layout_leftside_nav"] [class*="collapse-icon-wrapper-"] button, [class*="sidebar-"] button[aria-expanded]');
            const sidebar = document.querySelector('aside[data-testid="chat_siderbar"]');
            
            // 如果找到收起按钮，就在它的左边插入缩小按钮
            if (collapseButton) {
                // 移除已存在的按钮
                if (document.contains(minimizeButton)) {
                    minimizeButton.remove();
                }
                
                // 创建新按钮
                createMinimizeButton();
                
                // 在收起按钮之前插入
                collapseButton.parentNode.insertBefore(minimizeButton, collapseButton);
            } 
            // 如果找不到收起按钮，但有侧边栏，就添加到侧边栏顶部
            else if (sidebar) {
                // 移除已存在的按钮
                if (document.contains(minimizeButton)) {
                    minimizeButton.remove();
                }
                
                // 创建新按钮
                createMinimizeButton();
                
                // 添加到侧边栏顶部
                const topElement = sidebar.querySelector(':first-child');
                if (topElement) {
                    sidebar.insertBefore(minimizeButton, topElement);
                } else {
                    sidebar.appendChild(minimizeButton);
                }
            }
            
            // 如果侧边栏已处于缩小状态，应用缩小效果
            if (sidebarMinimized && sidebar) {
                // 保存原始宽度（如果尚未保存）
                if (!originalWidth) {
                    originalWidth = window.getComputedStyle(sidebar).width;
                }
                
                sidebar.style.width = minimizedWidth;
                
                // 隐藏文本内容
                // 使用更稳健的选择器，避免随机字符问题
                const textElements = sidebar.querySelectorAll('[class*="title-"], [class*="section-item-title-"], [class*="text-creation-"]');
                textElements.forEach(el => {
                    el.style.opacity = '0';
                    el.style.transform = 'translateX(-10px)';
                });
                
                // 隐藏"豆包"标题和关闭按钮
                // 使用属性选择器和部分匹配，避免随机字符问题
                const doubaoTitle = sidebar.querySelector('[class*="title-"]');
                const closeButton = sidebar.querySelector('[data-testid="siderbar_close_btn"]');
                
                if (doubaoTitle) {
                    doubaoTitle.style.opacity = '0';
                    doubaoTitle.style.transform = 'translateX(-10px)';
                }
                
                if (closeButton) {
                    closeButton.style.opacity = '0';
                    closeButton.style.transform = 'translateX(-10px)';
                }
                
                // 控制左侧导航元素的宽度
                // 使用属性选择器和部分匹配，避免随机字符问题
                const leftSideElement = document.querySelector('nav[data-testid="chat_route_layout_leftside_nav"]');
                if (leftSideElement) {
                    leftSideElement.style.width = '60px';
                }
            }
        }
        
        // 开始观察DOM变化，以便在侧边栏结构变化时重新初始化按钮
        function startObserver() {
            // 清除之前的观察器
            if (observer) {
                observer.disconnect();
                observer = null;
            }
            
            observer = new MutationObserver((mutations) => {
                // 检查是否有侧边栏相关的变化
                for (let mutation of mutations) {
                    if (mutation.addedNodes.length > 0) {
                        for (let node of mutation.addedNodes) {
                            if (node.nodeType === 1) { // 元素节点
                                // 检查是否是侧边栏或包含侧边栏
                                if (node.matches('aside[data-testid="chat_siderbar"]') || 
                                    node.querySelector('aside[data-testid="chat_siderbar"]')) {
                                    initButton();
                                    break;
                                }
                                // 检查是否是收起按钮
                                // 使用属性选择器和部分匹配，避免随机字符问题
                                if (node.matches('[class*="collapse-icon-wrapper-"] button, button[aria-expanded]') || 
                                    node.querySelector('[class*="collapse-icon-wrapper-"] button, button[aria-expanded]')) {
                                    initButton();
                                    break;
                                }
                                // 检查是否是"豆包"标题或关闭按钮
                                // 使用属性选择器和部分匹配，避免随机字符问题
                                if (node.matches('[class*="title-"], [data-testid="siderbar_close_btn"]') || 
                                    node.querySelector('[class*="title-"], [data-testid="siderbar_close_btn"]')) {
                                    // 如果侧边栏处于缩小状态，确保这些元素被隐藏
                                    if (sidebarMinimized) {
                                        const sidebar = document.querySelector('aside[data-testid="chat_siderbar"]');
                                        if (sidebar) {
                                            const doubaoTitle = node.matches('[class*="title-"]') ? 
                                                node : node.querySelector('[class*="title-"]');
                                            const closeButton = node.matches('[data-testid="siderbar_close_btn"]') ? 
                                                node : node.querySelector('[data-testid="siderbar_close_btn"]');
                                            
                                            if (doubaoTitle) {
                                                doubaoTitle.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                                                doubaoTitle.style.opacity = '0';
                                                doubaoTitle.style.transform = 'translateX(-10px)';
                                            }
                                            
                                            if (closeButton) {
                                                closeButton.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                                                closeButton.style.opacity = '0';
                                                closeButton.style.transform = 'translateX(-10px)';
                                            }
                                        }
                                    }
                                    break;
                                }
                                // 检查是否是左侧导航元素
                                // 使用属性选择器和部分匹配，避免随机字符问题
                                if (node.matches('nav[data-testid="chat_route_layout_leftside_nav"]') || 
                                    node.querySelector('nav[data-testid="chat_route_layout_leftside_nav"]')) {
                                    // 如果侧边栏处于缩小状态，确保该元素宽度为60px
                                    if (sidebarMinimized) {
                                        const leftSideElement = node.matches('nav[data-testid="chat_route_layout_leftside_nav"]') ? 
                                            node : node.querySelector('nav[data-testid="chat_route_layout_leftside_nav"]');
                                        
                                        if (leftSideElement) {
                                            leftSideElement.style.transition = 'width 0.3s ease';
                                            leftSideElement.style.width = '60px';
                                        }
                                    }
                                    break;
                                }
                            }
                        }
                    }
                }
            });
            
            // 开始观察整个文档的变化
            observer.observe(document.body, {
                childList: true,
                subtree: true
            });
            
            // 定期检查按钮是否存在
            setInterval(() => {
                if (!document.contains(minimizeButton)) {
                    console.log('定时检查发现按钮不存在，重新创建...');
                    initButton();
                }
                
                // 定期检查"豆包"标题和关闭按钮的显示状态
                if (sidebarMinimized) {
                    const sidebar = document.querySelector('aside[data-testid="chat_siderbar"]');
                    if (sidebar) {
                        // 使用属性选择器和部分匹配，避免随机字符问题
                        const doubaoTitle = sidebar.querySelector('[class*="title-"]');
                        const closeButton = sidebar.querySelector('[data-testid="siderbar_close_btn"]');
                        
                        if (doubaoTitle && doubaoTitle.style.opacity !== '0') {
                            doubaoTitle.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                            doubaoTitle.style.opacity = '0';
                            doubaoTitle.style.transform = 'translateX(-10px)';
                        }
                        
                        if (closeButton && closeButton.style.opacity !== '0') {
                            closeButton.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                            closeButton.style.opacity = '0';
                            closeButton.style.transform = 'translateX(-10px)';
                        }
                        
                        // 定期检查左侧导航元素的宽度
                        // 使用属性选择器和部分匹配，避免随机字符问题
                        const leftSideElement = document.querySelector('nav[data-testid="chat_route_layout_leftside_nav"]');
                        if (leftSideElement && leftSideElement.style.width !== '60px') {
                            leftSideElement.style.transition = 'width 0.3s ease';
                            leftSideElement.style.width = '60px';
                        }
                    }
                }
            }, 5000);
        }
        
        // 立即尝试初始化按钮
        initButton();
        
        // 添加一个延迟初始化，以确保页面加载完成
        setTimeout(() => {
            // 检查按钮是否已成功添加
            if (!document.contains(minimizeButton)) {
                console.log('延迟初始化按钮...');
                initButton();
            }
            // 启动监听器
            startObserver();
        }, 2000);
        
        // 返回控制函数
        return {
            toggleWidth: toggleSidebarWidth
        };
    }

    // 注册菜单命令
    function registerMenuCommands() {
        // 深色模式开关菜单项
        GM_registerMenuCommand(
            darkModeEnabled ? "禁用深色模式" : "启用深色模式",
            function() {
                darkModeEnabled = !darkModeEnabled;
                GM_setValue('darkModeEnabled', darkModeEnabled);
                // 重新初始化深色模式
                initAutoDarkMode();
            }
        );
        
        // 侧边栏宽度切换菜单
        GM_registerMenuCommand(
            sidebarMinimized ? "恢复侧边栏宽度" : "缩小侧边栏宽度", 
            function() {
                // 直接切换状态
                sidebarMinimized = !sidebarMinimized;
                GM_setValue('sidebarMinimized', sidebarMinimized);
                
                // 应用变化
                const sidebar = document.querySelector('aside[data-testid="chat_siderbar"]');
                if (sidebar) {
                    // 获取当前宽度作为原始宽度（如果处于缩小状态）
                    let originalWidth = null;
                    if (sidebarMinimized) {
                        // 如果要缩小，先保存当前宽度
                        originalWidth = window.getComputedStyle(sidebar).width;
                    } else {
                        // 如果要恢复，使用默认宽度
                        originalWidth = '240px'; // 豆包侧边栏默认宽度
                    }
                    
                    const minimizedWidth = '56px'; // 仅显示图标的宽度
                    
                    // 应用宽度变化，并添加过渡效果
                    sidebar.style.transition = 'width 0.3s ease';
                    sidebar.style.width = sidebarMinimized ? minimizedWidth : originalWidth;
                    
                    // 隐藏或显示侧边栏中的文本内容
            // 使用更稳健的选择器，避免随机字符问题
            const textElements = sidebar.querySelectorAll('[class*="title-"], [class*="section-item-title-"], [class*="text-creation-"]');
            textElements.forEach(el => {
                el.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                if (sidebarMinimized) {
                    el.style.opacity = '0';
                    el.style.transform = 'translateX(-10px)';
                } else {
                    el.style.opacity = '1';
                    el.style.transform = 'translateX(0)';
                }
            });
            
            // 隐藏或显示"豆包"标题和关闭按钮
            // 使用属性选择器和部分匹配，避免随机字符问题
            const doubaoTitle = sidebar.querySelector('[class*="title-"]');
            const closeButton = sidebar.querySelector('[data-testid="siderbar_close_btn"]');
                    
                    if (doubaoTitle) {
                        doubaoTitle.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                        if (sidebarMinimized) {
                            doubaoTitle.style.opacity = '0';
                            doubaoTitle.style.transform = 'translateX(-10px)';
                        } else {
                            doubaoTitle.style.opacity = '1';
                            doubaoTitle.style.transform = 'translateX(0)';
                        }
                    }
                    
                    if (closeButton) {
                        closeButton.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                        if (sidebarMinimized) {
                            closeButton.style.opacity = '0';
                            closeButton.style.transform = 'translateX(-10px)';
                        } else {
                            closeButton.style.opacity = '1';
                            closeButton.style.transform = 'translateX(0)';
                        }
                    }
                    
                    // 控制左侧导航元素的宽度
            // 使用属性选择器和部分匹配，避免随机字符问题
            const leftSideElement = document.querySelector('nav[data-testid="chat_route_layout_leftside_nav"]');
            if (leftSideElement) {
                leftSideElement.style.transition = 'width 0.3s ease';
                if (sidebarMinimized) {
                    leftSideElement.style.width = '60px';
                } else {
                    leftSideElement.style.width = '280px';
                }
            }
                }
            }
        );
    }

    // 主初始化函数
    function init() {
        // 等待DOM加载完成
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', function() {
                initInputFocusShortcut();
                initAutoDarkMode();
                initSidebarWidthControl();
                registerMenuCommands();
            });
        } else {
            // DOM已经加载完成，直接初始化
            initInputFocusShortcut();
            initAutoDarkMode();
            initSidebarWidthControl();
            registerMenuCommands();
        }
    }

    // 执行初始化
    init();
})();