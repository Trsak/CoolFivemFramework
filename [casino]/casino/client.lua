local casinoInteriors = {}
local wasInCasino = false
local isInCasino = false
local spinningObject
local spinningCar
local carOnShow = Config.Vehicle.Model
local showBigWin = false
local nearestChipShop
local chipSpawnedPeds
local inMenu = false

Citizen.CreateThread(
    function()
        createNewBlip(
            {
                coords = Config.Blip.coords,
                sprite = Config.Blip.sprite,
                display = Config.Blip.display,
                scale = Config.Blip.scale,
                colour = Config.Blip.colour,
                isShortRange = Config.Blip.isShortRange,
                text = Config.Blip.text
            }
        )

        local casinoMainInterior = 0
        local casinoGarageInterior = 0
        local casinoSlots = 0
        local casinoPenthouseInterior = 0
        local casinoVaultInterior = 0
        local casinoBackInterior = 0
        local casinoTunnelInterior = 0

        while casinoMainInterior == 0 or casinoGarageInterior == 0 or casinoSlots == 0 or casinoPenthouseInterior == 0 or casinoVaultInterior == 0 or casinoBackInterior == 0 or casinoTunnelInterior == 0 do
            casinoMainInterior = GetInteriorAtCoords(935.1050, 42.5656, 71.2737)
            casinoGarageInterior = GetInteriorAtCoords(945.58, 22.14, 81.16)
            casinoSlots = GetInteriorAtCoords(978.932984, 49.585110, 70.237922)
            casinoPenthouseInterior = GetInteriorAtCoords(976.6364, 70.2947, 115.1641)
            casinoVaultInterior = GetInteriorAtCoords(946.251, 43.2715, 58.9172)
            casinoBackInterior = GetInteriorAtCoords(974.5600, 22.5161, 70.8396)
            casinoTunnelInterior = GetInteriorAtCoords(930.1539, -0.2010, 59.1323)
            Citizen.Wait(500)
        end

        casinoInteriors[casinoMainInterior] = true
        casinoInteriors[casinoGarageInterior] = true
        casinoInteriors[casinoSlots] = true
        casinoInteriors[casinoPenthouseInterior] = true
        casinoInteriors[casinoVaultInterior] = true
        casinoInteriors[casinoBackInterior] = true
        casinoInteriors[casinoTunnelInterior] = true

        while true do
            Citizen.Wait(500)
            local currentInterior = GetInteriorFromEntity(PlayerPedId())
            if casinoInteriors[currentInterior] then
                if not wasInCasino then
                    wasInCasino = true
                    casinoEnter()
                    TriggerEvent("casino:enter")
                end
            elseif wasInCasino then
                wasInCasino = false
                casinoLeave()
                TriggerEvent("casino:leave")
            end
        end
    end
)

function casinoEnter()
    isInCasino = true
    startCasinoThreads()
    drawCarForWins()

    Citizen.CreateThread(function()
        while true do
            local nearestChipChair = GetClosestObjectOfType(Config.ChipSeatsPos, 5.0, -2139482741)
            if DoesEntityExist(nearestChipChair) then
                SetEntityAsMissionEntity(nearestChipChair, 1, 1)
                DeleteEntity(nearestChipChair)
            else
                break
            end

            Citizen.Wait(50)
        end

        spawnChipPeds()
    end)
end

function casinoLeave()
    isInCasino = false
    ClearAreaOfPeds(950.9, 34.9, 71.83846282959, 5.0, 1)

    for i, pedCoords in each(Config.ChipsPeds) do
        if chipSpawnedPeds ~= nil and chipSpawnedPeds[i] ~= nil and DoesEntityExist(chipSpawnedPeds[i]) then
            SetEntityAsNoLongerNeeded(chipSpawnedPeds[i])
            DeletePed(chipSpawnedPeds[i])
        end
    end
    chipSpawnedPeds = {}
end

