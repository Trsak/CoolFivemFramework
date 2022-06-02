local isSpawned, isDead, isOpened = false, false, false

local startedSearching = true
local DragStatus = {}
local isMenuFocused = false

Citizen.CreateThread(
    function()
        Citizen.Wait(500)
        if exports.data:getUserVar("status") == "spawned" or exports.data:getUserVar("status") == "dead" then
            isSpawned = true
        end
    end
)

RegisterCommand(
    "focus",
    function()
        SendNUIMessage(
            {
                type = "destroy"
            }
        )
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" then
            isSpawned = true
            isDead = false
        elseif status == "dead" then
            isDead = true
            DragStatus.IsDragged = false
            DragStatus.IsDragging = false
            DetachEntity(playerPed, true, false)
            if isOpened then
                isOpened = false
                SendNUIMessage(
                    {
                        type = "destroy"
                    }
                )
                SetNuiFocus(false, false)
                SetNuiFocusKeepInput(false)
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)
            if isSpawned and not isDead and not isOpened then
                if IsControlJustReleased(1, Config.openKey) then
                    toggleMenu()
                end
            end
        end
    end
)

function toggleMenu()
    if not isOpened and not IsHanducuffed then
        isOpened = true
        SendNUIMessage(
            {
                type = "init",
                resourceName = GetCurrentResourceName()
            }
        )
        SetNuiFocus(true, false)
        SetNuiFocusKeepInput(true)
    else
        isOpened = false
        SendNUIMessage(
            {
                type = "destroy"
            }
        )
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
    end
end

RegisterNUICallback(
    "closemenu",
    function(data, cb)
        if isOpened then
            isOpened = false
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
            SendNUIMessage(
                {
                    type = "destroy"
                }
            )
            PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)
            cb("ok")
        end
    end
)

RegisterNUICallback(
    "menufocus",
    function(data)
        if data.isMenuFocused then
            SetNuiFocus(true, true)
            SetNuiFocusKeepInput(false)
        else
            SetNuiFocus(true, false)
            SetNuiFocusKeepInput(true)
        end
    end
)

RegisterNUICallback(
    "openmenu",
    function(data)
        isOpened = false
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        SendNUIMessage(
            {
                type = "destroy"
            }
        )
        PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)

        if isHandcuffed then
            return
        end

        if data.id == "search" then
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            if veh ~= 0 then
                exports.notify:display({ type = "error", title = "Chyba", text = "Tuto akci nelze provést ve vozidle!", icon = "fas fa-car", length = 3000 })
            else
                TriggerEvent(
                    "util:closestPlayer",
                    {
                        radius = 1.8
                    },
                    function(player)
                        if player then
                            startedSearching = true

                            Citizen.CreateThread(
                                function()
                                    while startedSearching do
                                        local playerCoords = GetEntityCoords(PlayerPedId())
                                        local targetCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(player)))
                                        local dist = #(playerCoords - targetCoords)

                                        if dist > 1.8 then
                                            exports.progressbar:cancelProgressBar(false)
                                            exports.inventory:closeInventory()
                                            exports.notify:display({ type = "error", title = "Chyba", text = "Hráč se od tebe příliš vzdálil!", icon = "fas fa-times", length = 4000 })
                                            break
                                        end
                                        Citizen.Wait(500)
                                    end
                                end
                            )
                            exports.progressbar:startProgressBar({
                                Duration = 6500,
                                Label = "Prohledáváš osobu..",
                                CanBeDead = false,
                                CanCancel = true,
                                DisableControls = {
                                    Movement = true,
                                    CarMovement = true,
                                    Mouse = false,
                                    Combat = true
                                },
                                Animation = {
                                    animDict = "anim@gangops@facility@servers@bodysearch@",
                                    anim = "player_search",
                                    flags = 16
                                }
                            }, function(finished)
                                startedSearching = false
                                if finished then
                                    TriggerEvent("inventory:openPlayerInventory", player, 1.8, "search2")
                                end
                            end)
                        end
                    end
                )
            end
        elseif data.id == "cuff" then
            exports.cuffs:cuff()
        elseif data.id == "clothes" then
            exports.skinchooser:openClothingMenu()
        elseif data.id == "injuries" then
            exports.injuries:openInjuriesMenu()
        elseif data.id == "inoutvehicle" then
            exports.cuffs:vehiclePlayer()
        elseif data.id == "shoulderwalk" then
            exports.cuffs:takePlayer()
        elseif data.id == "trunk" then
            openTrunk()
        elseif data.id == "box" then
            openBox()
        elseif data.id == "hood" then
            exports.vehiclecontrol:toggleHood()
        elseif data.id == "engine" then
            ExecuteCommand("engine")
        elseif data.id == "doors" then
            exports.vehiclecontrol:toggleDoor()
        elseif data.id == "window" then
            exports.vehiclecontrol:toggleWindow()
        elseif data.id == "carry" then
            ExecuteCommand("carry")
        elseif data.id == "liftup" then
            ExecuteCommand("liftup")
        elseif data.id == "backride" then
            ExecuteCommand("backride")
        elseif data.id == "sackoff" then
            exports.sack:takeOffSack()
        end
    end
)

