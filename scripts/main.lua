----------------------------------------------------------------------------------------------------
--[[
Admin Tools for Farming Simulator 2022

Copyright (c) -tinte-, 2021

Author: André Buchmann
Issues: https://github.com/schliesser/fs-admintoolbox/issues

Feel free to open a pull reuests for enhancements or bugfixes.

You are not allowed to sell this or a modified version of the mod.
]] ----------------------------------------------------------------------------------------------------
AdminToolBox = {}
local AdminToolBox_mt = Class(AdminToolBox)

function AdminToolBox.new(isServer, isClient, customEnvironment, baseDirectory)
    if g_adminToolBox ~= nil then
        return
    end

    local self = {}
    setmetatable(self, AdminToolBox_mt)

    -- todo: read config file
    self.isServer = isServer
    self.isClient = isClient
    self.customEnvironment = customEnvironment
    self.baseDirectory = baseDirectory

    self:mergeModTranslations(g_i18n)

    self.isEnabled = false

    addModEventListener(self)

    return self
end

function AdminToolBox:load()
    self.xml = self:getSettingsFile()

    self.settings = AtbSettings.new(nil, g_messageCenter)
    self.settings:loadFromXML(self.xml)

    local atbMenu = AtbTabbedMenu.new(nil, g_messageCenter, g_i18n, g_gui.inputManager)
    local generalFrame = AtbGeneralFrame.new(nil, g_i18n)

    if g_gui ~= nil then
        g_gui:loadGui(self.baseDirectory .. "gui/AtbGeneralFrame.xml", "AtbGeneralFrame", generalFrame, true)
        g_gui:loadGui(self.baseDirectory .. "gui/AtbTabbedMenu.xml", "AtbMenu", atbMenu)
    end

    self.isEnabled = true
end

function AdminToolBox:onInputOpenMenu(_, inputValue)
    if self.isEnabled and not g_gui:getIsGuiVisible() then
        self.atbGui = g_gui:showGui("AtbMenu")
    end
end

function AdminToolBox:update(dt)
    if not self.isEnabled then
        return
    end
    -- Enable/Disable shop menu and handle shop opening hours
    AtbOverrides:openShop(g_gui.currentGuiName)
end

function AdminToolBox:initFunctionOverridesOnStartup()
    -- Enable/Disable store lease button
    ShopConfigScreen.updateButtons = Utils.prependedFunction(ShopConfigScreen.updateButtons, AtbOverrides.storeLease)

    -- Enable/Disable missions vehicle leasing
    AbstractFieldMission.hasLeasableVehicles = Utils.overwrittenFunction(AbstractFieldMission.hasLeasableVehicles, AtbOverrides.missionLease)

    -- Enable/Disable sleeping
    SleepManager.getCanSleep = Utils.overwrittenFunction(SleepManager.getCanSleep, AtbOverrides.getCanSleep)
end

function AdminToolBox:applySettings()
    if not self.isEnabled then
        return
    end

    local farmChanged = false

    if g_currentMission ~= nil then
        -- Set number of AI workers
        local aiWorkerCount = self.settings:getValue(AtbSettings.SETTING.AI_WORKER_COUNT)
        g_currentMission.maxNumHirables = aiWorkerCount
        -- Disable if number of AI workers is 0
        if aiWorkerCount == 0 then
            g_currentMission.disableAIVehicle = true
        else
            g_currentMission.disableAIVehicle = false
        end

        -- Override contract limit
        MissionManager.ACTIVE_CONTRACT_LIMIT =  self.settings:getValue(AtbSettings.SETTING.MISSIONS_CONTRACT_LIMIT)

        -- Enable/Disable super strength
        -- todo: On the inital call the player is not yet set. Maybe this needs to be triggered later. Works after opening and closing ATB menu
        if g_currentMission.player ~= nil then
            local atbSuperStrengh = self.settings:getValue(AtbSettings.SETTING.GENERAL_STRENGH)
            local playerSuperStrengh = Utils.getNoNil(g_currentMission.player.superStrengthEnabled, false)
            if atbSuperStrengh ~= playerSuperStrengh then
                print(g_currentMission.player:consoleCommandToggleSuperStrongMode())
            end
        end
    end

    -- Override farm loan settings
    local loanMin = self.settings:getValue(AtbSettings.SETTING.FARM_LOAN_MIN)
    if loanMin ~= Farm.MIN_LOAN then
        Farm.MIN_LOAN = loanMin
        farmChanged = true
    end

    local loanMax = self.settings:getValue(AtbSettings.SETTING.FARM_LOAN_MAX)
    if loanMax ~= Farm.MAX_LOAN then
        Farm.MAX_LOAN = loanMax
        farmChanged = true
    end

    -- Update farms
    if farmChanged then
        for _, farm in ipairs(g_farmManager.farms) do
			local farmId = farm.farmId
			if farmId ~= FarmManager.SPECTATOR_FARM_ID then
                g_messageCenter:publish(MessageType.FARM_PROPERTY_CHANGED, farmId)
            end
        end
    end
