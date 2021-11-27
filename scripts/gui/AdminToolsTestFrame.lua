AdminToolsTestFrame = {}
local AdminToolsTestFrame_mt = Class(AdminToolsTestFrame, TabbedMenuFrameElement)
AdminToolsTestFrame.CONTROLS = {
    "settingsContainer",
	"boxLayout",
    "checkTest",
    "multiTest"
}

function AdminToolsTestFrame.new()
    print_r("New AdminToolsFrame")
	local self = AdminToolsTestFrame:superClass().new(nil, AdminToolsTestFrame_mt)

    self.checkboxMapping = {}
	self.optionMapping = {}
    self.hasCustomMenuButtons = true

	self:registerControls(AdminToolsTestFrame.CONTROLS)

	return self
end

function AdminToolsTestFrame:initialize(l10n)
    print('Init AdminToolsFrame')
end

function AdminToolsTestFrame:onFrameOpen(element)
    print('OnFrameOpen AdminToolsFrame')
	AdminToolsTestFrame:superClass().onFrameOpen(self)
	--self:updateGeneralSettings()

	local isMultiplayer = g_currentMission.missionDynamicInfo.isMultiplayer
end

function AdminToolsTestFrame:onFrameClose()
    print('OnFrameClose AdminToolsFrame')
	AdminToolsTestFrame:superClass().onFrameClose(self)
	--self.settingsModel:saveChanges(SettingsModel.SETTING_CLASS.SAVE_GAMEPLAY_SETTINGS)
end

