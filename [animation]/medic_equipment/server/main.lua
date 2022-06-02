RegisterNetEvent("inventory:usedItem")
AddEventHandler(
	"inventory:usedItem",
	function(itemName, slot, data)
		local client = source

		if itemName == "wheelchair" then
			local removeWheelchair = exports.inventory:removePlayerItem(client, itemName, 1, data, slot)
			if removeWheelchair == "done" then
				local wheelchair =
					Citizen.InvokeNative(
					GetHashKey("CREATE_OBJECT_NO_OFFSET"),
					GetHashKey("prop_wheelchair_01"),
					GetEntityCoords(GetPlayerPed(client)),
					0.0
				)
				while not DoesEntityExist(wheelchair) do
					Wait(0)
				end
			end
		end
	end
)

RegisterNetEvent("medic_equipment:getItemBack")
AddEventHandler(
	"medic_equipment:getItemBack",
	function(item, count, entityId)
		local client = source

		if item == "wheelchair" and count == 1 then
			DeleteEntity(NetworkGetEntityFromNetworkId(entityId))
			exports.inventory:forceAddPlayerItem(client, "wheelchair", 1, {})
		else
			exports.admin:banClientForCheating(
				client,
				"0",
				"Cheating",
				"medic_equipment:getItemBack",
				"Hráč si pokusil dát jiný item, než vozíček!"
			)
		end
	end
)
