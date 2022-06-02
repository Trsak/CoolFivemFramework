math.randomseed(os.time() .. math.random(1000, 9999))
local hint, location, hasPaper = "0000", nil, false
local npcHandle, npcNetId = nil, nil
local loaded = false

Citizen.CreateThread(function()
    Citizen.Wait(500)
    Citizen.SetTimeout(600000, function()
        print("[KATHRIN] Setting homeless guy as available")
        loaded, hasPaper = true, true
        if not npcHandle then
            createNpc()
        end
        while true do
            local newLocation = location
            while newLocation == location do
                for name, data in pairs(ServerConfig.Locations) do
                    if math.random(1, 100) <= 20 and location ~= data.Coords then
                        exports.logs:sendToDiscord({
                            channel = "illegal-sell",
                            title = "Kathrin",
                            description = "Objevila se na Postal Code " .. name,
                            color = "2061822"
                        })
                        newLocation = data.Coords
                        hint = data.Message
                        break
                    end
                end
                Citizen.Wait(100)
            end
            location = newLocation
            TriggerClientEvent("kathrin:sync", -1, newLocation)

            Citizen.Wait(60000 * ServerConfig.RefreshTime)
        end
    end)
end)

RegisterNetEvent("kathrin:sync")
AddEventHandler("kathrin:sync", function()
    local client = source
    if not loaded then
        return
    end
    while not location or not npcNetId do
        Citizen.Wait(5000)
    end
    TriggerClientEvent("kathrin:sync", client, location, npcNetId)
end)

function createNpc()

    local pedModel = GetHashKey("s_m_y_dealer_01")
    npcHandle = Citizen.InvokeNative(GetHashKey("CREATE_PED"), 0, pedModel, ServerConfig.NpcPosition.xyz,
        ServerConfig.NpcPosition.w)

    while not DoesEntityExist(npcHandle) do
        Wait(0)
    end

    SetEntityHeading(npcHandle, ServerConfig.NpcPosition.w)
    FreezeEntityPosition(npcHandle, true)
    SetPedResetFlag(npcHandle, 249, 1)
    SetPedConfigFlag(npcHandle, 185, true)
    SetPedConfigFlag(npcHandle, 108, true)
    SetPedConfigFlag(npcHandle, 208, true)
    TaskPlayAnim(npcHandle, "amb@world_human_drug_dealer_hard@male@base", "base", 1.0, 1.0, -1, 1, 0)

    Citizen.CreateThread(function()
        while DoesEntityExist(npcHandle) do
            Citizen.Wait(30000)
            if #(ServerConfig.NpcPosition.xyz - GetEntityCoords(npcHandle)) > 5.0 then
                FreezeEntityPosition(npcHandle, false)
                SetEntityCoords(npcHandle, ServerConfig.NpcPosition.xyz)
                SetEntityHeading(npcHandle, ServerConfig.NpcPosition.w)
                Citizen.Wait(100)
                FreezeEntityPosition(npcHandle, true)
            end
        end
        createNpc()
    end)

    npcNetId = NetworkGetNetworkIdFromEntity(npcHandle)
    while npcNetId <= 0 do
        npcNetId = NetworkGetNetworkIdFromEntity(npcHandle)
        Citizen.Wait(100)
    end

    TriggerClientEvent("kathrin:createHintGuy", -1, npcNetId)
end

RegisterNetEvent("kathrin:askForKathrin")
AddEventHandler("kathrin:askForKathrin", function()
    local client = source
    local playerCoords = GetEntityCoords(GetPlayerPed(client))
    if #(playerCoords - ServerConfig.NpcPosition.xyz) <= 50.0 then
        if hasPaper then
            hasPaper = false
            TriggerClientEvent("notify:display", client, {
                type = "success",
                title = "Chlapík",
                text = "More já fakt nic nevím.. Tumáš papírek...",
                icon = "fas fa-hand-rock",
                length = 4500
            })
            local done = exports.inventory:addPlayerItem(client, "notepad", 1, {
                id = client .. os.time() .. math.random(1000, 9999),
                text = hint,
                label = "More papír"
            })
            exports.logs:sendToDiscord({
                channel = "illegal-sell",
                title = "Kathrin",
                description = "Zeptal se na papírek!",
                color = "2061822"
            }, client)
            Citizen.SetTimeout(ServerConfig.PaperTime * 60000, function()
                hasPaper = true
            end)
        else
            TriggerClientEvent("notify:display", client, {
                type = "warning",
                title = "Chlapík",
                text = "Teď nemám papírek, někomu jsem ho už dal!",
                icon = "fas fa-hand-rock",
                length = 4500
            })
        end
    else
        exports.admin:takePlayerScreenshot(client, "Hráč se pokusil zeptat na Kathrin, ale není blízko!")
    end
end)

