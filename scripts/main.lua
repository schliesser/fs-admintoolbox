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
    if g_atb ~= nil then
        return
    end

    local self = {}
    setmetatable(self, AdminToolBox_mt)

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

    if self.isClient then
        local atbMenu = AtbMenu.new(nil, g_messageCenter, g_i18n, g_gui.inputManager)
        local atbFrames = AtbFrames.new()
        local generalFrame = AtbFrameGeneral.new(nil, g_i18n)
        local storeFrame = AtbFrameStore.new(nil, g_i18n)

        if g_gui ~= nil then
            g_gui:loadGui(Utils.getFilename("gui/AtbFrameGeneral.xml", self.baseDirectory), "AtbFrameGeneral", generalFrame, true)
            g_gui:loadGui(Utils.getFilename("gui/AtbFrameStore.xml", self.baseDirectory), "AtbFrameStore", storeFrame, true)
            g_gui:loadGui(Utils.getFilename("gui/AtbMenu.xml", self.baseDirectory), "AtbMenu", atbMenu)
            g_gui:loadGui(Utils.getFilename("gui/AtbFrames.xml", self.baseDirectory), "AtbFrames", atbFrames)

            self:addInGameMenuFrame(atbFrames.pageAtbStore, AtbFrames.TAB_UV.STORE)
            self:addInGameMenuFrame(atbFrames.pageAtbGeneral, AtbFrames.TAB_UV.GENERAL)
        end
    end

    if g_currentMission.missionInfo.savegameDirectory ~= nil then
        self.xmlPath = g_currentMission.missionInfo.savegameDirectory .. "/adminToolBox.xml"
    end

    self.isEnabled = true
end

function AdminToolBox:onInputOpenMenu(_, inputValue)
    -- todo: validate that player has access
    if self.isServer or g_currentMission.isMasterUser then
        if self.isEnabled and not g_gui:getIsGuiVisible() then
            self.atbGui = g_gui:showGui("AtbMenu")
        end
    end
end

function AdminToolBox:addInGameMenuFrame(frame, icon)
    local inGameMenu = g_currentMission.inGameMenu

	if frame ~= nil then
		local pagingElement = inGameMenu.pagingElement
		local index = pagingElement:getPageIndexByElement(inGameMenu.pageSettingsGeneral) + 1

		PagingElement:superClass().addElement(pagingElement, frame)
		pagingElement:addPage(string.upper(frame.name), frame, 'MyTitle', index)

		inGameMenu:registerPage(frame, index, inGameMenu:makeIsGeneralSettingsEnabledPredicate())
		inGameMenu:addPageTab(frame, g_iconsUIFilename, GuiUtils.getUVs(icon))
		inGameMenu[frame.name] = frame
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
    AbstractFieldMission.hasLeasableVehicles = Utils.overwrittenFunction(AbstractFieldMission.hasLeasableVehicles,
        AtbOverrides.missionLease)

    -- Enable/Disable sleeping
    SleepManager.getCanSleep = Utils.overwrittenFunction(SleepManager.getCanSleep, AtbOverrides.getCanSleep)

    -- Enable/Disable vehicle tabbing
    BaseMission.onSwitchVehicle = Utils.overwrittenFunction(BaseMission.onSwitchVehicle, AtbOverrides.onSwitchVehicle)

    -- Override farm loan calculation
    Farm.updateMaxLoan = Utils.overwrittenFunction(Farm.updateMaxLoan, AtbOverrides.updateMaxLoan)
end

