AdminToolsTestFrame = {}
local AdminToolsTestFrame_mt = Class(AdminToolsTestFrame, TabbedMenuFrameElement)
AdminToolsTestFrame.CONTROLS = {
    SETTINGS_CONTAINER = "settingsContainer",
	BOX_LAYOUT = "boxLayout",
    CHECKBOX_TEST = "checkTest",
    OPTION_TEST = "multiTest"
}

function AdminToolsTestFrame.new(subclass_mt, l10n)
    print("New AdminToolsFrame")
	local self = AdminToolsTestFrame:superClass().new(nil, subclass_mt or AdminToolsTestFrame_mt)

	self:registerControls(AdminToolsTestFrame.CONTROLS)

    self.l10n = l10n
    self.missionInfo = nil
    -- self.hasCustomMenuButtons = true
    self.checkboxMapping = {}
	self.optionMapping = {}

	return self
end

function AdminToolsTestFrame:copyAttributes(src)
	AdminToolsTestFrame:superClass().copyAttributes(self, src)

	self.l10n = src.l10n
end

function AdminToolsTestFrame:initialize()
    print('Init AdminToolsFrame')

    self.backButtonInfo = {
		inputAction = InputAction.MENU_BACK
	}
	self.saveButton = {
		showWhenPaused = true,
		inputAction = InputAction.MENU_ACTIVATE
	}

    self.checkboxMapping[self.checkTest] = SettingsModel.SETTING.USE_ACRE
    self.optionMapping[self.multiTest] = SettingsModel.SETTING.MONEY_UNIT

    local multiTestTexts = {
		self.l10n:getText("ADT_optionMulti_foo"),
		self.l10n:getText("ADT_optionMulti_bar"),
		self.l10n:getText("ADT_optionMulti_baz")
	}

	self.multiTest:setTexts(multiTestTexts)
end

function AdminToolsTestFrame:onFrameOpen(element)
    print('OnFrameOpen AdminToolsFrame')
	AdminToolsTestFrame:superClass().onFrameOpen(self)
	--self:updateGeneralSettings()

	-- local isMultiplayer = g_currentMission.missionDynamicInfo.isMultiplayer
end

function AdminToolsTestFrame:onFrameClose()
    print('OnFrameClose AdminToolsFrame')
	-- AdminToolsTestFrame:superClass().onFrameClose(self)
	--self.settingsModel:saveChanges(SettingsModel.SETTING_CLASS.SAVE_GAMEPLAY_SETTINGS)
end

function AdminToolsTestFrame:getMainElementSize()
	return self.settingsContainer.size
end

function AdminToolsTestFrame:getMainElementPosition()
	return self.settingsContainer.absPosition
end


