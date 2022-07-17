SaveAtbSettingsEvent = {}
local SaveAtbSettingsEvent_mt = Class(SaveAtbSettingsEvent, Event)

InitEventClass(SaveAtbSettingsEvent, "SaveAtbSettingsEvent")

function SaveAtbSettingsEvent.emptyNew()
	local self = Event.new(SaveAtbSettingsEvent_mt, NetworkNode.CHANNEL_SECONDARY)

	return self
end

function SaveAtbSettingsEvent.new()
	local self = SaveAtbSettingsEvent.emptyNew()

	return self
end

function SaveAtbSettingsEvent:readStream(streamId, connection)
	local aiWorkerCount = streamReadInt32(streamId)
	local sleepEnabled = streamReadBool(streamId)
	local vehicleTabbingEnabled = streamReadBool(streamId)
	local storeEnabled = streamReadBool(streamId)
    local storeOpenTime = streamReadInt32(streamId)
    local storeCloseTime = streamReadInt32(streamId)
	local storeLeasingEnabled = streamReadBool(streamId)
    local farmLoanMin = streamReadInt32(streamId)
    local farmLoanMax = streamReadInt32(streamId)
    local missionsContractLimit = streamReadInt32(streamId)
	local missionsLeasingEnabled = streamReadBool(streamId)

	if connection:getIsServer() or g_currentMission.userManager:getIsConnectionMasterUser(connection) then
		g_atb.settings:setValue(AtbSettings.SETTING.AI_WORKER_COUNT, aiWorkerCount, true)
		g_atb.settings:setValue(AtbSettings.SETTING.GENERAL_SLEEP, sleepEnabled, true)
		g_atb.settings:setValue(AtbSettings.SETTING.VEHICLE_TABBING, vehicleTabbingEnabled, true)
		g_atb.settings:setValue(AtbSettings.SETTING.STORE_ACTIVE, storeEnabled, true)
		g_atb.settings:setValue(AtbSettings.SETTING.STORE_OPEN_TIME, storeOpenTime, true)
		g_atb.settings:setValue(AtbSettings.SETTING.STORE_CLOSE_TIME, storeCloseTime, true)
		g_atb.settings:setValue(AtbSettings.SETTING.STORE_LEASING, storeLeasingEnabled, true)
		g_atb.settings:setValue(AtbSettings.SETTING.FARM_LOAN_MIN, farmLoanMin, true)
		g_atb.settings:setValue(AtbSettings.SETTING.FARM_LOAN_MAX, farmLoanMax, true)
		g_atb.settings:setValue(AtbSettings.SETTING.MISSIONS_CONTRACT_LIMIT, missionsContractLimit, true)
		g_atb.settings:setValue(AtbSettings.SETTING.MISSIONS_LEASING, missionsLeasingEnabled, true)

		if not connection:getIsServer() then
			g_server:broadcastEvent(self, false, connection)
		end
	end
end

function SaveAtbSettingsEvent:writeStream(streamId, connection)
	streamWriteInt32(streamId, g_atb.settings:getValue(AtbSettings.SETTING.AI_WORKER_COUNT))
	streamWriteBool(streamId, g_atb.settings:getValue(AtbSettings.SETTING.GENERAL_SLEEP))
	streamWriteBool(streamId, g_atb.settings:getValue(AtbSettings.SETTING.GENERAL_STRENGH))
	streamWriteBool(streamId, g_atb.settings:getValue(AtbSettings.SETTING.VEHICLE_TABBING))
	streamWriteBool(streamId, g_atb.settings:getValue(AtbSettings.SETTING.STORE_ACTIVE))
	streamWriteInt32(streamId, g_atb.settings:getValue(AtbSettings.SETTING.STORE_OPEN_TIME))
	streamWriteInt32(streamId, g_atb.settings:getValue(AtbSettings.SETTING.STORE_CLOSE_TIME))
	streamWriteBool(streamId, g_atb.settings:getValue(AtbSettings.SETTING.STORE_LEASING))
	streamWriteInt32(streamId, g_atb.settings:getValue(AtbSettings.SETTING.FARM_LOAN_MIN))
	streamWriteInt32(streamId, g_atb.settings:getValue(AtbSettings.SETTING.FARM_LOAN_MAX))
	streamWriteInt32(streamId, g_atb.settings:getValue(AtbSettings.SETTING.MISSIONS_CONTRACT_LIMIT))
	streamWriteBool(streamId, g_atb.settings:getValue(AtbSettings.SETTING.MISSIONS_LEASING))
end

function SaveAtbSettingsEvent:run(connection)
	print("Error: SaveAtbSettingsEvent is not allowed to be executed on a local client")
end

function SaveAtbSettingsEvent.sendEvent(noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_currentMission:getIsServer() then
			g_server:broadcastEvent(SaveAtbSettingsEvent.new(), false)
		else
			g_client:getServerConnection():sendEvent(SaveAtbSettingsEvent.new())
		end
	end
end
