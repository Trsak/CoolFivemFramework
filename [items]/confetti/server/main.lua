local conffetiHash = GetHashKey("xs_prop_arena_confetti_cannon")

RegisterNetEvent("inventory:usedItem")
AddEventHandler(
	"inventory:usedItem",
	function(itemName, slot, data)
		local client = source

		if itemName == "confetti" then
			local removeResult = exports.inventory:removePlayerItem(client, itemName, 1, data, slot)
			if removeResult == "done" then
				TriggerClientEvent("confetti:use", client)
			end
		end
	end
)

RegisterNetEvent("confetti:getItemBack")
AddEventHandler(
	"confetti:getItemBack",
	function()
		local client = source
		exports.inventory:addPlayerItem(client, "confetti", 1, {})
	end
)

RegisterNetEvent("confetti:shareEffect")
AddEventHandler(
	"confetti:shareEffect",
	function(netId)
		local client = source
		local entity = NetworkGetEntityFromNetworkId(netId)
		local entityModel = GetEntityModel(entity)

		if entityModel == conffetiHash then
			TriggerClientEvent("confetti:shareEffect", -1, netId)
		else
			exports.admin:banClientForCheating(_source, "0", "Cheating", "confetti:shareEffect", "Špatný model konfet!")
		end
	end
)
