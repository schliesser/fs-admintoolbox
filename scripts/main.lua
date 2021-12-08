----------------------------------------------------------------------------------------------------
--[[
Admin Tools for Farming Simulator 2022

Copyright (c) schliesser, 2021

Author: André Buchmann
Issues: https://github.com/schliesser/fs-admintools/issues

Feel free to open a pull reuests for enhancements or bugfixes.

You are not allowed to sell this mod or a modified version of it.
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

    self.isEnabled = false

    addModEventListener(self)

    return self
end

function AdminToolBox:load()
    print("ATB: Load Settings")
    self.xml = self:getSettingsFile()

    print("init atb settings")
    self.settings = AtbSettings.new(nil, g_messageCenter)
    self.settings:loadFromXML(self.xml)

    print("Load Menu")
    local atbMenu = AtbTabbedMenu.new(nil, g_messageCenter, g_i18n, g_gui.inputManager)
    print("Load Frames")
    local generalFrame = AtbGeneralFrame.new(nil, g_i18n)
    local testFrame = AtbTestFrame.new(nil, g_i18n)

    print("Load GUI")
    if g_gui ~= nil then
        g_gui:loadGui(self.baseDirectory .. "gui/AtbGeneralFrame.xml", "AtbGeneralFrame", generalFrame, true)
        g_gui:loadGui(self.baseDirectory .. "gui/AtbTestFrame.xml", "AtbTestFrame", testFrame, true)
        g_gui:loadGui(self.baseDirectory .. "gui/AtbTabbedMenu.xml", "AtbMenu", atbMenu)
    end

    self.isEnabled = true
end

function AdminToolBox:onInputOpenMenu(_, inputValue)
    if self.isEnabled and not g_gui:getIsGuiVisible() then
        self.atbGui = g_gui:showGui("AtbMenu")
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

--[[
	Returns the file path to the settings file, which is located in the savegame folder.
]]
function AdminToolBox:getSettingsFilePath()
    local savegameFolderPath = g_currentMission.missionInfo.savegameDirectory .. "/"
	if savegameFolderPath == nil then
		savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(), g_currentMission.missionInfo.savegameIndex .. "/")
	end
	return savegameFolderPath .. "adminToolBox.xml"
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

            -- Load menu with frames
            source(modDir .. "scripts/gui/AtbTabbedMenu.lua");
            source(modDir .. "scripts/gui/AtbGeneralFrame.lua");
            source(modDir .. "scripts/gui/AtbTestFrame.lua");

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