function openBox()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)

    if veh ~= 0 and DoesEntityExist(veh) then
        exports.inventory:openGlovebox(veh)
    else
        exports.notify:display({ type = "error", title = "Chyba", text = "Musíš být ve vozidle!", icon = "fas fa-car", length = 3000 })
    end
end

function openTrunk(veh)
    if GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 then
        exports.notify:display({ type = "error", title = "Chyba", text = "Nemůžeš otevřít kufr ve vozidle!", icon = "fas fa-car", length = 3000 })
    else
        if veh == nil or not DoesEntityExist(veh) then
            veh = getVehicleInDirection(6.0)
        end

        if not DoesEntityExist(veh) then
            veh = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 3.0, 0, 70)
        end

        if veh ~= nil and DoesEntityExist(veh) then
            exports.inventory:openTrunk(veh)
        else
            exports.notify:display({ type = "error", title = "Chyba", text = "Není u tebe žádné vozidlo!", icon = "fas fa-car", length = 3000 })
        end
    end
end

RegisterNetEvent("rp:refreshanim")
AddEventHandler(
    "rp:refreshanim",
    function()
        local playerPed = PlayerPedId()
        SetEnableHandcuffs(playerPed, true)
        DisablePlayerFiring(PlayerId(), true)
        SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true) -- unarm player
        SetPedCanPlayGestureAnims(playerPed, false)
        DisplayRadar(false)
        TaskPlayAnim(playerPed, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
    end
)

