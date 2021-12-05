AtbTabbedMenu = {}
local AtbTabbedMenu_mt = Class(AtbTabbedMenu, TabbedMenu)

AtbTabbedMenu.CONTROLS = {"pageTest", "pageGeneral", "pageSettingsGame", "pageSettingsGeneral"}

AtbTabbedMenu.TAB_UV = {
    GAME_SETTINGS = {650, 0, 65, 65},
    GENERAL_SETTINGS = {715, 0, 65, 65},
    CONTROLS_SETTINGS = {845, 0, 65, 65}
}

function AtbTabbedMenu:new(target, messageCenter, l10n, inputManager)
    local self = AtbTabbedMenu:superClass().new(target, AtbTabbedMenu_mt, messageCenter, l10n, inputManager)
    print("AtbTabbedMenu new")

    AtbTabbedMenu:registerControls(AtbTabbedMenu.CONTROLS)

    AtbTabbedMenu.pageSetupIndex = 1
    AtbTabbedMenu.allowPageSetup = false
    AtbTabbedMenu.l10n = l10n

    return AtbTabbedMenu
end

function AtbTabbedMenu:onGuiSetupFinished()
    AtbTabbedMenu:superClass().onGuiSetupFinished(AtbTabbedMenu)
    print("AtbTabbedMenu onGuiSetupFinished")
    print_r(AtbTabbedMenu.l10n)

    print(AtbTabbedMenu.l10n:getText(AtbTabbedMenu.L10N_SYMBOL.BUTTON_BACK))
    print(AtbTabbedMenu.l10n:getText(AtbTabbedMenu.L10N_SYMBOL.TOOLTIP_CHECK))
    -- self.messageCenter:subscribe(MessageType.GUI_INGAME_OPEN_TEST_SCREEN, self.openTestScreen, self)
    AtbTabbedMenu.clickBackCallback = AtbTabbedMenu:makeSelfCallback(AtbTabbedMenu.onButtonBack)
    AtbTabbedMenu:setupMenuPages()
end

function AtbTabbedMenu:setupMenuPages()
    print("AtbTabbedMenu setupMenuPages")
    AtbTabbedMenu.pageIndex = 1
    AtbTabbedMenu.allowPageSetup = true
    AtbTabbedMenu:setupPage(AtbTabbedMenu.pageTest, AtbTabbedMenu.TAB_UV.GENERAL_SETTINGS)
    AtbTabbedMenu:setupPage(AtbTabbedMenu.pageGeneral, AtbTabbedMenu.TAB_UV.GAME_SETTINGS)
    AtbTabbedMenu.allowPageSetup = false
end

function AtbTabbedMenu:setupPage(page, icon)
    print("AtbTabbedMenu setupPage")
    if page ~= nil and AtbTabbedMenu.allowPageSetup then
        -- Call initialize method from page
        page:initialize()

        AtbTabbedMenu:registerPage(page, AtbTabbedMenu.pageSetupIndex, predicate)

        local normalizedUVs = GuiUtils.getUVs(icon)

        AtbTabbedMenu:addPageTab(page, g_iconsUIFilename, normalizedUVs)

        AtbTabbedMenu.pageSetupIndex = AtbTabbedMenu.pageSetupIndex + 1
    end
end

function AtbTabbedMenu:setupMenuButtonInfo()
    InGameMenu:superClass().setupMenuButtonInfo(AtbTabbedMenu)
    local onButtonBackFunction = AtbTabbedMenu:makeSelfCallback(AtbTabbedMenu.onButtonBack)

    AtbTabbedMenu.backButtonInfo = {
        inputAction = InputAction.MENU_BACK,
        text = AtbTabbedMenu.l10n:getText(AtbTabbedMenu.L10N_SYMBOL.BUTTON_BACK),
        callback = onButtonBackFunction
    }

    AtbTabbedMenu.defaultMenuButtonInfo = {AtbTabbedMenu.backButtonInfo}

    AtbTabbedMenu.defaultMenuButtonInfoByActions[InputAction.MENU_BACK] = AtbTabbedMenu.defaultMenuButtonInfo[1]

    AtbTabbedMenu.defaultButtonActionCallbacks = {
        [InputAction.MENU_BACK] = onButtonBackFunction
    }
end

function AtbTabbedMenu:onButtonBack()
    print('Button Back')
    AtbTabbedMenu:superClass().exitMenu(AtbTabbedMenu)
end

function AtbTabbedMenu:onClickMenu()
    AtbTabbedMenu:exitMenu()

    return true
end

function AtbTabbedMenu:exitMenu()
    AtbTabbedMenu:superClass().exitMenu(AtbTabbedMenu)
end

AtbTabbedMenu.L10N_SYMBOL = {
    TOOLTIP_CHECK = "ATB_toolTipCheck",
    BUTTON_BACK = "button_back"
}