function spawnChipPeds()
    for _, pedModel in each(Config.ChipsPedsModels) do
        RequestModel(GetHashKey(pedModel))
        while (not HasModelLoaded(GetHashKey(pedModel))) do
            Citizen.Wait(1)
        end
    end

    if not HasAnimDictLoaded("anim_casino_b@amb@casino@games@shared@dealer@") then
        RequestAnimDict("anim_casino_b@amb@casino@games@shared@dealer@")
        repeat Wait(0) until HasAnimDictLoaded("anim_casino_b@amb@casino@games@shared@dealer@")
    end

    local chipSpawnedPedsNew = {}
    for i, pedCoords in each(Config.ChipsPeds) do
        if chipSpawnedPeds == nil or chipSpawnedPeds[i] == nil or not DoesEntityExist(chipSpawnedPeds[i]) and NetworkHasControlOfEntity(chipSpawnedPeds[i])  then
            chipSpawnedPedsNew[i] = CreatePed(2, GetHashKey(Config.ChipsPedsModels[i]), pedCoords.x, pedCoords.y, pedCoords.z, false, false)

            SetEntityCanBeDamaged(chipSpawnedPedsNew[i], 0)
            SetPedAsEnemy(chipSpawnedPedsNew[i], 0)
            SetBlockingOfNonTemporaryEvents(chipSpawnedPedsNew[i], 1)
            SetPedResetFlag(chipSpawnedPedsNew[i], 249, 1)
            SetPedConfigFlag(chipSpawnedPedsNew[i], 185, true)
            SetPedConfigFlag(chipSpawnedPedsNew[i], 108, true)
            SetPedCanEvasiveDive(chipSpawnedPedsNew[i], 0)
            SetPedCanRagdollFromPlayerImpact(chipSpawnedPedsNew[i], 0)
            SetPedConfigFlag(chipSpawnedPedsNew[i], 208, true)

            local scene = CreateSynchronizedScene(pedCoords.x, pedCoords.y, pedCoords.z, 0.0, 0.0, pedCoords.w - 180.0, 2)
            TaskSynchronizedScene(chipSpawnedPedsNew[i], scene, "anim_casino_b@amb@casino@games@shared@dealer@", "idle", 1000.0, -8.0, 4, 1, 1148846080, 0)
        end
    end

    chipSpawnedPeds = chipSpawnedPedsNew
end

function startCasinoThreads()
    RequestStreamedTextureDict("Prop_Screen_Vinewood")

    while not HasStreamedTextureDictLoaded("Prop_Screen_Vinewood") do
        Citizen.Wait(100)
    end

    RegisterNamedRendertarget("casinoscreen_01")

    LinkNamedRendertarget("vw_vwint01_video_overlay")

    videoWallRenderTarget = GetNamedRendertargetRenderId("casinoscreen_01")

    Citizen.CreateThread(
        function()
            local lastUpdatedTvChannel = 0

            while true do
                Citizen.Wait(0)

                if not isInCasino then
                    ReleaseNamedRendertarget("casinoscreen_01")

                    videoWallRenderTarget = nil
                    showBigWin = false

                    break
                end

                if videoWallRenderTarget then
                    local currentTime = GetGameTimer()

                    if showBigWin then
                        setVideoWallTvChannelWin()

                        lastUpdatedTvChannel = GetGameTimer() - 33666
                        showBigWin = false
                    else
                        if (currentTime - lastUpdatedTvChannel) >= 42666 then
                            setVideoWallTvChannel()

                            lastUpdatedTvChannel = currentTime
                        end
                    end

                    SetTextRenderId(videoWallRenderTarget)
                    SetScriptGfxDrawOrder(4)
                    SetScriptGfxDrawBehindPausemenu(true)
                    DrawInteractiveSprite("Prop_Screen_Vinewood", "BG_Wall_Colour_4x4", 0.25, 0.5, 0.5, 1.0, 0.0, 255, 255, 255, 255)
                    DrawTvChannel(0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)
                    SetTextRenderId(GetDefaultScriptRendertargetRenderId())
                end
            end
        end
    )
end

function setVideoWallTvChannel()
    SetTvChannelPlaylist(0, Config.VideoType, true)
    SetTvAudioFrontend(true)
    SetTvVolume(-100.0)
    SetTvChannel(0)
end

function setVideoWallTvChannelWin()
    SetTvChannelPlaylist(0, "CASINO_WIN_PL", true)
    SetTvAudioFrontend(true)
    SetTvVolume(-100.0)
    SetTvChannel(-1)
    SetTvChannel(0)
end

function drawCarForWins()
    if DoesEntityExist(spinningCar) then
        DeleteEntity(spinningCar)
    end

    RequestModel(carOnShow)
    while not HasModelLoaded(carOnShow) do
        Citizen.Wait(0)
    end
    SetModelAsNoLongerNeeded(carOnShow)
    spinningCar = CreateVehicle(carOnShow, Config.Vehicle.Coords, 0.0, false, false)

    Citizen.CreateThread(function()
        while not DoesEntityExist(spinningCar) do
            Citizen.Wait(100)
        end

        while isInCasino do
            Citizen.Wait(1000)
            SetVehicleLivery(spinningCar, Config.Vehicle.Livery)
            SetVehicleColours(spinningCar, Config.Vehicle.Colors.Primary, Config.Vehicle.Colors.Secondary)
            SetVehicleDirtLevel(spinningCar, 0.0)
            SetVehicleOnGroundProperly(spinningCar)
            FreezeEntityPosition(spinningCar, 1)
        end
    end)
