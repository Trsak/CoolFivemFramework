RegisterNetEvent("inventory:usedItem")
AddEventHandler(
	"inventory:usedItem",
	function(itemName, slot, data)
		local client = source

		if itemName == "fortunecookie" then
			local removeResult = exports.inventory:removePlayerItem(client, itemName, 1, data, slot)
			if removeResult == "done" then
				TriggerClientEvent("fortunecookie:show", client)
			end
		end
	end
)