RegisterNetEvent("kathrin:openMenu")
AddEventHandler("kathrin:openMenu", function()
    local client = source
    local playerCoords = GetEntityCoords(GetPlayerPed(client))
    if #(playerCoords - location) <= 50.0 then
        local policeCount = exports.data:countEmployees(nil, "police", nil, true)
        if policeCount >= ServerConfig.PoliceCount then
            TriggerClientEvent("kathrin:openMenu", client)
        else
            TriggerClientEvent("notify:display", client, {
                type = "error",
                title = "Kathrin",
                text = "Nic teď nechci, jdi pryč.",
                icon = "fas fa-book-dead",
                length = 5000
            })

        end
    else
        exports.admin:takePlayerScreenshot(client, "Hráč se pokusil mluvit s Kathrin, ale není blízko!")
    end
end)

RegisterNetEvent("kathrin:askForRyan")
AddEventHandler("kathrin:askForRyan", function()
    local client = source
    local playerCoords = GetEntityCoords(GetPlayerPed(client))
    if #(playerCoords - location) <= 50.0 then
        exports.ryan:askForRyan(client)
    else
        exports.admin:takePlayerScreenshot(client, "Zeptal se na Ryan, ale není blízko!")
    end
end)

local sells = {}
RegisterNetEvent("kathrin:sell")
AddEventHandler("kathrin:sell", function(amount, itemName)
    local client = source
    if not ServerConfig.ItemsPrices[itemName] then
        exports.admin:banClientForCheating(client, "0", "Cheating", "kathrin:sell", "Hráč se pokusil prodat Kathrin něco, co nemůže!\nItem:" .. itemName)
    end

    local policeCount = exports.data:countEmployees(nil, "police", nil, true)
    if policeCount < ServerConfig.PoliceCount then
        TriggerClientEvent("notify:display", client, {
            type = "error",
            title = "Kathrin",
            text = "Nic teď nechci, jdi pryč.",
            icon = "fas fa-book-dead",
            length = 5000
        })
        return
    end

    local playerCoords = GetEntityCoords(GetPlayerPed(client))
    local distance = #(playerCoords - location)

    if distance <= 5.0 then
        if not sells[tostring(client)] then
            sells[tostring(client)] = {
                Item = itemName,
                Amount = amount,
                Current = amount,
                Price = 0
            }
        end
        local removeItem = exports.inventory:removePlayerItem(client, itemName, 1, {})
        if removeItem == "done" then
            local itemConfig = ServerConfig.ItemsPrices[itemName]
            local price = 0
            if type(itemConfig) == "table" then
                price = (math.random(itemConfig.Min, itemConfig.Max))
            else
                price = (math.random(itemConfig - 25, itemConfig + 25))
            end

            exports.inventory:forceAddPlayerItem(client, "cash", price, {})
            sells[tostring(client)].Current = sells[tostring(client)].Current - 1
            sells[tostring(client)].Price = sells[tostring(client)].Price + price

            if math.random(1, 100) <= 10 then
                TriggerEvent("outlawalert:sendAlert", {
                    Type = "illegalsell",
                    Coords = location
                })
            end

            if sells[tostring(client)].Current <= 0 then
                stopSelling(client, true)
            end
        elseif sells[tostring(client)] then
            stopSelling(client, nil, distance)

        end
    else
        stopSelling(client, nil, distance)
    end
end)

RegisterNetEvent("kathrin:stopSelling")
AddEventHandler("kathrin:stopSelling", function()
    local client = tostring(source)
    if sells[client] then
        sells[client] = nil
    end
end)

AddEventHandler("playerDropped", function(reason)
    local client = tostring(source)
    if sells[client] then
        sells[client] = nil
    end
end)

function stopSelling(client, soldAll, distance)
    local clientData = sells[tostring(client)]
    if not clientData then
        return
    end
    local itemLabel = exports.inventory:getItem(clientData.Item).label
    if soldAll or clientData.Amount - clientData.Current > 0 then
        exports.logs:sendToDiscord({
            channel = "illegal-sell",
            title = "Kathrin",
            description = "Prodal " .. (soldAll and clientData.Amount or clientData.Amount - clientData.Current) .. "x " ..
                itemLabel .. " za " .. exports.data:getFormattedCurrency(clientData.Price),
            color = "2061822"
        }, client)
    end

    sells[tostring(client)] = nil
    if soldAll then
        TriggerClientEvent("notify:display", client, {
            type = "success",
            title = "Kathrin",
            text = "Díky za obchod! Stav se zase někdy! ",
            icon = "fas fa-book-dead",
            length = 5000
        })
    elseif clientData.Amount - clientData.Current > 0 and (not distance or distance <= 5.0) then
        TriggerClientEvent("notify:display", client, {
            type = "warning",
            title = "Kathrin",
            text = "Však to nemáš!",
            icon = "fas fa-book-dead",
            length = 5000
        })
        TriggerClientEvent("kathrin:stopSell", client)
    elseif distance and distance > 5.0 then
        TriggerClientEvent("notify:display", client, {
            type = "warning",
            title = "Kathrin",
            text = "Jak mi to chceš na dálku prodávat?!",
            icon = "fas fa-book-dead",
            length = 5000
        })
        TriggerClientEvent("kathrin:stopSell", client)
    end
end

AddEventHandler("onResourceStop", function(resource)
    if (GetCurrentResourceName() == resource) then
        if npcHandle then
            if DoesEntityExist(npcHandle) then
                DeleteEntity(npcHandle)
            end

            npcHandle = nil
        end
    else
        return
    end
end)
