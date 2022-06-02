local equipedWeapon = {
    hash = nil,
    maxFireRatio = nil
}
local weaponData = {
    activeWeapon = {},
    lastWeapon = nil,
    shootingDisabled = false,
    reloading = false

}

local isSpawned, isDead = false, false
local currentAmmo, currentVehicle, currentStrength = 0, nil, 0.0

-- INIT SCRIPT
Citizen.CreateThread(function()
    local status = exports.data:getUserVar("status")
    if status == "spawned" then
        isSpawned = true
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        isSpawned, isDead = false, false
        equipedWeapon.hash, equipedWeapon.maxFireRatio = nil, nil
        currentStrength, currentAmmo, currentVehicle = 0, nil, 0
        weaponData = {
            activeWeapon = {},
            lastWeapon = nil,
            shootingDisabled = false,
            reloading = false

        }
    elseif status == "spawned" or status == "dead" then
        isDead = (status == "dead")
        if not isSpawned then
            isSpawned = true
            equipedWeapon.hash, equipedWeapon.maxFireRatio = nil, nil
            currentStrength, currentAmmo, currentVehicle = 0, nil, 0
            weaponData = {
                activeWeapon = {},
                lastWeapon = nil,
                shootingDisabled = false,
                reloading = false

            }
        end
    end
end)

--- THREADS

-- Getting current weapon in hands with inventory data
Citizen.CreateThread(function()
    while true do
        if not IsPauseMenuActive() then
            local playerPed = PlayerPedId()
            local currentWeapon, weaponFound = GetSelectedPedWeapon(playerPed), false
            local hasWeapon, weaponHash = GetCurrentPedWeapon(playerPed)
            if hasWeapon and not IsPedArmed(playerPed, 1) then
                if Config.WeaponData[currentWeapon] then
                    weaponFound = "weapon"
                elseif Config.WeaponData[(currentWeapon % 0x100000000)] then
                    currentWeapon = currentWeapon % 0x100000000
                    weaponFound = "weapon"
                elseif Config.Throwable[currentWeapon] then
                    weaponFound = "throwable"
                elseif Config.Throwable[(currentWeapon % 0x100000000)] then
                    currentWeapon = currentWeapon % 0x100000000
                    weaponFound = "throwable"
                elseif Config.Tank[currentWeapon] then
                    weaponFound = "tank"
                elseif Config.Tank[(currentWeapon % 0x100000000)] then
                    currentWeapon = currentWeapon % 0x100000000
                    weaponFound = "tank"
                end
                
                if weaponFound then
                    if not weaponData.lastWeapon or weaponData.lastWeapon.hash ~= currentWeapon then
                        local activeWeapons = exports.inventory:getActiveWeapons()
                        for itemName, itemData in each(activeWeapons) do
                            if currentWeapon == GetHashKey(itemName) then
                                if not weaponData.lastWeapon or weaponData.lastWeapon.number ~= itemData.data.number then
                                    if weaponFound == "weapon" then
                                        equipedWeapon.maxFireRatio = Config.WeaponData[currentWeapon].fireMode
                                    else
                                        equipedWeapon.maxFireRatio = "disabled"
                                    end
                                    equipedWeapon.hash = currentWeapon
                                    weaponData.activeWeapon = itemData.data
                                    weaponData.activeWeapon.name = itemData.name
                                    weaponData.activeWeapon.hasClip = Config.Weapons[itemName].hasClip
                                    weaponData.activeWeapon.hash = Config.Weapons[itemName].hash
                                    weaponData.shootingDisabled = (itemData.data.fireMode == 0)
                                    weaponData.activeWeapon.type = weaponFound
                                    weaponData.lastWeapon = {
                                        hash = currentWeapon,
                                        number = itemData.number
                                    }
                                    break
                                end
                            end
                        end
                    end
                elseif equipedWeapon.maxFireRatio then
                    equipedWeapon.maxFireRatio, equipedWeapon.hash = nil, nil
                    equipedWeapon.hash = nil
                    weaponData.lastWeapon = false
                    weaponData.activeWeapon = {}
                end
                if equipedWeapon.hash and not equipedWeapon.maxFireRatio and not IsPedArmed(PlayerPedId(), 2) then
                    weaponData.shootingDisabled = true
                end
            else
                if equipedWeapon.maxFireRatio then
                    equipedWeapon.maxFireRatio = nil
                    equipedWeapon.hash = nil
                    weaponData.lastWeapon = false
                    weaponData.activeWeapon = {}
                end
                weaponData.shootingDisabled = false
            end
        end
        Citizen.Wait(500)
    end
end)

