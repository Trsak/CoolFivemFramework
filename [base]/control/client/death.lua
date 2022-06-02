local isDead = false
local isSpawned = false

local deathHashTable = {
    [GetHashKey('WEAPON_ANIMAL')] = 'Animal',
    [GetHashKey('WEAPON_COUGAR')] = 'Cougar',
    [GetHashKey('WEAPON_ADVANCEDRIFLE')] = 'Advanced Rifle',
    [GetHashKey('WEAPON_APPISTOL')] = 'AP Pistol',
    [GetHashKey('WEAPON_ASSAULTRIFLE')] = 'Assault Rifle',
    [GetHashKey('WEAPON_ASSAULTRIFLE_MK2')] = 'Assault Rifke Mk2',
    [GetHashKey('WEAPON_ASSAULTSHOTGUN')] = 'Assault Shotgun',
    [GetHashKey('WEAPON_ASSAULTSMG')] = 'Assault SMG',
    [GetHashKey('WEAPON_AUTOSHOTGUN')] = 'Automatic Shotgun',
    [GetHashKey('WEAPON_BULLPUPRIFLE')] = 'Bullpup Rifle',
    [GetHashKey('WEAPON_BULLPUPRIFLE_MK2')] = 'Bullpup Rifle Mk2',
    [GetHashKey('WEAPON_BULLPUPSHOTGUN')] = 'Bullpup Shotgun',
    [GetHashKey('WEAPON_CARBINERIFLE')] = 'Carbine Rifle',
    [GetHashKey('WEAPON_CARBINERIFLE_MK2')] = 'Carbine Rifle Mk2',
    [GetHashKey('WEAPON_COMBATMG')] = 'Combat MG',
    [GetHashKey('WEAPON_COMBATMG_MK2')] = 'Combat MG Mk2',
    [GetHashKey('WEAPON_COMBATPDW')] = 'Combat PDW',
    [GetHashKey('WEAPON_COMBATPISTOL')] = 'Combat Pistol',
    [GetHashKey('WEAPON_COMPACTRIFLE')] = 'Compact Rifle',
    [GetHashKey('WEAPON_DBSHOTGUN')] = 'Double Barrel Shotgun',
    [GetHashKey('WEAPON_DOUBLEACTION')] = 'Double Action Revolver',
    [GetHashKey('WEAPON_FLAREGUN')] = 'Flare gun',
    [GetHashKey('WEAPON_GUSENBERG')] = 'Gusenberg',
    [GetHashKey('WEAPON_HEAVYPISTOL')] = 'Heavy Pistol',
    [GetHashKey('WEAPON_HEAVYSHOTGUN')] = 'Heavy Shotgun',
    [GetHashKey('WEAPON_HEAVYSNIPER')] = 'Heavy Sniper',
    [GetHashKey('WEAPON_HEAVYSNIPER_MK2')] = 'Heavy Sniper',
    [GetHashKey('WEAPON_MACHINEPISTOL')] = 'Machine Pistol',
    [GetHashKey('WEAPON_MARKSMANPISTOL')] = 'Marksman Pistol',
    [GetHashKey('WEAPON_MARKSMANRIFLE')] = 'Marksman Rifle',
    [GetHashKey('WEAPON_MARKSMANRIFLE_MK2')] = 'Marksman Rifle Mk2',
    [GetHashKey('WEAPON_MG')] = 'MG',
    [GetHashKey('WEAPON_MICROSMG')] = 'Micro SMG',
    [GetHashKey('WEAPON_MINIGUN')] = 'Minigun',
    [GetHashKey('WEAPON_MINISMG')] = 'Mini SMG',
    [GetHashKey('WEAPON_MUSKET')] = 'Musket',
    [GetHashKey('WEAPON_PISTOL')] = 'Pistol',
    [GetHashKey('WEAPON_PISTOL_MK2')] = 'Pistol Mk2',
    [GetHashKey('WEAPON_PISTOL50')] = 'Pistol .50',
    [GetHashKey('WEAPON_PUMPSHOTGUN')] = 'Pump Shotgun',
    [GetHashKey('WEAPON_PUMPSHOTGUN_MK2')] = 'Pump Shotgun Mk2',
    [GetHashKey('WEAPON_RAILGUN')] = 'Railgun',
    [GetHashKey('WEAPON_REVOLVER')] = 'Revolver',
    [GetHashKey('WEAPON_REVOLVER_MK2')] = 'Revolver Mk2',
    [GetHashKey('WEAPON_SAWNOFFSHOTGUN')] = 'Sawnoff Shotgun',
    [GetHashKey('WEAPON_SMG')] = 'SMG',
    [GetHashKey('WEAPON_SMG_MK2')] = 'SMG Mk2',
    [GetHashKey('WEAPON_SNIPERRIFLE')] = 'Sniper Rifle',
    [GetHashKey('WEAPON_SNSPISTOL')] = 'SNS Pistol',
    [GetHashKey('WEAPON_SNSPISTOL_MK2')] = 'SNS Pistol Mk2',
    [GetHashKey('WEAPON_SPECIALCARBINE')] = 'Special Carbine',
    [GetHashKey('WEAPON_SPECIALCARBINE_MK2')] = 'Special Carbine Mk2',
    [GetHashKey('WEAPON_STINGER')] = 'Stinger',
    [GetHashKey('WEAPON_STUNGUN')] = 'Stungun',
    [GetHashKey('WEAPON_VINTAGEPISTOL')] = 'Vintage Pistol',
    [GetHashKey('VEHICLE_WEAPON_PLAYER_LASER')] = 'Vehicle Lasers',
    [GetHashKey('WEAPON_FIRE')] = 'Fire',
    [GetHashKey('WEAPON_FLARE')] = 'Flare',
    [GetHashKey('WEAPON_FLAREGUN')] = 'Flaregun',
    [GetHashKey('WEAPON_MOLOTOV')] = 'Molotov',
    [GetHashKey('WEAPON_PETROLCAN')] = 'Petrol Can',
    [GetHashKey('WEAPON_HELI_CRASH')] = 'Helicopter Crash',
    [GetHashKey('WEAPON_RAMMED_BY_CAR')] = 'Rammed by Vehicle',
    [GetHashKey('WEAPON_RUN_OVER_BY_CAR')] = 'Ranover by Vehicle',
    [GetHashKey('VEHICLE_WEAPON_SPACE_ROCKET')] = 'Vehicle Space Rocket',
    [GetHashKey('VEHICLE_WEAPON_TANK')] = 'Tank',
    [GetHashKey('WEAPON_AIRSTRIKE_ROCKET')] = 'Airstrike Rocket',
    [GetHashKey('WEAPON_AIR_DEFENCE_GUN')] = 'Air Defence Gun',
    [GetHashKey('WEAPON_COMPACTLAUNCHER')] = 'Compact Launcher',
    [GetHashKey('WEAPON_EXPLOSION')] = 'Explosion',
    [GetHashKey('WEAPON_FIREWORK')] = 'Firework',
    [GetHashKey('WEAPON_GRENADE')] = 'Grenade',
    [GetHashKey('WEAPON_GRENADELAUNCHER')] = 'Grenade Launcher',
    [GetHashKey('WEAPON_HOMINGLAUNCHER')] = 'Homing Launcher',
    [GetHashKey('WEAPON_PASSENGER_ROCKET')] = 'Passenger Rocket',
    [GetHashKey('WEAPON_PIPEBOMB')] = 'Pipe bomb',
    [GetHashKey('WEAPON_PROXMINE')] = 'Proximity Mine',
    [GetHashKey('WEAPON_RPG')] = 'RPG',
    [GetHashKey('WEAPON_STICKYBOMB')] = 'Sticky Bomb',
    [GetHashKey('WEAPON_VEHICLE_ROCKET')] = 'Vehicle Rocket',
    [GetHashKey('WEAPON_BZGAS')] = 'BZ Gas',
    [GetHashKey('WEAPON_FIREEXTINGUISHER')] = 'Fire Extinguisher',
    [GetHashKey('WEAPON_SMOKEGRENADE')] = 'Smoke Grenade',
    [GetHashKey('WEAPON_BATTLEAXE')] = 'Battleaxe',
    [GetHashKey('WEAPON_BOTTLE')] = 'Bottle',
    [GetHashKey('WEAPON_KNIFE')] = 'Knife',
    [GetHashKey('WEAPON_MACHETE')] = 'Machete',
    [GetHashKey('WEAPON_SWITCHBLADE')] = 'Switch Blade',
    [GetHashKey('OBJECT')] = 'Object',
    [GetHashKey('VEHICLE_WEAPON_ROTORS')] = 'Vehicle Rotors',
    [GetHashKey('WEAPON_BALL')] = 'Ball',
    [GetHashKey('WEAPON_BAT')] = 'Bat',
    [GetHashKey('WEAPON_CROWBAR')] = 'Crowbar',
    [GetHashKey('WEAPON_FLASHLIGHT')] = 'Flashlight',
    [GetHashKey('WEAPON_GOLFCLUB')] = 'Golfclub',
    [GetHashKey('WEAPON_HAMMER')] = 'Hammer',
    [GetHashKey('WEAPON_HATCHET')] = 'Hatchet',
    [GetHashKey('WEAPON_HIT_BY_WATER_CANNON')] = 'Water Cannon',
    [GetHashKey('WEAPON_KNUCKLE')] = 'Knuckle',
    [GetHashKey('WEAPON_NIGHTSTICK')] = 'Night Stick',
    [GetHashKey('WEAPON_POOLCUE')] = 'Pool Cue',
    [GetHashKey('WEAPON_SNOWBALL')] = 'Snowball',
    [GetHashKey('WEAPON_UNARMED')] = 'Fist',
    [GetHashKey('WEAPON_WRENCH')] = 'Wrench',
    [GetHashKey('WEAPON_DROWNING')] = 'Drowned',
    [GetHashKey('WEAPON_DROWNING_IN_VEHICLE')] = 'Drowned in Vehicle',
    [GetHashKey('WEAPON_BARBED_WIRE')] = 'Barbed Wire',
    [GetHashKey('WEAPON_BLEEDING')] = 'Bleed',
    [GetHashKey('WEAPON_ELECTRIC_FENCE')] = 'Electric Fence',
    [GetHashKey('WEAPON_EXHAUSTION')] = 'Exhaustion',
    [GetHashKey('WEAPON_FALL')] = 'Falling',
}

