AtbOverrides = {}

function AtbOverrides:storeLease(storeItem, vehicle, saleItem)
    storeItem.allowLeasing = g_atb.settings:getValue(AtbSettings.STORE_LEASING)
end

function AtbOverrides:missionLease()
    return self.vehiclesToLoad ~= nil and g_atb.settings:getValue(AtbSettings.MISSIONS_LEASING)
end

function AtbOverrides:getCanSleep()
    return not self.isSleeping and g_atb.settings:getValue(AtbSettings.GENERAL_SLEEP)
end

function AtbOverrides:openShop(guiName)
    if guiName ~= "ShopMenu" and guiName ~= "ShopConfigScreen" then
        return
    end

    -- general enable/disable of the shop
    if not g_atb.settings:getValue(AtbSettings.STORE_ACTIVE) then
        g_gui:showGui("")
        g_gui:showInfoDialog({
            text = g_i18n:getText("ATB_storeDialogDisabled")
        })
        return
    end

    -- closed by time
    local openTime = g_atb.settings:getValue(AtbSettings.STORE_OPEN_TIME)
    local closeTime = g_atb.settings:getValue(AtbSettings.STORE_CLOSE_TIME)
    if not (g_currentMission.environment.currentHour >= openTime and g_currentMission.environment.currentHour < closeTime) then
        g_gui:showGui("")
        g_gui:showInfoDialog({
            text = string.format(g_i18n:getText("ATB_storeDialogClosed"), openTime)
        })
    end
end

-- check if vehicle switching is allowed
function AtbOverrides:onSwitchVehicle(superFunc, one, two, directionValue)
    if g_atb.settings:getValue(AtbSettings.VEHICLE_TABBING) then
        superFunc(self, one, two, directionValue)
    end
end

-- override loan calculation of Farm class
function AtbOverrides:updateMaxLoan()
    local roundedTo5000 = math.floor(Farm.EQUITY_LOAN_RATIO * self:getEquity() / 5000) * 5000
    self.loanMax = MathUtil.clamp(roundedTo5000, g_atb.settings:getValue(AtbSettings.FARM_LOAN_MIN), g_atb.settings:getValue(AtbSettings.FARM_LOAN_MAX))
end
