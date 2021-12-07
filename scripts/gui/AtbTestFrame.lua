AtbTestFrame = {}
local AtbTestFrame_mt = Class(AtbTestFrame, TabbedMenuFrameElement)
AtbTestFrame.CONTROLS = {
    SETTINGS_CONTAINER = "settingsContainer",
	BOX_LAYOUT = "boxLayout",
    CHECKBOX_TEST = "checkTest",
    OPTION_TEST = "multiTest"
}

function AtbTestFrame.new(subclass_mt, l10n)
    print("New AtbTestFrame")
	local self =AtbTestFrame:superClass().new(nil, subclass_mt or AtbTestFrame_mt)

	self:registerControls(AtbTestFrame.CONTROLS)

    self.l10n = l10n
    self.missionInfo = nil
    -- self.hasCustomMenuButtons = true
    self.checkboxMapping = {}
	self.optionMapping = {}

	return self
end

function AtbTestFrame:copyAttributes(src)
	AtbTestFrame:superClass().copyAttributes(self, src)

    self.l10n = src.l10n
end

function AtbTestFrame:initialize()
    print('Init AtbTestFrame')

    self.backButtonInfo = {
		inputAction = InputAction.MENU_BACK
	}
	-- self.saveButton = {
	-- 	inputAction = InputAction.MENU_ACTIVATE
	-- }

    self.checkboxMapping[self.checkTest] = SettingsModel.SETTING.USE_ACRE
    self.optionMapping[self.multiTest] = SettingsModel.SETTING.MONEY_UNIT

    local multiTestTexts = {
		self.l10n:getText("ATB_optionMulti_foo"),
		self.l10n:getText("ATB_optionMulti_bar"),
		self.l10n:getText("ATB_optionMulti_baz")
	}

	self.multiTest:setTexts(multiTestTexts)
end

function AtbTestFrame:onFrameOpen(element)
    print('OnFrameOpen AtbTestFrame')
	AtbTestFrame:superClass().onFrameOpen(self)
	--self:updateGeneralSettings()

	-- local isMultiplayer = g_currentMission.missionDynamicInfo.isMultiplayer
end

function AtbTestFrame:onFrameClose()
    print('OnFrameClose AtbTestFrame')
	-- AtbTestFrame:superClass().onFrameClose(self)
	--self.settingsModel:saveChanges(SettingsModel.SETTING_CLASS.SAVE_GAMEPLAY_SETTINGS)
end

function AtbTestFrame:getMainElementSize()
	return self.settingsContainer.size
end

function AtbTestFrame:getMainElementPosition()
	return self.settingsContainer.absPosition
end


