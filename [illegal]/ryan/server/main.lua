math.randomseed(os.time() .. math.random(1000, 9999))

local ryanPed
local currentRyanLocation
local futureRyanLocation
local spawnTime
local soldOut = false

local playersInRange = {}

function createRyan()
    if ryanPed == nil then
        ryanPed = Citizen.InvokeNative(GetHashKey("CREATE_PED"), 0, GetHashKey("mp_f_freemode_01"), currentRyanLocation.x, currentRyanLocation.y, currentRyanLocation.z, currentRyanLocation.w)

        while not DoesEntityExist(ryanPed) do
            Wait(0)
        end

        applyPedConfig(ryanPed)
    end
end

function spawnRyan()
    local randomItems = selectRandomItems()
    exports.base_shops:createSpecialShop("Ryan", randomItems)

    spawnRyanOnRandomCoords()

    exports.logs:sendToDiscord(
        {
            channel = "ryan",
            title = "Spawn",
            description = "Ryan se spawnula na **" .. currentRyanLocation.x .. " " .. currentRyanLocation.y .. " " .. currentRyanLocation.z .. " " .. "**\n\n**Zboží:**\n" .. json.encode(randomItems),
            color = "2067276"
        }
    )
end

function selectRandomItems()
    local items = {}

    for tier, count in pairs(ServerConfig.ItemTiers) do
        count = count - math.random(0, 1)

        while count > 0 do
            count = count - 1

            local randomItem = selectRandomTierItem(tier)
            if randomItem.count > 0 then
                items[randomItem.name] = randomItem

                if randomItem.type == "ammoWeapon" and ServerConfig.WeaponMagazines[randomItem.name] then
                    local randomAmmo = selectRandomWeaponAmmo(randomItem.name)

                    if items[randomAmmo.name] then
                        items[randomAmmo.name].count = items[randomAmmo.name].count + randomAmmo.count
                    else
                        items[randomAmmo.name] = randomAmmo
                    end
                end
            end
        end
    end

    return items
end

function selectRandomWeaponAmmo(weapon)
    local totalChance = 0

    for _, ammo in each(ServerConfig.WeaponMagazines[weapon]) do
        totalChance = totalChance + ammo.Chance
    end

    local randomChance = math.random(0, totalChance)

    local currentChance = 0
    for _, ammo in each(ServerConfig.WeaponMagazines[weapon]) do
        currentChance = currentChance + ammo.Chance

        if currentChance >= randomChance then
            return {
                name = ammo.Name,
                price = ammo.Price,
                count = math.random(ammo.Min, ammo.Max),
                label = exports.inventory:getItem(ammo.Name).label
            }
        end
    end
end

function selectRandomTierItem(tier)
    local totalChance = 0

    for _, item in each(ServerConfig.Items) do
        if item.Tier == tier then
            totalChance = totalChance + item.Chance
        end
    end

    local randomChance = math.random(0, totalChance)

    local currentChance = 0
    for _, item in each(ServerConfig.Items) do
        if item.Tier == tier then
            currentChance = currentChance + item.Chance

            if currentChance >= randomChance then
                return {
                    name = item.Name,
                    price = item.Price,
                    count = math.random(item.Min, item.Max),
                    label = exports.inventory:getItem(item.Name).label,
                    type = item.Type
                }
            end
        end
    end
end

