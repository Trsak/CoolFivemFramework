local robberies, isReady = {}, false
local npcHandle, npcNetId = nil, nil

Citizen.CreateThread(function()
    Citizen.SetTimeout(600000, function()
        print("[LOCATOR] Setting locator as available")
        isReady = true
        if not npcHandle then
            createNpc()
        end
        while true do
            local changed = false
            Citizen.Wait(120000)
            local policeCount = exports.data:countEmployees(nil, "police", nil, true)
            for houseId, data in pairs(robberies) do
                if data.Source then
                    if data.Entity and data.NetId then
                        if not DoesEntityExist(data.Entity) then
                            if GetResourceState("active_blips") == "started" then
                                exports.active_blips:remove(robberies[houseId].NetId)
                            else
                                exports.player_blips:addVeh(robberies[houseId].NetId, "crime", false, 7, true)
                                Citizen.Wait(500)
                                TriggerClientEvent("player_blips:locatorRefresh", -1)

                            end
                            TriggerClientEvent("rob_locator:vehicleIsGone", data.Source)
                            TriggerClientEvent("player_blips:locatorRefresh", -1)
                            robberies[houseId] = nil
                            changed = true
                        end
                    end
                    if not data.Entity and not data.NetId and policeCount < ServerConfig.PoliceCount then
                        TriggerClientEvent("notify:display", data.Source, {
                            type = "success",
                            title = "Lokátor",
                            text = "Zkus to někdy jindy, už tam auto není...",
                            icon = "fas fa-hand-rock",
                            length = 4500
                        })
                        robberies[houseId] = nil
                        changed = true
                    end
                end
            end
            if changed then
                TriggerClientEvent("rob_locator:sendRobberies", -1, robberies)
            end
        end
    end)
end)

AddEventHandler("txAdmin:events:scheduledRestart", function(data)
    local actualTime = tonumber(data.secondsRemaining / 60) - 3
    if actualTime <= 10 then
        isReady = false
    end
end)

RegisterNetEvent("rob_locator:askForJob")
AddEventHandler("rob_locator:askForJob", function()
    local client = source
    if exports.data:countEmployees(nil, "police", nil, true) >= ServerConfig.PoliceCount and isReady then
        if not isSourceRobberiesSource(client) then
            if tableLength(robberies) < 2 then
                local house = 0
                local try = 10
                while true do
                    house = math.random(1, tableLength(ServerConfig.Houses))
                    if not ServerConfig.Houses[house].Taken then
                        break
                    end
                    try = try - 1
                    if try <= 0 then
                        break
                    end
                    Citizen.Wait(1)
                end
                
                if try <= 0 or ServerConfig.Houses[house].Taken then
                    for i, houseData in each(ServerConfig.Houses) do
                        if not houseData.Taken then
                            house = i
                            break
                        end
                    end
                end

                if house > 0 and not ServerConfig.Houses[house].Taken then
                    TriggerClientEvent("notify:display", client, {
                        type = "success",
                        title = "Chlapík",
                        text = "Nevím co chceš, ale tady něco máš...",
                        icon = "fas fa-hand-rock",
                        length = 4500
                    })
                    local done = exports.inventory:addPlayerItem(client, "notepad", 1, {
                        id = client .. os.time(),
                        text = ServerConfig.Houses[house].Message,
                        label = "Reklamní letáček na prodej domu.."
                    })
                    ServerConfig.Houses[house].Taken = true
                    robberies[tostring(house)] = {
                        Entity = nil,
                        NetId = nil,
                        Source = client
                    }
                    Citizen.SetTimeout(3600000, function()
                        if robberies[tostring(house)] and robberies[tostring(house)].Source == client then
                            if DoesEntityExist(robberies[tostring(house)].Entity) then
                                despawnVehicle(tostring(house))
                            end
                            robberies[tostring(house)] = nil
                        end
                        Citizen.Wait(500)
                        ServerConfig.Houses[house].Taken = false
                    end)
                    TriggerClientEvent("rob_locator:sendRobberies", -1, robberies)
                    TriggerClientEvent("rob_locator:openHouse", client, house, ServerConfig.Houses[house])
                else
                    TriggerClientEvent("notify:display", client, {
                        type = "error",
                        title = "Chlapík",
                        text = "Nic nemám, táhni odsud.",
                        icon = "fas fa-hand-rock",
                        length = 3000
                    })
                end
            else
                TriggerClientEvent("notify:display", client, {
                    type = "error",
                    title = "Chlapík",
                    text = "Už jsem toho rozdal až moc...",
                    icon = "fas fa-hand-rock",
                    length = 3000
                })
            end
        else
            TriggerClientEvent("notify:display", client, {
                type = "error",
                title = "Chlapík",
                text = "Tobě už jsem něco dal, táhni odsud.",
                icon = "fas fa-hand-rock",
                length = 3000
            })
        end
    else
        TriggerClientEvent("notify:display", client, {
            type = "error",
            title = "Chlapík",
            text = "Nikdo teď nic nechce, přijď později.",
            icon = "fas fa-hand-rock",
            length = 3000
        })
    end
end)

