AtbGeneralFrame = {}
local AtbGeneralFrame_mt = Class(AtbGeneralFrame, TabbedMenuFrameElement)
AtbGeneralFrame.CONTROLS = {
    SETTINGS_CONTAINER = "settingsContainer",
	BOX_LAYOUT = "boxLayout",
    ENABLE_SLEEPING = "enableSleeping",
    ENABLE_AI = "enableAi",
    ENABLE_SUPER_STRENGH = "enableSuperStrengh",
    FARMS_LOAN_MIN = "farmsLoanMin",
    FARMS_LOAN_MAX = "farmsLoanMax",
    STORE_ACTIVE = "storeActive",
    STORE_LEASING = "storeLeasing",
    STORE_OPEN_TIME = "storeOpenTime",
    STORE_CLOSE_TIME = "storeCloseTime",
    MISSIONS_ACTIVE = "missionsActive",
    MISSIONS_LEASING = "missionsLeasing",
}

function AtbGeneralFrame.new(subclass_mt, l10n)
    print("New AtbGeneralFrame")
	local self = AtbGeneralFrame:superClass().new(nil, subclass_mt or AtbGeneralFrame_mt)

	self:registerControls(AtbGeneralFrame.CONTROLS)

    self.l10n = l10n
    self.missionInfo = nil

    self.checkboxMapping = {}
	self.optionMapping = {}
    self.inputNumericMapping = {}

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

    -- Build available times for shop
    self.times = {}
    for i = AtbSettings.MIN_TIME, AtbSettings.MAX_TIME do
		table.insert(self.times, string.format("%d:00", i))
	end

    -- Add checkbox fields
    self.checkboxMapping[self.enableAi] = AtbSettings.SETTING.GENERAL_AI
    self.checkboxMapping[self.enableSleeping] = AtbSettings.SETTING.GENERAL_SLEEP
    self.checkboxMapping[self.enableSuperStrengh] = AtbSettings.SETTING.GENERAL_STRENGH
    self.checkboxMapping[self.storeActive] = AtbSettings.SETTING.STORE_ACTIVE
    self.checkboxMapping[self.storeLeasing] = AtbSettings.SETTING.STORE_LEASING
    self.checkboxMapping[self.missionsActive] = AtbSettings.SETTING.MISSIONS_ACTIVE
    self.checkboxMapping[self.missionsLeasing] = AtbSettings.SETTING.MISSIONS_LEASING

    -- Add input fields
    self.inputNumericMapping[self.farmsLoanMin] = AtbSettings.SETTING.FARM_LOAN_MIN
    self.inputNumericMapping[self.farmsLoanMax] = AtbSettings.SETTING.FARM_LOAN_MAX

    -- Add select fields
    self.optionMapping[self.storeOpenTime] = AtbSettings.SETTING.STORE_OPEN_TIME
    self.optionMapping[self.storeCloseTime] = AtbSettings.SETTING.STORE_CLOSE_TIME

    -- Define select options
    self.storeOpenTime:setTexts(self.times)
    self.storeCloseTime:setTexts(self.times)
end

function AtbGeneralFrame:onFrameOpen(element)
    print('OnFrameOpen AtbGeneralFrame')
	AtbGeneralFrame:superClass().onFrameOpen(self)
    self:updateSettings()
end

function AtbGeneralFrame:updateSettings()
	for element, settingsKey in pairs(self.checkboxMapping) do
		element:setIsChecked(g_adminToolBox.settings:getValue(settingsKey))
	end

	for element, settingsKey in pairs(self.optionMapping) do
        -- Add offset +1 for state to have times displayed correctly
		element:setState(g_adminToolBox.settings:getValue(settingsKey) + 1)
	end

    for element, settingsKey in pairs(self.inputNumericMapping) do
		element:setText(tostring(g_adminToolBox.settings:getValue(settingsKey)))
	end
end

function AtbGeneralFrame:onClickCheckbox(state, element)
    print("AtbGeneralFrame onClickCheckbox")
	local settingsKey = self.checkboxMapping[element]

	if settingsKey ~= nil then
		g_adminToolBox.settings:setValue(settingsKey, state == CheckedOptionElement.STATE_CHECKED, true)
	else
		print("Warning: Invalid settings checkbox event or key configuration for element " .. element:toString())
	end
end

function AtbGeneralFrame:onEnterPressed(element)
    print("AtbGeneralFrame:onEnterPressed")
    local settingsKey = self.inputNumericMapping[element]
    if settingsKey ~= nil then
        local value = tonumber(element.text)

        -- Reset on empty value to current value
        if value == nil then
            value = g_adminToolBox.settings:getValue(settingsKey)
        end

        -- loan must be lower than max money constant
        math.min(value, AtbSettings.MAX_MONEY)

        -- min loan must be lower than max loan
        if element.id == AtbGeneralFrame.CONTROLS.FARMS_LOAN_MIN then
            value = math.min(value, tonumber(self.farmsLoanMax.text))
        end

        -- max loan must be higer than min loan
        if element.id == AtbGeneralFrame.CONTROLS.FARMS_LOAN_MAX then
            value = math.max(value, tonumber(self.farmsLoanMin.text))
        end

        element:setText(tostring(value))
        g_adminToolBox.settings:setValue(settingsKey, value, true)
    else
        print("Warning: Invalid settings input event or key configuration for element " .. element:toString())
    end
end

function AtbGeneralFrame:onEscPressed(element)
    print("AtbGeneralFrame:onEscPressed")
    -- reset value
    local settingsKey = self.inputNumericMapping[element]
    if settingsKey ~= nil then
        element:setText(tostring(g_adminToolBox.settings:getValue(settingsKey)))
    end
end

function AtbGeneralFrame:onClickTime(state, element)
    -- self.selectedTargetTime = state - 1 + SleepDialog.MIN_TARGET_TIME

    local settingsKey = self.optionMapping[element]

	if settingsKey ~= nil then
        local value = state - 1

        -- opening must be before closing
        if element.id == AtbGeneralFrame.CONTROLS.STORE_OPEN_TIME then
            value = math.min(value, (self.storeCloseTime.state - 2))
        end

        -- closing must be after opening
        if element.id == AtbGeneralFrame.CONTROLS.STORE_CLOSE_TIME then
            value = math.max(value, self.storeOpenTime.state)
        end

        -- update modifed value
        local valueState = value + 1
        if valueState ~= state then
            element:setState(valueState)
        end

        -- save value
		g_adminToolBox.settings:setValue(settingsKey, value, true)
	else
		print("Warning: Invalid settings checkbox event or key configuration for element " .. element:toString())
	end
end
