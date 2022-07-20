math.randomseed(os.time() .. math.random(10000, 99999))
local Drugs = {}

MySQL.ready(function()
    MySQL.Async.fetchAll("SELECT * FROM drugs", {}, function(drugs)
        for i, object in each(drugs) do
            Drugs[object.id] = {
                owner = object.char_id,
                data = json.decode(object.data)
            }
        end

        Citizen.CreateThread(function()
            Citizen.Wait(500)
            createDrugObjects()
        end)
    end)
end)

function createDrugObjects()
    for objectId, object in pairs(Drugs) do
        CreateDrugObject(objectId, object)
    end
end

function CreateDrugObject(objectId, object)
    if not object.entity then
        local objectPos = object.data.Position

        local objectHash = GetHashKey(Config.Objects[object.data.Item])
        if object.data.Stage then
            objectHash = GetHashKey(Config.Objects[object.data.Item][object.data.Stage])
        end

        local objectModel = Citizen.InvokeNative(GetHashKey("CREATE_OBJECT_NO_OFFSET"), objectHash, objectPos.x,
            objectPos.y, objectPos.z - 0.99, 0.0)

        while not DoesEntityExist(objectModel) do
            Wait(0)
        end

        SetEntityHeading(objectModel, objectPos.h or 0.0)

        if object.data.Instance then
            SetEntityRoutingBucket(objectModel, exports.instance:createInstanceIfNotExists(object.data.Instance))
        end

        FreezeEntityPosition(objectModel, true)
        Drugs[objectId].entity = objectModel

        setEntityStateBags(objectId, object.data, objectModel)
    end
end

AddEventHandler("onResourceStop", function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        for objectId, object in pairs(Drugs) do
            if object.entity then
                if DoesEntityExist(object.entity) then
                    DeleteEntity(object.entity)
                end

                Drugs[objectId].entity = nil
            end
        end

        saveAllDrugData()
    end
end)

RegisterNetEvent("drugs:collectObject")
AddEventHandler("drugs:collectObject", function(objectId)
    local client = source

    if Drugs[objectId] then
        local plantPos = Drugs[objectId].data.Position
        local playerCoords = GetEntityCoords(GetPlayerPed(client))
        local isInSameInstance = true

        if Drugs[objectId].entity and GetEntityRoutingBucket(Drugs[objectId].entity) ~= GetPlayerRoutingBucket(client) then
            isInSameInstance = false
        end

        if #(playerCoords - vec3(plantPos.x, plantPos.y, plantPos.z)) < 2.5 and isInSameInstance then
            if Drugs[objectId].data.Percent >= 98.0 then
                collectItems(client, Drugs[objectId].data)

                if Drugs[objectId].entity then
                    DeleteEntity(Drugs[objectId].entity)
                end

                Drugs[objectId] = nil
                MySQL.Async.execute("DELETE FROM drugs WHERE id = @id", {
                    ["@id"] = objectId
                })

                TriggerClientEvent("notify:display", client, {
                    type = "success",
                    title = "Chyba",
                    text = "Uklidil jsi objekt",
                    icon = "fas fa-prescription-bottle",
                    length = 3500
                })
            else
                TriggerClientEvent("notify:display", client, {
                    type = "error",
                    title = "Chyba",
                    text = "Objekt ještě není připravený!",
                    icon = "fas fa-prescription-bottle",
                    length = 3500
                })
            end
        else
            TriggerClientEvent("notify:display", client, {
                type = "error",
                title = "Chyba",
                text = "Jsi od objektu příliš daleko!",
                icon = "fas fa-prescription-bottle",
                length = 3500
            })
        end
    end
end)

