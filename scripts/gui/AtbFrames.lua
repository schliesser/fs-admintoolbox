AtbFrames = {}
local AtbFrames_mt = Class(AtbFrames, TabbedMenuFrameElement)

AtbFrames.CONTROLS = {
    "pageAtbGeneral",
    "pageAtbStore",
}

AtbFrames.TAB_UV = {
    GENERAL = {715, 0, 65, 65},
    FARMS = {260, 65, 65, 65},
    USERS = {650, 65, 65, 65},
    STORE = {325, 0, 65, 65},
}

function AtbFrames.new(target, messageCenter, l10n, inputManager)
    local self = AtbFrames:superClass().new(target, AtbFrames_mt, messageCenter, l10n, inputManager)

    self:registerControls(AtbFrames.CONTROLS)

    return self
end