Citizen.CreateThread(
    function()
        local playerPed
        local targetPed
        local resetAnim = true

        while true do
            Citizen.Wait(1)
            if handCuffing then
                DisablePlayerFiring(PlayerId(), true)
            end

            if isOpened then
                DisableControlAction(1, 18, true)
                DisableControlAction(1, 24, true)
                DisableControlAction(1, 25, true)
                DisableControlAction(1, 68, true)
                DisableControlAction(1, 69, true)
                DisableControlAction(1, 70, true)
                DisableControlAction(1, 347, true)
            end

            if isHandcuffed then
                if isDead then
                    while isDead do
                        Citizen.Wait(500)
                    end
                    TriggerServerEvent("rp:refreshanim")
                end

                playerPed = PlayerPedId()
                -- DisableControlAction(0, 1, true) -- Disable pan
                -- DisableControlAction(0, 2, true) -- Disable tilt
                DisableControlAction(1, 23, true)
                DisableControlAction(1, 24, true)
                DisableControlAction(1, 25, true)
                DisableControlAction(0, 37, true) -- Select Weapon
                DisableControlAction(0, 44, true) -- Cover
                DisableControlAction(0, 45, true) -- Reload
                DisableControlAction(1, 55, true)
                DisableControlAction(1, 75, true)
                DisableControlAction(1, 75, true)
                DisableControlAction(0, 257, true) -- Attack 2
                DisableControlAction(0, 263, true) -- Melee Attack 1
                DisableControlAction(0, 288, true) -- Disable phone
                --DisableControlAction(0, 289, true) -- Inventory
                DisableControlAction(0, 170, true) -- Animations
                DisableControlAction(0, 167, true) -- Job
                DisableControlAction(0, 0, true) -- Disable changing view
                DisableControlAction(0, 26, true) -- Disable looking behind
                DisableControlAction(0, 73, true) -- Disable clearing animation
                DisableControlAction(2, 199, true) -- Disable pause screen

                DisableControlAction(0, 59, true) -- Disable steering in vehicle
                DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
                DisableControlAction(0, 72, true) -- Disable reversing in vehicle

                DisableControlAction(2, 36, true) -- Disable going stealth

                DisableControlAction(0, 47, true) -- Disable weapon
                DisableControlAction(0, 264, true) -- Disable melee
                DisableControlAction(0, 257, true) -- Disable melee
                DisableControlAction(0, 140, true) -- Disable melee
                DisableControlAction(0, 141, true) -- Disable melee
                DisableControlAction(0, 142, true) -- Disable melee
                DisableControlAction(0, 143, true) -- Disable melee
                DisableControlAction(0, 75, true) -- Disable exit vehicle
                DisableControlAction(27, 75, true) -- Disable exit vehicle

                -- if IsEntityPlayingAnim(playerPed, "mp_arresting", "idle", 3) ~= 1 and not handCuffing then
                --     TaskPlayAnim(playerPed, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
                -- end

                if resetAnim and not handCuffing then
                    resetAnim = false

                    ClearPedTasks(playerPed)
                    TaskPlayAnim(playerPed, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)

                    Citizen.CreateThread(
                        function()
                            Citizen.Wait(3500)
                            resetAnim = true
                        end
                    )
                end
            end
        end
    end
)

RegisterNetEvent("rp:cuffing")
AddEventHandler(
    "rp:cuffing",
    function()
        exports.emotes:cancelEmote()
        Citizen.Wait(50)
        handCuffing = true
        local playerPed = PlayerPedId()
        RequestAnimDict(arrestDict)
        while not HasAnimDictLoaded(arrestDict) do
            Citizen.Wait(100)
        end

        TaskPlayAnim(playerPed, arrestDict, animArresting, 8.0, -8.0, 5500, 33, 0, false, false, false)
        TriggerServerEvent("rp:removeItem", "cuffs", 1)
        handCuffing = false
    end
)

RegisterNetEvent("rp:uncuffing")
AddEventHandler(
    "rp:uncuffing",
    function(target)
        exports.emotes:cancelEmote()
        Citizen.Wait(50)
        handCuffing = true
        local playerPed = PlayerPedId()
        RequestAnimDict("mp_arresting")
        while not HasAnimDictLoaded("mp_arresting") do
            Citizen.Wait(100)
        end

        TaskPlayAnim(playerPed, "mp_arresting", "a_uncuff", 8.0, -8.0, 5500, 33, 0, false, false, false)

        Citizen.Wait(50)
        while IsEntityPlayingAnim(playerPed, "mp_arresting", "a_uncuff", 3) do
            Wait(200)
        end
        TriggerServerEvent("rp:uncuff", target)
        handCuffing = false
    end
)

RegisterNetEvent("rp:uncuff")
AddEventHandler(
    "rp:uncuff",
    function(himself)
        local playerPed = PlayerPedId()
        if himself then
            RequestAnimDict("mp_arresting")
            while not HasAnimDictLoaded("mp_arresting") do
                Citizen.Wait(100)
            end

            TaskPlayAnim(playerPed, "mp_arresting", "a_uncuff", 8.0, -8.0, 5500, 33, 0, false, false, false)

            Citizen.Wait(50)
            while IsEntityPlayingAnim(playerPed, "mp_arresting", "a_uncuff", 3) do
                Wait(200)
            end
        end
        TriggerServerEvent("rp:updateCuff", false)
        isHandcuffed = false
        ClearPedSecondaryTask(playerPed)
        SetEnableHandcuffs(playerPed, false)
        SetPedCanPlayGestureAnims(playerPed, true)
        FreezeEntityPosition(playerPed, false)
        TriggerEvent("rp:updateCuffed", isHandcuffed)
    end
)

RegisterNetEvent("rp:cuff")
AddEventHandler(
    "rp:cuff",
    function(target, hascuffs, haskeys)
        local playerPed = PlayerPedId()
        local targetPed = GetPlayerPed(GetPlayerFromServerId(target))

        Citizen.CreateThread(
            function()
                if not isHandcuffed and not isDead and not DragStatus.IsDragging then
                    if not hascuffs then
                        TriggerServerEvent("rp:notify", target, "error", "Zatčení", "Nemáte u sebe pouta")
                        return
                    end
                    exports.emotes:cancelEmote()
                    Citizen.Wait(50)
                    handCuffing = true

                    TriggerServerEvent("rp:updateCuff", true)
                    isHandcuffed = true
                    if isOpened then
                        toggleMenu()
                    end

                    TriggerServerEvent("rp:cuffing", target)
                    RequestAnimDict(arrestDict)
                    while not HasAnimDictLoaded(arrestDict) do
                        Citizen.Wait(100)
                    end

                    AttachEntityToEntity(playerPed, targetPed, 11816, 0.07, 1.1, 0.0, 80.0, 100.0, 20.0, false, false, false, false, 20, false)
                    TaskPlayAnim(playerPed, arrestDict, animArrested, 8.0, -8.0, 5500, 33, 0, false, false, false)

                    Citizen.Wait(950)
                    DetachEntity(playerPed, true, false)

                    Citizen.Wait(2900)

                    handCuffing = false

                    RequestAnimDict("mp_arresting")
                    while not HasAnimDictLoaded("mp_arresting") do
                        Citizen.Wait(100)
                    end

                    TaskPlayAnim(playerPed, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)

                    SetEnableHandcuffs(playerPed, true)
                    SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true) -- unarm player
                    SetPedCanPlayGestureAnims(playerPed, false)
                    DisplayRadar(false)
                    TriggerEvent("rp:updateCuffed", isHandcuffed)
                elseif isHandcuffed and not DragStatus.IsDragging then
                    if not haskeys then
                        TriggerServerEvent("rp:notify", target, "error", "Zatčení", "Nemáte u sebe klíčky od pout")
                        return
                    end
                    if not isDead then
                        local heading = GetEntityHeading(targetPed)
                        FreezeEntityPosition(playerPed, true)
                        SetEntityHeading(playerPed, heading)
                        TriggerServerEvent("rp:uncuffing", target)
                    else
                        local playerPed = PlayerPedId()
                        TriggerServerEvent("rp:updateCuff", false)
                        isHandcuffed = false
                        ClearPedSecondaryTask(playerPed)
                        SetEnableHandcuffs(playerPed, false)
                        SetPedCanPlayGestureAnims(playerPed, true)
                        FreezeEntityPosition(playerPed, false)
                        TriggerEvent("rp:updateCuffed", isHandcuffed)
                    end
                end
            end
        )
    end
)

RegisterNetEvent("rp:notify")
AddEventHandler(
    "rp:notify",
    function(type, title, text)
        exports.notify:display({ type = type, title = title, text = text, icon = "fas fa-info-circle", length = 3000 })
    end
)

RegisterNetEvent("rp:sendError")
AddEventHandler(
    "rp:sendError",
    function(message)
        TriggerEvent(
            "chat:addMessage",
            {
                templateId = "error",
                args = { message }
            }
        )
    end
)

function getVehicleInDirection(range)
    local coordA = GetEntityCoords(GetPlayerPed(-1), 1)
    local coordB = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, range, 0.0)

    local rayHandle = CastRayPointToPoint(coordA.x, coordA.y, coordA.z, coordB.x, coordB.y, coordB.z, 10, GetPlayerPed(-1), 0)
    local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
    return vehicle
end

function makeEntityFaceEntity(entity1, p2)
    local p1 = GetEntityCoords(entity1, true)

    local dx = p2.x - p1.x
    local dy = p2.y - p1.y

    local heading = GetHeadingFromVector_2d(dx, dy)
    SetEntityHeading(entity1, heading)
end