Citizen.CreateThread(
    function()
        Citizen.Wait(500)
        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            SetPedConfigFlag(PlayerPedId(), 184, true)
            isSpawned = true

            if status == "dead" then
                isDead = true
            else
                TriggerServerEvent("admin:playerGodModeWhitelist", false)
                SetPlayerInvincible(PlayerPedId(), false)
            end
        end
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
        end

        if status == "dead" then
            isSpawned = true
            isDead = true
            Citizen.CreateThread(function ()
                while isDead do
                    DisableInputGroup(0)
                    DisableInputGroup(1)
                    DisableInputGroup(2)
                    DisableAllControlActions(0)
                    EnableControlAction(0, 245, true)
                    EnableControlAction(0, 249, true)
                    EnableControlAction(0, 289, true)
                    EnableControlAction(0, 0, true)
                    EnableControlAction(0, 1, true)
                    EnableControlAction(0, 2, true)
                    EnableControlAction(0, 3, true)
                    EnableControlAction(0, 4, true)
                    EnableControlAction(0, 5, true)
                    EnableControlAction(0, 6, true)
                    EnableControlAction(0, 75, true)
                    DisablePlayerFiring(PlayerPedId(), true)
                    Citizen.Wait(1) 
                end
            end)
        else
            isDead = false
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(250)
            if isSpawned then
                local playerPed = PlayerPedId()

                if (IsEntityDead(playerPed) or IsPedDeadOrDying(playerPed, false)) and not isDead then
                    logDeath()
                    isDead = true
                    local seat = 0
                    local veh = GetVehiclePedIsUsing(playerPed)
                    if veh ~= 0 then
                        local vehmodel = GetEntityModel(veh)
                        for i = -1, GetVehicleModelNumberOfSeats(vehmodel) do
                            if GetPedInVehicleSeat(veh, i) == playerPed then
                                seat = i
                            end
                        end
                    else
                        while GetEntitySpeed(playerPed) > 0.5 do
                            Citizen.Wait(5)
                        end
                    end

                    NetworkResurrectLocalPlayer(GetEntityCoords(playerPed, false), true, true, false)

                    TriggerServerEvent("s:playerStatus", "dead")

                    if veh ~= 0 then
                        TaskWarpPedIntoVehicle(playerPed, veh, seat)
                    end

                    Citizen.CreateThread(
                        function()
                            while isDead do
                                if veh == 0 then
                                    SetPedToRagdoll(playerPed, 1000, 1000, 0, 0, 0, 0)
                                end
                                Wait(0)
                            end
                        end
                    )

                    Citizen.CreateThread(
                        function()
                            if isDead then
                                TriggerServerEvent("admin:playerGodModeWhitelist", true)
                            end

                            while isDead do
                                SetPlayerInvincible(PlayerPedId(), true)
                                veh = GetVehiclePedIsUsing(PlayerPedId())
                                Wait(1000)
                            end
                        end
                    )

                    Citizen.CreateThread(
                        function()
                            while isDead do
                                Wait(Config.updateDuration)
                                if isDead and veh == 0 then
                                    ClearPedTasksImmediately(playerPed)
                                    SetPedToRagdoll(playerPed, 1000, 1000, 0, 0, 0, 0)
                                end
                            end
                        end
                    )

                    Wait(300)
                    if seat == -1 then
                        SetVehicleUndriveable(veh, true)
                    end

                    while isDead do
                        playerPed = PlayerPedId()
                        if isDead and IsPedSittingInAnyVehicle(playerPed) and (not IsDeadVehAnimPlaying() or IsPedRagdoll(playerPed)) then
                            DoVehDeathAnim(playerPed)
                        end
                        Citizen.Wait(200)
                    end

                    ClearPedBloodDamage(playerPed)
                    ClearPedTasks(playerPed)

                    SetEntityInvincible(playerPed, false)
                    SetPlayerInvincible(PlayerPedId(), false)
                    TriggerServerEvent("admin:playerGodModeWhitelist", false)

                    if veh then
                        TaskWarpPedIntoVehicle(playerPed, veh, seat)
                    end
                end
            end
        end
    end
)

