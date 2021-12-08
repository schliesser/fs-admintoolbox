AtbGeneralFrame = {}
local AtbGeneralFrame_mt = Class(AtbGeneralFrame, TabbedMenuFrameElement)
AtbGeneralFrame.CONTROLS = {
    SETTINGS_CONTAINER = "settingsContainer",
	BOX_LAYOUT = "boxLayout",
    ENABLE_SLEEPING = "enableSleeping",
    ENABLE_AI = "enableAi",
    ENABLE_SUPER_STRENGH = "enableSuperStrengh"
}

function AtbGeneralFrame.new(subclass_mt, l10n)
    print("New AtbGeneralFrame")
	local self = AtbGeneralFrame:superClass().new(nil, subclass_mt or AtbGeneralFrame_mt)

	self:registerControls(AtbGeneralFrame.CONTROLS)

    self.l10n = l10n
    self.missionInfo = nil
    -- self.hasCustomMenuButtons = true
    self.checkboxMapping = {}
	self.optionMapping = {}

	return self
end

function AtbGeneralFrame:copyAttributes(src)
	AtbGeneralFrame:superClass().copyAttributes(self, src)

    self.l10n = src.l10n
end

function AtbGeneralFrame:initialize()
    print('Init AtbGeneralFrame')

    self.backButtonInfo = {
		inputAction = InputAction.MENU_BACK
	}
	-- self.saveButton = {
	-- 	inputAction = InputAction.MENU_ACTIVATE
	-- }

    self.checkboxMapping[self.enableAi] = AtbSettings.SETTING.GENERAL_AI
    self.checkboxMapping[self.enableSleeping] = AtbSettings.SETTING.GENERAL_SLEEP
    self.checkboxMapping[self.enableSuperStrengh] = AtbSettings.SETTING.GENERAL_STRENGH
end

function AtbGeneralFrame:onFrameOpen(element)
    print('OnFrameOpen AtbGeneralFrame')
	AtbGeneralFrame:superClass().onFrameOpen(self)
    self:updateGeneralSettings()

	-- local isMultiplayer = g_currentMission.missionDynamicInfo.isMultiplayer
end


function AtbGeneralFrame:updateGeneralSettings()
	-- self.settingsModel:refresh()

	for element, settingsKey in pairs(self.checkboxMapping) do
        print(settingsKey)
		element:setIsChecked(g_adminToolBox.settings:getValue(settingsKey))
	end

	for element, settingsKey in pairs(self.optionMapping) do
		-- element:setState(self.settingsModel:getValue(settingsKey))
	end
end

-- function AtbGeneralFrame:onFrameClose()
--     print('OnFrameClose AtbGeneralFrame')
-- end
