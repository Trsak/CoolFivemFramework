math.randomseed(os.time() .. math.random(10000, 99999))
local Plants = {}

MySQL.ready(
    function()
        MySQL.Async.fetchAll(
            "SELECT * FROM weed_plants",
            {},
            function(plants)
                for i, plant in each(plants) do
                    Plants[plant.plant_id] = {
                        owner = plant.char_id,
                        data = json.decode(plant.plant_data)
                    }
                end

                Citizen.CreateThread(
                    function()
                        Citizen.Wait(500)
                        createWeedObjects()
                    end
                )
            end
        )
    end
)

function createWeedObjects()
    for plantId, plant in pairs(Plants) do
        createWeedObject(plantId, plant)
    end
end

function createWeedObject(plantId, plant)
    if plant.entity == nil then
        local plantPos = plant.data.Position
        local weedPlant = Citizen.InvokeNative(GetHashKey("CREATE_OBJECT_NO_OFFSET"), GetHashKey(Config.Objects[plant.data.Stage]), plantPos.x, plantPos.y, plantPos.z - 0.99, 0.0)

        while not DoesEntityExist(weedPlant) do
            Wait(0)
        end

        if plant.data.Instance ~= nil then
            SetEntityRoutingBucket(weedPlant, exports.instance:createInstanceIfNotExists(plant.data.Instance))
        end

        FreezeEntityPosition(weedPlant, true)
        Plants[plantId].entity = weedPlant

        local weedEntity = Entity(weedPlant)
        weedEntity.state.Id = plantId
        weedEntity.state.Growth = plant.data.Growth
        weedEntity.state.Quality = plant.data.Quality
        weedEntity.state.Water = plant.data.Water
        weedEntity.state.Food = plant.data.Food
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    for plantId, plant in pairs(Plants) do
        if plant.entity ~= nil then
            if DoesEntityExist(plant.entity) then
                DeleteEntity(plant.entity)
            end

            Plants[plantId].entity = nil
        end
    end

    saveAllWeedData()
end)

RegisterNetEvent("weed:collectWeed")
AddEventHandler(
    "weed:collectWeed",
    function(plantId)
        local client = source

        if Plants[plantId] then
            local plantPos = Plants[plantId].data.Position
            local playerCoords = GetEntityCoords(GetPlayerPed(client))
            local isInSameInstance = true

            if Plants[plantId].entity and GetEntityRoutingBucket(Plants[plantId].entity) ~= GetPlayerRoutingBucket(client) then
                isInSameInstance = false
            end

            if #(playerCoords - vec3(plantPos.x, plantPos.y, plantPos.z)) < 2.5 and isInSameInstance then
                if Plants[plantId].data.Growth >= 98.0 then
                    collectItems(client, Plants[plantId])

                    if Plants[plantId].entity then
                        DeleteEntity(Plants[plantId].entity)
                    end

                    Plants[plantId] = nil
                    MySQL.Async.execute(
                        "DELETE FROM weed_plants WHERE plant_id = @plant_id",
                        {
                            ["@plant_id"] = plantId
                        }
                    )
                    exports.inventory:forceAddPlayerItem(client, "plantpot", 1, {})

                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "success",
                            title = "Chyba",
                            text = "Sklidil jsi rostlinku",
                            icon = "fas fa-cannabis",
                            length = 3500
                        }
                    )
                else
                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "error",
                            title = "Chyba",
                            text = "Rostlina ještě není dostatečně vyrostlá!",
                            icon = "fas fa-cannabis",
                            length = 3500
                        }
                    )
                end
            else
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "error",
                        title = "Chyba",
                        text = "Jsi od rostlinky příliš daleko!",
                        icon = "fas fa-cannabis",
                        length = 3500
                    }
                )
            end
        end
    end
)