function IsDeadVehAnimPlaying()
    return IsEntityPlayingAnim(PlayerPedId(), Config.carAnimTree, Config.carAnim, 1)
end

function IsDeadAnimPlaying()
    return IsEntityPlayingAnim(PlayerPedId(), Config.defaultAnimTree, Config.defaultAnim, 1)
end

function DoVehDeathAnim(ped)
    loadAnimDict(Config.carAnimTree)
    TaskPlayAnim(ped, Config.carAnimTree, Config.carAnim, 8.0, -8, -1, 1, 0, 0, 0, 0)
end

function logDeath()
    local deathText = ""
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local killerEntity, deathCause = GetPedSourceOfDeath(playerPed), GetPedCauseOfDeath(playerPed)
    local killerClientId = NetworkGetPlayerIndexFromPed(killerEntity)

    local killerServerId = nil

    
    if IsEntityAVehicle(killerEntity) then
        local driverPed = GetPedInVehicleSeat(killerEntity, -1)
        if DoesEntityExist(driverPed) and IsPedAPlayer(driverPed) then
            local entityOwner = NetworkGetPlayerIndexFromPed(driverPed)
            killerServerId = GetPlayerServerId(entityOwner)
            deathText = deathText .. "Zabit hráčem " .. GetPlayerName(entityOwner) .. " (" .. killerServerId .. ")\n\n"
        end
    end


    if killerEntity ~= playerPed and killerClientId and NetworkIsPlayerActive(killerClientId) then
        killerServerId = GetPlayerServerId(killerClientId)
        deathText = deathText .. "Zabit hráčem " .. GetPlayerName(killerClientId) .. " (" .. killerServerId .. ")\n\n"
    end

    if deathHashTable[deathCause] then
        deathCause = deathHashTable[deathCause]
    end

    deathText = deathText .. "Důvod: " .. deathCause

    TriggerServerEvent(
        "logs:sendToLog",
        {
            channel = "umrti",
            title = "Úmrtí",
            description = deathText,
            color = "8782097",
            killer = killerServerId
        }
    )
end

function loadAnimDict(dict)
    RequestAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        Citizen.Wait(1)
    end
end
