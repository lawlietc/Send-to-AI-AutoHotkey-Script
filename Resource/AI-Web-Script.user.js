// ==UserScript==
// @name         AI Web Script (统一 AI 聊天网站增强)
// @namespace    http://tampermonkey.net/
// @version      1.2
// @description  整合 DeepSeek / Gemini / Grok / Qwen / ZAI / Doubao 的快捷键与界面增强，按网址自动适配。
// @updateURL    https://cdn.jsdelivr.net/gh/lawlietc/AI-Website-Script@main/AI-Web-Script.user.js
// @downloadURL  https://cdn.jsdelivr.net/gh/lawlietc/AI-Website-Script@main/AI-Web-Script.user.js
// @homepageURL  https://github.com/lawlietc/AI-Website-Script
// @author       Lawliet
// @match        https://chat.deepseek.com/*
// @match        https://gemini.google.com/app*
// @match        https://grok.com/*
// @match        https://chat.qwen.ai/*
// @match        https://chat.z.ai/*
// @match        https://*.doubao.com/*
// @grant        GM_registerMenuCommand
// @grant        GM_setValue
// @grant        GM_getValue
// @run-at       document-start
// @license      MIT
// ==/UserScript==

(function () {
    'use strict';

    // ===== 每站开关（如某站不想用，改 false 即可）=====
    const ENABLED = {
        deepseek: true,
        gemini:   true,
        grok:     true,
        qwen:     true,
        zai:      true,
        doubao:   true,
    };

    const host = location.hostname;

    // ===== 按 hostname 分流（同一时刻只跑一个站点）=====
    if (ENABLED.deepseek && host.includes('chat.deepseek.com')) initDeepSeek();
    else if (ENABLED.gemini && host.includes('gemini.google.com')) initGemini();
    else if (ENABLED.grok && host.includes('grok.com')) initGrok();
    else if (ENABLED.qwen && host.includes('chat.qwen.ai')) initQwen();
    else if (ENABLED.zai && host.includes('chat.z.ai')) initZAI();
    else if (ENABLED.doubao && host.includes('doubao.com')) initDoubao();

    /* =========================================================
     * 共享工具：聚焦页面上第一个「可见」的文本输入框
     * 仅用于没有专属 Alt+1 逻辑的站点（DeepSeek / Gemini / Grok）
     * ========================================================= */
    function focusFirstTextInput() {
        const inputSelector = [
            'input[type="text"]:not([disabled]):not([readonly])',
            'input[type="email"]:not([disabled]):not([readonly])',
            'input[type="password"]:not([disabled]):not([readonly])',
            'input[type="search"]:not([disabled]):not([readonly])',
            'input[type="tel"]:not([disabled]):not([readonly])',
            'input[type="url"]:not([disabled]):not([readonly])',
            'input:not([type]):not([disabled]):not([readonly])',
            'textarea:not([disabled]):not([readonly])',
            '[contenteditable="true"]:not([disabled]):not([readonly])',
            '[role="textbox"]:not([disabled]):not([readonly])'
        ].join(',');

        const allInputs = document.querySelectorAll(inputSelector);
        const firstVisibleInput = Array.from(allInputs).find(function (input) {
            const style = window.getComputedStyle(input);
            return style.display !== 'none' && style.visibility !== 'hidden';
        });

        if (firstVisibleInput) firstVisibleInput.focus();
    }

    /* =========================================================
     * DeepSeek：Ctrl+K 映射为 Ctrl+J（捕获阶段拦截并重派发），
     *              Ctrl+J 保留原有功能，不做任何改动。
     * ========================================================= */
    function initDeepSeek() {
        let redirecting = false;

        document.addEventListener('keydown', function (event) {
            if (redirecting) return; // 防止重派发的事件再次被拦截

            const isK = event.ctrlKey && (event.key === 'k' || event.key === 'K');
            if (!isK) return; // 只处理 Ctrl+K；Ctrl+J 保持原样

            const newKey = event.key === 'k' ? 'j' : 'J';
            const newCode = event.code === 'KeyK' ? 'KeyJ' : event.code;

            event.stopImmediatePropagation();
            event.preventDefault();

            const newEvent = new KeyboardEvent('keydown', {
                key: newKey,
                code: newCode,
                location: event.location,
                ctrlKey: event.ctrlKey,
                shiftKey: event.shiftKey,
                altKey: event.altKey,
                metaKey: event.metaKey,
                repeat: event.repeat,
                isComposing: event.isComposing,
                bubbles: true,
                cancelable: true,
                composed: true,
            });

            redirecting = true;
            event.target.dispatchEvent(newEvent);
            redirecting = false;
        }, true);

        // Alt+1：聚焦第一个可见文本输入框
        document.addEventListener('keydown', function (event) {
            if (event.altKey && event.key === '1') {
                event.preventDefault();
                focusFirstTextInput();
            }
        }, false);
    }

    /* =========================================================
     * Gemini：Ctrl+K 新建对话（点击「发起新对话」按钮）
     * ========================================================= */
    function initGemini() {
        document.addEventListener('keydown', function (e) {
            if (e.ctrlKey && (e.key === 'k' || e.key === 'K')) {
                e.preventDefault();
                e.stopPropagation();

                const selectors = [
                    'button[data-test-id="expanded-button"]',
                    'button[data-test-id="fab-button"]',
                    'button[aria-label="发起新对话"]',
                    'button[aria-label="New chat"]'
                ];
                const newChatButton = document.querySelector(selectors.join(', '));

                if (newChatButton) {
                    console.log('[AI Web Script] Gemini: 已点击新建对话');
                    newChatButton.click();
                } else {
                    console.error('[AI Web Script] Gemini: 未找到新建对话按钮，UI 可能已更新');
                }
            }
        });

        // Alt+1：聚焦第一个可见文本输入框
        document.addEventListener('keydown', function (event) {
            if (event.altKey && event.key === '1') {
                event.preventDefault();
                focusFirstTextInput();
            }
        }, false);
    }

    /* =========================================================
     * Grok：Ctrl+K (Mac: Cmd+K) → 模拟 Ctrl+J（新建对话）
     * ========================================================= */
    function initGrok() {
        window.addEventListener('keydown', function (e) {
            const isK = (e.key && e.key.toLowerCase() === 'k') || e.code === 'KeyK';

            if ((e.ctrlKey || e.metaKey) && !e.shiftKey && !e.altKey && isK) {
                e.preventDefault();
                e.stopPropagation();
                e.stopImmediatePropagation();

                const simulateEvent = (target) => {
                    const event = new KeyboardEvent('keydown', {
                        key: 'j',
                        code: 'KeyJ',
                        keyCode: 74,
                        which: 74,
                        ctrlKey: true,
                        metaKey: e.metaKey,
                        altKey: false,
                        shiftKey: false,
                        bubbles: true,
                        cancelable: true,
                        composed: true,
                        view: window
                    });
                    target.dispatchEvent(event);
                };

                const activeEl = document.activeElement || document.body;
                simulateEvent(activeEl);
                simulateEvent(document);
                simulateEvent(window);
            }
        }, true);

        // Alt+1：聚焦第一个可见文本输入框
        document.addEventListener('keydown', function (event) {
            if (event.altKey && event.key === '1') {
                event.preventDefault();
                focusFirstTextInput();
            }
        }, false);
    }

    /* =========================================================
     * Qwen：Ctrl+K 新建对话 + 网络搜索 + 深度思考；Alt+1 聚焦输入框
     * ========================================================= */
    function initQwen() {
        function clickNewChatButton() {
            let expandedButton = document.querySelector('.sidebar-entry-fixed-list [aria-label="新建对话"].sidebar-entry-fixed-list-content');
            if (expandedButton && expandedButton.offsetParent !== null) {
                expandedButton.click();
                console.log('[AI Web Script] Qwen: 点击了展开侧边栏状态下的新建对话按钮');
                return;
            }
            let collapsedButton = document.querySelector('.sidebar-entry-fixed-list-only-icon [aria-label="新建对话"].sidebar-entry-fixed-list-content');
            if (collapsedButton && collapsedButton.offsetParent !== null) {
                collapsedButton.click();
                console.log('[AI Web Script] Qwen: 点击了收起侧边栏状态下的新建对话按钮');
                return;
            }
            let fallbackButton = document.querySelector('[aria-label="新建对话"].sidebar-entry-fixed-list-content');
            if (fallbackButton && fallbackButton.offsetParent !== null) {
                fallbackButton.click();
                console.log('[AI Web Script] Qwen: 点击了新建对话按钮（通用选择器）');
                return;
            }
            console.warn('[AI Web Script] Qwen: 未找到可见的新建对话按钮');
        }

        function clickWebSearchButton() {
            let webSearchButton;
            let searchIcon = document.querySelector('svg use[href="#icon-line-globe-01"]');
            if (searchIcon) {
                webSearchButton = searchIcon.closest('.chat-input-feature-btn');
            }
            let searchTooltip = document.querySelector('[aria-describedby*="搜索"]');
            if (searchTooltip && !webSearchButton) {
                webSearchButton = searchTooltip;
            }
            if (!webSearchButton) {
                let allFeatureBtns = document.querySelectorAll('.chat-input-feature-btn');
                for (let btn of allFeatureBtns) {
                    if (btn.textContent.includes('搜索')) {
                        webSearchButton = btn;
                        break;
                    }
                }
            }
            if (!webSearchButton) {
                let featureBtns = document.querySelectorAll('.action-bar-left-btns .chat-input-feature-btn');
                if (featureBtns.length >= 2) {
                    webSearchButton = featureBtns[1];
                }
            }
            if (webSearchButton && webSearchButton.offsetParent !== null) {
                webSearchButton.click();
                console.log('[AI Web Script] Qwen: 点击了网络搜索按钮');
            } else {
                console.warn('[AI Web Script] Qwen: 未找到可见的网络搜索按钮');
            }
        }

        function clickDepthThinkingButton() {
            let depthThinkingButton;
            let thinkingContainer = document.querySelector('.chat-message-input-thinking-budget-btn');
            if (thinkingContainer) {
                depthThinkingButton = thinkingContainer.querySelector('.chat-input-feature-btn');
            }
            if (!depthThinkingButton) {
                let thinkingIcon = document.querySelector('svg use[href="#icon-line-deepthink-01"]');
                if (thinkingIcon) {
                    depthThinkingButton = thinkingIcon.closest('.chat-input-feature-btn');
                }
            }
            if (!depthThinkingButton) {
                let allFeatureBtns = document.querySelectorAll('.chat-input-feature-btn');
                for (let btn of allFeatureBtns) {
                    if (btn.textContent.includes('深度思考')) {
                        depthThinkingButton = btn;
                        break;
                    }
                }
            }
            if (!depthThinkingButton) {
                let thinkingLabel = document.querySelector('[aria-label="深度思考"]');
                if (thinkingLabel) {
                    depthThinkingButton = thinkingLabel.nextElementSibling || thinkingLabel.closest('.chat-input-feature-btn');
                }
            }
            if (!depthThinkingButton) {
                let actionBar = document.querySelector('.action-bar-left-btns');
                if (actionBar && actionBar.firstElementChild) {
                    depthThinkingButton = actionBar.firstElementChild.querySelector('.chat-input-feature-btn');
                }
            }
            if (depthThinkingButton && depthThinkingButton.offsetParent !== null) {
                depthThinkingButton.click();
                console.log('[AI Web Script] Qwen: 点击了深度思考按钮');
            } else {
                console.warn('[AI Web Script] Qwen: 未找到可见的深度思考按钮');
            }
        }

        function focusChatInput() {
            let chatInput = document.querySelector('#chat-input');
            if (chatInput) {
                chatInput.focus();
                chatInput.setSelectionRange(chatInput.value.length, chatInput.value.length);
            } else {
                console.warn('[AI Web Script] Qwen: 未找到聊天输入框');
            }
        }

        function handleKeyDown(e) {
            if (e.ctrlKey && (e.key === 'k' || e.key === 'K')) {
                e.preventDefault();
                clickNewChatButton();
                setTimeout(() => {
                    clickWebSearchButton();
                    clickDepthThinkingButton();
                }, 500);
            } else if (e.altKey && e.key === '1') {
                e.preventDefault();
                focusChatInput();
            }
        }

        document.addEventListener('keydown', handleKeyDown, true);
    }

    /* =========================================================
     * ZAI：Ctrl+K 新建对话 + 切换搜索；Alt+1 聚焦输入框
     * ========================================================= */
    function initZAI() {
        document.addEventListener('keydown', function (event) {
            if ((event.ctrlKey || event.metaKey) && (event.key === 'k' || event.key === 'K')) {
                event.preventDefault();
                clickNewChatAndToggleSearch();
            }
            if (event.altKey && event.key === '1') {
                event.preventDefault();
                focusChatInput();
            }
        });

        function clickNewChatAndToggleSearch() {
            let buttonClicked = false;
            let sidebarButton = document.getElementById('sidebar-new-chat-button');
            if (sidebarButton) {
                sidebarButton.click();
                buttonClicked = true;
            }
            if (!buttonClicked) {
                let collapsedButton = document.getElementById('new-chat-button');
                if (collapsedButton) {
                    collapsedButton.click();
                    buttonClicked = true;
                }
            }
            if (buttonClicked) {
                setTimeout(clickSearchToggle, 100);
            } else {
                console.log('[AI Web Script] ZAI: 未找到新建对话按钮，可能页面还在加载中...');
            }
        }

        function clickSearchToggle() {
            const selector = 'div[aria-label="Enable or disable search"] button[type="button"]:first-of-type, div[aria-label="开启或关闭搜索"] button[type="button"]:first-of-type';
            const searchToggleButton = document.querySelector(selector);
            if (searchToggleButton) {
                searchToggleButton.click();
            } else {
                console.log('[AI Web Script] ZAI: 未找到搜索开关按钮 (已检查英文和中文 aria-label)');
            }
        }

        function focusChatInput() {
            const chatInput = document.getElementById('chat-input');
            if (chatInput) {
                chatInput.focus();
            } else {
                console.log('[AI Web Script] ZAI: 未找到聊天输入框 (#chat-input)');
            }
        }
    }

    /* =========================================================
     * Doubao：Alt+1 聚焦输入框 + 自动深色模式 + 侧边栏切换 + 隐藏推荐 + 油猴菜单
     * ========================================================= */
    function initDoubao() {
        let darkModeEnabled = GM_getValue('darkModeEnabled', true);
        let hideSuggestionsEnabled = GM_getValue('hideSuggestionsEnabled', true);

        function initHideSuggestions() {
            function hideSuggestionsElements() {
                let hiddenCount = 0;
                const suggestionsContainer = document.querySelector('#experiment-guidance-suggestions');
                if (suggestionsContainer) {
                    if (suggestionsContainer.style.display !== 'none') {
                        suggestionsContainer.style.display = 'none';
                        hiddenCount++;
                    }
                    suggestionsContainer.style.minHeight = '0';
                    const firstDiv = suggestionsContainer.querySelector(':scope > div');
                    if (firstDiv && firstDiv.style.display !== 'none') {
                        firstDiv.style.display = 'none';
                        hiddenCount++;
                    }
                }
                const similarContainers = document.querySelectorAll('.flex.min-h-150.w-full.flex-col.justify-center');
                similarContainers.forEach(container => {
                    container.style.display = 'none';
                    container.style.minHeight = '0';
                    hiddenCount++;
                });
                const allContainers = document.querySelectorAll('.flex.min-h-150.w-full');
                allContainers.forEach(container => {
                    const scrollChild = container.querySelector('div.overflow-x-auto');
                    if (scrollChild) {
                        container.style.display = 'none';
                        container.style.minHeight = '0';
                        hiddenCount++;
                    }
                });
                const suggestFoundationElements = document.querySelectorAll('[data-foundation-type="receive-message-suggest-foundation"]');
                suggestFoundationElements.forEach(element => {
                    if (element.style.display !== 'none') {
                        element.style.display = 'none';
                        hiddenCount++;
                    }
                });
                const suggestMessageListElements = document.querySelectorAll('.suggest-message-list-wrapper-QLdGFg');
                suggestMessageListElements.forEach(element => {
                    if (element.style.display !== 'none') {
                        element.style.display = 'none';
                        hiddenCount++;
                    }
                });
                if (hiddenCount > 0) {
                    console.log(`[AI Web Script] Doubao: 本次检查共隐藏了 ${hiddenCount} 个元素`);
                }
            }

            const observer = new MutationObserver(function () {
                if (hideSuggestionsEnabled) hideSuggestionsElements();
            });

            function startObserver() {
                if (document.body) {
                    observer.observe(document.body, { childList: true, subtree: true });
                } else {
                    setTimeout(startObserver, 100);
                }
            }

            if (hideSuggestionsEnabled) {
                hideSuggestionsElements();
                startObserver();
                setInterval(() => {
                    if (hideSuggestionsEnabled) hideSuggestionsElements();
                }, 1000);
            }

            return { hide: hideSuggestionsElements };
        }

        function initAutoDarkMode() {
            let darkModeInterval;

            function detectColorScheme() {
                if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) return 'dark';
                return 'light';
            }
            function setDataTheme(theme) {
                document.documentElement.setAttribute('data-theme', theme);
            }
            function startDarkMode() {
                setDataTheme(detectColorScheme());
                darkModeInterval = setInterval(() => setDataTheme(detectColorScheme()), 16);
                if (window.matchMedia) {
                    const q = window.matchMedia('(prefers-color-scheme: dark)');
                    if (q.addEventListener) {
                        q.addEventListener('change', (e) => setDataTheme(e.matches ? 'dark' : 'light'));
                    } else if (q.addListener) {
                        q.addListener((e) => setDataTheme(e.matches ? 'dark' : 'light'));
                    }
                }
            }
            function stopDarkMode() {
                if (darkModeInterval) clearInterval(darkModeInterval);
                setDataTheme('light');
            }

            if (darkModeEnabled) startDarkMode();
            else stopDarkMode();

            return { start: startDarkMode, stop: stopDarkMode };
        }

        function initInputFocusShortcut() {
            document.addEventListener('keydown', function (event) {
                if (event.altKey && event.key === '1') {
                    event.preventDefault();
                    const inputElement = document.querySelector('textarea[data-testid="chat_input_input"]');
                    if (inputElement) {
                        inputElement.focus();
                        inputElement.style.transition = 'box-shadow 0.3s';
                        inputElement.style.boxShadow = '0 0 5px rgba(66, 153, 225, 0.5)';
                        setTimeout(() => { inputElement.style.boxShadow = ''; }, 500);
                    } else {
                        console.log('[AI Web Script] Doubao: 未找到输入框');
                    }
                }
            });
        }

        function initSidebarToggle() {
            const styleId = 'doubao-sidebar-ultimate-fix';
            if (!document.getElementById(styleId)) {
                const style = document.createElement('style');
                style.id = styleId;
                style.textContent = `
                    .left-side-U7A0kz:not(.left-side__expand-OIQFEm):hover,
                    .left-side-U7A0kz:not(.left-side__expand-OIQFEm):hover * { pointer-events: none !important; }
                    .left-side-U7A0kz:not(.left-side__expand-OIQFEm) #flow_chat_sidebar {
                        display: none !important; visibility: hidden !important; opacity: 0 !important; pointer-events: none !important;
                    }
                    #flow_chat_sidebar.-translate-x-full:hover { transform: translateX(-100%) !important; opacity: 0 !important; }
                `;
                document.head.appendChild(style);
            }

            function initSidebar() {
                const SIDEBAR_ELEMENT = document.querySelector('#flow_chat_sidebar');
                const TOGGLE_BUTTON = document.querySelector('[data-testid="siderbar_closed_status_btn"]');
                const LEFT_SIDE_CONTAINER = document.querySelector('.left-side-U7A0kz');

                if (!SIDEBAR_ELEMENT) {
                    setTimeout(initSidebar, 500);
                    return;
                }

                let isHidden = false;
                let allowExpand = false;

                function hideSidebar() {
                    if (!isHidden) {
                        isHidden = true;
                        if (LEFT_SIDE_CONTAINER) LEFT_SIDE_CONTAINER.classList.remove('left-side__expand-OIQFEm');
                    }
                }
                function showSidebar() {
                    if (isHidden) {
                        isHidden = false;
                        if (LEFT_SIDE_CONTAINER) LEFT_SIDE_CONTAINER.classList.add('left-side__expand-OIQFEm');
                    }
                }

                if (TOGGLE_BUTTON) {
                    TOGGLE_BUTTON.addEventListener('click', function () {
                        allowExpand = true;
                        setTimeout(function () { allowExpand = false; }, 500);
                        if (isHidden) showSidebar(); else hideSidebar();
                    }, true);
                }
                if (LEFT_SIDE_CONTAINER) {
                    LEFT_SIDE_CONTAINER.addEventListener('mouseenter', function (e) {
                        if (isHidden && !allowExpand) { e.stopPropagation(); e.preventDefault(); }
                    }, true);
                    LEFT_SIDE_CONTAINER.addEventListener('mouseover', function (e) {
                        if (isHidden && !allowExpand) { e.stopPropagation(); e.preventDefault(); }
                    }, true);
                }

                const observer = new MutationObserver(function (mutations) {
                    mutations.forEach(function (mutation) {
                        if (mutation.attributeName === 'class' && isHidden && !allowExpand) {
                            if (LEFT_SIDE_CONTAINER && LEFT_SIDE_CONTAINER.classList.contains('left-side__expand-OIQFEm')) {
                                setTimeout(function () {
                                    if (isHidden && !allowExpand) hideSidebar();
                                }, 10);
                            }
                        }
                    });
                });
                observer.observe(LEFT_SIDE_CONTAINER || SIDEBAR_ELEMENT, { attributes: true, attributeFilter: ['class'] });

                window.toggleSidebar = function () {
                    allowExpand = true;
                    setTimeout(function () { allowExpand = false; }, 500);
                    if (isHidden) showSidebar(); else hideSidebar();
                };
                window.collapseSidebar = hideSidebar;
                window.expandSidebar = showSidebar;
            }
            initSidebar();
        }

        function registerMenuCommands() {
            GM_registerMenuCommand(
                darkModeEnabled ? '禁用深色模式' : '启用深色模式',
                function () {
                    darkModeEnabled = !darkModeEnabled;
                    GM_setValue('darkModeEnabled', darkModeEnabled);
                    initAutoDarkMode();
                }
            );
            GM_registerMenuCommand(
                hideSuggestionsEnabled ? '显示推荐内容' : '隐藏推荐内容',
                function () {
                    hideSuggestionsEnabled = !hideSuggestionsEnabled;
                    GM_setValue('hideSuggestionsEnabled', hideSuggestionsEnabled);
                    initHideSuggestions();
                }
            );
        }

        function init() {
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', function () {
                    initInputFocusShortcut();
                    initAutoDarkMode();
                    initSidebarToggle();
                    initHideSuggestions();
                    registerMenuCommands();
                });
            } else {
                initInputFocusShortcut();
                initAutoDarkMode();
                initSidebarToggle();
                initHideSuggestions();
                registerMenuCommands();
            }
        }
        init();
    }
})();