function collectItems(player, plantData)
    local isBetterQuality = false
    if string.match(plantData.data.Item, "high") then
        isBetterQuality = true
    end

    if plantData.data.Gender == "Female" then
        local count = math.ceil(math.random(math.ceil(plantData.data.Quality / 8), math.ceil(plantData.data.Quality / 5)))
        if isBetterQuality then
            count = math.ceil(math.random(math.ceil(plantData.data.Quality / 6), math.ceil(plantData.data.Quality / 3)))
        end

        exports.inventory:forceAddPlayerItem(player, "cannabis", count, {})
    else
        local baseDivider = 60
        if isBetterQuality then
            baseDivider = 40
        end

        local seeds = {}

        local r = math.random(0, 5)
        if r < 3 then
            table.insert(
                seeds,
                {
                    seed = "lowgradefemaleseed",
                    count = math.ceil(
                        math.random(math.ceil(plantData.data.Quality / 4), math.ceil(plantData.data.Quality / 2)) / baseDivider
                    )
                }
            )
        elseif r == 4 then
            table.insert(
                seeds,
                {
                    seed = "highgradefemaleseed",
                    count = math.ceil(
                        math.random(math.ceil(plantData.data.Quality / 4), math.ceil(plantData.data.Quality / 2)) / baseDivider
                    )
                }
            )
        else
            if plantData.data.Quality > 95 then
                table.insert(
                    seeds,
                    {
                        seed = "highgrademaleseed",
                        count = math.ceil(
                            math.random(
                                math.ceil(plantData.data.Quality),
                                math.ceil(plantData.data.Quality * 1.5)
                            ) / (baseDivider - 10)
                        )
                    }
                )
            elseif plantData.data.Quality > 80 then
                table.insert(
                    seeds,
                    {
                        seed = "lowgrademaleseed",
                        count = math.ceil(
                            math.random(
                                math.ceil(plantData.data.Quality / 2),
                                math.ceil(plantData.data.Quality * 1.5)
                            ) / baseDivider
                        )
                    }
                )
            else
                table.insert(
                    seeds,
                    {
                        seed = "lowgrademaleseed",
                        count = math.ceil(
                            math.random(math.ceil(plantData.data.Quality / 2), math.ceil(plantData.data.Quality * 1.2)) / baseDivider
                        )
                    }
                )
            end
        end

        for i, seed in each(seeds) do
            if seed.count > 0 then
                exports.inventory:forceAddPlayerItem(player, seed.seed, seed.count, {})
            else
                exports.inventory:forceAddPlayerItem(player, seed.seed, 1, {})
            end
        end
    end
end

RegisterNetEvent("weed:destroyWeed")
AddEventHandler(
    "weed:destroyWeed",
    function(plantId)
        local client = source

        if Plants[plantId] then
            local plantPos = Plants[plantId].data.Position
            local playerCoords = GetEntityCoords(GetPlayerPed(client))
            local isInSameInstance = true

            if Plants[plantId].entity and GetEntityRoutingBucket(Plants[plantId].entity) ~= GetPlayerRoutingBucket(client) then
                isInSameInstance = false
            end

            if #(playerCoords - vec3(plantPos.x, plantPos.y, plantPos.z)) < 2.5 and isInSameInstance then
                if Plants[plantId].entity then
                    DeleteEntity(Plants[plantId].entity)
                end

                Plants[plantId] = nil
                MySQL.Async.execute(
                    "DELETE FROM weed_plants WHERE plant_id = @plant_id",
                    {
                        ["@plant_id"] = plantId
                    }
                )

                exports.inventory:forceAddPlayerItem(client, "plantpot", 1, {})
            else
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "error",
                        title = "Chyba",
                        text = "Jsi od rostlinky příliš daleko!",
                        icon = "fas fa-cannabis",
                        length = 3500
                    }
                )
            end
        end
    end
)

RegisterNetEvent("weed:newPlant")
AddEventHandler(
    "weed:newPlant",
    function(plantId, plantData)
        local client = source
        local canBePlanted = true
        local plantPos = vec3(plantData.data.Position.x, plantData.data.Position.y, plantData.data.Position.z)

        for plantCurrentId, plantCurrentData in pairs(Plants) do
            if plantCurrentData.data.Instance == plantData.data.Instance then
                local plantCurrentPos = vec3(plantCurrentData.data.Position.x, plantCurrentData.data.Position.y, plantCurrentData.data.Position.z)
                if #(plantCurrentPos - plantPos) < 2.0 then
                    canBePlanted = false
                    break
                end
            end
        end

        if canBePlanted then
            local removeSeed = exports.inventory:removePlayerItem(client, plantData.data.Item, 1, {})
            local removePlantPot = exports.inventory:removePlayerItem(client, "plantpot", 1, {})

            if removePlantPot == "done" and removeSeed == "done" then
                Plants[plantId] = plantData

                MySQL.Async.execute(
                    "INSERT INTO weed_plants VALUES (@char_id, @plant_id, @plant_data)",
                    {
                        ["@char_id"] = plantData.owner,
                        ["@plant_id"] = plantId,
                        ["@plant_data"] = json.encode(plantData.data)
                    }
                )

                createWeedObject(plantId, plantData)
            end
        else
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "error",
                    title = "Chyba",
                    text = "Tak blízko sebe rostlinky sázet nemůžeš!",
                    icon = "fas fa-cannabis",
                    length = 3500
                }
            )
        end
    end
)