function spawnRyanOnRandomCoords()
    if futureRyanLocation then
        currentRyanLocation = futureRyanLocation
    else
        currentRyanLocation = ServerConfig.SpawnCoords[math.random(#ServerConfig.SpawnCoords)]
    end

    createRyan()
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    if ryanPed ~= nil then
        if DoesEntityExist(ryanPed) then
            DeleteEntity(ryanPed)
        end

        ryanPed = nil
    end
end)

function askForRyan(client)

    exports.logs:sendToDiscord(
        {
            channel = "ryan",
            title = "Zeptání se na Ryan",
            description = "Hráč se zeptal na pozici Ryan",
            color = "9807270"
        },
        client
    )

    if soldOut then
        TriggerClientEvent(
            "notify:display",
            client,
            {
                type = "error",
                title = "Ryan",
                text = "Ryan už dnes prodej uskutečnila",
                icon = "game-icon game-icon-machine-gun-magazine",
                length = 6000
            }
        )
    elseif currentRyanLocation then
        TriggerClientEvent("ryan:markPosition", client, currentRyanLocation, true)
    else
        local isSpawningSoon = false
        local hours = tonumber(os.date("%H"))
        local minutes = tonumber(os.date("%M"))

        if hours == spawnTime.hours and minutes + 5 >= spawnTime.minutes then
            isSpawningSoon = true
        elseif hours + 1 == spawnTime.hours and (minutes - 60) + 5 >= spawnTime.minutes then
            isSpawningSoon = true
        elseif spawnTime.hours == 0 and hours == 23 and (minutes - 60) + 5 >= spawnTime.minutes then
            isSpawningSoon = true
        end

        if isSpawningSoon then
            if not futureRyanLocation then
                futureRyanLocation = ServerConfig.SpawnCoords[math.random(#ServerConfig.SpawnCoords)]
            end

            TriggerClientEvent("ryan:markPosition", client, futureRyanLocation, false)
        else
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "error",
                    title = "Ryan",
                    text = "Ryan se v nejbližší době zboží prodávat nechystá",
                    icon = "game-icon game-icon-machine-gun-magazine",
                    length = 6000
                }
            )
        end
    end
end

Citizen.CreateThread(
    function()
        Wait(1000)

        spawnTime = {
            hours = ServerConfig.HoursToSpawnIn[math.random(#ServerConfig.HoursToSpawnIn)],
            minutes = math.random(0, 59)
        }

        if tonumber(os.date("%H")) > 14 then
            exports.logs:sendToDiscord(
                {
                    channel = "ryan",
                    title = "Zvolený čas",
                    description = "Ryan se spawne " .. string.format("%02d", spawnTime.hours) .. ":" .. string.format("%02d", spawnTime.minutes),
                    color = "10181046"
                }
            )
        end

        while true do
            Wait(1500)

            if soldOut then
                if DoesEntityExist(ryanPed) then
                    DeleteEntity(ryanPed)
                end
                break
            end

            if currentRyanLocation and ryanPed then
                SetEntityCoords(ryanPed, currentRyanLocation.x, currentRyanLocation.y, currentRyanLocation.z - 1.0)
                if not DoesEntityExist(ryanPed) then
                    ryanPed = nil
                    createRyan()
                end

                local players = GetPlayers()
                local ryanVec3Location = vec3(currentRyanLocation.x, currentRyanLocation.y, currentRyanLocation.z)

                for _, playerId in each(players) do
                    local playerPed = GetPlayerPed(playerId)
                    local playerCoords = GetEntityCoords(playerPed)
                    local distance = #(playerCoords - ryanVec3Location)

                    if distance <= 80.0 and not playersInRange[playerId] then
                        playersInRange[playerId] = true
                        TriggerClientEvent("ryan:enteredArea", playerId, NetworkGetNetworkIdFromEntity(ryanPed))
                    elseif distance > 80.0 and playersInRange[playerId] then
                        playersInRange[playerId] = nil
                    end

                    Wait(1)
                end
            elseif currentRyanLocation == nil then
                local hours = tonumber(os.date("%H"))
                local minutes = tonumber(os.date("%M"))

                if (spawnTime.hours > 10 and hours > spawnTime.hours) or (spawnTime.hours < 10 and hours < 10 and hours > spawnTime.hours) or (hours == spawnTime.hours and minutes >= spawnTime.minutes) then
                    spawnRyan()
                end
            end
        end
    end
)

AddEventHandler('base_shops:specialShopEmpty', function(shopName)
    if shopName ~= "Ryan" then
        return
    end

    soldOut = true

    exports.logs:sendToDiscord(
        {
            channel = "ryan",
            title = "Vykoupení",
            description = "Všechno zboží u Ryan bylo vykoupeno!",
            color = "2899536"
        }
    )
end)