RegisterNetEvent("rob_locator:enterHouse")
AddEventHandler("rob_locator:enterHouse", function(house)
    local client = source

    local removeResult = exports.inventory:removePlayerItem(client, "lockpick", 1, {}, nil)
    if removeResult == "done" then
        TriggerClientEvent("rob_locator:enterHouse", client, house)
    else
        TriggerClientEvent("notify:display", client, {
            type = "error",
            title = "Dveře",
            text = "Chybí ti šperhák!",
            icon = "fas fa-hand-rock",
            length = 3000
        })
    end
end)

RegisterNetEvent("rob_locator:getData")
AddEventHandler("rob_locator:getData", function()
    local client = source
    TriggerClientEvent("rob_locator:sendRobberies", client, robberies, npcNetId)
end)

RegisterNetEvent("rob_locator:spawnVehicle")
AddEventHandler("rob_locator:spawnVehicle", function(houseId)
    local client = source
    local houseId = tostring(houseId)
    if robberies[houseId] and robberies[houseId].Source == client and not robberies[houseId].Entity then
        local plate, instance = generateVehPlate(), "rob_locator_" .. houseId
        local selectedVeh = ServerConfig.Vehicles[math.random(1, #ServerConfig.Vehicles)]
        local garageType = ServerConfig.Houses[tonumber(houseId)].Type
        local coords = Config.Garages[garageType].Vehicle

        local veh, netId = exports.base_vehicles:createVehicle({
            spz = plate,
            data = {
                actualPlate = plate,
                model = selectedVeh,
                fuelLevel = 100.0
            }
        }, coords, client, true, exports.instance:createInstanceIfNotExists(instance))

        robberies[houseId].Entity = veh
        robberies[houseId].NetId = netId
        TriggerClientEvent("rob_locator:sendRobberies", -1, robberies)
    end
end)

RegisterNetEvent("rob_locator:foundKeys")
AddEventHandler("rob_locator:foundKeys", function(houseId)
    local client = source
    local houseId = tostring(houseId)
    if robberies[houseId] and robberies[houseId].Source == client and robberies[houseId].Entity and
        robberies[houseId].NetId then
        local plate = exports.data:getVehicleActualPlateNumber(robberies[houseId].Entity)
        exports.inventory:addPlayerItem(client, "car_keys", 1, {
            id = plate,
            spz = plate,
            label = "Klíče pro vozidlo s SPZ: " .. plate
        })
        TriggerClientEvent("notify:display", client, {
            type = "success",
            title = "Úspěch",
            text = "Tady klíčky dneska byly!",
            icon = "fas fa-car",
            length = 3000
        })
    end
end)

RegisterNetEvent("rob_locator:announceLocator")
AddEventHandler("rob_locator:announceLocator", function(houseId)
    local client = source
    local houseId = tostring(houseId)
    if robberies[houseId] and robberies[houseId].Source == client and robberies[houseId].Entity then
        SetEntityRoutingBucket(robberies[houseId].Entity, 0)
        exports.instance:playerQuitInstance(client)
        if GetResourceState("active_blips") == "started" then
            exports.active_blips:add(robberies[houseId].NetId, {
                coords = GetEntityCoords(robberies[houseId].Entity),
                sprite = 523,
                display = 4,
                scale = 0.7,
                colour = 76,
                isShortRange = true,
                text = "Vozidlo s lokátorem"
            }, {
                type = "police"
            })
        else
            exports.player_blips:addVeh(robberies[houseId].NetId, "crime", false, 7, false)

        end
        TriggerEvent("outlawalert:sendAlert", {
            Type = "carJack",
            Coords = ServerConfig.Houses[tonumber(houseId)].Exit.xyz,
            Title = "Krádež vozidla s lokátorem",
            Plate = exports.data:getVehicleActualPlateNumber(robberies[houseId].Entity)
        })
    end
end)

RegisterNetEvent("rob_locator:shareLocator")
AddEventHandler("rob_locator:shareLocator", function(target, houseId)
    local client = source
    local houseId = tostring(houseId)
    if robberies[houseId] and robberies[houseId].Source == client then
        TriggerClientEvent("rob_locator:shareLocator", target, houseId)
    end
end)

RegisterNetEvent("rob_locator:removeLocator")
AddEventHandler("rob_locator:removeLocator", function(houseId, status)
    local client = source
    local houseId = tostring(houseId)
    if robberies[houseId] and robberies[houseId].Source == client then
        if GetResourceState("active_blips") == "started" then
            exports.active_blips:remove(robberies[houseId].NetId)
        else
            exports.player_blips:addVeh(robberies[houseId].NetId, "crime", false, 7, true)
            Citizen.Wait(500)
            TriggerClientEvent("player_blips:locatorRefresh", -1)

        end
        Citizen.Wait(500)
        if status == "success" then
            local sellPoint = ServerConfig.SellPoints[math.random(1, #(ServerConfig.SellPoints))]
            TriggerClientEvent("rob_locator:sellPoint", client, sellPoint)
        end
    end
end)

RegisterNetEvent("rob_locator:finishTheft")
AddEventHandler("rob_locator:finishTheft", function(houseId)
    local reward = math.random(6000, 7000)
    local client = source
    local houseId = tostring(houseId)

    if robberies[houseId] and robberies[houseId].Source == client then
        local done = exports.inventory:forceAddPlayerItem(client, "cash", reward, {})
        local removed = exports.inventory:removePlayerItem(client, "car_keys", 1, {
            spz = robberies[houseId].Plate,
            id = robberies[houseId].Plate
        })
        if DoesEntityExist(robberies[houseId].Entity) then
            despawnVehicle(houseId)
        end
        Citizen.Wait(500)
        robberies[houseId] = nil
        exports.logs:sendToDiscord({
            channel = "locator",
            title = "Lokátor",
            description = "Odevzdal vozidlo a získal $" .. reward,
            color = "7601682"
        }, client)
        TriggerClientEvent("notify:display", client, {
            type = "success",
            title = "Úspěch",
            text = "Díky za auto! Tady máš " .. exports.data:getFormattedCurrency(reward),
            icon = "fas fa-car",
            length = 4500
        })
    end
end)

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function isSourceRobberiesSource(source)
    for house, data in pairs(robberies) do
        if data.Source == source then
            return tostring(house)
        end
    end
    return false
end

AddEventHandler("playerDropped", function(reason)
    local client = source
    local hasJob = isSourceRobberiesSource(client)
    if hasJob then
        if DoesEntityExist(robberies[hasJob].Entity) then
            despawnVehicle(hasJob)
        end
        Citizen.Wait(500)
        robberies[hasJob] = nil
    end
end)

function despawnVehicle(houseId)
    exports.base_vehicles:removeVehicle(robberies[houseId].Entity)
end

function generateVehPlate()
    local plate = ""
    for i = 1, 8 do
        plate = plate .. Config.PlateChars[math.random(#Config.PlateChars)]
    end

    return plate
end

AddEventHandler("onResourceStop", function(resource)
    if (GetCurrentResourceName() == resource) then
        for houseId, _ in pairs(robberies) do
            if DoesEntityExist(robberies[houseId].Entity) then
                despawnVehicle(houseId)
            end
            robberies[houseId] = nil
        end
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

function createNpc()
    local pedModel = GetHashKey("ig_joeminuteman")
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
    Citizen.CreateThread(function()
        while DoesEntityExist(npcHandle) do
            Citizen.Wait(30000)
                
            SetEntityCoords(npcHandle, ServerConfig.NpcPosition.xyz)
            SetEntityHeading(npcHandle, ServerConfig.NpcPosition.w)
        end
        createNpc()
    end)

    npcNetId = NetworkGetNetworkIdFromEntity(npcHandle)
    while npcNetId <= 0 do
        npcNetId = NetworkGetNetworkIdFromEntity(npcHandle)
        Citizen.Wait(100)
    end
    
    TriggerClientEvent("rob_locator:sendRobberies", -1, robberies, npcNetId)
end


RegisterCommand("locator", function(source)
    if source == 0 then
        local function dump(node, printing)
            local cache, stack, output = {}, {}, {}
            local depth = 1
            local output_str = "{\n"
        
            while true do
                local size = 0
                for k, v in pairs(node) do
                    size = size + 1
                end
        
                local cur_index = 1
                for k, v in pairs(node) do
                    if (cache[node] == nil) or (cur_index >= cache[node]) then
        
                        if (string.find(output_str, "}", output_str:len())) then
                            output_str = output_str .. ",\n"
                        elseif not (string.find(output_str, "\n", output_str:len())) then
                            output_str = output_str .. "\n"
                        end
        
                        -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                        table.insert(output, output_str)
                        output_str = ""
        
                        local key
                        if (type(k) == "number" or type(k) == "boolean") then
                            key = "[" .. tostring(k) .. "]"
                        else
                            key = "['" .. tostring(k) .. "']"
                        end
        
                        if (type(v) == "number" or type(v) == "boolean") then
                            output_str = output_str .. string.rep('\t', depth) .. key .. " = " .. tostring(v)
                        elseif (type(v) == "table") then
                            output_str = output_str .. string.rep('\t', depth) .. key .. " = {\n"
                            table.insert(stack, node)
                            table.insert(stack, v)
                            cache[node] = cur_index + 1
                            break
                        else
                            output_str = output_str .. string.rep('\t', depth) .. key .. " = '" .. tostring(v) .. "'"
                        end
        
                        if (cur_index == size) then
                            output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}"
                        else
                            output_str = output_str .. ","
                        end
                    else
                        -- close the table
                        if (cur_index == size) then
                            output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}"
                        end
                    end
        
                    cur_index = cur_index + 1
                end
        
                if (size == 0) then
                    output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}"
                end
        
                if (#stack > 0) then
                    node = stack[#stack]
                    stack[#stack] = nil
                    depth = cache[node] == nil and depth + 1 or depth - 1
                else
                    break
                end
            end
        
            -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
            table.insert(output, output_str)
            output_str = table.concat(output)
            if not printing then
                print(output_str)
            end
            return output_str
        end
        dump (robberies)
        if DoesEntityExist(npcHandle) then
            print ("NPC exist:", DoesEntityExist(npcHandle), "Net ID:", npcNetId, "Entity Coords:", GetEntityCoords(npcHandle))
        else
            print ("NPC exist:", "NOT SPAWNED", "Net ID:", "nil", "Entity Coords:", "0.0, 0.0, 0.0")
        end
    else
        return
    end
end)