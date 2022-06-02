RegisterNetEvent("inventory:usedItem")
AddEventHandler(
	"inventory:usedItem",
	function(itemName, slot, data)
		local _source = source

		if itemName == "boombox" then
			if GetVehiclePedIsIn(GetPlayerPed(_source), false) == 0 then
				local removeResult = exports.inventory:removePlayerItem(_source, itemName, 1, data, slot)
				if removeResult == "done" then
					TriggerClientEvent("boombox:place", _source)
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

RegisterNetEvent("boombox:takeFromGround")
AddEventHandler(
	"boombox:takeFromGround",
	function()
		local _source = source
		exports.inventory:addPlayerItem(_source, "boombox", 1, {})
	end
)
