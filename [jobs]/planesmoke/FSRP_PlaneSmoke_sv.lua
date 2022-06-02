local PlayerSmokeSettings = {}

RegisterNetEvent('JM36-FSRP:PlaneSmokeSettingsUpdate')
AddEventHandler('JM36-FSRP:PlaneSmokeSettingsUpdate', function(Data)
	local src = source
	PlayerSmokeSettings[src] = Data
	PlayerSmokeSettings[src][6] = NetworkGetNetworkIdFromEntity(GetPlayerPed(src))
	PlayerSmokeSettings[src][7] = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(src)))
	TriggerClientEvent('JM36-FSRP:PlaneSmokeSettingsUpdate', -1, PlayerSmokeSettings)
end)

AddEventHandler('playerDropped', function(reason)
	local src = tonumber(source)
	PlayerSmokeSettings[src] = nil
	TriggerClientEvent('JM36-FSRP:PlaneSmokeSettingsUpdate', -1, PlayerSmokeSettings)
end)