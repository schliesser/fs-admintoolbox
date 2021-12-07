----------------------------------------------------------------------------------------------------
--[[
Admin Tools for Farming Simulator 2022

Copyright (c) schliesser, 2021

Author: André Buchmann
Issues: https://github.com/schliesser/fs-admintools/issues

Feel free to open a pull reuests for enhancements or bugfixes.

You are not allowed to sell this mod or a modified version of it.
]] ----------------------------------------------------------------------------------------------------
AdminToolBox = {
    NAME = "AdminToolBox",
    VERSION = 1,
    FILENAME = "AdminToolBox.xml",
    GENERAL = {
        AI = true,
        SLEEP = true,
        STRENGH = false,
        SPEED = 100,
        TIME = 1000
    },
    STORE = {
        OPEN = true,
        HOURS_OPEN = "8:00",
        HOURS_CLOSE = "18:00",
        LEASING = true
    },
    FARM = {
        LOAN_MIN = 500000,
        LOAN_MAX = 3000000
    },
    MISSIONS = {
        ENABLE = true,
        LEASING = true,
        REWARDS = {
            -- Todo: copy base game rewards
        }
    }
}
local AdminToolBox_mt = Class(AdminToolBox)

function AdminToolBox:new(isServer, isClient, customEnvironment, baseDirectory)
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
    -- self:loadSettings()
    print("Load Menu")
    local atbMenu = AtbTabbedMenu.new(nil, g_messageCenter, g_i18n, g_gui.inputManager)
    print("Load Frames")
    local testFrame = AtbTestFrame.new(nil, g_i18n)
    -- local generalFrame = AtbGeneralFrame.new(nil, g_i18n)

    print("Load GUI")
    if g_gui ~= nil then
        g_gui:loadGui(self.baseDirectory .. "gui/AtbTestFrame.xml", "AtbTestFrame", testFrame, true)
        -- g_gui:loadGui(self.baseDirectory .. "gui/AtbGeneralFrame.xml", "AtbGeneralFrame", generalFrame, true)
        g_gui:loadGui(self.baseDirectory .. "gui/AtbTabbedMenu.xml", "AtbMenu", atbMenu)
    end

    self.isEnabled = true
end

function AdminToolBox:onInputOpenMenu(_, inputValue)
    if self.isEnabled and not g_gui:getIsGuiVisible() then
        self.atbGui = g_gui:showGui("AtbMenu")
    end
end

--[[
	Loads the saved settings from the settings file, if such a file is present and the version numbers match.
	Otherwise saves the current settings to a new settings file (existing settings will be overwritten and lost).
]]
function AdminToolBox:loadSettings()
	print("Info - AdminToolBox: Loading settings...");
	local settingsFilePath = AdminToolBox.getSettingsFilePath();
    if settingsFilePath == nil then
		print("Error - AdminToolBox: Could not get a valid file path")
		return;
	end

	if fileExists(settingsFilePath) then
		local file = loadXMLFile("AdminToolBoxSettingsFile", AdminToolBox.getSettingsFilePath(), "AdminToolBox");
		local xmlVersion = Utils.getNoNil(getXMLInt(file, "AdminToolBox#VERSION"), 0);
		if xmlVersion == AdminToolBox.VERSION then
			AdminToolBox.GENERAL.AI = Utils.getNoNil(getXMLBool(file, "AdminToolBox.general.ai"), AdminToolBox.GENERAL.AI);
			AdminToolBox.GENERAL.SLEEP = Utils.getNoNil(getXMLBool(file, "AdminToolBox.general.sleep"), AdminToolBox.GENERAL.SLEEP);
			AdminToolBox.GENERAL.STRENGH = Utils.getNoNil(getXMLBool(file, "AdminToolBox.general.strengh"), AdminToolBox.GENERAL.STRENGH);
			AdminToolBox.GENERAL.SPEED = Utils.getNoNil(getXMLInt(file, "AdminToolBox.general.speed"), AdminToolBox.GENERAL.SPEED);
			AdminToolBox.GENERAL.TIME = Utils.getNoNil(getXMLInt(file, "AdminToolBox.general.time"), AdminToolBox.GENERAL.TIME);
			print("Info - AdminToolBox: Settings successfully loaded");
		else
			print("Warning - AdminToolBox: Settings file version did not match (file has " .. (xmlVersion < AdminToolBox.VERSION and "older" or "newer") .. " version). Overwriting with current version's default settings");
			AdminToolBox.saveSettings();
		end
	else
		print("Info - AdminToolBox: Settings file could not be found. Creating new settings file '" .. settingsFilePath .. "'");
		AdminToolBox.saveSettings();
	end
end

--[[
	Saves the current settings to the settings file.
]]
function AdminToolBox:saveSettings()
	print("Info - AdminToolBox: Saving settings...");
	local settingsFilePath = AdminToolBox.getSettingsFilePath();
    if settingsFilePath == nil then
		print("Error - AdminToolBox: Could not get a valid file path")
		return;
	end

	local file = createXMLFile("AdminToolBoxSettingsFile", settingsFilePath, "AdminToolBox")
	setXMLInt(file, "AdminToolBox#VERSION", AdminToolBox.VERSION);
	setXMLBool(file, "AdminToolBox.general.ai", AdminToolBox.GENERAL.AI);
	setXMLBool(file, "AdminToolBox.general.sleep", AdminToolBox.GENERAL.SLEEP);
	setXMLBool(file, "AdminToolBox.general.strengh", AdminToolBox.GENERAL.STRENGH);
	setXMLInt(file, "AdminToolBox.general.speed", AdminToolBox.GENERAL.SPEED);
	setXMLInt(file, "AdminToolBox.general.time", AdminToolBox.GENERAL.TIME);
	saveXMLFile(file);
	print("Info - AdminToolBox: Settings successfully saved");
end

--[[
	Returns the file path to the settings file, which is located in the savegame folder.
	AdminToolBox.FILENAME has to have a valid value (not nil and at least 1 character long).
	Returns nil if FILENAME has an invalid value.
]]
function AdminToolBox:getSettingsFilePath()
	if AdminToolBox.FILENAME == nil or string.len(AdminToolBox.FILENAME) <= 0 then
		print("Error - AdminToolBox: FILENAME is invalid");
		return
	end
	local path = getUserProfileAppPath() .. "modSettings/";
	createFolder(path);
	local path = path .. AdminToolBox.FILENAME;
	return path;
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
        local atb = AdminToolBox:new(g_server ~= nil, g_dedicatedServerInfo == nil, name, modDir)
        if atb ~= nil then
            -- Define global Admin Tools variable
            getfenv(0)["g_adminToolBox"] = atb

            -- Load menu with frames
            source(modDir .. "scripts/gui/AtbTabbedMenu.lua");
            source(modDir .. "scripts/gui/AtbTestFrame.lua");
            -- source(modDir .. "scripts/gui/AtbGeneralFrame.lua");

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