RegisterNetEvent("inventory:usedItem")
AddEventHandler(
    "inventory:usedItem",
    function(itemName, slot, data)
        local _source = source
        local seedTemplate = seedTemplate()

        if itemName == "lowgrademaleseed" then
            seedTemplate.Item = "lowgrademaleseed"
            seedTemplate.Gender = "Male"
            seedTemplate.Quality = math.random(1, 100) / 10
            seedTemplate.Food = math.random(100, 200) / 10
            seedTemplate.Water = math.random(100, 200) / 10
        elseif itemName == "highgrademaleseed" then
            seedTemplate.Item = "highgrademaleseed"
            seedTemplate.Gender = "Male"
            seedTemplate.Quality = 0.2
            seedTemplate.Quality = math.random(200, 500) / 10
            seedTemplate.Food = math.random(200, 400) / 10
            seedTemplate.Water = math.random(200, 400) / 10
        elseif itemName == "lowgradefemaleseed" then
            seedTemplate.Item = "lowgradefemaleseed"
            seedTemplate.Gender = "Female"
            seedTemplate.Quality = 0.1
            seedTemplate.Quality = math.random(1, 100) / 10
            seedTemplate.Food = math.random(100, 200) / 10
            seedTemplate.Water = math.random(100, 200) / 10
        elseif itemName == "highgradefemaleseed" then
            seedTemplate.Item = "highgradefemaleseed"
            seedTemplate.Gender = "Female"
            seedTemplate.Quality = 0.2
            seedTemplate.Quality = math.random(200, 500) / 10
            seedTemplate.Food = math.random(200, 400) / 10
            seedTemplate.Water = math.random(200, 400) / 10
        elseif itemName == "wateringcan" then
            TriggerClientEvent("weed:useItem", _source, "water", 0.1, itemName)
        elseif itemName == "purifiedwater" then
            TriggerClientEvent("weed:useItem", _source, "water", 0.2, itemName)
        elseif itemName == "lowgradefert" then
            TriggerClientEvent("weed:useItem", _source, "food", 0.1, itemName)
        elseif itemName == "highgradefert" then
            TriggerClientEvent("weed:useItem", _source, "food", 0.2, itemName)
        elseif itemName == "supergradefert" then
            TriggerClientEvent("weed:useItem", _source, "food", 0.5, itemName)
        elseif itemName == "scale" or itemName == "drugbag" then
            packCannabis(_source)
        elseif itemName == "weedbag" then
            unpackWeedBag(_source, slot, data)
        elseif itemName == "joint_paper" then
            makeJoint(_source, slot, data)
        end

        if seedTemplate and seedTemplate.Item then
            local hasPlantPot = exports.inventory:checkPlayerItem(_source, "plantpot", 1, {})

            if hasPlantPot then
                TriggerClientEvent("weed:seedUsed", _source, seedTemplate)
            else
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "error",
                        title = "Chyba",
                        text = "Pro zasazení potřebuješ květináč!",
                        icon = "fas fa-cannabis",
                        length = 3500
                    }
                )
            end
        end
    end
)

function seedTemplate()
    return {
        Gender = "Female",
        Quality = 0.0,
        Growth = 0.0,
        Water = 20.0,
        Food = 20.0,
        Stage = 1,
        PlantID = os.time() .. math.random(math.random(10000, 99999))
    }
