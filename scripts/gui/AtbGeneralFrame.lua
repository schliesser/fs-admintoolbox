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

function AtbTestFrame:copyAttributes(src)
	AtbTestFrame:superClass().copyAttributes(AtbTestFrame, src)

    self.l10n = src.l10n
end

function AtbGeneralFrame:initialize()
    print('Init AtbGeneralFrame')

    self.backButtonInfo = {
		inputAction = InputAction.MENU_BACK
	}
	self.saveButton = {
		inputAction = InputAction.MENU_ACTIVATE
	}

    AtbGeneralFrame.checkboxMapping[AtbGeneralFrame.enableAi] = AdminToolBox.GENERAL.AI
    AtbGeneralFrame.checkboxMapping[AtbGeneralFrame.enableSleeping] = AdminToolBox.GENERAL.SLEEP
    AtbGeneralFrame.checkboxMapping[AtbGeneralFrame.enableSuperStrengh] = AdminToolBox.GENERAL.STRENGH
end

function AtbGeneralFrame:onFrameOpen(element)
    print('OnFrameOpen AtbGeneralFrame')
	AtbGeneralFrame:superClass().onFrameOpen(AtbGeneralFrame)
	AdminToolBox.loadFromXML()

	-- local isMultiplayer = g_currentMission.missionDynamicInfo.isMultiplayer
end

function AtbGeneralFrame:onFrameClose()
    print('OnFrameClose AtbGeneralFrame')
	AtbGeneralFrame:superClass().onFrameClose(AtbGeneralFrame)
	AdminToolBox.saveToXMLFile()
end

function AtbGeneralFrame:getMainElementSize()
	return AtbGeneralFrame.settingsContainer.size
end

function AtbGeneralFrame:getMainElementPosition()
	return AtbGeneralFrame.settingsContainer.absPosition
end


