AdminToolsTabbedMenu = {}
local AdminToolsTabbedMenu_mt = Class(AdminToolsTabbedMenu, TabbedMenu)

AdminToolsTabbedMenu.CONTROLS = {"pageTest", "pageSettingsGame", "pageSettingsGeneral"}

AdminToolsTabbedMenu.TAB_UV = {
    GAME_SETTINGS = {650, 0, 65, 65},
    GENERAL_SETTINGS = {715, 0, 65, 65},
    CONTROLS_SETTINGS = {845, 0, 65, 65}
}

function AdminToolsTabbedMenu:new(target, messageCenter, l10n, inputManager)
    local self = AdminToolsTabbedMenu:superClass().new(target, AdminToolsTabbedMenu_mt, messageCenter, l10n,
        inputManager)
    print("AdminToolsTabbedMenu new")

    self:registerControls(AdminToolsTabbedMenu.CONTROLS)

    self.pageSetupIndex = 1
    self.allowPageSetup = false
    self.l10n = l10n

    return self
end

function AdminToolsTabbedMenu:onGuiSetupFinished()
    AdminToolsTabbedMenu:superClass().onGuiSetupFinished(self)
    print("AdminToolsTabbedMenu onGuiSetupFinished")
    print_r(self.l10n)

    print(self.l10n:getText(AdminToolsTabbedMenu.L10N_SYMBOL.BUTTON_BACK))
    print(self.l10n:getText(AdminToolsTabbedMenu.L10N_SYMBOL.TOOLTIP_CHECK))
    -- self.messageCenter:subscribe(MessageType.GUI_INGAME_OPEN_TEST_SCREEN, self.openTestScreen, self)
    self.clickBackCallback = self:makeSelfCallback(self.onButtonBack)
    self:setupMenuPages()
end

function AdminToolsTabbedMenu:setupMenuPages()
    print("AdminToolsTabbedMenu setupMenuPages")
    self.pageIndex = 1
    self.allowPageSetup = true
    self:setupPage(self.pageTest, AdminToolsTabbedMenu.TAB_UV.GENERAL_SETTINGS)
    self.allowPageSetup = false
end

function AdminToolsTabbedMenu:setupPage(page, icon)
    print("AdminToolsTabbedMenu setupPage")
    if page ~= nil and self.allowPageSetup then
        -- Call initialize method from page
        page:initialize()

        self:registerPage(page, self.pageSetupIndex, predicate)

        local normalizedUVs = GuiUtils.getUVs(icon)

        self:addPageTab(page, g_iconsUIFilename, normalizedUVs)

        self.pageSetupIndex = self.pageSetupIndex + 1
    end
end

function AdminToolsTabbedMenu:setupMenuButtonInfo()
    InGameMenu:superClass().setupMenuButtonInfo(self)
    local onButtonBackFunction = self:makeSelfCallback(self.onButtonBack)

    self.backButtonInfo = {
        inputAction = InputAction.MENU_BACK,
        text = self.l10n:getText(AdminToolsTabbedMenu.L10N_SYMBOL.BUTTON_BACK),
        callback = onButtonBackFunction
    }

    self.defaultMenuButtonInfo = {self.backButtonInfo}

    self.defaultMenuButtonInfoByActions[InputAction.MENU_BACK] = self.defaultMenuButtonInfo[1]

    self.defaultButtonActionCallbacks = {
        [InputAction.MENU_BACK] = onButtonBackFunction
    }
end

function AdminToolsTabbedMenu:onButtonBack()
    print('Button Back')
    AdminToolsTabbedMenu:superClass().exitMenu(self)
end

function AdminToolsTabbedMenu:onClickMenu()
    self:exitMenu()

    return true
end

function AdminToolsTabbedMenu:exitMenu()
    AdminToolsTabbedMenu:superClass().exitMenu(self)
end

AdminToolsTabbedMenu.L10N_SYMBOL = {
    TOOLTIP_CHECK = "admn_toolTip_check",
    BUTTON_BACK = "button_back"
}
