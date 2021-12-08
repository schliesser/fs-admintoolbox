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
	-- self.saveButton = {
	-- 	inputAction = InputAction.MENU_ACTIVATE
	-- }

    self.checkboxMapping[self.enableAi] = AtbSettings.SETTING.GENERAL_AI
    self.checkboxMapping[self.enableSleeping] = AtbSettings.SETTING.GENERAL_SLEEP
    self.checkboxMapping[self.enableSuperStrengh] = AtbSettings.SETTING.GENERAL_STRENGH

    self.inputNumericMapping[self.farmsLoanMin] = AtbSettings.SETTING.FARM_LOAN_MIN
    self.inputNumericMapping[self.farmsLoanMax] = AtbSettings.SETTING.FARM_LOAN_MAX
end

function AtbGeneralFrame:onFrameOpen(element)
    print('OnFrameOpen AtbGeneralFrame')
	AtbGeneralFrame:superClass().onFrameOpen(self)
    self:updateSettings()

	-- self.farmsLoanMin:setText(g_i18n:formatMoney(g_adminToolBox.settings:getValue(AtbSettings.SETTING.FARM_LOAN_MIN)))
	-- self.farmsLoanMax:setText(g_i18n:formatMoney(g_adminToolBox.settings:getValue(AtbSettings.SETTING.FARM_LOAN_MAX)))
end


function AtbGeneralFrame:updateSettings()
	for element, settingsKey in pairs(self.checkboxMapping) do
		element:setIsChecked(g_adminToolBox.settings:getValue(settingsKey))
	end

	for element, settingsKey in pairs(self.optionMapping) do
		element:setState(g_adminToolBox.settings:getValue(settingsKey))
	end

    for element, settingsKey in pairs(self.inputNumericMapping) do
		element:setText(tostring(g_adminToolBox.settings:getValue(settingsKey)))
	end
end

function AtbGeneralFrame:onClickCheckbox(state, checkboxElement)
    print("AtbGeneralFrame onClickCheckbox")
	local settingsKey = self.checkboxMapping[checkboxElement]

	if settingsKey ~= nil then
		g_adminToolBox.settings:setValue(settingsKey, state == CheckedOptionElement.STATE_CHECKED, true)

		-- self.dirty = true
	else
		print("Warning: Invalid settings checkbox event or key configuration for element " .. checkboxElement:toString())
	end
end

function AtbGeneralFrame:onEnterPressed(inputElement)
    print("AtbGeneralFrame:onEnterPressed")
    local settingsKey = self.inputNumericMapping[inputElement]
    if settingsKey ~= nil then
        local value = tonumber(inputElement.text)

        -- Reset on empty value to current value
        if value == nil then
            value = g_adminToolBox.settings:getValue(settingsKey)
        end

        -- loan must be lower than max money constant
        math.min(value, AtbSettings.MAX_MONEY)

        -- min loan must be lower than max loan
        if inputElement.id == AtbGeneralFrame.CONTROLS.FARMS_LOAN_MIN then
            value = math.min(value, tonumber(self.farmsLoanMax.text))
        end

        -- max loan must be higer than min loan
        if inputElement.id == AtbGeneralFrame.CONTROLS.FARMS_LOAN_MAX then
            value = math.max(value, tonumber(self.farmsLoanMin.text))
        end

        inputElement:setText(tostring(value))
        g_adminToolBox.settings:setValue(settingsKey, value, true)
    else
        print("Warning: Invalid settings input event or key configuration for element " .. inputElement:toString())
    end
end

function AtbGeneralFrame:onEscPressed(inputElement)
    print("AtbGeneralFrame:onEscPressed")
    -- reset value
    local settingsKey = self.inputNumericMapping[inputElement]
    if settingsKey ~= nil then
        inputElement:setText(tostring(g_adminToolBox.settings:getValue(settingsKey)))
    end
end
-- function AtbGeneralFrame:onFrameClose()
--     print('OnFrameClose AtbGeneralFrame')
-- end