end

RegisterNetEvent("casino:bigWinHappened")
AddEventHandler(
    "casino:bigWinHappened",
    function()
        if not isInCasino then
            return
        end

        showBigWin = true
    end
)

RegisterNetEvent("casino:boughtChips")
AddEventHandler(
    "casino:boughtChips",
    function(chipValue)
        exports.notify:display(
            {
                type = "success",
                title = "Úspěch",
                text = "Úspěšně jsi nakoupil žetony v hodnotě " .. exports.data:getFormattedCurrency(chipValue) .. "!",
                icon = "fas fa-coins",
                length = 3500
            }
        )
    end
)

RegisterNetEvent("casino:resetAll")
AddEventHandler("casino:resetAll", function()
    ClearAreaOfPeds(991.93, 54.1, 69.83, 50.0, 300)
end)

RegisterNetEvent("casino:soldChips")
AddEventHandler(
    "casino:soldChips",
    function(chipValue)
        exports.notify:display(
            {
                type = "success",
                title = "Úspěch",
                text = "Úspěšně jsi prodal žetony v hodnotě " .. exports.data:getFormattedCurrency(chipValue) .. "!",
                icon = "fas fa-coins",
                length = 3500
            }
        )
    end
)

RegisterNetEvent("casino:notEnoughMoney")
AddEventHandler(
    "casino:notEnoughMoney",
    function()
        exports.notify:display(
            {
                type = "error",
                title = "Chyba",
                text = "Nemáš u sebe dostatek financí!",
                icon = "fas fa-coins",
                length = 3500
            }
        )
    end
)

RegisterNetEvent("casino:notEnoughChips")
AddEventHandler(
    "casino:notEnoughChips",
    function()
        exports.notify:display(
            {
                type = "error",
                title = "Chyba",
                text = "Nedokážeš prodat žetony v takové hodnotě!",
                icon = "fas fa-coins",
                length = 3500
            }
        )
    end
)

function openMenu()
    WarMenu.CreateMenu("chips_menu", "Žetony", "Nákup a prodej žetonů")
    WarMenu.OpenMenu("chips_menu")
    WarMenu.SetMenuY("chips_menu", 0.35)
    inMenu = true
    FreezeEntityPosition(PlayerPedId(), true)
    TaskStandStill(PlayerPedId(), -1)

    WarMenu.CreateSubMenu("chips_menu_sell", "chips_menu", "Prodej žetonů")

    while true do
        if WarMenu.IsMenuOpened("chips_menu") then
            if WarMenu.Button("Nakoupit žetony") then
                exports.input:openInput(
                    "number",
                    { title = "Za kolik $ chcete nakoupit žetony?", placeholder = "Minimálně 10" },
                    function(buyValue)
                        if buyValue == nil then
                            exports.notify:display(
                                {
                                    type = "error",
                                    title = "Chyba",
                                    text = "Musíš zadat částku!",
                                    icon = "fas fa-times",
                                    length = 3500
                                }
                            )
                        else
                            buyValue = tonumber(buyValue)
                            if buyValue == nil or buyValue < 10 or (buyValue % 10) ~= 0 then
                                exports.notify:display(
                                    {
                                        type = "error",
                                        title = "Chyba",
                                        text = "Částka musí být číslo násobkem 10!",
                                        icon = "fas fa-times",
                                        length = 3500
                                    }
                                )
                            else
                                TriggerServerEvent("casino:buyChips", buyValue)
                                WarMenu.CloseMenu()
                            end
                        end
                    end
                )
            end

            WarMenu.MenuButton("Prodat žetony", "chips_menu_sell")

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened("chips_menu_sell") then
            if WarMenu.Button("Prodat všechny žetony") then
                TriggerServerEvent("casino:sellChips", -1)
                WarMenu.CloseMenu()
            elseif WarMenu.Button("Prodat část žetonů") then
                exports.input:openInput(
                    "number",
                    { title = "Žetony v jaké hodnotě chceš prodat?", placeholder = "" },
                    function(sellValue)
                        if sellValue == nil then
                            exports.notify:display(
                                {
                                    type = "error",
                                    title = "Chyba",
                                    text = "Musíš zadat částku!",
                                    icon = "fas fa-times",
                                    length = 3500
                                }
                            )
                        else
                            sellValue = tonumber(sellValue)
                            if sellValue == nil or sellValue < 10 or (sellValue % 10) ~= 0 then
                                exports.notify:display(
                                    {
                                        type = "error",
                                        title = "Chyba",
                                        text = "Částka musí být číslo násobkem 10!",
                                        icon = "fas fa-times",
                                        length = 3500
                                    }
                                )
                            else
                                TriggerServerEvent("casino:sellChips", sellValue)
                                WarMenu.CloseMenu()
                            end
                        end
                    end
                )
            end

            WarMenu.Display()
        else
            WarMenu.CloseMenu()
            break
        end

        Citizen.Wait(0)
    end

    inMenu = false
    ClearPedTasks(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
end

Citizen.CreateThread(
    function()
        Citizen.Wait(1000)
        exports["target"]:AddCircleZone(
            "casinoBuyChips",
            vector3(950.847230, 32.544490, 71.838738),
            3.2,
            {
                actions = {
                    casinoChips = {
                        cb = function()
                            openMenu()
                        end,
                        cbData = {},
                        icon = "fas fa-coins",
                        label = "Prodat / Koupit žetony",
                    }
                },
                distance = 0.2
            })
    end
)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    ClearAreaOfPeds(950.9, 34.9, 71.83846282959, 5.0, 1)

    for i, pedCoords in each(Config.ChipsPeds) do
        if chipSpawnedPeds ~= nil and chipSpawnedPeds[i] ~= nil and DoesEntityExist(chipSpawnedPeds[i]) then
            SetEntityAsNoLongerNeeded(chipSpawnedPeds[i])
            DeletePed(chipSpawnedPeds[i])
        end
    end

    if DoesEntityExist(spinningCar) then
        DeleteEntity(spinningCar)
    end
end)