end

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(120000)

            local instancesData = {}
            for plantId, plantData in pairs(Plants) do
                Wait(0)
                if plantData.data.Instance ~= nil then
                    if instancesData[plantData.data.Instance] == nil then
                        instancesData[plantData.data.Instance] = 1
                    else
                        instancesData[plantData.data.Instance] = instancesData[plantData.data.Instance] + 1
                    end
                end

                plantData.data.Food = math.max(0.0, plantData.data.Food - Config.FoodDrainSpeed)
                plantData.data.Water = math.max(0.0, plantData.data.Water - Config.WaterDrainSpeed)

                local isBetterQuality = false
                if string.match(plantData.data.Item, "high") then
                    isBetterQuality = true
                end

                if plantData.data.Food > 80.0 and plantData.data.Water > 80.0 then
                    if isBetterQuality then
                        plantData.data.Quality = math.min(100.0, plantData.data.Quality + (Config.QualityGainSpeed * 2.5))
                        plantData.data.Growth = math.min(100.0, plantData.data.Growth + (Config.GrowthGainSpeed * 2))
                    else
                        plantData.data.Quality = math.min(100.0, plantData.data.Quality + (Config.QualityGainSpeed * 2))
                        plantData.data.Growth = math.min(100.0, plantData.data.Growth + (Config.GrowthGainSpeed * 1.5))
                    end
                elseif plantData.data.Food > 55 and plantData.data.Water > 55 then
                    if isBetterQuality then
                        plantData.data.Quality = math.min(100.0, plantData.data.Quality + Config.QualityGainSpeed)
                        plantData.data.Growth = math.min(100.0, plantData.data.Growth + Config.GrowthGainSpeed * 1.5)
                    else
                        plantData.data.Quality = math.min(100.0, plantData.data.Quality + (Config.QualityGainSpeed / 1.5))
                        plantData.data.Growth = math.min(100.0, plantData.data.Growth + Config.GrowthGainSpeed * 1.2)
                    end
                elseif plantData.data.Food > 20 and plantData.data.Water > 20 then
                    if isBetterQuality then
                        plantData.data.Quality = math.min(100.0, plantData.data.Quality + (Config.QualityGainSpeed / 1.5))
                        plantData.data.Growth = math.min(100.0, plantData.data.Growth + Config.GrowthGainSpeed * 1.2)
                    else
                        plantData.data.Quality = math.min(100.0, plantData.data.Quality + (Config.QualityGainSpeed / 2.0))
                        plantData.data.Growth = math.min(100.0, plantData.data.Growth + Config.GrowthGainSpeed)
                    end
                elseif plantData.data.Food > 10 and plantData.data.Water > 10 then
                    if isBetterQuality then
                        plantData.data.Growth = math.min(100.0, plantData.data.Growth + (Config.GrowthGainSpeed / 1.5))
                    else
                        plantData.data.Growth = math.min(100.0, plantData.data.Growth + (Config.GrowthGainSpeed / 2))
                    end
                else
                    if isBetterQuality then
                        plantData.data.Growth = math.min(100.0, plantData.data.Growth + (Config.GrowthGainSpeed / 3))
                    else
                        plantData.data.Growth = math.min(100.0, plantData.data.Growth + (Config.GrowthGainSpeed / 4))
                    end
                end

                if (plantData.data.Food + 20.0 < plantData.data.Quality or plantData.data.Water + 20.0 < plantData.data.Quality) and plantData.data.Growth <= 99.8 then
                    if isBetterQuality then
                        plantData.data.Quality = math.max(0.0, plantData.data.Quality - (Config.QualityDrainSpeed / 1.3))
                    else
                        plantData.data.Quality = math.max(0.0, plantData.data.Quality - Config.QualityDrainSpeed)
                    end
                end

                local divider = 95.0 / #Config.Objects
                local targetStage = math.max(1, math.floor(plantData.data.Growth / divider))

                if plantData.data.Stage ~= math.min(targetStage, 7) then
                    if plantData.entity then
                        if DoesEntityExist(plantData.entity) then
                            DeleteEntity(plantData.entity)
                        end

                        Plants[plantId].entity = nil
                    end

                    plantData.data.Stage = math.min(targetStage, 7)
                    createWeedObject(plantId, Plants[plantId])
                end

                if plantData.entity then
                    if DoesEntityExist(plantData.entity) then
                        local weedEntity = Entity(plantData.entity)
                        weedEntity.state.Growth = plantData.data.Growth
                        weedEntity.state.Quality = plantData.data.Quality
                        weedEntity.state.Water = plantData.data.Water
                        weedEntity.state.Food = plantData.data.Food

                        local plantPos = plantData.data.Position
                        SetEntityCoords(plantData.entity, plantPos.x, plantPos.y, plantPos.z - 0.99)
                        FreezeEntityPosition(plantData.entity, true)
                    else
                        Plants[plantId].entity = nil
                        createWeedObject(plantId, Plants[plantId])
                    end
                end
            end

            for instance, count in each(instancesData) do
                if count > Config.InteriorReport.MinimalAmount and math.random(0, 100000) <= Config.InteriorReport.ReportChancePerPlant * (count - Config.InteriorReport.MinimalAmount) then
                    local postalData, placeDetails, roomId = exports.instance:getInstancePostalCode(instance)

                    if placeDetails then
                        local text = postalData.Code
                        local canReport = true

                        if placeDetails.type == "storage1" or placeDetails.type == "storage2" or placeDetails.type == "storage3" then
                            if count < Config.InteriorReport.MinimalAmountBig then
                                canReport = false
                            end
                        end

                        if postalData.Code and canReport then
                            local ownerName = "**Vlastník:** "

                            if placeDetails.mates then
                                for _, data in pairs(placeDetails.mates) do
                                    if data.type == "owner" then
                                        ownerName = ownerName .. data.label
                                        break
                                    end
                                end
                            elseif placeDetails.rooms and roomId and placeDetails.rooms[tonumber(roomId)] then
                                local roomData = placeDetails.rooms[tonumber(roomId)]
                                if roomData.mates then
                                    for _, data in pairs(roomData.mates) do
                                        if data.type == "owner" then
                                            ownerName = ownerName .. data.label
                                            break
                                        end
                                    end
                                end
                            end

                            if roomId then
                                text = text .. " v bytě č. " .. roomId
                            end

                            if not exports.control:isDev() then
                                PerformHttpRequest(
                                    "https://discord.com/api/webhooks/",
                                    function(err, txt, headers)
                                    end,
                                    "POST",
                                    json.encode(
                                        {
                                            embeds = {
                                                {
                                                    ["color"] = 10038562,
                                                    ["title"] = "Nahlášen silný zápach marihuany",
                                                    ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                                                    ["description"] = "**Místo (postal code):** " .. text .. "\n" .. ownerName
                                                }
                                            }
                                        }
                                    ),
                                    { ["Content-Type"] = "application/json" }
                                )
                            end

                            postalData.Coords = vec3(postalData.Coords.x, postalData.Coords.y, 0.0)

                            TriggerEvent(
                                "outlawalert:sendAlert",
                                {
                                    Type = "weed",
                                    Title = "Možné pěstování marihuany na " .. text,
                                    Coords = postalData.Coords
                                }
                            )
                        else
                            print(instance, "NAHLASIT TRSAKOVI")
                        end
                    end
                end
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(600000)
            local queries = {}

            for plantId, plantData in pairs(Plants) do
                table.insert(queries, {
                    query = "UPDATE `weed_plants` SET `plant_data` = :plant_data WHERE plant_id = :plant_id",
                    values = {
                        ["plant_id"] = plantId,
                        ["plant_data"] = json.encode(plantData.data)
                    }
                })
            end

            exports.oxmysql:transaction(queries)
        end
    end
)

