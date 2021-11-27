----------------------------------------------------------------------------------------------------
-- Entry point of FS22_AdminTools mod
--
-- Copyright (c) Schliesser, 2021
----------------------------------------------------------------------------------------------------
source(g_currentModDirectory .. "scripts/gui/InGameMenuAdminToolsFrame.lua");

AdminTools = {}
AdminTools.name = "AdminTools"

function AdminTools:initialize()
    print("Initialize AdminTools")


    local inGameMenuAdminToolsFrame = InGameMenuAdminToolsFrame.new(nil)

    table.insert(InGameMenu.CONTROLS, "pageAdminTools")
    InGameMenu.updateHasMasterRights = Utils.prependedFunction(InGameMenu.updateHasMasterRights, AdminTools.updateHasMasterRights)
    InGameMenu.setupMenuPages = Utils.appendedFunction(InGameMenu.setupMenuPages, AdminTools.setupMenuPages)

    print("Load GUI")
    if g_gui ~= nil then
        g_gui:loadGui(g_currentModDirectory .. "gui/InGameMenuAdminToolsFrame.xml", "AdminToolsFrame", inGameMenuAdminToolsFrame, true)
        g_gui:loadGui(g_currentModDirectory .. "gui/InGameMenu.xml", "InGameMenu", inGameMenu)
    end


end



function AdminTools:updateHasMasterRights()
	if self.pageAdminTools ~= nil then
		self.pageAdminTools:setHasMasterRights(hasMasterRights)
	end
end

function InGameMenu:setupMenuPages()
    local page = "pageAdminTools"
    InGameMenu.registerPage(page, 50, IngameMenu:makeIsGameSettingsEnabledPredicate())
    local normalizedUVs = GuiUtils.getUVs(iconUVs)
    self:addPageTab(page, g_iconsUIFilename, normalizedUVs)
end

AdminTools.initialize()
