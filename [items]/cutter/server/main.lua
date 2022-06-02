RegisterNetEvent("inventory:usedItem")
AddEventHandler(
	"inventory:usedItem",
	function(itemName, slot, data)
		local _source = source

		if itemName == "cutter" then
			if GetVehiclePedIsIn(GetPlayerPed(_source), false) == 0 then
				local removeResult = exports.inventory:removePlayerItem(_source, itemName, 1, data, slot)
				if removeResult == "done" then
					TriggerClientEvent("cutter:take", _source, itemName)
				end
			else
				TriggerClientEvent(
					"chat:addMessage",
					_source,
					{
						templateId = "error",
						args = {"Nemůžeš použít tento předmět ve vozidle"}
					}
				)
			end
		end
	end
)
RegisterNetEvent("cutter:hideCutter")
AddEventHandler(
	"cutter:hideCutter",
	function()
		local _source = source

		exports.inventory:addPlayerItem(_source, "cutter", 1, {})
	end
)

RegisterNetEvent("cutter:cut")
AddEventHandler(
	"cutter:cut",
	function(vehicle, door)
		local owner = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(vehicle))
		if owner then
			TriggerClientEvent("cutter:cut", owner, vehicle, door)
		end
	end
)
RegisterNetEvent("cutter:startSparks")
AddEventHandler(
	"cutter:startSparks",
	function(netID)
		TriggerClientEvent("cutter:startSparks", -1, netID)
	end
)
RegisterNetEvent("cutter:stopSparks")
AddEventHandler(
	"cutter:stopSparks",
	function(netID)
		TriggerClientEvent("cutter:stopSparks", -1, netID)
	end
)
