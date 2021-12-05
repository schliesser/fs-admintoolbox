AtbTestFrame = {}
local AtbTestFrame_mt = Class(AtbTestFrame, TabbedMenuFrameElement)
AtbTestFrame.CONTROLS = {
    SETTINGS_CONTAINER = "settingsContainer",
	BOX_LAYOUT = "boxLayout",
    CHECKBOX_TEST = "checkTest",
    OPTION_TEST = "multiTest"
}

function AtbTestFrame.new(subclass_mt, l10n)
    print("New AtbFrame")
	local self = AtbTestFrame:superClass().new(nil, subclass_mt or AtbTestFrame_mt)

	self:registerControls(AtbTestFrame.CONTROLS)

    self.l10n = l10n
    self.missionInfo = nil
    -- self.hasCustomMenuButtons = true
    self.checkboxMapping = {}
	self.optionMapping = {}

	return self
end

function AtbTestFrame:copyAttributes(src)
	AtbTestFrame:superClass().copyAttributes(AtbTestFrame, src)

	AtbTestFrame.l10n = src.l10n
end

function AtbTestFrame:initialize()
    print('Init AtbFrame')

    AtbTestFrame.backButtonInfo = {
		inputAction = InputAction.MENU_BACK
	}
	AtbTestFrame.saveButton = {
		showWhenPaused = true,
		inputAction = InputAction.MENU_ACTIVATE
	}

    AtbTestFrame.checkboxMapping[AtbTestFrame.checkTest] = SettingsModel.SETTING.USE_ACRE
    AtbTestFrame.optionMapping[AtbTestFrame.multiTest] = SettingsModel.SETTING.MONEY_UNIT

    local multiTestTexts = {
		AtbTestFrame.l10n:getText("ATB_optionMulti_foo"),
		AtbTestFrame.l10n:getText("ATB_optionMulti_bar"),
		AtbTestFrame.l10n:getText("ATB_optionMulti_baz")
	}

	AtbTestFrame.multiTest:setTexts(multiTestTexts)
end

function AtbTestFrame:onFrameOpen(element)
    print('OnFrameOpen AtbFrame')
	AtbTestFrame:superClass().onFrameOpen(AtbTestFrame)
	--self:updateGeneralSettings()

	-- local isMultiplayer = g_currentMission.missionDynamicInfo.isMultiplayer
end

function AtbTestFrame:onFrameClose()
    print('OnFrameClose AtbFrame')
	-- AtbTestFrame:superClass().onFrameClose(self)
	--self.settingsModel:saveChanges(SettingsModel.SETTING_CLASS.SAVE_GAMEPLAY_SETTINGS)
end

function AtbTestFrame:getMainElementSize()
	return AtbTestFrame.settingsContainer.size
end

function AtbTestFrame:getMainElementPosition()
	return AtbTestFrame.settingsContainer.absPosition
end


