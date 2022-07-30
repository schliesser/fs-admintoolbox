AtbMenu = {}
local AtbMenu_mt = Class(AtbMenu, TabbedMenu)

AtbMenu.CONTROLS = {
    "pageAtbGeneral",
    "background"
}

AtbMenu.TAB_UV = {
    GENERAL = {715, 0, 65, 65},
    FARMS = {260, 65, 65, 65},
    USERS = {650, 65, 65, 65},
    STORE = {325, 0, 65, 65},
}

function AtbMenu.new(target, messageCenter, l10n, inputManager)
    local self = AtbMenu:superClass().new(target, AtbMenu_mt, messageCenter, l10n, inputManager)

    self:registerControls(AtbMenu.CONTROLS)

    self.pageSetupIndex = 1
    self.allowPageSetup = false
    self.l10n = l10n

    return self
end

function AtbMenu:onGuiSetupFinished()
    AtbMenu:superClass().onGuiSetupFinished(self)

    self.clickBackCallback = self:makeSelfCallback(self.onButtonBack)
    self:setupMenuPages()
end

function AtbMenu:setupMenuPages()
    self.pageIndex = 1
    self.allowPageSetup = true
    self:setupPage(self.pageAtbGeneral, AtbMenu.TAB_UV.GENERAL)
    self:setupPage(self.pageAtbStore, AtbMenu.TAB_UV.STORE)
    self.allowPageSetup = false
end

function AtbMenu:setupPage(page, icon)
    if page ~= nil and self.allowPageSetup then
        -- Call initialize method from page
        page:initialize()

        self:registerPage(page, self.pageSetupIndex, predicate)

        local normalizedUVs = GuiUtils.getUVs(icon)

        self:addPageTab(page, g_iconsUIFilename, normalizedUVs)

        self.pageSetupIndex = self.pageSetupIndex + 1
    end
end

function AtbMenu:setupMenuButtonInfo()
    AtbMenu:superClass().setupMenuButtonInfo(self)
    local onButtonBackFunction = self:makeSelfCallback(self.onButtonBack)

    self.backButtonInfo = {
        inputAction = InputAction.MENU_BACK,
        text = self.l10n:getText(AtbMenu.L10N_SYMBOL.BUTTON_BACK),
        callback = onButtonBackFunction
    }

    self.defaultMenuButtonInfo = {self.backButtonInfo}

    self.defaultMenuButtonInfoByActions[InputAction.MENU_BACK] = self.defaultMenuButtonInfo[1]

    self.defaultButtonActionCallbacks = {
        [InputAction.MENU_BACK] = onButtonBackFunction
    }
end

function AtbMenu:exitMenu()
    g_atb:applySettings()

    AtbMenu:superClass().exitMenu(self)
end

AtbMenu.L10N_SYMBOL = {
    BUTTON_BACK = "button_back"
}
