AtbSettings = {}
local AtbSettings_mt = Class(AtbSettings)
AtbSettings.SETTING = {
    GENERAL_AI = "generalAi",
    GENERAL_SLEEP = "generalSleep",
    GENERAL_STRENGH = "generalStrength",
    GENERAL_SPEED = "generalSpeed",
    GENERAL_TIME = "generalTime"
}

function AtbSettings.new(customMt, messageCenter)
    if customMt == nil then
		customMt = AtbSettings_mt
	end

    local self = {}

	setmetatable(self, customMt)

    self.messageCenter = messageCenter
	self.notifyOnChange = false

    self[AtbSettings.SETTING.GENERAL_AI] = true
    self[AtbSettings.SETTING.GENERAL_SLEEP] = true
    self[AtbSettings.SETTING.GENERAL_STRENGH] = false
    self[AtbSettings.SETTING.GENERAL_SPEED] = 100
    self[AtbSettings.SETTING.GENERAL_TIME] = 1000

    self.printedSettingsChanges = {}

    return self
end

function AtbSettings:getTableValue(name, index)
	if name == nil then
		print("Error: AtbSetting table name missing or nil!")

		return false
	end

	if index == nil then
		print("Error: AtbSetting table index missing or nil!")

		return false
	end

	return self[name][index]
end

function AtbSettings:setTableValue(name, index, value, doSave)
	if name == nil then
		print("Error: AtbSetting table name missing or nil!")

		return false
	end

	if index == nil then
		print("Error: AtbSetting table index missing or nil!")

		return false
	end

	if value == nil then
		print("Error: AtbSetting table value missing or nil for index '" .. index("'!"))

		return false
	end

	if self[name] == nil then
		print("Error: AtbSetting table '" .. name .. "' not found!")

		return false
	end

	self[name][index] = value

	if doSave then
		self:saveToXMLFile(g_adminToolBox.xml)
	end

	return true
end

function AtbSettings:getValue(name)
	if name == nil then
		Logging.error("AtbSetting %s missing or nil!", name)
		printCallstack()

		return false
	end

	return self[name]
end

function AtbSettings:setValue(name, value, doSave)
	if name == nil then
		Logging.error("AtbSetting %s missing or nil!", name)
		printCallstack()

		return false
	end

	if value == nil then
		Logging.error("AtbSetting value missing or nil for setting '%s'!", name)
		printCallstack()

		return false
	end

	if self[name] == nil then
		Logging.error("AtbSetting '" .. name .. "' not found!")

		return false
	end

	self[name] = value

	if self.printedSettingsChanges[name] ~= nil then
		print("  " .. string.format(self.printedSettingsChanges[name], value))
	end

	if self.notifyOnChange then
		local messageType = MessageType.SETTING_CHANGED[name]

		self.messageCenter:publish(messageType, value)
	end

	if doSave then
		self:saveToXMLFile(g_adminToolBox.xml)
	end

	return true
end

function AtbSettings:loadFromXML(xmlFile)
	if xmlFile ~= nil then
        self:setValue(AtbSettings.SETTING.GENERAL_AI, Utils.getNoNil(getXMLBool(xmlFile, "AdminToolBox.general.ai"), self[AtbSettings.SETTING.GENERAL_AI]))
        self:setValue(AtbSettings.SETTING.GENERAL_SLEEP, Utils.getNoNil(getXMLBool(xmlFile, "AdminToolBox.general.sleep"), self[AtbSettings.SETTING.GENERAL_SLEEP]))
        self:setValue(AtbSettings.SETTING.GENERAL_STRENGH, Utils.getNoNil(getXMLBool(xmlFile, "AdminToolBox.general.strengh"), self[AtbSettings.SETTING.GENERAL_STRENGH]))
        self:setValue(AtbSettings.SETTING.GENERAL_SPEED, MathUtil.clamp(Utils.getNoNil(getXMLInt(xmlFile, "AdminToolBox.general.speed"), self[AtbSettings.SETTING.GENERAL_SPEED]), 0, 10))
        self:setValue(AtbSettings.SETTING.GENERAL_TIME, MathUtil.clamp(Utils.getNoNil(getXMLInt(xmlFile, "AdminToolBox.general.time"), self[AtbSettings.SETTING.GENERAL_TIME]), 200, 2000))

        self.notifyOnChange = true
    end
end

function AtbSettings:setTableValueFromXML(tableName, index, xmlFunc, xmlFile, xmlPath)
	local value = xmlFunc(xmlFile, xmlPath)

	if value ~= nil then
		self:setTableValue(tableName, index, value)
	end
end

function AtbSettings:saveToXMLFile(xmlFile)
	if xmlFile ~= nil then
        setXMLBool(xmlFile, "AdminToolBox.general.ai", self[AtbSettings.SETTING.GENERAL_AI])
        setXMLBool(xmlFile, "AdminToolBox.general.sleep", self[AtbSettings.SETTING.GENERAL_SLEEP])
        setXMLBool(xmlFile, "AdminToolBox.general.strengh", self[AtbSettings.SETTING.GENERAL_STRENGH])
		setXMLInt(xmlFile, "AdminToolBox.general.speed", self[AtbSettings.SETTING.GENERAL_SPEED])
		setXMLInt(xmlFile, "AdminToolBox.general.time", self[AtbSettings.SETTING.GENERAL_TIME])
        saveXMLFile(xmlFile)
    end
end

function AtbSettings:setXMLValue(xmlFile, func, xPath, value)
	if value ~= nil then
		func(xmlFile, xPath, value)
	end
end
