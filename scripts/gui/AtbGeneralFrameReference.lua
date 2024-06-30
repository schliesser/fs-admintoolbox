AtbGeneralFrameReference = {}

local AtbGeneralFrameReference_mt = Class(AtbGeneralFrameReference, TabbedMenuFrameElement)

AtbGeneralFrameReference.CONTROLS = {
	PAGE_ATB_GENERAL = "pageAtbGeneral"
}

function AtbGeneralFrameReference.new(subclass_mt)
    local self = TabbedMenuFrameElement.new(nil, subclass_mt or AtbGeneralFrameReference_mt)
    self:registerControls(AtbGeneralFrameReference.CONTROLS)
    return self
end