-- Shooting handler 
Citizen.CreateThread(function()
    while true do
        if not IsPauseMenuActive() and equipedWeapon.maxFireRatio and equipedWeapon.hash then
            local playerPed, button = PlayerPedId(), 24
            local button = 24
            if IsControlJustPressed(1, 54) then
                if IsFlashLightOn(playerPed) then
                    SetFlashLightKeepOnWhileMoving(1)
                else
                    SetFlashLightKeepOnWhileMoving(0)
                end
            end

            if currentVehicle then
                button = 69
            end

            if IsDisabledControlJustReleased(1, 45) and not weaponData.Reloading and not IsPedReloading(playerPed) then
                local maxAmmo = GetMaxAmmoInClip(playerPed, equipedWeapon.hash, 1)
                if maxAmmo ~= weaponData.activeWeapon.ammo then
                    weaponData.Reloading = true
                    weaponData.shootingDisabled = true
                    reload()
                end
            end

            if IsDisabledControlJustPressed(1, button) and weaponData.activeWeapon.type == "weapon" then
                local fireMode = weaponData.activeWeapon.fireMode
                if fireMode == 0 then
                    PlaySoundFrontend(-1, "HACKING_MOVE_CURSOR", 0, 1)
                else
                    local isNotFirstPerson = (GetFollowVehicleCamViewMode() ~= 4)
                    if not fireMode or fireMode == 1 then
                        -- Clicking simulator
                        if not weaponData.shootingDisabled then

                            if isNotFirstPerson or currentVehicle then
                                if weaponData.activeWeapon.ammo ~= 0 then
                                    shoot()
                                end
                            end
                            while IsDisabledControlPressed(1, button) do
                                DisablePlayerFiring(PlayerId(), true)
                                Citizen.Wait(0)
                            end
                        end
                    elseif weaponData.activeWeapon.fireMode == 2 then
                        -- Semi simulator
                        if not weaponData.shootingDisabled then

                            if isNotFirstPerson or currentVehicle then
                                if weaponData.activeWeapon.ammo ~= 0 then
                                    shoot()
                                end
                            end
                            Citizen.Wait(200)
                            while IsDisabledControlPressed(1, button) do
                                DisablePlayerFiring(PlayerId(), true)
                                Citizen.Wait(0)
                            end
                        end
                    elseif weaponData.activeWeapon.fireMode == 3 then
                        -- Full auto
                        if isNotFirstPerson or currentVehicle then

                            if weaponData.activeWeapon.ammo ~= 0 then
                                shoot()
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(1)
    end
end)

-- Blocking shooting with FireMode thread
Citizen.CreateThread(function()
    local breaked = false
    while true do
        if not IsPauseMenuActive() then
            if equipedWeapon.hash then
                _, currentAmmo = GetAmmoInClip(PlayerPedId(), equipedWeapon.hash)
                if equipedWeapon.maxFireRatio then
                    weaponData.activeWeapon.ammo = currentAmmo
                end

                if currentAmmo == 1 and not breaked then
                    SetWeaponsNoAutoswap(true)
                    SetWeaponsNoAutoreload(true)
                    breaked = true
                elseif currentAmmo > 1 and breaked then
                    breaked = false
                else
                    if equipedWeapon.maxFireRatio then
                        local currentFireMode = weaponData.activeWeapon.fireMode
                        if not currentFireMode or currentFireMode ~= 0 then
                            if weaponData.shootingDisabled and not currentVehicle then
                                weaponData.shootingDisabled = false
                            end
                        else
                            weaponData.shootingDisabled = true
                        end
                    end
                end
            end
        end
        Citizen.Wait(1)
    end
end)