exports('getIsInCasino', function()
    return isInCasino
end)

RegisterNetEvent("casino:reset")
AddEventHandler("casino:reset", function()
    ClearAreaOfPeds(950.9, 34.9, 71.83846282959, 5.0, 1)

    for i, pedCoords in each(Config.ChipsPeds) do
        if chipSpawnedPeds ~= nil and chipSpawnedPeds[i] ~= nil and DoesEntityExist(chipSpawnedPeds[i]) then
            SetEntityAsNoLongerNeeded(chipSpawnedPeds[i])
            DeletePed(chipSpawnedPeds[i])
        end
    end
    chipSpawnedPeds = {}
    Citizen.Wait(500)
    spawnChipPeds()
end)

exports('setCasinoPedRandomClothes', function(ped, tableEntity)
    while not NetworkGetEntityIsNetworked(tableEntity) do
        NetworkRegisterEntityAsNetworked(tableEntity)
        Wait(10)
    end

    local entity = Entity(tableEntity)
    local type = entity.state.randomClothes

    if type ~= nil and tonumber(type) ~= nil then
        setPedClothes(ped, tonumber(type))
    else
        entity.state:set('randomClothes', setPedClothes(ped), true)
    end
end)

local lastTypeNumber = 11

local typesTable = {}

function generateTypesTable()
    typesTable = {}

    for i = 0, lastTypeNumber do
        table.insert(typesTable, i)
    end

end

