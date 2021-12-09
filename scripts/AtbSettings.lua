AtbSettings = {}
local AtbSettings_mt = Class(AtbSettings)
AtbSettings.SETTING = {
    AI_WORKER_COUNT = "aiWorkerCount",
    GENERAL_SLEEP = "generalSleep",
    GENERAL_STRENGH = "generalStrength",
    VEHICLE_TABBING = "generalVehicleTabbing",
    GENERAL_TIME = "generalTime",
    STORE_ACTIVE = "storeActive",
    STORE_OPEN_TIME = "storeOpenTime",
    STORE_CLOSE_TIME = "storeHoursClose",
    STORE_LEASING = "storeLeasing",
    FARM_LOAN_MIN = "farmLoanMin",
    FARM_LOAN_MAX = "farmLoanMax",
    MISSIONS_CONTRACT_LIMIT = "missionsContractLimit",
    MISSIONS_LEASING = "missionsLeasing",
    MISSIONS_UPDATE_INTERVAL = "missionsUpdateIntveral",
    MISSIONS_MAX_AVAILABLE = "missionsMaxAvailable",
    MISSIONS_PER_PLAYER = "missionsPerPlayer",
    -- Mission rewards
}
AtbSettings.MAX_MONEY = 999999999
AtbSettings.MIN_TIME = 0
AtbSettings.MAX_TIME = 24
AtbSettings.WORKERS_DEFAULT = 10
AtbSettings.WORKERS_MAX = 20
AtbSettings.MISSIONS_COUNT_DEFAULT = 3
AtbSettings.MISSIONS_COUNT_MAX = 10


