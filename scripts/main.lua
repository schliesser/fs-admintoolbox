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

function AdminToolBox.new(customMt, isServer, isClient, customEnvironment, baseDirectory)
    if g_atb ~= nil then
        return
    end

    local self = setmetatable({}, customMt or AdminToolBox_mt)
    -- todo: read config file
    self.isServer = isServer
    self.isClient = isClient
    self.customEnvironment = customEnvironment
    self.baseDirectory = baseDirectory
    self.xmlPath = nil

    self:mergeModTranslations(g_i18n)

    self.isEnabled = false

    addModEventListener(self)

    return self
end

function AdminToolBox:load()
    self.settings = AtbSettings.new(nil)

    if self.isClient and g_gui ~= nil then
        local generalFrame = AtbGeneralFrame.new(nil, g_i18n)
        local generalFrameReference = AtbGeneralFrameReference.new()
        g_gui:loadGui(self.baseDirectory .. "gui/AtbGeneralFrame.xml", "AtbGeneralFrame", generalFrame, true)
        g_gui:loadGui(self.baseDirectory .. "gui/AtbGeneralFrameReference.xml", "AtbGeneralFrameReference", generalFrameReference)

        local inGameMenu = g_currentMission.inGameMenu
        local pageAtbGeneral = generalFrameReference.pageAtbGeneral

        if pageAtbGeneral ~= nil then
            local pagingElement = inGameMenu.pagingElement
            local index = pagingElement:getPageIndexByElement(inGameMenu.pageSettingsGame) + 1

            PagingElement:superClass().addElement(pagingElement, pageAtbGeneral)
            pagingElement:addPage(pageAtbGeneral.name, pageAtbGeneral, g_i18n:getText("ATB_header_general"), index)

            inGameMenu:registerPage(pageAtbGeneral, index, inGameMenu:makeIsGameSettingsEnabledPredicate())
            inGameMenu:addPageTab(pageAtbGeneral, g_iconsUIFilename, GuiUtils.getUVs(ModHubScreen.TAB_UV.BEST))
            inGameMenu.pageAtbGeneral = pageAtbGeneral
            inGameMenu.pageAtbGeneral:initialize()
        end
    end

    if g_currentMission.missionInfo.savegameDirectory ~= nil then
        self.xmlPath = g_currentMission.missionInfo.savegameDirectory .. "/adminToolBox.xml"
    end

    self.isEnabled = true
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

    -- Enable/Disable vehicle tabbing
    BaseMission.onSwitchVehicle = Utils.overwrittenFunction(BaseMission.onSwitchVehicle, AtbOverrides.onSwitchVehicle)

    -- Override farm loan calculation
    Farm.updateMaxLoan = Utils.overwrittenFunction(Farm.updateMaxLoan, AtbOverrides.updateMaxLoan)
end

function AdminToolBox:applySettings()
    if not self.isEnabled then
        printWarning('AdminToolBox:applySettings() is disabled!')
        return
    end

    local farmChanged = false

    if g_currentMission ~= nil then
        -- Set number of AI workers
        local aiWorkerCount = g_atb.settings:getValue(AtbSettings.AI_WORKER_COUNT)
        g_currentMission.maxNumHirables = aiWorkerCount
        -- Disable if number of AI workers is 0
        if aiWorkerCount == 0 then
            g_currentMission.disableAIVehicle = true
        else
            g_currentMission.disableAIVehicle = false
        end

        -- Override contract limit
        MissionManager.ACTIVE_CONTRACT_LIMIT =  g_atb.settings:getValue(AtbSettings.MISSIONS_CONTRACT_LIMIT)
    end

    -- Override farm loan settings
    local loanMin = g_atb.settings:getValue(AtbSettings.FARM_LOAN_MIN)
    if loanMin ~= Farm.MIN_LOAN then
        Farm.MIN_LOAN = loanMin
    end

    local loanMax = g_atb.settings:getValue(AtbSettings.FARM_LOAN_MAX)
    if loanMax ~= Farm.MAX_LOAN then
        Farm.MAX_LOAN = loanMax
    end

    -- Trigger farm change event to recalculate loans
    for _, farm in ipairs(g_farmManager.farms) do
        local farmId = farm.farmId
        if farmId ~= FarmManager.SPECTATOR_FARM_ID then
            g_messageCenter:publish(MessageType.FARM_PROPERTY_CHANGED, farmId)
        end
    end
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
local modDir = g_currentModDirectory
source(modDir .. "scripts/AtbSettings.lua");
source(modDir .. "scripts/AtbOverrides.lua");
source(modDir .. "scripts/events/SaveAtbSettingsEvent.lua");
source(modDir .. "scripts/gui/AtbGeneralFrameReference.lua");
source(modDir .. "scripts/gui/AtbGeneralFrame.lua");

function initAdminToolBox(name)
    if name == nil then
        return
    end

    if g_atb == nil then
        -- Define global Admin Tools variable
        g_atb = AdminToolBox.new(nil, g_server ~= nil, g_dedicatedServerInfo == nil, name, modDir)

        if g_atb ~= nil then
            FSBaseMission.loadMapFinished = Utils.prependedFunction(FSBaseMission.loadMapFinished, loadMapFinished)
            FSBaseMission.onConnectionFinishedLoading = Utils.appendedFunction(FSBaseMission.onConnectionFinishedLoading, onConnectionFinishedLoading)
            FSCareerMissionInfo.saveToXMLFile = Utils.appendedFunction(FSCareerMissionInfo.saveToXMLFile, saveToXMLFile)
            Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished, loadMission00Finished)
        end
    end
end

function loadMapFinished()
    if g_atb ~= nil then
        g_atb:load()
        g_atb:initFunctionOverridesOnStartup()
        g_atb:applySettings()
    end
end

function saveToXMLFile(missionInfo)
    if g_atb ~= nil and g_atb.settings ~=nil then
        g_atb.settings:saveToXMLFile()
    end
end

function loadMission00Finished(mission)
    if mission:getIsServer() and  g_atb ~= nil and g_atb.xmlPath ~= nil and fileExists(g_atb.xmlPath) then
        local xmlFile = loadXMLFile("AdminToolBoxXML", g_atb.xmlPath)
        if xmlFile ~= nil then
            g_atb.settings:loadFromXML(xmlFile)
            delete(xmlFile)
        end
    end
    g_atb:applySettings()
end

function onConnectionFinishedLoading(mission, connection, x,y,z, viewDistanceCoeff)
    if g_atb ~= nil and connection ~= nil then
        connection:sendEvent(SaveAtbSettingsEvent.new())
    end
end

initAdminToolBox(g_currentModName)