function collectItems(player, objectData)
    local loot = {}

    if objectData.Item == "methtable" then
        table.insert(loot, {
            Item = "methtable",
            Count = 1
        })
        table.insert(loot, {
            Item = "methslush",
            Count = math.ceil(math.random(math.ceil(objectData.Quality / 80), math.ceil(objectData.Quality / 30)))
        })
    elseif objectData.Item == "cokeseed" then
        table.insert(loot, {
            Item = "cocaplant",
            Count = 50
        })
        table.insert(loot, {
            Item = "cokeseed",
            Count = math.random(1, 2) -- TO DO
        })
    elseif objectData.Item == "tray_meth" then
        table.insert(loot, {
            Item = "tray_methdryed",
            Count = 1
        })
    end

    for i, toAdd in each(loot) do
        if toAdd.Count > 0 then
            exports.inventory:forceAddPlayerItem(player, toAdd.Item, toAdd.Count, {})
        else
            exports.inventory:forceAddPlayerItem(player, toAdd.Item, 1, {})
        end
    end
end

RegisterNetEvent("drugs:destroyObject")
AddEventHandler("drugs:destroyObject", function(objectId)
    local client = source

    if Drugs[objectId] then
        local plantPos = Drugs[objectId].data.Position
        local playerCoords = GetEntityCoords(GetPlayerPed(client))
        local isInSameInstance = true

        if Drugs[objectId].entity and GetEntityRoutingBucket(Drugs[objectId].entity) ~= GetPlayerRoutingBucket(client) then
            isInSameInstance = false
        end

        if #(playerCoords - vec3(plantPos.x, plantPos.y, plantPos.z)) < 2.5 and isInSameInstance then
            if Drugs[objectId].entity then
                DeleteEntity(Drugs[objectId].entity)
            end

            exports.inventory:forceAddPlayerItem(client, Drugs[objectId].data.Item, 1, {})

            Drugs[objectId] = nil
            MySQL.Async.execute("DELETE FROM drugs WHERE id = @id", {
                ["@id"] = objectId
            })
        else
            TriggerClientEvent("notify:display", client, {
                type = "error",
                title = "Chyba",
                text = "Jsi od objektu příliš daleko!",
                icon = "fas fa-prescription-bottle",
                length = 3500
            })
        end
    end
end)

RegisterNetEvent("drugs:newObject")
AddEventHandler("drugs:newObject", function(objectId, objectData)
    local client = source
    local canBePlaced = true
    local objectPos = vec3(objectData.data.Position.x, objectData.data.Position.y, objectData.data.Position.z)

    for objectId, objectCurrentData in pairs(Drugs) do
        if objectCurrentData.data.Instance == objectData.data.Instance then
            local objectCurrentPos = vec3(objectCurrentData.data.Position.x, objectCurrentData.data.Position.y,
                objectCurrentData.data.Position.z)
            if #(objectCurrentPos - objectPos) < 2.0 then
                canBePlaced = false
                break
            end
        end
    end

    if canBePlaced then
        local removeItem = exports.inventory:removePlayerItem(client, objectData.data.Item, 1, {})

        if removeItem == "done" then
            Drugs[objectId] = objectData

            MySQL.Async.execute("INSERT INTO drugs VALUES (@id, @char_id, @data)", {
                ["@id"] = objectId,
                ["@char_id"] = objectData.owner,
                ["@data"] = json.encode(objectData.data)
            })

            CreateDrugObject(objectId, objectData)
        end
    else
        TriggerClientEvent("notify:display", client, {
            type = "error",
            title = "Chyba",
            text = "Tak blízko sebe nemůžeš dávat věci!",
            icon = "fas fa-prescription-bottle",
            length = 3500
        })
    end
end)