function AtbSettings.new(customMt, messageCenter)
    if customMt == nil then
		customMt = AtbSettings_mt
	end

    local self = {}

	setmetatable(self, customMt)

    self.messageCenter = messageCenter
	self.notifyOnChange = false

    -- general
    self[AtbSettings.SETTING.AI_WORKER_COUNT] = AtbSettings.WORKERS_DEFAULT
    self[AtbSettings.SETTING.GENERAL_SLEEP] = true
    self[AtbSettings.SETTING.GENERAL_STRENGH] = false
    self[AtbSettings.SETTING.GENERAL_TIME] = 1000
    self[AtbSettings.SETTING.VEHICLE_TABBING] = true

    -- store
    self[AtbSettings.SETTING.STORE_ACTIVE] = true
    self[AtbSettings.SETTING.STORE_OPEN_TIME] = AtbSettings.MIN_TIME
    self[AtbSettings.SETTING.STORE_CLOSE_TIME] = AtbSettings.MAX_TIME
    self[AtbSettings.SETTING.STORE_LEASING] = true

    -- farms
    self[AtbSettings.SETTING.FARM_LOAN_MIN] = 500000
    self[AtbSettings.SETTING.FARM_LOAN_MAX] = 3000000

    -- missions
    self[AtbSettings.SETTING.MISSIONS_CONTRACT_LIMIT] = AtbSettings.MISSIONS_COUNT_DEFAULT
    self[AtbSettings.SETTING.MISSIONS_LEASING] = true

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
        local key = "AdminToolBox."
        -- general
        self:setValue(AtbSettings.SETTING.AI_WORKER_COUNT, MathUtil.clamp(Utils.getNoNil(getXMLInt(xmlFile, key.."ai.workers"), self[AtbSettings.SETTING.AI_WORKER_COUNT]), 0, AtbSettings.WORKERS_MAX))
        self:setValue(AtbSettings.SETTING.GENERAL_SLEEP, Utils.getNoNil(getXMLBool(xmlFile, key.."general.sleep"), self[AtbSettings.SETTING.GENERAL_SLEEP]))
        self:setValue(AtbSettings.SETTING.GENERAL_STRENGH, Utils.getNoNil(getXMLBool(xmlFile, key.."general.strengh"), self[AtbSettings.SETTING.GENERAL_STRENGH]))
        self:setValue(AtbSettings.SETTING.VEHICLE_TABBING, Utils.getNoNil(getXMLBool(xmlFile, key.."general.vehicleTabbing"), self[AtbSettings.SETTING.VEHICLE_TABBING]))
        -- self:setValue(AtbSettings.SETTING.GENERAL_TIME, MathUtil.clamp(Utils.getNoNil(getXMLInt(xmlFile, key.."general.time"), self[AtbSettings.SETTING.GENERAL_TIME]), 200, 2000))

        -- store
        self:setValue(AtbSettings.SETTING.STORE_ACTIVE, Utils.getNoNil(getXMLBool(xmlFile, key.."store.active"), self[AtbSettings.SETTING.STORE_ACTIVE]))
        self:setValue(AtbSettings.SETTING.STORE_LEASING, Utils.getNoNil(getXMLBool(xmlFile, key.."store.leasing"), self[AtbSettings.SETTING.STORE_LEASING]))
        self:setValue(AtbSettings.SETTING.STORE_OPEN_TIME, MathUtil.clamp(Utils.getNoNil(getXMLInt(xmlFile, key.."store.open"), self[AtbSettings.SETTING.STORE_OPEN_TIME]), AtbSettings.MIN_TIME, AtbSettings.MAX_TIME))
        self:setValue(AtbSettings.SETTING.STORE_CLOSE_TIME, MathUtil.clamp(Utils.getNoNil(getXMLInt(xmlFile, key.."store.close"), self[AtbSettings.SETTING.STORE_CLOSE_TIME]), AtbSettings.MIN_TIME, AtbSettings.MAX_TIME))

        -- farms
        self:setValue(AtbSettings.SETTING.FARM_LOAN_MIN, MathUtil.clamp(Utils.getNoNil(getXMLInt(xmlFile, key.."farms.loanMin"), self[AtbSettings.SETTING.FARM_LOAN_MIN]), 0, AtbSettings.MAX_MONEY))
        self:setValue(AtbSettings.SETTING.FARM_LOAN_MAX, MathUtil.clamp(Utils.getNoNil(getXMLInt(xmlFile, key.."farms.loanMax"), self[AtbSettings.SETTING.FARM_LOAN_MAX]), 0, AtbSettings.MAX_MONEY))

        -- missions
        self:setValue(AtbSettings.SETTING.MISSIONS_CONTRACT_LIMIT, MathUtil.clamp(Utils.getNoNil(getXMLInt(xmlFile, key.."missions.limit"), self[AtbSettings.SETTING.MISSIONS_CONTRACT_LIMIT]), 0, AtbSettings.MISSIONS_COUNT_MAX))
        self:setValue(AtbSettings.SETTING.MISSIONS_LEASING, Utils.getNoNil(getXMLBool(xmlFile, key.."missions.leasing"), self[AtbSettings.SETTING.MISSIONS_LEASING]))


        -- self.notifyOnChange = true
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
        local key = "AdminToolBox."

        -- general
        setXMLInt(xmlFile, key.."ai.workers", self[AtbSettings.SETTING.AI_WORKER_COUNT])
        setXMLBool(xmlFile, key.."general.sleep", self[AtbSettings.SETTING.GENERAL_SLEEP])
        setXMLBool(xmlFile, key.."general.strengh", self[AtbSettings.SETTING.GENERAL_STRENGH])
        setXMLBool(xmlFile, key.."general.vehicleTabbing", self[AtbSettings.SETTING.VEHICLE_TABBING])
		-- setXMLInt(xmlFile, key.."general.time", self[AtbSettings.SETTING.GENERAL_TIME])

        -- store
        setXMLBool(xmlFile, key.."store.active", self[AtbSettings.SETTING.STORE_ACTIVE])
        setXMLBool(xmlFile, key.."store.leasing", self[AtbSettings.SETTING.STORE_LEASING])
		setXMLInt(xmlFile, key.."store.open", self[AtbSettings.SETTING.STORE_OPEN_TIME])
		setXMLInt(xmlFile, key.."store.close", self[AtbSettings.SETTING.STORE_CLOSE_TIME])

        -- farms
        setXMLInt(xmlFile, key.."farms.loanMin", self[AtbSettings.SETTING.FARM_LOAN_MIN])
        setXMLInt(xmlFile, key.."farms.loanMax", self[AtbSettings.SETTING.FARM_LOAN_MAX])

        -- missions
        setXMLInt(xmlFile, key.."missions.limit", self[AtbSettings.SETTING.MISSIONS_CONTRACT_LIMIT])
        setXMLBool(xmlFile, key.."missions.leasing", self[AtbSettings.SETTING.MISSIONS_LEASING])

        -- save file
        saveXMLFile(xmlFile)
    end
end

function AtbSettings:setXMLValue(xmlFile, func, xPath, value)
	if value ~= nil then
		func(xmlFile, xPath, value)
	end
end