end

function AdminToolBox:getSettingsFile()
    local key = "AdminToolBoxXML"
    local path = self:getSettingsFilePath()

    -- Init settings file
    if not fileExists(path) then
        local xmlFile = createXMLFile(key, path, "AdminToolBox")
        saveXMLFile(xmlFile)
		delete(xmlFile)
    end

    return loadXMLFile(key, path)
end

function AdminToolBox:getSettingsFilePath()
    local savegameFolderPath = g_currentMission.missionInfo.savegameDirectory .. "/"
	if savegameFolderPath == nil then
		savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(), g_currentMission.missionInfo.savegameIndex .. "/")
	end
	return savegameFolderPath .. "adminToolBox.xml"
end

function AdminToolBox:mergeModTranslations(i18n)
    -- We can copy all our translations to the global table because we prefix everything with ATB_
    -- Thanks for blocking the getfenv Giants..
    local modEnvMeta = getmetatable(_G)
    local env = modEnvMeta.__index

    local global = env.g_i18n.texts
    for key, text in pairs(i18n.texts) do
        global[key] = text
    end
end

----------------------------------------------------------------------------------------------------
-- Initialize Admin Tool Box
----------------------------------------------------------------------------------------------------
function initAdminToolBox(name)
    if name == nil then
        return
    end

    if g_adminToolBox == nil then
        local modDir = g_currentModDirectory
        local atb = AdminToolBox.new(g_server ~= nil, g_dedicatedServerInfo == nil, name, modDir)
        if atb ~= nil then
            -- Define global Admin Tools variable
            getfenv(0)["g_adminToolBox"] = atb

            -- Load files
            source(modDir .. "scripts/AtbSettings.lua");
            source(modDir .. "scripts/AtbOverrides.lua");

            -- Load menu with frames
            source(modDir .. "scripts/gui/AtbTabbedMenu.lua");
            source(modDir .. "scripts/gui/AtbGeneralFrame.lua");

            FSBaseMission.loadMapFinished = Utils.prependedFunction(FSBaseMission.loadMapFinished, loadMapFinished)

            FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents, registerActionEvents)
            BaseMission.unregisterActionEvents = Utils.appendedFunction(BaseMission.unregisterActionEvents, unregisterActionEvents)
        end

        print("  Initialized Admin Tool Box")
    end
end

function loadMapFinished()
    if g_adminToolBox ~= nil then
        g_adminToolBox:load()
        g_adminToolBox:initFunctionOverridesOnStartup()
        g_adminToolBox:applySettings()
    end
end

function registerActionEvents()
    if g_dedicatedServerInfo == nil and g_adminToolBox ~= nil then
        -- Menu Open
        local _, eventIdOpenMenu = g_inputBinding:registerActionEvent(InputAction.ATB_MENU, g_adminToolBox, g_adminToolBox.onInputOpenMenu, false, true, false, true)
        -- g_inputBinding:setActionEventTextVisibility(eventIdOpenMenu, false) -- Hide from help menu
        g_adminToolBox.eventIdOpenMenu = eventIdOpenMenu
    end
end

function unregisterActionEvents()
    if g_adminToolBox ~= nil then
        g_inputBinding:removeActionEventsByTarget(g_adminToolBox)
    end
end

initAdminToolBox(g_currentModName)