RegisterNetEvent("inventory:usedItem")
AddEventHandler("inventory:usedItem", function(itemName, slot, data)
    local client = source

    local itemTemplate = {}
    itemTemplate.ObjectID = os.time() .. math.random(math.random(10000, 99999))
    if itemName == "cokeseed" then
        itemTemplate.Item = "cokeseed"
        itemTemplate.Percent = 0.0
    elseif itemName == "tray_meth" then
        itemTemplate.Item = itemName
        itemTemplate.Percent = 0.0
    elseif itemName == "methtable" then
        itemTemplate.Item = "methtable"
        itemTemplate.Percent = 0.0
        itemTemplate.Quality = 0.0
        itemTemplate.Mix = 0.0
        itemTemplate.Battery = 0.0
    elseif itemName == "methmix" or itemName == "lithiumbattery" then
        if GetVehiclePedIsIn(GetPlayerPed(client)) == 0 then
            TriggerClientEvent("drugs:useItem", client, itemName == "methmix" and "Mix" or "Battery", itemName)
        else
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "warning",
                args = {"Tento předmět nelze použít ve vozidle!"}
            })
        end
    end

    if itemTemplate and itemTemplate.Item then
        if GetVehiclePedIsIn(GetPlayerPed(client)) == 0 then
            TriggerClientEvent("drugs:itemUsed", client, itemTemplate)
        else
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "warning",
                args = {"Tento předmět nelze použít ve vozidle!"}
            })
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000)

        for objectId, objectData in pairs(Drugs) do
            --- DRAINING
            local objectItem = objectData.data.Item
            if ServerConfig.DrainSpeeds[objectItem] then
                for target, drainSpeed in pairs(ServerConfig.DrainSpeeds[objectItem]) do
                    if target ~= "Quality" then
                        objectData.data[target] = math.max(0.0, objectData.data[target] - drainSpeed)
                    end
                end
            end

            local gainSpeeds = ServerConfig.GainSpeeds[objectItem]
            if objectItem == "tray_meth" or objectItem == "cokeseed" then
                objectData.data.Percent = math.min(100.0, objectData.data.Percent + (gainSpeeds.Percent * 1.2))
            elseif objectItem == "methtable" then
                if objectData.data.Battery > 5.0 then
                    if objectData.data.Mix > 80.0 then
                        objectData.data.Quality = math.min(100.0, objectData.data.Quality + (gainSpeeds.Quality * 2))
                        objectData.data.Percent = math.min(100.0, objectData.data.Percent + (gainSpeeds.Percent * 1.5))
                    elseif objectData.data.Mix > 55 then
                        objectData.data.Quality = math.min(100.0, objectData.data.Quality + (gainSpeeds.Quality / 1.5))
                        objectData.data.Percent = math.min(100.0, objectData.data.Percent + gainSpeeds.Percent * 1.2)
                    elseif objectData.data.Mix > 20 then
                        objectData.data.Quality = math.min(100.0, objectData.data.Quality + (gainSpeeds.Quality / 2.0))
                        objectData.data.Percent = math.min(100.0, objectData.data.Percent + gainSpeeds.Percent)
                    elseif objectData.data.Mix > 10 then
                        objectData.data.Percent = math.min(100.0, objectData.data.Percent + (gainSpeeds.Percent / 2))
                    else
                        objectData.data.Percent = math.min(100.0, objectData.data.Percent + (gainSpeeds.Percent / 4))
                    end
                end

                local updatedData = objectData
                if updatedData.data.Mix + 20.0 < updatedData.data.Quality and updatedData.data.Percent <= 99.8 then
                    objectData.data.Quality = math.max(0.0, objectData.data.Quality -
                        ServerConfig.DrainSpeeds[objectItem].Quality)
                end
            end

            --- DRAINING

            if objectData.data.Stage and type(Config.Objects[objectData.data.Item]) == "table" then
                local stageCount = #Config.Objects[objectData.data.Item]
                local divider = 95.0 / stageCount
                local targetStage = math.max(1, math.floor(objectData.data.Percent / divider))

                if objectData.data.Stage ~= math.min(targetStage, stageCount) then
                    if objectData.entity then
                        if DoesEntityExist(objectData.entity) then
                            DeleteEntity(objectData.entity)
                        end

                        Drugs[objectId].entity = nil
                    end

                    objectData.data.Stage = math.min(targetStage, stageCount)
                    CreateDrugObject(objectId, Drugs[objectId])
                end
            end

            if objectData.entity then
                if DoesEntityExist(objectData.entity) then
                    setEntityStateBags(objectId, objectData.data, objectData.entity)

                    local plantPos = objectData.data.Position
                    SetEntityCoords(objectData.entity, plantPos.x, plantPos.y, plantPos.z - 0.99)
                    FreezeEntityPosition(objectData.entity, true)
                else
                    Drugs[objectId].entity = nil
                    CreateDrugObject(objectId, Drugs[objectId])
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(600000)
        local queries = {}

        for objectId, objectData in pairs(Drugs) do
            table.insert(queries, {
                query = "UPDATE `drugs` SET `data` = :data WHERE id = :id",
                values = {
                    id = objectId,
                    data = json.encode(objectData.data)
                }
            })
        end

        exports.oxmysql:transaction(queries)
    end
