----------------------------------------------------------------------------------------------------
--[[
Admin Tools for Farming Simulator 2022

Copyright (c) schliesser, 2021

Author: André Buchmann
Issues: https://github.com/schliesser/fs-admintools/issues

Feel free to open a pull reuests for enhancements or bugfixes.

You are not allowed to sell this mod or a modified version of it.
]] ----------------------------------------------------------------------------------------------------
AdminTools = {}
local AdminTools_mt = Class(AdminTools)

AdminTools.name = "AdminTools"

function AdminTools:new(isServer, isClient, customEnvironment, baseDirectory)
    print("New AdminTools")
    if g_adminTools ~= nil then
        return
    end

    local self = {}
    setmetatable(self, AdminTools_mt)

    -- todo: read config file
    self.isServer = isServer
    self.isClient = isClient
    self.customEnvironment = customEnvironment
    self.baseDirectory = baseDirectory

    self.isEnabled = false

    addModEventListener(self)

    return self
end

function AdminTools:load()
    print("load tabbed menu")
    local tabbedMenu = AdminToolsTabbedMenu:new(nil, g_messageCenter, g_i18n, g_gui.inputManager)
    print("Load Testframe")
    local testFrame = AdminToolsTestFrame.new(nil, g_i18n)

    print("Load GUI")
    if g_gui ~= nil then
        g_gui:loadGui(self.baseDirectory .. "gui/AdminToolsTestFrame.xml", "AdminToolsTestFrame", testFrame, true)
        g_gui:loadGui(self.baseDirectory .. "gui/AdminToolsTabbedMenu.xml", "AdminToolsTabbedMenu", tabbedMenu)
    end

    self.isEnabled = true
end

function AdminTools:onInputOpenMenu(_, inputValue)
    print("Toggle Menu")
    if self.isEnabled and not g_gui:getIsGuiVisible() then
        print("Show gui")
        self.adminToolsGui = g_gui:showGui("AdminToolsTabbedMenu")
    end
end

----------------------------------------------------------------------------------------------------
-- Initialize Admin Tools
----------------------------------------------------------------------------------------------------
function initAdminTools(name)
    if name == nil then
        return
    end

    if g_adminTools == nil then
        local modDir = g_currentModDirectory
        local adminTools = AdminTools:new(g_server ~= nil, g_dedicatedServerInfo == nil, name, modDir)
        if adminTools ~= nil then
            -- Define global Admin Tools variable
            getfenv(0)["g_adminTools"] = adminTools

            -- Load menu frames
            source(modDir .. "scripts/gui/AdminToolsTabbedMenu.lua");
            source(modDir .. "scripts/gui/AdminToolsTestFrame.lua");

            FSBaseMission.loadMapFinished = Utils.prependedFunction(FSBaseMission.loadMapFinished, loadMapFinished)

            FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents, registerActionEvents)
            BaseMission.unregisterActionEvents = Utils.appendedFunction(BaseMission.unregisterActionEvents, unregisterActionEvents)
        end

        print("  Initialized Admin Tools")
    end
end

function loadMapFinished()
    if g_adminTools ~= nil then
        g_adminTools:load()
    end
end

function registerActionEvents()
    if g_dedicatedServerInfo == nil and g_adminTools ~= nil then
        local _, eventId = g_inputBinding:registerActionEvent(InputAction.ADT_MENU, g_adminTools, g_adminTools.onInputOpenMenu, false, true, false, true)
        -- g_inputBinding:setActionEventTextVisibility(eventId, false)
        g_adminTools.eventIdOpenMenu = eventId
    end
end

function unregisterActionEvents()
    if g_adminTools ~= nil then
        g_inputBinding:removeActionEventsByTarget(g_adminTools)
    end
end

initAdminTools(g_currentModName)