-- Blocking shooting in vehicle thread
Citizen.CreateThread(function()
    while true do
        local refreshTime, playerPed = 100, PlayerPedId()
        local isInVehicle = IsPedInAnyVehicle(playerPed)
        if currentVehicle then
            refreshTime = 10
        end

        if not currentVehicle and isInVehicle then
            currentVehicle = GetVehiclePedIsIn(playerPed)
        elseif not isInVehicle then
            currentVehicle = nil
        end

        if currentVehicle then
            if DoesVehicleHaveWeapons(currentVehicle) then
                for _, weaponHash in each(Config.VehicleWeapons) do
                    DisableVehicleWeapon(true, weaponHash, currentVehicle, playerPed)
                end
            end

            if equipedWeapon.hash then
                if GetFollowVehicleCamViewMode() == 4 then -- First person
                    weaponData.shootingDisabled = false
                    SetPlayerCanDoDriveBy(PlayerId(), true)
                else
                    weaponData.shootingDisabled = true
                    SetPlayerCanDoDriveBy(PlayerId(), false)
                end
            else
                SetPlayerCanDoDriveBy(PlayerId(), true)
            end
        end

        Citizen.Wait(refreshTime)
    end
end)

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()

        if equipedWeapon.maxFireRatio ~= "reticle" then
            HideHudComponentThisFrame(14)
        end
        -- Hide hud weapons
        HideHudComponentThisFrame(22)

        if IsPedBeingStunned(playerPed) then
            SetPedMinGroundTimeForStungun(playerPed, 7000)
        end

        while weaponData.shootingDisabled do
            DisablePlayerFiring(PlayerId(), true)
            DisableControlAction(0, 45, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 264, true)
            Citizen.Wait(0)
        end

        DisableControlAction(0, 140, true)
        DisableControlAction(0, 141, true)

        if equipedWeapon.hash then
            DisableControlAction(0, 45, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 264, true)

            if IsPlayerFreeAiming(PlayerId()) then
                local group = GetWeapontypeGroup(equipedWeapon.hash)
                if group ~= 416676503 and group ~= 2685387236 then
                    DisableControlAction(0, 22, true)
                end
            end
        end
        if IsPedShooting(playerPed) then

            while IsPedShooting(playerPed) do
                Citizen.Wait(1)
            end
            shoot()
        end
        Citizen.Wait(1)
    end
end)

createNewKeyMapping({
    command = "changeFireRate",
    text = "Odjištění / zajištění zbraně",
    key = "Z"
})

function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

-- FUNCTIONS 

function changeFireRatio() -- change current weaopon fire rate
    if not equipedWeapon.maxFireRatio or equipedWeapon.maxFireRatio == "disabled" then
        return
    end
    local newMode = "error"

    if weaponData.activeWeapon.fireMode == 0 then
        newMode = "single"
        PlaySoundFrontend(-1, "Reset_Prop_Position", "DLC_Dmod_Prop_Editor_Sounds", 0)
        weaponData.activeWeapon.fireMode = 1
    elseif weaponData.activeWeapon.fireMode == 1 then
        newMode = (equipedWeapon.maxFireRatio == "full" and "burst" or "safety")
        PlaySoundFrontend(-1, "Faster_Click", "RESPAWN_ONLINE_SOUNDSET", 1)
        weaponData.activeWeapon.fireMode = (equipedWeapon.maxFireRatio == "full" and 2 or 0)
    elseif weaponData.activeWeapon.fireMode == 2 then
        newMode = "automatic"
        PlaySoundFrontend(-1, "Faster_Click", "RESPAWN_ONLINE_SOUNDSET", 1)
        weaponData.activeWeapon.fireMode = 3
    elseif weaponData.activeWeapon.fireMode == 3 then
        newMode = "safety"
        PlaySoundFrontend(-1, "Reset_Prop_Position", "DLC_Dmod_Prop_Editor_Sounds", 0)
        weaponData.activeWeapon.fireMode = 0
    end
    weaponData.shootingDisabled = (newMode == "safety")

    exports.notify:display({
        type = "success",
        title = "Zbraň",
        text = Config.FireModes[newMode],
        icon = "game-icon game-icon-heavy-bullets",
        length = 1000
    })
    TriggerServerEvent("inventory:setWeaponFireMode", weaponData.activeWeapon.hash, weaponData.activeWeapon.fireMode,
        currentAmmo)
end

