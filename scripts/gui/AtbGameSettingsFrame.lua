AtbGameSettingsFrame = {
    MOD_NAME = g_currentModName
}

local AtbGameSettingsFrame_mt = Class(AtbGameSettingsFrame)

function AtbGameSettingsFrame.new(atb, customMt)
    local self = setmetatable({}, customMt or AtbGameSettingsFrame_mt)
    self.atb = atb
    self.elementsCreated = false
    self.settingsHeadline = g_i18n:getText("ATB_header_general")
    self.settings = {}

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

    self:addSetting(AtbSettings.AI_WORKER_COUNT, AtbSettings.TYPE_MULTI, g_i18n:getText("ATB_title_worker"), g_i18n:getText("ATB_tip_worker"), nil, self, workers)
    self:addSetting(AtbSettings.VEHICLE_TABBING, AtbSettings.TYPE_CHECK, g_i18n:getText("ATB_title_vtab"), g_i18n:getText("ATB_tip_vtab"), nil, self)
    self:addSetting(AtbSettings.GENERAL_SLEEP, AtbSettings.TYPE_CHECK, g_i18n:getText("ATB_title_sleep"), g_i18n:getText("ATB_tip_sleep"), nil, self)
    self:addSetting(AtbSettings.STORE_ACTIVE, AtbSettings.TYPE_CHECK, g_i18n:getText("ATB_title_storeActive"), g_i18n:getText("ATB_tip_storeActive"), nil, self)
    self:addSetting(AtbSettings.STORE_OPEN_TIME, AtbSettings.TYPE_TIME, g_i18n:getText("ATB_title_storeOpenTime"), g_i18n:getText("ATB_tip_storeOpenTime"), nil, self, times)
    self:addSetting(AtbSettings.STORE_CLOSE_TIME, AtbSettings.TYPE_TIME, g_i18n:getText("ATB_title_storeCloseTime"), g_i18n:getText("ATB_tip_storeCloseTime"), nil, self, times)
    self:addSetting(AtbSettings.STORE_LEASING, AtbSettings.TYPE_CHECK, g_i18n:getText("ATB_title_storeLeasing"), g_i18n:getText("ATB_tip_storeLeasing"), nil, self)
    self:addSetting(AtbSettings.MISSIONS_LEASING, AtbSettings.TYPE_CHECK, g_i18n:getText("ATB_title_missionsLeasing"), g_i18n:getText("ATB_tip_missionsLeasing"), nil, self)
    self:addSetting(AtbSettings.MISSIONS_CONTRACT_LIMIT, AtbSettings.TYPE_MULTI, g_i18n:getText("ATB_title_contractLimit"), g_i18n:getText("ATB_tip_contractLimit"), nil, self, missions)

    return self
end

function AtbGameSettingsFrame:addSetting(name, type, title, toolTip, callback, callbackTarget,  optionTexts)
    -- todo: validate type
    -- checkbox || numeric || multiOption
    local setting = {
        name = name,
        title = title,
        type = type,
        toolTip = toolTip,
        callback = callback,
        callbackTarget = callbackTarget,
        optionTexts = optionTexts,
        element = nil
    }

    if type == AtbSettings.TYPE_MULTI and optionTexts == nil then
        Logging.error('ATB: No optionTexts defined for TYPE_MULTI!')
    end

    -- load value form settings
    local value = self.atb.settings:getValue(name)
    if value ~= nil then
        setting.state = value
    elseif type == AtbSettings.TYPE_CHECK then
        setting.state = false
    else
        setting.state = 0
    end

    table.insert(self.settings, setting)
    -- self:loadSettings()
    self:onSettingChanged(setting)
end

function AtbGameSettingsFrame:onSettingChanged(setting)
    if setting.callback ~= nil and setting.callbackTarget == nil then
        setting.callback(setting.state)
    elseif setting.callback ~= nil and setting.callbackTarget ~= nil then
        setting.callback(setting.callbackTarget, setting.state)
    end

    self.atb.settings:setValue(setting.name, setting.state)
end

