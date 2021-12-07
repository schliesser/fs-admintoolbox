AtbTabbedMenu = {}
local AtbTabbedMenu_mt = Class(AtbTabbedMenu, TabbedMenu)

AtbTabbedMenu.CONTROLS = {
    "pageTest",
    -- "pageGeneral",
    "background"
}

AtbTabbedMenu.TAB_UV = {
    GAME_SETTINGS = {650, 0, 65, 65},
    GENERAL_SETTINGS = {715, 0, 65, 65},
    CONTROLS_SETTINGS = {845, 0, 65, 65}
}

function AtbTabbedMenu.new(target, messageCenter, l10n, inputManager)
    local self = AtbTabbedMenu:superClass().new(target, AtbTabbedMenu_mt, messageCenter, l10n, inputManager)
    print("AtbTabbedMenu new")

    self:registerControls(AtbTabbedMenu.CONTROLS)

    self.pageSetupIndex = 1
    self.allowPageSetup = false
    self.l10n = l10n

    return self
end

function AtbTabbedMenu:onGuiSetupFinished()
    AtbTabbedMenu:superClass().onGuiSetupFinished(self)
    print("AtbTabbedMenu onGuiSetupFinished")
    print_r(self.l10n)

    print(self.l10n:getText(AtbTabbedMenu.L10N_SYMBOL.BUTTON_BACK))
    print(self.l10n:getText(AtbTabbedMenu.L10N_SYMBOL.TOOLTIP_CHECK))
    -- self.messageCenter:subscribe(MessageType.GUI_INGAME_OPEN_TEST_SCREEN, self.openTestScreen, self)
    self.clickBackCallback = self:makeSelfCallback(self.onButtonBack)
    self:setupMenuPages()
end

function AtbTabbedMenu:setupMenuPages()
    print("AtbTabbedMenu setupMenuPages")
    self.pageIndex = 1
    self.allowPageSetup = true
    self:setupPage(self.pageTest, AtbTabbedMenu.TAB_UV.GENERAL_SETTINGS)
    -- self:setupPage(self.pageGeneral, AtbTabbedMenu.TAB_UV.GAME_SETTINGS)
    self.allowPageSetup = false
end

function AtbTabbedMenu:setupPage(page, icon)
    print("AtbTabbedMenu setupPage")
    if page ~= nil and self.allowPageSetup then
        -- Call initialize method from page
        page:initialize()

        self:registerPage(page, self.pageSetupIndex, predicate)

        local normalizedUVs = GuiUtils.getUVs(icon)

        self:addPageTab(page, g_iconsUIFilename, normalizedUVs)

        self.pageSetupIndex = self.pageSetupIndex + 1
    end
end

function AtbTabbedMenu:setupMenuButtonInfo()
    AtbTabbedMenu:superClass().setupMenuButtonInfo(self)
    local onButtonBackFunction = self:makeSelfCallback(self.onButtonBack)

    self.backButtonInfo = {
        inputAction = InputAction.MENU_BACK,
        text = self.l10n:getText(AtbTabbedMenu.L10N_SYMBOL.BUTTON_BACK),
        callback = onButtonBackFunction
    }

    self.defaultMenuButtonInfo = {self.backButtonInfo}

    self.defaultMenuButtonInfoByActions[InputAction.MENU_BACK] = self.defaultMenuButtonInfo[1]

    self.defaultButtonActionCallbacks = {
        [InputAction.MENU_BACK] = onButtonBackFunction
    }
end

function AtbTabbedMenu:onButtonBack()
    print('Button Back')
    AtbTabbedMenu:superClass().exitMenu(self)
end

function AtbTabbedMenu:onClickMenu()
    self:exitMenu()

    return true
end

function AtbTabbedMenu:exitMenu()
    AtbTabbedMenu:superClass().exitMenu(self)
end

AtbTabbedMenu.L10N_SYMBOL = {
    TOOLTIP_CHECK = "ATB_toolTipCheck",
    BUTTON_BACK = "button_back"
}