function applyRecoil() -- Apply recoil when player start shooting
    local playerPed = PlayerPedId()
    if IsPedArmed(playerPed, 4) and not Config.NoRecoil[equipedWeapon.hash] then
        local GamePlayCam = GetFollowPedCamViewMode()
        local MovementSpeed = math.ceil(GetEntitySpeed(playerPed))
        if MovementSpeed > 69 then
            MovementSpeed = 69
        end
        local group = GetWeapontypeGroup(equipedWeapon.hash)

        local pitch = GetGameplayCamRelativePitch()
        local cameraDistance = #(GetGameplayCamCoord() - GetEntityCoords(playerPed))
        local rightleft = math.random(0, 4)
        local h = GetGameplayCamRelativeHeading()
        local hf = math.random(10, 40 + MovementSpeed) / 100
        local recoil = math.random(100, 140 + MovementSpeed) / 100
        local strength = exports.data:getCharVar("skills").strength

        if cameraDistance < 5.3 then
            cameraDistance = 1.5
        else
            if cameraDistance < 8.0 then
                cameraDistance = 4.0
            else
                cameraDistance = 7.0
            end
        end

        if currentVehicle then
            recoil = recoil + (recoil * cameraDistance)
        else
            recoil = recoil * 0.1
        end

        if GamePlayCam == 4 then
            recoil = recoil * 1.0
        end

        if group == 970310034 then -- Rifles
            recoil = recoil * (3.5 - strength / 20)
            hf = hf * (2.5 - strength / 20)
        elseif group == 860033945 then -- Shotguns
            recoil = recoil * (9.0 - strength / 20)
            hf = hf * (15.0 - strength / 20)
        elseif group == 416676503 then -- Handguns
            recoil = recoil * (3.0 - strength / 20)
            hf = hf * (2.0 - strength / 20)
        elseif group == -957766203 then -- Machines
            recoil = recoil * (3.2 - strength / 20)
            hf = hf * (2.0 - strength / 20)
        end

        if currentVehicle then
            hf = hf * 4.7
        end

        if GamePlayCam == 4 then
            hf = hf * 1.9
        end

        recoil = recoil + (rightleft / 5)
        hf = hf + (rightleft / 5)

        if rightleft == 1 or rightleft == 3 then
            SetGameplayCamRelativeHeading(h + hf)
        elseif rightleft == 2 or rightleft == 4 then
            SetGameplayCamRelativeHeading(h - hf)
        end

        local set = pitch + recoil

        SetGameplayCamRelativePitch(set, 0.8)
    end
end

function reload() -- Just reload
    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        local maxAmmo = GetMaxAmmoInClip(playerPed, equipedWeapon.hash, 1)
        local found = {}

        if weaponData.activeWeapon.hasAmmo then
            local lookForMagazine = weaponData.activeWeapon.hasClip

            local usableItems = exports.inventory:getUsableItems()
            for _, item in each(usableItems) do
                if not lookForMagazine and item.data.isAmmo then
                    if weaponData.activeWeapon.ammoType == item.data.ammoType then
                        reloadWeaponWithAmmo(weaponData.activeWeapon.hash, item.name, item.slot, item.data)
                        break
                    end
                elseif lookForMagazine and item.data.isMagazine then
                    if split(weaponData.activeWeapon.name, "_")[2] == split(item.name, "_")[2] then
                        if item.data.currentAmmo ~= 0 then
                            table.insert(found, {item.data.currentAmmo, item.name, item.slot, item.data})
                        end
                    end
                end
            end

            table.sort(found, function(a, b)
                return a[1] > b[1]
            end)

            if found[1] then
                reloadWeaponWithMagazine(weaponData.activeWeapon.hash, found[1][2], found[1][3], found[1][4])
            end
        end
        weaponData.shootingDisabled = false
        weaponData.Reloading = false
    end)
end

function shoot() -- Just shoot
    Citizen.CreateThread(function()
        if equipedWeapon.maxFireRatio and weaponData.activeWeapon.type == "weapon" then
            if weaponData.activeWeapon.fireMode and weaponData.activeWeapon.fireMode ~= 0 then
                applyRecoil()
                TriggerServerEvent("inventory:setWeaponAmmo", getWeaponData(weaponData.activeWeapon.hash).name,
                    currentAmmo)
                -- local playerPed = PlayerPedId()
                -- local clothes = getClothes(playerPed)
                -- local coords = GetEntityCoords(playerPed)
                -- local found, newZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
                -- coords = vector3(coords.x, coords.y, newZ - 0.2)
                -- TriggerServerEvent("weapons_scripts:server:shot", coords, weaponData.activeWeapon, clothes)
            end
        elseif weaponData.activeWeapon.type ~= "weapon" and equipedWeapon.hash then
            local weapon = equipedWeapon.hash
            local weaponData = Config.Tank[weapon]
            if not weaponData then
                weaponData = Config.Throwable[weapon]
            end
            
            if weaponData then
                local playerPed = PlayerPedId()
                local _, ammoInClip = GetAmmoInClip(playerPed, weapon)
                TriggerServerEvent("inventory:setWeaponAmmo", getWeaponData(weapon).name, ammoInClip)
            end
        end
    end)
end

function getWeaponData(weaponHash) -- get inventory weapon data
    local data = exports.inventory:getWeaponFromHash(weaponHash)
    if not data then
        data = exports.inventory:getWeaponFromHash(weaponHash % 0x100000000)
    end
    return data
end

-- Commands

RegisterCommand("changeFireRate", changeFireRatio) -- command for change weapon fire ratio