function AtbGameSettingsFrame:onClickCheckbox(state, checkboxElement)
    for i = 1, #self.settings do
        local setting = self.settings[i]

        if setting.element == checkboxElement then
            setting.state = state == CheckedOptionElement.STATE_CHECKED

            self:onSettingChanged(setting)
        end
    end
end

function AtbGameSettingsFrame:onClickMultiOption(state, optionElement)
    for i = 1, #self.settings do
        local setting = self.settings[i]

        if setting.element == optionElement then
            setting.state = state -1

            self:onSettingChanged(setting)
        end
    end
end

function AtbGameSettingsFrame:onClickTimeOption(state, timeElement)
    atbPrint('onClickTime ' .. tostring(state))

    for i = 1, #self.settings do
        local setting = self.settings[i]
        if setting.element == timeElement then
            local value = state - 1
            atbPrint('value ' .. tostring(value))

            -- opening must be before closing
            if timeElement.name == AtbSettings.STORE_OPEN_TIME then
                local closeTime = g_atb.settings:getValue(AtbSettings.STORE_CLOSE_TIME)
                atbPrint('close time ' .. tostring(closeTime))
                if state == 25 then
                    value = math.min(closeTime - 2, AtbSettings.MAX_TIME)
                elseif state >= closeTime then
                    value = 0
                end
            end

            -- closing must be after opening
            if timeElement.name == AtbSettings.STORE_CLOSE_TIME then
                local openTime = g_atb.settings:getValue(AtbSettings.STORE_OPEN_TIME)
                atbPrint('close time ' .. tostring(openTime))
                if state == openTime then
                    value = math.max(openTime, AtbSettings.MAX_TIME)
                elseif state <= openTime then
                    value = openTime
                end
            end

            setting.state = value

            self:onSettingChanged(setting)
        end
    end
end


function AtbGameSettingsFrame:onFrameOpen(superFunc, element)
    -- superFunc(element)

    if not g_atb.gameSettingsFrame.elementsCreated then
        -- add ATB elements
        for i = 1, #self.boxLayout.elements do
            local elem = self.boxLayout.elements[i]

            if elem:isa(TextElement) then
                local header = elem:clone(self.boxLayout)

                header:setText(g_atb.gameSettingsFrame.settingsHeadline)
                header:reloadFocusHandling(true)

                break
            end
        end

        for i = 1, #g_atb.gameSettingsFrame.settings do
            local setting = g_atb.gameSettingsFrame.settings[i]

            if setting.type == AtbSettings.TYPE_CHECK then
                setting.element = self.checkFruitDestruction:clone(self.boxLayout)

                function setting.element.onClickCallback(_, ...)
                    g_atb.gameSettingsFrame:onClickCheckbox(...)
                end

                setting.element:reloadFocusHandling(true)
                setting.element:setIsChecked(setting.state)
            elseif setting.type == AtbSettings.TYPE_MULTI then
                setting.element = self.multiTimeScale:clone(self.boxLayout)
                setting.element:setTexts(setting.optionTexts)

                function setting.element.onClickCallback(_, ...)
                    g_atb.gameSettingsFrame:onClickMultiOption(...)
                end

                setting.element:reloadFocusHandling(true)
                setting.element:setState(setting.state + 1)
            elseif setting.type == AtbSettings.TYPE_TIME then
                setting.element = self.multiTimeScale:clone(self.boxLayout)
                setting.element:setTexts(setting.optionTexts)

                function setting.element.onClickCallback(_, ...)
                    g_atb.gameSettingsFrame:onClickTimeOption(...)
                end

                setting.element:reloadFocusHandling(true)
                setting.element:setState(setting.state + 1)
            elseif setting.type == AtbSettings.TYPE_NUMERIC then
                Logging.warning("ATB: TYPE_NUMERIC is not yet defined!", setting.type)
            else
                Logging.warning("ATB: Undefined type '%s'", setting.type)
            end

            setting.element.elements[4]:setText(setting.title)
            setting.element.elements[6]:setText(setting.toolTip)
        end


        -- repaint frame
        self.boxLayout:invalidateLayout()
        g_atb.gameSettingsFrame.elementsCreated = true
    end
end

function AtbGameSettingsFrame:onFrameClose(element)

end
