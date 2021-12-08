AtbTabbedMenu = {}
local AtbTabbedMenu_mt = Class(AtbTabbedMenu, TabbedMenu)

AtbTabbedMenu.CONTROLS = {
    "pageAtbGeneral",
    "pageAtbTest",
    "background"
}

AtbTabbedMenu.TAB_UV = {
    GENERAL = {715, 0, 65, 65},
    TEST = {0, 65, 65, 65},
    FARMS = {260, 65, 65, 65},
    USERS = {650, 65, 65, 65},
    STORE = {260, 0, 65, 65},
}

function AtbTabbedMenu.new(target, messageCenter, l10n, inputManager)
    local self = AtbTabbedMenu:superClass().new(target, AtbTabbedMenu_mt, messageCenter, l10n, inputManager)

    self:registerControls(AtbTabbedMenu.CONTROLS)

    self.pageSetupIndex = 1
    self.allowPageSetup = false
    self.l10n = l10n

    return self
end

function AtbTabbedMenu:onGuiSetupFinished()
    AtbTabbedMenu:superClass().onGuiSetupFinished(self)

    -- self.messageCenter:subscribe(MessageType.GUI_INGAME_OPEN_TEST_SCREEN, self.openTestScreen, self)
    self.clickBackCallback = self:makeSelfCallback(self.onButtonBack)
    self:setupMenuPages()
end

function AtbTabbedMenu:setupMenuPages()
    self.pageIndex = 1
    self.allowPageSetup = true
    self:setupPage(self.pageAtbGeneral, AtbTabbedMenu.TAB_UV.GENERAL)
    -- self:setupPage(self.pageAtbTest, AtbTabbedMenu.TAB_UV.TEST)
    self.allowPageSetup = false
end

function AtbTabbedMenu:setupPage(page, icon)
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

function AtbTabbedMenu:exitMenu()
    g_adminToolBox:applySettings()

    AtbTabbedMenu:superClass().exitMenu(self)
end

AtbTabbedMenu.L10N_SYMBOL = {
    BUTTON_BACK = "button_back"
}
