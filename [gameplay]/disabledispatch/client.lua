local isSpawned = false

local SUPPRESSED_MODELS = {
    "JET", -- They spawn on LSIA and try to take off and land, remove this if you still want em in the skies
    "LAZER", -- They spawn on Zancudo and try to take off
    "TITAN", -- They spawn on Zancudo and try to take off
    "BARRACKS", -- Regularily driving around the Zancudo airport surface
    "BARRACKS2", -- Regularily driving around the Zancudo airport surface
    "CRUSADER", -- Regularily driving around the Zancudo airport surface
    "RHINO", -- Regularily driving around the Zancudo airport surface
    "BLIMP"
}

function SetWeaponDrops()
    local handle, ped = FindFirstPed()
    local finished = false

    repeat
        if not IsEntityDead(ped) then
            SetPedDropsWeaponsWhenDead(ped, false)
        end
        finished, ped = FindNextPed(handle)
    until not finished

    EndFindPed(handle)
end

Citizen.CreateThread(
    function()
        while not exports.data:isUserLoaded() do
            Citizen.Wait(100)
        end

        local status = exports.data:getUserVar("status")
        if status == ("spawned" or "dead") then
            isSpawned = true
        end

        while not isSpawned do
            Citizen.Wait(200)
        end

        SwitchTrainTrack(0, true)
        SwitchTrainTrack(3, true)
        SetTrainTrackSpawnFrequency(0, 120000)
        SetRandomTrains(true)

        while true do
            Citizen.Wait(1)
            DisablePlayerVehicleRewards(PlayerId())
        end
    end
)

Citizen.CreateThread(
    function()
        while not isSpawned do
            Citizen.Wait(200)
        end

        while true do
            SetWeaponDrops()

            for _, model in each(SUPPRESSED_MODELS) do
                SetVehicleModelIsSuppressed(GetHashKey(model), true)
            end

            SetPedConfigFlag(PlayerPedId(), 35, false)

            if GetEntityMaxHealth(PlayerPedId()) ~= 200 then
                SetEntityMaxHealth(PlayerPedId(), 200)
                SetEntityHealth(PlayerPedId(), 200)
            end

            SetPlayerHealthRechargeLimit(PlayerId(), 0)

            RemoveAllPickupsOfType('PICKUP_WEAPON_GolfClub')
            RemoveAllPickupsOfType('PICKUP_WEAPON_CARBINERIFLE')
            RemoveAllPickupsOfType('PICKUP_WEAPON_PISTOL')
            RemoveAllPickupsOfType('PICKUP_WEAPON_PUMPSHOTGUN')
            RemoveAllPickupsOfType('PICKUP_WEAPON_COMBATPDW')
            RemoveAllPickupsOfType('PICKUP_WEAPON_COMBATPISTOL')
            RemoveAllPickupsOfType('PICKUP_WEAPON_COMBATPISTOL')

            Citizen.Wait(500)
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(10)

            SetCreateRandomCops(0)
            CancelCurrentPoliceReport()
            DistantCopCarSirens(false)

            for i = 0, 15 do
                EnableDispatchService(i, false)
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while not isSpawned do
            Citizen.Wait(200)
        end

        while true do
            local playerLocalisation = GetEntityCoords(PlayerPedId())
            ClearAreaOfCops(playerLocalisation.x, playerLocalisation.y, playerLocalisation.z, 200.0)
            ClearAreaOfPeds(342.44, -587.00, 27.79, 25.0, 1)
            ClearAreaOfPeds(472.45095825195, -989.45037841797, 23.914764404297, 25.0, 1)
            SetPedConfigFlag(PlayerPedId(), 35, false)
            Citizen.Wait(200)
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == ("spawned" or "dead") then
            isSpawned = true
        else
            isSpawned = false
        end
    end
)