function AdminToolBox:applySettings()
    if not self.isEnabled then
        print('ATB: Apply settings - disabled!!!!')
        return
    end

    print('ATB: Apply settings')

    local farmChanged = false

    if g_currentMission ~= nil then
        -- Set number of AI workers
        local aiWorkerCount = g_atb.settings:getValue(AtbSettings.SETTING.AI_WORKER_COUNT)
        g_currentMission.maxNumHirables = aiWorkerCount
        -- Disable if number of AI workers is 0
        if aiWorkerCount == 0 then
            g_currentMission.disableAIVehicle = true
        else
            g_currentMission.disableAIVehicle = false
        end

        -- Override contract limit
        MissionManager.ACTIVE_CONTRACT_LIMIT = g_atb.settings:getValue(AtbSettings.SETTING.MISSIONS_CONTRACT_LIMIT)
    end

    -- Override farm loan settings
    local loanMin = g_atb.settings:getValue(AtbSettings.SETTING.FARM_LOAN_MIN)
    if loanMin ~= Farm.MIN_LOAN then
        Farm.MIN_LOAN = loanMin
    end

    local loanMax = g_atb.settings:getValue(AtbSettings.SETTING.FARM_LOAN_MAX)
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
local atb = nil
local modDir = g_currentModDirectory
source(modDir .. "scripts/AtbSettings.lua");
source(modDir .. "scripts/AtbOverrides.lua");
source(modDir .. "scripts/events/SaveAtbSettingsEvent.lua");
source(modDir .. "scripts/gui/AtbMenu.lua");
source(modDir .. "scripts/gui/AtbFrames.lua");
source(modDir .. "scripts/gui/AtbFrameGeneral.lua");
source(modDir .. "scripts/gui/AtbFrameStore.lua");

function initAdminToolBox(name)
    if name == nil then
        return
    end

    if g_atb == nil then

        atb = AdminToolBox.new(g_server ~= nil, g_dedicatedServerInfo == nil, name, modDir)
        if atb ~= nil then
            -- Define global Admin Tools variable
            -- Doesn't work correctly in FS22 anymore, it's not accessible for other mods
            getfenv(0)["g_atb"] = atb

            FSBaseMission.loadMapFinished = Utils.prependedFunction(FSBaseMission.loadMapFinished, loadMapFinished)
            FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents,
                registerActionEvents)
            FSBaseMission.onConnectionFinishedLoading = Utils.appendedFunction(
                FSBaseMission.onConnectionFinishedLoading, onConnectionFinishedLoading)
            FSCareerMissionInfo.saveToXMLFile = Utils.appendedFunction(FSCareerMissionInfo.saveToXMLFile, saveToXMLFile)
            Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished,
                loadMission00Finished)
            BaseMission.unregisterActionEvents = Utils.appendedFunction(BaseMission.unregisterActionEvents,
                unregisterActionEvents)
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

function registerActionEvents()
    if g_dedicatedServerInfo == nil and g_atb ~= nil then
        -- Menu Open
        local _, eventIdOpenMenu = g_inputBinding:registerActionEvent(InputAction.ATB_MENU, g_atb,
            g_atb.onInputOpenMenu, false, true, false, true)
        if not g_atb.isServer and not g_currentMission.isMasterUser then
            g_inputBinding:setActionEventTextVisibility(eventIdOpenMenu, false) -- Hide from help menu
        end
        g_atb.eventIdOpenMenu = eventIdOpenMenu
    end
end

function unregisterActionEvents()
    if g_atb ~= nil then
        g_inputBinding:removeActionEventsByTarget(g_atb)
    end
end

function saveToXMLFile(missionInfo)
    if g_atb ~= nil and g_atb.settings ~= nil then
        g_atb.settings:saveToXMLFile()
    end
end

function loadMission00Finished(mission)
    if mission:getIsServer() and g_atb ~= nil and g_atb.xmlPath ~= nil and fileExists(g_atb.xmlPath) then
        local xmlFile = loadXMLFile("AdminToolBoxXML", g_atb.xmlPath)
        if xmlFile ~= nil then
            g_atb.settings:loadFromXML(xmlFile)
            delete(xmlFile)
        end
    end
    g_atb:applySettings()
end

function onConnectionFinishedLoading(mission, connection, x, y, z, viewDistanceCoeff)
    if g_atb ~= nil and connection ~= nil then
        connection:sendEvent(SaveAtbSettingsEvent.new())
    end
end

initAdminToolBox(g_currentModName)
