AtbSettings = {
    -- Settings
    AI_WORKER_COUNT = "aiWorkerCount",
    GENERAL_SLEEP = "generalSleep",
    VEHICLE_TABBING = "generalVehicleTabbing",
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

    -- Defaults
    MAX_MONEY = 999999999,
    MIN_TIME = 0,
    MAX_TIME = 24,
    WORKERS_DEFAULT = 10,
    WORKERS_MAX = 20,
    MISSIONS_COUNT_DEFAULT = 3,
    MISSIONS_COUNT_MAX = 10,

    -- Types
    TYPE_CHECK = "check",
    TYPE_MULTI = "multi",
    TYPE_TIME = "time",
    TYPE_NUMERIC = "numeric",
}

local AtbSettings_mt = Class(AtbSettings)


function AtbSettings.new(customMt)
    local self = setmetatable({}, customMt or AtbSettings_mt)

    -- general
    self[AtbSettings.AI_WORKER_COUNT] = AtbSettings.WORKERS_DEFAULT
    self[AtbSettings.GENERAL_SLEEP] = true
    self[AtbSettings.VEHICLE_TABBING] = true

    -- store
    self[AtbSettings.STORE_ACTIVE] = true
    self[AtbSettings.STORE_OPEN_TIME] = AtbSettings.MIN_TIME
    self[AtbSettings.STORE_CLOSE_TIME] = AtbSettings.MAX_TIME
    self[AtbSettings.STORE_LEASING] = true

    -- farms
    self[AtbSettings.FARM_LOAN_MIN] = 500000
    self[AtbSettings.FARM_LOAN_MAX] = 3000000

    -- missions
    self[AtbSettings.MISSIONS_CONTRACT_LIMIT] = AtbSettings.MISSIONS_COUNT_DEFAULT
    self[AtbSettings.MISSIONS_LEASING] = true

    self.printedSettingsChanges = {}
    self.xmlKey = "AdminToolBox"

    return self
end

function AtbSettings:getValue(name)
    if name == nil then
        Logging.error("AtbSetting %s missing or nil!", name)
        printCallstack()

        return false
    end

    return self[name]
end

function AtbSettings:setValue(name, value, noEventSend)
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

    SaveAtbSettingsEvent.sendEvent(noEventSend)
    -- Logging.info("Savegame Setting 'stonesEnabled': %s", isEnabled)

    return true
end

function AtbSettings:loadFromXML(xmlFile)
    if xmlFile ~= nil then
        local key = self.xmlKey
        -- general
        self:setValue(AtbSettings.AI_WORKER_COUNT,
            MathUtil.clamp(
                Utils.getNoNil(getXMLInt(xmlFile, key .. ".ai.workers"), self[AtbSettings.AI_WORKER_COUNT]), 0,
                AtbSettings.WORKERS_MAX), true)
        self:setValue(AtbSettings.GENERAL_SLEEP, Utils.getNoNil(getXMLBool(xmlFile, key .. ".general.sleep"),
            self[AtbSettings.GENERAL_SLEEP]), true)
        self:setValue(AtbSettings.VEHICLE_TABBING, Utils.getNoNil(
            getXMLBool(xmlFile, key .. ".general.vehicleTabbing"), self[AtbSettings.VEHICLE_TABBING]), true)

        -- store
        self:setValue(AtbSettings.STORE_ACTIVE, Utils.getNoNil(getXMLBool(xmlFile, key .. ".store.active"),
            self[AtbSettings.STORE_ACTIVE]), true)
        self:setValue(AtbSettings.STORE_LEASING, Utils.getNoNil(getXMLBool(xmlFile, key .. ".store.leasing"),
            self[AtbSettings.STORE_LEASING]), true)
        self:setValue(AtbSettings.STORE_OPEN_TIME,
            MathUtil.clamp(
                Utils.getNoNil(getXMLInt(xmlFile, key .. ".store.open"), self[AtbSettings.STORE_OPEN_TIME]),
                AtbSettings.MIN_TIME, AtbSettings.MAX_TIME), true)
        self:setValue(AtbSettings.STORE_CLOSE_TIME,
            MathUtil.clamp(
                Utils.getNoNil(getXMLInt(xmlFile, key .. ".store.close"), self[AtbSettings.STORE_CLOSE_TIME]),
                AtbSettings.MIN_TIME, AtbSettings.MAX_TIME), true)

        -- farms
        self:setValue(AtbSettings.FARM_LOAN_MIN,
            MathUtil.clamp(
                Utils.getNoNil(getXMLInt(xmlFile, key .. ".farms.loanMin"), self[AtbSettings.FARM_LOAN_MIN]), 0,
                AtbSettings.MAX_MONEY), true)
        self:setValue(AtbSettings.FARM_LOAN_MAX,
            MathUtil.clamp(
                Utils.getNoNil(getXMLInt(xmlFile, key .. ".farms.loanMax"), self[AtbSettings.FARM_LOAN_MAX]), 0,
                AtbSettings.MAX_MONEY), true)

        -- missions
        self:setValue(AtbSettings.MISSIONS_CONTRACT_LIMIT,
            MathUtil.clamp(Utils.getNoNil(getXMLInt(xmlFile, key .. ".missions.limit"),
                self[AtbSettings.MISSIONS_CONTRACT_LIMIT]), 0, AtbSettings.MISSIONS_COUNT_MAX), true)
        self:setValue(AtbSettings.MISSIONS_LEASING, Utils.getNoNil(
            getXMLBool(xmlFile, key .. ".missions.leasing"), self[AtbSettings.MISSIONS_LEASING]), true)

        -- Broadcast loaded settings
        SaveAtbSettingsEvent.sendEvent()
    end
end

function AtbSettings:saveToXMLFile()
    self:delete()
    local xmlFile = createXMLFile("AdminToolBoxXML", g_atb.xmlPath, "AdminToolBox")
    self.xmlFile = xmlFile
    local key = self.xmlKey

    -- general
    setXMLInt(xmlFile, key .. ".ai.workers", self[AtbSettings.AI_WORKER_COUNT])
    setXMLBool(xmlFile, key .. ".general.sleep", self[AtbSettings.GENERAL_SLEEP])
    setXMLBool(xmlFile, key .. ".general.vehicleTabbing", self[AtbSettings.VEHICLE_TABBING])

    -- store
    setXMLBool(xmlFile, key .. ".store.active", self[AtbSettings.STORE_ACTIVE])
    setXMLBool(xmlFile, key .. ".store.leasing", self[AtbSettings.STORE_LEASING])
    setXMLInt(xmlFile, key .. ".store.open", self[AtbSettings.STORE_OPEN_TIME])
    setXMLInt(xmlFile, key .. ".store.close", self[AtbSettings.STORE_CLOSE_TIME])

    -- farms
    setXMLInt(xmlFile, key .. ".farms.loanMin", self[AtbSettings.FARM_LOAN_MIN])
    setXMLInt(xmlFile, key .. ".farms.loanMax", self[AtbSettings.FARM_LOAN_MAX])

    -- missions
    setXMLInt(xmlFile, key .. ".missions.limit", self[AtbSettings.MISSIONS_CONTRACT_LIMIT])
    setXMLBool(xmlFile, key .. ".missions.leasing", self[AtbSettings.MISSIONS_LEASING])

    -- save file
    saveXMLFile(xmlFile)
end

function AtbSettings:delete()
	if self.xmlFile ~= nil then
		delete(self.xmlFile)
	end
end