function setPedClothes(ped, type)
    if type == nil then
        if #typesTable == 0 then
            generateTypesTable()
        end

        type = table.remove(typesTable, math.random(1, #typesTable))
    end

    if type == 0 then
        SetPedComponentVariation(ped, 0, 0, 0, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 0, 0, 0)
        SetPedComponentVariation(ped, 3, 0, 1, 0)
        SetPedComponentVariation(ped, 4, 0, 0, 0)
        SetPedComponentVariation(ped, 6, 0, 0, 0)
        SetPedComponentVariation(ped, 7, 0, 0, 0)
        SetPedComponentVariation(ped, 8, 0, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 0, 0, 0)
        SetPedPropIndex(ped, 1, 0, 0, false)
    elseif type == 1 then
        SetPedComponentVariation(ped, 0, 3, 1, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 3, 1, 0)
        SetPedComponentVariation(ped, 3, 0, 1, 0)
        SetPedComponentVariation(ped, 4, 0, 0, 0)
        SetPedComponentVariation(ped, 6, 0, 0, 0)
        SetPedComponentVariation(ped, 7, 0, 0, 0)
        SetPedComponentVariation(ped, 8, 0, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 0, 0, 0)
    elseif type == 2 then
        SetPedComponentVariation(ped, 0, 3, 0, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 3, 0, 0)
        SetPedComponentVariation(ped, 3, 0, 1, 0)
        SetPedComponentVariation(ped, 4, 1, 0, 0)
        SetPedComponentVariation(ped, 6, 1, 0, 0)
        SetPedComponentVariation(ped, 7, 1, 0, 0)
        SetPedComponentVariation(ped, 8, 0, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 0, 0, 0)
        SetPedPropIndex(ped, 1, 0, 0, false)
    elseif type == 3 then
        SetPedComponentVariation(ped, 0, 2, 1, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 2, 1, 0)
        SetPedComponentVariation(ped, 3, 3, 3, 0)
        SetPedComponentVariation(ped, 4, 1, 0, 0)
        SetPedComponentVariation(ped, 6, 1, 0, 0)
        SetPedComponentVariation(ped, 7, 2, 0, 0)
        SetPedComponentVariation(ped, 8, 3, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 0, 0, 0)
    elseif type == 4 then
        SetPedComponentVariation(ped, 0, 0, 1, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 0, 1, 0)
        SetPedComponentVariation(ped, 3, 0, 0, 0)
        SetPedComponentVariation(ped, 4, 0, 0, 0)
        SetPedComponentVariation(ped, 6, 0, 0, 0)
        SetPedComponentVariation(ped, 7, 1, 0, 0)
        SetPedComponentVariation(ped, 8, 0, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 0, 0, 0)
    elseif type == 5 then
        SetPedComponentVariation(ped, 0, 3, 1, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 1, 1, 0)
        SetPedComponentVariation(ped, 3, 3, 1, 0)
        SetPedComponentVariation(ped, 4, 0, 0, 0)
        SetPedComponentVariation(ped, 6, 1, 0, 0)
        SetPedComponentVariation(ped, 7, 2, 0, 0)
        SetPedComponentVariation(ped, 8, 3, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 0, 0, 0)
    elseif type == 6 then
        SetPedComponentVariation(ped, 0, 4, 1, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 1, 0, 0)
        SetPedComponentVariation(ped, 3, 3, 1, 0)
        SetPedComponentVariation(ped, 4, 0, 0, 0)
        SetPedComponentVariation(ped, 6, 1, 0, 0)
        SetPedComponentVariation(ped, 7, 2, 0, 0)
        SetPedComponentVariation(ped, 8, 3, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 0, 0, 0)
        SetPedPropIndex(ped, 1, 0, 0, false)
    elseif type == 7 then
        SetPedComponentVariation(ped, 0, 5, 0, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 2, 1, 0)
        SetPedComponentVariation(ped, 3, 3, 2, 0)
        SetPedComponentVariation(ped, 4, 1, 0, 0)
        SetPedComponentVariation(ped, 6, 1, 0, 0)
        SetPedComponentVariation(ped, 7, 2, 0, 0)
        SetPedComponentVariation(ped, 8, 3, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 0, 0, 0)
        SetPedPropIndex(ped, 1, 0, 0, false)
    elseif type == 8 then
        SetPedComponentVariation(ped, 0, 3, 0, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 0, 1, 0)
        SetPedComponentVariation(ped, 3, 0, 1, 0)
        SetPedComponentVariation(ped, 4, 0, 0, 0)
        SetPedComponentVariation(ped, 6, 0, 0, 0)
        SetPedComponentVariation(ped, 7, 1, 0, 0)
        SetPedComponentVariation(ped, 8, 0, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 0, 0, 0)
    elseif type == 9 then
        SetPedComponentVariation(ped, 0, 2, 0, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 2, 0, 0)
        SetPedComponentVariation(ped, 3, 3, 3, 0)
        SetPedComponentVariation(ped, 4, 1, 0, 0)
        SetPedComponentVariation(ped, 6, 1, 0, 0)
        SetPedComponentVariation(ped, 7, 1, 0, 0)
        SetPedComponentVariation(ped, 8, 3, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 0, 0, 0)
    elseif type == 10 then
        SetPedComponentVariation(ped, 0, 4, 0, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 4, 0, 0)
        SetPedComponentVariation(ped, 3, 0, 1, 0)
        SetPedComponentVariation(ped, 4, 1, 0, 0)
        SetPedComponentVariation(ped, 6, 1, 0, 0)
        SetPedComponentVariation(ped, 7, 1, 0, 0)
        SetPedComponentVariation(ped, 8, 0, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 0, 0, 0)
    elseif type == 11 then
        SetPedComponentVariation(ped, 0, 5, 0, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 5, 0, 0)
        SetPedComponentVariation(ped, 3, 0, 2, 0)
        SetPedComponentVariation(ped, 4, 1, 0, 0)
        SetPedComponentVariation(ped, 6, 1, 0, 0)
        SetPedComponentVariation(ped, 7, 0, 0, 0)
        SetPedComponentVariation(ped, 8, 0, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 0, 0, 0)
    end

    return type
end