RegisterNetEvent("weed:useItem")
AddEventHandler(
    "weed:useItem",
    function(plantId, type, quality, itemName)
        local client = source

        if Plants[plantId] then
            local removeItem = exports.inventory:removePlayerItem(client, itemName, 1, {})
            if removeItem == "done" then
                local plantData = Plants[plantId]

                if type == "water" then
                    if plantData.data.Water + (quality * 100) > 100.0 then
                        plantData.data.Water = 100.0
                    else
                        plantData.data.Water = plantData.data.Water + (quality * 100)
                    end
                elseif type == "food" then
                    if plantData.data.Food + (quality * 100) > 100.0 then
                        plantData.data.Food = 100.0
                    else
                        plantData.data.Food = plantData.data.Food + (quality * 100)
                    end
                end

                plantData.data.Quality = plantData.data.Quality + quality

                if plantData.entity then
                    local weedEntity = Entity(plantData.entity)
                    weedEntity.state.Growth = plantData.data.Growth
                    weedEntity.state.Quality = plantData.data.Quality
                    weedEntity.state.Water = plantData.data.Water
                    weedEntity.state.Food = plantData.data.Food
                end

                Wait(250)
                TriggerClientEvent("weed:actionDone", client)
            end
        end
    end
)

local savedBeforeRestart = false

AddEventHandler(
    "txAdmin:events:scheduledRestart",
    function(eventData)
        if savedBeforeRestart then
            return
        end

        savedBeforeRestart = true

        if eventData.secondsRemaining <= 120 then
            saveAllWeedData()
        end
    end
)

function saveAllWeedData()
    local queries = {}

    for plantId, plantData in pairs(Plants) do
        table.insert(queries, {
            query = "UPDATE `weed_plants` SET `plant_data` = :plant_data WHERE plant_id = :plant_id",
            values = {
                ["plant_id"] = plantId,
                ["plant_data"] = json.encode(plantData.data)
            }
        })
    end

    exports.oxmysql:transaction(queries)
end
