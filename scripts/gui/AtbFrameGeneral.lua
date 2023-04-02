AtbFrameGeneral = {}
local AtbFrameGeneral_mt = Class(AtbFrameGeneral, TabbedMenuFrameElement)
AtbFrameGeneral.CONTROLS = {
    SETTINGS_CONTAINER = "settingsContainer",
    BOX_LAYOUT = "boxLayout",
    AI_WORKER_COUNT = "aiWorkerCount",
    VEHICE_TABBING = "enableVehicleTabbing",
    ENABLE_SLEEPING = "enableSleeping",
    FARMS_LOAN_MIN = "farmsLoanMin",
    FARMS_LOAN_MAX = "farmsLoanMax",
    MISSIONS_PARALLEL_COUNT = "missionsContractLimit",
    MISSIONS_LEASING = "missionsLeasing"
}

function AtbFrameGeneral.new(subclass_mt, l10n)
    local self = AtbFrameGeneral:superClass().new(nil, subclass_mt or AtbFrameGeneral_mt)

    self:registerControls(AtbFrameGeneral.CONTROLS)

    self.l10n = l10n
    self.missionInfo = nil

    self.checkboxMapping = {}
    self.optionMapping = {}
    self.inputNumericMapping = {}

    return self
end

function AtbFrameGeneral:copyAttributes(src)
    AtbFrameGeneral:superClass().copyAttributes(self, src)

    self.l10n = src.l10n
end

function AtbFrameGeneral:initialize()
    self.backButtonInfo = {
        inputAction = InputAction.MENU_BACK
    }

    -- Add checkbox fields
    self.checkboxMapping[self.enableVehicleTabbing] = AtbSettings.SETTING.VEHICLE_TABBING
    self.checkboxMapping[self.enableSleeping] = AtbSettings.SETTING.GENERAL_SLEEP
    self.checkboxMapping[self.missionsLeasing] = AtbSettings.SETTING.MISSIONS_LEASING

    -- Add input fields
    self.inputNumericMapping[self.farmsLoanMin] = AtbSettings.SETTING.FARM_LOAN_MIN
    self.inputNumericMapping[self.farmsLoanMax] = AtbSettings.SETTING.FARM_LOAN_MAX

    -- Add select fields
    self.optionMapping[self.aiWorkerCount] = AtbSettings.SETTING.AI_WORKER_COUNT
    self.optionMapping[self.missionsContractLimit] = AtbSettings.SETTING.MISSIONS_CONTRACT_LIMIT

    -- Build workers select texts
    local workers = {}
    for i = 0, AtbSettings.WORKERS_MAX do
        table.insert(workers, tostring(i))
    end

    -- Build missions select texts
    local missions = {}
    for i = 0, AtbSettings.MISSIONS_COUNT_MAX do
        table.insert(missions, tostring(i))
    end

    -- Define select options
    self.aiWorkerCount:setTexts(workers)
    self.missionsContractLimit:setTexts(missions)
end

function AtbFrameGeneral:onFrameOpen(element)
    AtbFrameGeneral:superClass().onFrameOpen(self)
    self:updateSettings()
end

function AtbFrameGeneral:updateSettings()
    for element, settingsKey in pairs(self.checkboxMapping) do
        element:setIsChecked(g_atb.settings:getValue(settingsKey))
    end

    for element, settingsKey in pairs(self.optionMapping) do
        -- Add offset +1 for state to have times displayed correctly
        element:setState(g_atb.settings:getValue(settingsKey) + 1)
    end

    for element, settingsKey in pairs(self.inputNumericMapping) do
        element:setText(tostring(g_atb.settings:getValue(settingsKey)))
    end
end

function AtbFrameGeneral:atbOnClickCheckbox(state, element)
    local settingsKey = self.checkboxMapping[element]

    if settingsKey ~= nil then
        g_atb.settings:setValue(settingsKey, state == CheckedOptionElement.STATE_CHECKED)
    else
        print("ATB General Warning: Invalid settings checkbox event or key configuration for element " .. element:toString())
    end
end

function AtbFrameGeneral:atbOnEnterPressed(element)
    local settingsKey = self.inputNumericMapping[element]
    if settingsKey ~= nil then
        local value = tonumber(element.text)

        -- Reset on empty value to current value
        if value == nil then
            value = g_atb.settings:getValue(settingsKey)
        end

        -- loan must be lower than max money constant
        value = math.min(value, AtbSettings.MAX_MONEY)

        -- min loan must be lower than max loan
        if element.id == AtbFrameGeneral.CONTROLS.FARMS_LOAN_MIN then
            value = math.min(value, tonumber(self.farmsLoanMax.text))
        end

        -- max loan must be higer than min loan
        if element.id == AtbFrameGeneral.CONTROLS.FARMS_LOAN_MAX then
            value = math.max(value, tonumber(self.farmsLoanMin.text))
        end

        element:setText(tostring(value))
        g_atb.settings:setValue(settingsKey, value)
    else
        print("ATB General Warning: Invalid settings input event or key configuration for element " .. element:toString())
    end
end

function AtbFrameGeneral:atbOnEscPressed(element)
    local settingsKey = self.inputNumericMapping[element]

    if settingsKey ~= nil then
        -- Reset value
        element:setText(tostring(g_atb.settings:getValue(settingsKey)))
    end
end

function AtbFrameGeneral:atbOnClickMultiOption(state, element)
    local settingsKey = self.optionMapping[element]

    if settingsKey ~= nil then
        local value = state - 1
        g_atb.settings:setValue(settingsKey, value)
    else
        print("ATB General Warning: Invalid settings multi option event or key configuration for element " .. element:toString())
    end
end
