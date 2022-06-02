RegisterNetEvent("inventory:usedItem")
AddEventHandler("inventory:usedItem", function(itemName, slot, data)
    local _source = source

    if Config.AllowedItems[itemName] then
        if GetVehiclePedIsIn(GetPlayerPed(_source), false) == 0 then
            local removeResult = exports.inventory:removePlayerItem(_source, itemName, 1, data, slot)
            if removeResult == "done" then
                local count = 1
                if itemName == "spikestrips" then
                    count = 2
                end

                TriggerClientEvent("utility_items:place", _source, Config.AllowedItems[itemName], count)
            end
        else
            TriggerClientEvent("chat:addMessage", _source, {
                templateId = "error",
                args = {"Nemůžeš použít tento předmět ve vozidle"}
            })
        end
    end
end)

RegisterNetEvent("utility_items:takeFromGround")
AddEventHandler("utility_items:takeFromGround", function(itemName)
    local _source = source
    if Config.AllowedItems[itemName] then
        exports.inventory:addPlayerItem(_source, itemName, 1, {})
    end
end)

RegisterNetEvent("utility_items:deleteObject")
AddEventHandler("utility_items:deleteObject", function(netId, itemName)
    local client = source
	local entity = NetworkGetEntityFromNetworkId(netId)
	if DoesEntityExist(entity) and Config.AllowedItems[itemName] then
		local owner = NetworkGetEntityOwner(entity)
		if owner <= 0 then
			DeleteEntity(entity)
		else
			TriggerClientEvent("utility_items:deleteObject", owner, netId)
		end
	end
end)