end)

RegisterNetEvent("drugs:useItem")
AddEventHandler("drugs:useItem", function(objectId, type, itemName, quality)
    local client = source

    if Drugs[objectId] then
        local removeItem = exports.inventory:removePlayerItem(client, itemName, 1, {})
        if removeItem == "done" then
            if Config.Items[itemName] then
                Drugs[objectId].data[type] = Drugs[objectId].data[type] + Config.Items[itemName].Add
                if Drugs[objectId].data[type] > 100.0 then
                    Drugs[objectId].data[type] = 100.0
                end
            end

            local objectData = Drugs[objectId]
            if objectData.entity then
                setEntityStateBags(objectId, objectData.data, objectData.entity)
            end

            Wait(250)
            TriggerClientEvent("drugs:actionDone", client)
        end
    end
end)

local savedBeforeRestart = false

AddEventHandler("txAdmin:events:scheduledRestart", function(eventData)
    if savedBeforeRestart then
        return
    end

    savedBeforeRestart = true

    if eventData.secondsRemaining <= 120 then
        saveAllDrugData()
    end
end)

function saveAllDrugData()
    local queries = {}

    for objectId, objectData in pairs(Drugs) do
        table.insert(queries, {
            query = "UPDATE `drugs` SET `data` = :data WHERE id = :id",
            values = {
                id = objectId,
                data = json.encode(objectData.data)
            }
        })
    end

    exports.oxmysql:transaction(queries)
end

function setEntityStateBags(objectId, objectData, entity)
    local targetEntity = entity
    if Drugs[objectId].entity then
        targetEntity = Drugs[objectId].entity
    end

    local objectEntity = Entity(targetEntity)
    if objectData.Item == "methtable" then
        objectEntity.state:set("DrugData", {
            Id = objectId,
            Item = objectData.Item,
            Quality = objectData.Quality,
            Percent = objectData.Percent,
            Mix = objectData.Mix,
            Battery = objectData.Battery
        }, true)
    elseif objectData.Item == "tray_meth" then
        objectEntity.state:set("DrugData", {
            Id = objectId,
            Item = objectData.Item,
            Percent = objectData.Percent,
            Stage = objectData.Stage
        }, true)
    elseif objectData.Item == "cokeseed" then
        objectEntity.state:set("DrugData", {
            Id = objectId,
            Item = objectData.Item,
            Percent = objectData.Percent,
            Quality = objectData.Quality,
            Water = objectData.Water,
            Fertilizer = objectData.Fertilizer
        }, true)
    end
end

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

RegisterNetEvent("drugs:usePack")
AddEventHandler("drugs:usePack", function(itemName, data, slot)
    local client = source
    if not string.find(itemName, "super_pills") then
        return
    end
    local newAmount = data.amount - 1
    local itemRemoved = exports.inventory:removePlayerItem(client, itemName, 1, {
        id = data.id
    }, slot)
    if itemRemoved then
        exports.inventory:forceAddPlayerItem(client, itemName, 1, {
            id = itemName .. "-" .. newAmount,
            amount = newAmount,
            label = "Zbývá: " .. newAmount .. " pilulek"
        })
    end
end)
