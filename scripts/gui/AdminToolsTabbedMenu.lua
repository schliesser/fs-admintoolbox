AdminToolsTabbedMenu = {}
local AdminToolsTabbedMenu_mt = Class(AdminToolsTabbedMenu, TabbedMenu)

AdminToolsTabbedMenu.CONTROLS = {"pageTest"}

AdminToolsTabbedMenu.TAB_UV = {
    GAME_SETTINGS = {650, 0, 65, 65},
    GENERAL_SETTINGS = {715, 0, 65, 65},
    CONTROLS_SETTINGS = {845, 0, 65, 65}
}

function AdminToolsTabbedMenu:new(target, messageCenter, l10n, inputManager)
    local self = AdminToolsTabbedMenu:superClass().new(target, AdminToolsTabbedMenu_mt, messageCenter, l10n,
        inputManager)

    self.pageSetupIndex = 1
    self.allowPageSetup = false

    self.l10n = l10n

    self:registerControls(AdminToolsTabbedMenu.CONTROLS)

    return self
end

function AdminToolsTabbedMenu:onGuiSetupFinished()
    AdminToolsTabbedMenu:superClass().onGuiSetupFinished(self)
    -- self.messageCenter:subscribe(MessageType.GUI_INGAME_OPEN_TEST_SCREEN, self.openTestScreen, self)
    -- self.messageCenter:subscribe(MessageType.MONEY_CHANGED, self.onMoneyChanged, self)
    -- self.messageCenter:subscribe(MessageType.MASTERUSER_ADDED, self.onMasterUserAdded, self)
    -- self.messageCenter:subscribe(MessageType.UNLOADING_STATIONS_CHANGED, self.onUnloadingStationsChanged, self)
    -- self:initializePages()
    self:setupMenuPages()
end

function AdminToolsTabbedMenu:setupMenuPages()

    self.pageIndex = 1
    self.allowPageSetup = true
    self:setupPage(self.pageTest, AdminToolsTabbedMenu.TAB_UV.GENERAL_SETTINGS)
    self.allowPageSetup = false
end

function AdminToolsTabbedMenu:setupPage(page, icon)
    if page ~= nil and self.allowPageSetup then
        -- Call initialize method from page
        page:initialize(self.l10n)

        self:registerPage(page, self.pageSetupIndex, predicate)

        local normalizedUVs = getNormalizedUVs(icon)

        self:addPageTab(page, g_iconsUIFilename, normalizedUVs)

        self.pageSetupIndex = self.pageSetupIndex + 1
    end
end
