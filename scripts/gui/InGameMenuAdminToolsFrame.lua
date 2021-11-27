InGameMenuAdminToolsFrame = {}
local InGameMenuAdminToolsFrame_mt = Class(InGameMenuAdminToolsFrame, TabbedMenuFrameElement)
InGameMenuAdminToolsFrame.CONTROLS = {
    "settingsContainer",
	"boxLayout",
    "checkTest",
    "multiTest"
}

function InGameMenuAdminToolsFrame.new(subclass_mt)
    print_r("New AdminToolsFrame")
	local self = InGameMenuAdminToolsFrame:superClass().new(nil, subclass_mt or InGameMenuAdminToolsFrame_mt)

	self:registerControls(InGameMenuAdminToolsFrame.CONTROLS)

	self.checkboxMapping = {}
	self.optionMapping = {}
    self.hasCustomMenuButtons = true

	return self
end

function InGameMenuAdminToolsFrame:initialize()
    print('Init AdminToolsFrame')
end

function InGameMenuAdminToolsFrame:onFrameOpen(element)
    print('OnFrameOpen AdminToolsFrame')
	InGameMenuAdminToolsFrame:superClass().onFrameOpen(self)
	--self:updateGeneralSettings()

	local isMultiplayer = g_currentMission.missionDynamicInfo.isMultiplayer
end

function InGameMenuAdminToolsFrame:onFrameClose()
    print('OnFrameClose AdminToolsFrame')
	InGameMenuAdminToolsFrame:superClass().onFrameClose(self)
	--self.settingsModel:saveChanges(SettingsModel.SETTING_CLASS.SAVE_GAMEPLAY_SETTINGS)
end

