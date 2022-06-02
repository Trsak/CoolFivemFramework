local vehicles, stocks = {}, {}
local blips, peds = {}, {}

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
            checkMisc()
        end

        for shop, place in each(Config.Places) do
            exports.target:AddCircleZone(
                "vehicle_shop_" .. shop,
                place.coords,
                1.0,
                {
                    actions = {
                        vehicleList = {
                            cb = function()
                                openCatalog(shop)
                            end,
                            icon = "far fa-id-badge",
                            label = "Seznam aut"
                        }
                    },
                    distance = 1.0
                }
            )
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" or status == "dead" then
            isDead = (status == "dead")
            if not isSpawned then
                isSpawned = true
                checkMisc()
                TriggerServerEvent("vehicles_shop:sync")
            end
        end
    end
)

RegisterNetEvent("vehicles_shop:sync")
AddEventHandler(
    "vehicles_shop:sync",
    function(serverVehs, serverStocks)
        vehicles, stocks = serverVehs, serverStocks
    end
)

RegisterNUICallback(
    "closepanel",
    function(data, cb)
        hideCatalog()
    end
)

RegisterNUICallback(
    "buyVehicleAttempt",
    function(vehicle, cb)
        local data = Config.Places[vehicle.shop]
    
        hideCatalog()

        Citizen.CreateThread(
            function()
                WarMenu.CreateMenu("pdm_register", "Zakoupení vozidla", "Zvolte možnost")
                WarMenu.OpenMenu("pdm_register")
                WarMenu.SetMenuY("pdm_register", 0.35)

                while WarMenu.IsMenuOpened("pdm_register") do
                    if WarMenu.Button("Zakoupit pro sebe") then
                        WarMenu.CloseMenu()
                        tryBuyVehicle("me", vehicle, data)
                    elseif WarMenu.Button("Zakoupit pro kámoše") then
                        WarMenu.CloseMenu()
                        tryBuyVehicle("friend", vehicle, data)
                    end

                    WarMenu.Display()

                    Citizen.Wait(1)
                end
            end
        )
    end
)

function openCatalog(shopId)

    exports.emotes:playEmoteByName("tablet")

    SendNUIMessage(
        {
            action = "show",
            currentshop = shopId,
            currentvehicles = stocks[shopId],
            categories = Config.VehClasses,
            allvehicles = vehicles,
            vehtypes = Config.VehTypes
        }
    )
    SetNuiFocus(true, true)
end

function hideCatalog()
    exports.emotes:cancelEmote()

    SendNUIMessage(
        {
            action = "hide"
        }
    )
    SetNuiFocus(false, false)
end

function checkMisc()
    if #peds <= 0 then
        for shop, place in pairs(Config.Places) do
            local model = place.npc.model ~= nil and place.npc.model
            local heading = place.npc.heading ~= nil and place.npc.heading or 90

            RequestModel(model)

            while not HasModelLoaded(model) do
                Citizen.Wait(1)
            end

            local ped = CreatePed(4, model, place.coords.x, place.coords.y, place.coords.z - 1, heading, false, false)

            SetBlockingOfNonTemporaryEvents(ped, true)

            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            table.insert(peds, ped)
        end
    end
    if #blips <= 0 then
        for shop, place in pairs(Config.Places) do
            local blip =
                createNewBlip(
                {
                    coords = place.coords,
                    sprite = Config.Types[place.type].type,
                    display = Config.Types[place.type].display,
                    scale = Config.Types[place.type].scale,
                    colour = Config.Types[place.type].color,
                    IsBlipShortRange = true,
                    text = "Prodejce vozidel"
                }
            )
            table.insert(blips, blip)
        end
    end
end

function tryBuyVehicle(forWho, vehicle, data)
    local shopKey = vehicle.shop
    local shopData = Config.Places[vehicle.shop]
    local spawnPoint, index = CheckSpawnPos(shopData.vehicleDelivery, shopKey)

    if spawnPoint then
        exports.emotes:cancelEmote()

        Wait(1000 * GetAnimDuration("mp_common", "givetake1_a"))

        if forWho == "me" then
            TriggerServerEvent("vehicles_shop:buyVehicle", vehicle, nil, shopKey, index)
        else
            TriggerEvent(
                "util:closestPlayer",
                {
                    radius = 5.0
                },
                function(player)
                    if player then
                        TriggerServerEvent("vehicles_shop:buyVehicle", vehicle, player, shopKey, index)
                    end
                end
            )
        end
    else
        exports.notify:display(
            {
                type = "error",
                title = "PDM",
                text = "Nelze zakoupit vozidlo, protože není místo, kam bychom ho dovezli!",
                icon = "fas fa-car",
                length = 3500
            }
        )
    end
end

function CheckSpawnPos(data, shopId)
    local settings = data.spawnSettings ~= nil and data.spawnSettings or nil

    if settings == nil then
        print("ERROR: Cannot get spawn setting for current places. [" .. shopId .. "]")
        return
    end

    local spawnPoints = data.spawnPos ~= nil and data.spawnPos or nil

    if spawnPoints == nil then
        print("ERROR: spawnPoints undefined -> check config.lua")
        return
    end

    local spawnPoint = nil
    local spawnIndex = nil

    for index, coords in pairs(spawnPoints) do
        if not IsSpawnPointOccluded(coords, settings.width, settings.length, settings.height) then
            spawnPoint = coords
            spawnIndex = index
            break
        end
    end

    return spawnPoint, spawnIndex
end

function IsSpawnPointOccluded(coords, width, length, height)
    local flags = 2
    local ray = StartShapeTestBox(coords.xyz, width, length, height, 0.0, 0.0, coords.w, 2, flags, PlayerPedId(), 4)

    local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(ray)

    return hit > 0
end