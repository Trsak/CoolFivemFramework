RegisterNetEvent("documents:requestNewDocument")
AddEventHandler(
    "documents:requestNewDocument",
    function(document, data)
        local _source = source
        local charId = exports.data:getCharVar(_source, "id")

        local removed = exports.inventory:removePlayerItem(_source, "cash", Config.Cost[document], {})
        local itemData = {id = charId}
        if removed == "done" then
            if document == "newlicense" then
                removedItem = exports.inventory:removePlayerItem(_source, "license", 1, itemData)
            elseif document == "newid" then
                removedItem = exports.inventory:removePlayerItem(_source, "idcard", 1, itemData)
            elseif document == "getcarkeys" then
                removedItem = "done"
            end
        end
        if removedItem ~= "done" then
            removedItem = "done"
        end

        TriggerClientEvent("documents:requestNewDocument", _source, document, removed, removedItem, data)
    end
)

RegisterNetEvent("documents:takeNewDocument")
AddEventHandler(
    "documents:takeNewDocument",
    function(documents)
        local _source = source
        local charId = exports.data:getCharVar(_source, "id")

        for key, value in pairs(documents) do
            if key == "newlicense" then
                local data = exports.license:makeLicenseCard(charId, _source)
                if data ~= "noDocument" then
                    documents[key] = exports.inventory:addPlayerItem(_source, "license", 1, data)
                else
                    documents[key] = "Nemáte žádné řidičské oprávnění"
                end
            elseif key == "newid" then
                documents[key] =
                    exports.inventory:addPlayerItem(
                    _source,
                    "idcard",
                    1,
                    {
                        id = charId,
                        label = exports.data:getCharVar(_source, "firstname") ..
                            " " ..
                                exports.data:getCharVar(_source, "lastname") ..
                                    "<br>" .. exports.data:getCharVar(_source, "birth")
                    }
                )
            elseif key == "getcarkeys" then
                documents[key] =
                    exports.inventory:addPlayerItem(
                    _source,
                    "car_keys",
                    1,
                    {
                        id = documents[key],
                        spz = documents[key],
                        label = documents[key]
                    }
                )
            end
        end

        TriggerClientEvent("documents:takeNewDocument", _source, documents)
    end
)

RegisterNetEvent("documents:ownedVehicles")
AddEventHandler(
    "documents:ownedVehicles",
    function()
        local _source = source
        local charId = exports.data:getCharVar(_source, "id")

        local ownedVehicles = exports.base_vehicles:getOwnedVehicles(charId, _source)

        TriggerClientEvent("documents:ownedVehicles", _source, ownedVehicles)
    end
)

RegisterNetEvent("documents:changeOwner")
AddEventHandler(
    "documents:changeOwner",
    function(ownerType, newOwner, vehPlate)
        local _source = source
        local vehicle = exports.base_vehicles:getVehicle(vehPlate)
        local hasCash = exports.inventory:removePlayerItem(_source, "cash", 240, {})
        if hasCash == "done" then
            TriggerClientEvent(
                "notify:display",
                _source,
                {
                    type = "info",
                    title = "Žádost o přepis vozu",
                    text = "Vozidlo úspěšně přepsáno!",
                    icon = "fas fa-car",
                    length = 3500
                }
            )
            
            local reowned = false
            local discordLabel = ""
            if ownerType == "person" then 
                local targetChar = exports.data:getCharNameById(exports.data:getCharVar(newOwner, "id"))
                
                if (type(vehicle.owner) == "number" and vehicle.owner == exports.data:getCharVar(_source, "id")) or type(vehicle.owner) == "table" then
                    reowned = true
                    discordLabel = " na hráče " .. GetPlayerName(newOwner) .. " s postavou " .. targetChar
                end  
            else
                if newOwner.job ~= "police" and newOwner.job ~= "medic" then
                    discordLabel = " na frakci " .. exports.base_jobs:getJobVar(newOwner.job, "label")
                else
                    local type =
                        newOwner.type == "police" and "Státní bezpečností složky (LSPD, LSSD a SAHP)" or
                        "Státní záchranné složky (EMS, LSFD)"

                    discordLabel = " na " .. type
                end

                reowned = true
            end

            if reowned then 
                exports.logs:sendToDiscord(
                    {
                        channel = "veh-transfer",
                        title = "Přepis vozidla",
                        description = "Přepsal vozidlo s SPZ: " ..
                            vehPlate .. discordLabel,
                        color = "34749"
                    },
                    _source
                )
                exports.base_vehicles:changeVehicleOwner(ownerType, newOwner, vehPlate)
            else 
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "error",
                        title = "Přepis vozidla",
                        text = "Nejste oprávněn vozidlo přepsat!",
                        icon = "fas fa-car",
                        length = 3000
                    }
                )
            end
        else
            TriggerClientEvent(
                "notify:display",
                _source,
                {
                    type = "error",
                    title = "Přepis vozidla",
                    text = "Nemáte dostatek hotovosti!",
                    icon = "fas fa-car",
                    length = 3000
                }
            )
        end
    end
)
