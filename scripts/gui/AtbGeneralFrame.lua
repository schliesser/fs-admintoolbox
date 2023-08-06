AtbGeneralFrame = {}
local AtbGeneralFrame_mt = Class(AtbGeneralFrame, TabbedMenuFrameElement)
AtbGeneralFrame.CONTROLS = {
    SETTINGS_CONTAINER = "settingsContainer",
    BOX_LAYOUT = "boxLayout",
    AI_WORKER_COUNT = "aiWorkerCount",
    VEHICE_TABBING = "enableVehicleTabbing",
    ENABLE_SLEEPING = "enableSleeping",
    STORE_ACTIVE = "storeActive",
    STORE_LEASING = "storeLeasing",
    STORE_OPEN_TIME = "storeOpenTime",
    STORE_CLOSE_TIME = "storeCloseTime",
    FARMS_LOAN_MIN = "farmsLoanMin",
    FARMS_LOAN_MAX = "farmsLoanMax",
    MISSIONS_PARALLEL_COUNT = "missionsContractLimit",
    MISSIONS_LEASING = "missionsLeasing"
}

function AtbGeneralFrame.new(subclass_mt, l10n)
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
    self.backButtonInfo = {
        inputAction = InputAction.MENU_BACK
    }

    -- Add checkbox fields
    self.checkboxMapping[self.enableVehicleTabbing] = AtbSettings.VEHICLE_TABBING
    self.checkboxMapping[self.enableSleeping] = AtbSettings.GENERAL_SLEEP
    self.checkboxMapping[self.storeActive] = AtbSettings.STORE_ACTIVE
    self.checkboxMapping[self.storeLeasing] = AtbSettings.STORE_LEASING
    self.checkboxMapping[self.missionsLeasing] = AtbSettings.MISSIONS_LEASING

    -- Add input fields
    self.inputNumericMapping[self.farmsLoanMin] = AtbSettings.FARM_LOAN_MIN
    self.inputNumericMapping[self.farmsLoanMax] = AtbSettings.FARM_LOAN_MAX

    -- Add select fields
    self.optionMapping[self.aiWorkerCount] = AtbSettings.AI_WORKER_COUNT
    self.optionMapping[self.storeOpenTime] = AtbSettings.STORE_OPEN_TIME
    self.optionMapping[self.storeCloseTime] = AtbSettings.STORE_CLOSE_TIME
    self.optionMapping[self.missionsContractLimit] = AtbSettings.MISSIONS_CONTRACT_LIMIT

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

    -- Build available times for shop
    local times = {}
    for i = AtbSettings.MIN_TIME, AtbSettings.MAX_TIME do
        table.insert(times, string.format("%d:00", i))
    end

    -- Define select options
    self.aiWorkerCount:setTexts(workers)
    self.storeOpenTime:setTexts(times)
    self.storeCloseTime:setTexts(times)
    self.missionsContractLimit:setTexts(missions)
end

function AtbGeneralFrame:onFrameOpen(element)
    AtbGeneralFrame:superClass().onFrameOpen(self)
    self:updateSettings()
end

function AtbGeneralFrame:updateSettings()
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

function AtbGeneralFrame:onClickCheckbox(state, element)
    local settingsKey = self.checkboxMapping[element]

    if settingsKey ~= nil then
        g_atb.settings:setValue(settingsKey, state == CheckedOptionElement.STATE_CHECKED)
    else
        print("Warning: Invalid settings checkbox event or key configuration for element " .. element:toString())
    end
end

function AtbGeneralFrame:onEnterPressed(element)
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
        if element.id == AtbGeneralFrame.CONTROLS.FARMS_LOAN_MIN then
            value = math.min(value, tonumber(self.farmsLoanMax.text))
        end

        -- max loan must be higer than min loan
        if element.id == AtbGeneralFrame.CONTROLS.FARMS_LOAN_MAX then
            value = math.max(value, tonumber(self.farmsLoanMin.text))
        end

        element:setText(tostring(value))
        g_atb.settings:setValue(settingsKey, value)
    else
        print("Warning: Invalid settings input event or key configuration for element " .. element:toString())
    end
end

function AtbGeneralFrame:onEscPressed(element)
    local settingsKey = self.inputNumericMapping[element]

    if settingsKey ~= nil then
        -- Reset value
        element:setText(tostring(g_atb.settings:getValue(settingsKey)))
    end
end

function AtbGeneralFrame:onClickTime(state, element)
    local settingsKey = self.optionMapping[element]

    if settingsKey ~= nil then
        local value = state - 1

        -- opening must be before closing
        if element.id == AtbGeneralFrame.CONTROLS.STORE_OPEN_TIME then
            if state == 25 then
                value = math.min(self.storeCloseTime.state - 2, AtbSettings.MAX_TIME)
            elseif state >= self.storeCloseTime.state then
                value = 0
            end
        end

        -- closing must be after opening
        if element.id == AtbGeneralFrame.CONTROLS.STORE_CLOSE_TIME then
            if state == self.storeOpenTime.state then
                value = math.max(self.storeOpenTime.state, AtbSettings.MAX_TIME)
            elseif state <= self.storeOpenTime.state then
                value = self.storeOpenTime.state
            end
        end

        -- update modifed value
        element:setState(value + 1)

        -- save value
        g_atb.settings:setValue(settingsKey, value)
    else
        print("Warning: Invalid settings checkbox event or key configuration for element " .. element:toString())
    end
end

function AtbGeneralFrame:onClickMultiOption(state, element)
    local settingsKey = self.optionMapping[element]

    if settingsKey ~= nil then
        local value = state - 1
        g_atb.settings:setValue(settingsKey, value)
    else
        print("Warning: Invalid settings multi option event or key configuration for element " .. element:toString())
    end
end
