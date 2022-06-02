AddEventHandler("inventory:usedItem", function(itemName, slot, data)
    if string.find(itemName, "magazine_") or string.find(itemName, "ammo_") then
        if not canReload() and not LocalPlayer.state.isCuffed then
            local playerPed = PlayerPedId()
            local _, weaponHash = GetCurrentPedWeapon(playerPed, true)
            local weapon = getWeaponData(weaponHash)
            if weapon and weapon.hasAmmo then
                if string.find(itemName, "ammo_") then
                    if weapon.hasClip then
                        loadAmmoIntoMagazine({
                            slot = slot,
                            data = data,
                            count = 1,
                            name = itemName
                        }, data)
                    elseif data.isAmmo then
                        reloadWeaponWithAmmo(weaponHash, itemName, slot, data)
                    end
                else
                    reloadWeaponWithMagazine(weaponHash, itemName, slot, data)
                end
            end
        end
    end
end)

function reloadWeaponWithAmmo(weaponHash, itemName, slot, data)
    local playerPed = PlayerPedId()
    local maxAmmo, ammoCount, weapon = getDependencies(weaponHash, playerPed)
    if not IsPedReloading(playerPed) then
        local ammo = Config.Ammo[itemName]
        local magazine = false
        local found = false
        if weapon and weapon.ammoType == data.ammoType then
            if ammoCount >= maxAmmo then
                exports.notify:display({
                    type = "error",
                    title = "Chyba",
                    text = "Zbraň je již plně nabitá!",
                    icon = "fas fa-times",
                    length = 5000
                })
            else
                ammoCount = ammoCount + ammo.ammo

                SetAmmoInClip(playerPed, weaponHash, 0)
                SetPedAmmo(playerPed, weaponHash, ammoCount)
                MakePedReload(playerPed)

                TriggerServerEvent("inventory:setWeaponAmmo", weapon.name, ammoCount)
                TriggerServerEvent("inventory:removePlayerItem", itemName, ammo.ammo, data, slot)
            end
        else
            exports.notify:display({
                type = "error",
                title = "Chyba",
                text = "Tento typ nábojů nepatří do této zbraně!",
                icon = "fas fa-times",
                length = 5000
            })
        end
    end
end

function reloadWeaponWithMagazine(weaponHash, itemName, slot, data)
    local playerPed = PlayerPedId()
    local maxAmmo, ammoCount, weapon = getDependencies(weaponHash, playerPed)
    if not IsPedReloading(playerPed) then

        local magazineData = Config.Magazines[itemName]
        local magazineHash = Config.WeaponAddons[magazineData.type][weapon.name]
        local ammoInMagazine = data.currentAmmo
        local compInWeapon = false
        local weaponComponents, magazineComponentFounded = nil, nil

        local activeWeapons = exports.inventory:getActiveWeapons()
        for _, v in each(activeWeapons) do
            if weapon.name == v.name then
                if v.data.components then
                    weaponComponents = v.data.components
                    for i, component in each(v.data.components) do
                        if magazineHash == component then
                            magazineComponentFounded = true
                            break
                        end
                    end
                end
            end
        end

        if weaponComponents and not magazineComponentFounded then
            for _, componentHash in each(weaponComponents) do
                local componentName = exports.inventory:getComponentNameByHash(weapon.name, componentHash)
                if componentHash and componentName then
                    if componentName ~= "clip_default" and string.find(componentName, "clip_") then
                        compInWeapon = componentName
                        break
                    end
                end
            end
        end

        if split(weapon.name, "_")[2] == split(itemName, "_")[2] then
            if weapon.hasAmmo and weapon.hasClip then
                if weapon and isSameAmmoType(weapon.ammoType, magazineData.ammoType) then
                    if magazineData.type ~= "clip_default" then
                        if not magazineComponentFounded and not compInWeapon then
                            GiveWeaponComponentToPed(playerPed, weaponHash, magazineHash)
                            TriggerServerEvent("inventory:addComponentToWeapon", weapon.name, magazineData.type, nil, true)
                            Citizen.Wait(500)
                        end
                    else
                        GiveWeaponComponentToPed(playerPed, weaponHash, magazineHash)
                        if compInWeapon then
                            TriggerServerEvent("inventory:removeComponentFromWeapon", weapon.name, compInWeapon, "clip")
                        end
                        Citizen.Wait(500)
                    end

                    SetAmmoInClip(playerPed, weaponHash, 0)
                    SetPedAmmo(playerPed, weaponHash, ammoInMagazine)   
                    MakePedReload(playerPed)

                    TriggerServerEvent("inventory:setWeaponAmmo", weapon.name, ammoInMagazine)
                    TriggerServerEvent("inventory:setMagazineAmmo", ammoCount, slot)
                else
                    exports.notify:display({
                        type = "error",
                        title = "Chyba",
                        text = "Použitý zásobník není určen do této zbraně!",
                        icon = "fas fa-times",
                        length = 5000
                    })
                end
            else
                exports.notify:display({
                    type = "error",
                    title = "Chyba",
                    text = "Tato zbraň nemá zásobník!",
                    icon = "fas fa-times",
                    length = 5000
                })
            end
        end
    end
end

function reloadMagazine(weaponHash, itemName, slot, data, ammoUsed, magslot)
    local playerPed = PlayerPedId()
    local maxAmmo, ammoCount, weapon = getDependencies(weaponHash, playerPed)
    local ammo = Config.Ammo[itemName]
    local magazine = false
    local found = false
    local ammoUsedReload = nil

    if ammoUsed then
        ammoUsedReload = ammoUsed
    else
        ammoUsedReload = ammo.ammo
    end

    local usableItems = exports.inventory:getUsableItems()
    for _, item in each(usableItems) do
        if not magslot then
            if item.data.isMagazine then
                if item.data.ammoType == ammo.ammoType then
                    if item.data.currentAmmo ~= item.data.maxAmmo then
                        found, magazine = true, item
                        break
                    end
                end
            end
        else
            if item.slot == magslot then
                found, magazine = true, item
                break
            end
        end
    end

    if found then
        if magazine.data.ammoType == ammo.ammoType then
            if magazine.data.currentAmmo < magazine.data.maxAmmo then
                exports.progressbar:startProgressBar({
                    Duration = 6500,
                    Label = "Nabíjíš zásobník..",
                    CanBeDead = false,
                    CanCancel = true,
                    DisableControls = {
                        Movement = false,
                        CarMovement = true,
                        Mouse = false,
                        Combat = true
                    },
                    Animation = {
                        emotes = itemName
                    }
                }, function(finished)
                    if finished then

                        magazine.data.currentAmmo = magazine.data.currentAmmo + ammoUsedReload

                        if magazine.data.currentAmmo > magazine.data.maxAmmo then
                            magazine.data.currentAmmo = magazine.data.maxAmmo
                        end

                        TriggerServerEvent("inventory:setMagazineAmmo", magazine.data.currentAmmo, magazine.slot)
                        TriggerServerEvent("inventory:removePlayerItem", itemName, ammoUsedReload, data, slot)
                    end
                end)
            else
                exports.notify:display({
                    type = "error",
                    title = "Chyba",
                    text = "Zasobník je už plný!",
                    icon = "fas fa-times",
                    length = 5000
                })
            end
        else
            exports.notify:display({
                type = "error",
                title = "Chyba",
                text = "Špatný typ náboju!",
                icon = "fas fa-times",
                length = 5000
            })
        end
    else
        exports.notify:display({
            type = "error",
            title = "Chyba",
            text = "Nemáš žádný zásobník k páskování!",
            icon = "fas fa-times",
            length = 5000
        })
    end
end

function loadAmmoIntoMagazine(item, data)
    if not IsPedArmed(PlayerPedId(), 4) or not IsPedArmed(PlayerPedId(), 2) then
        if not canReload() then
            local playerPed = PlayerPedId()
            local _, weaponHash = GetCurrentPedWeapon(playerPed, true)
            local maxAmmo = GetMaxAmmoInClip(playerPed, weaponHash, 1)
            local _, ammoCount = GetAmmoInClip(playerPed, weaponHash)
            local weapon = exports.inventory:getWeaponFromHash(weaponHash)
            local found = false

            for k, v in each(exports.inventory:getUsableItems()) do
                if v.data.isMagazine then
                    if item.data.ammoType == v.data.ammoType then
                        if v.data.maxAmmo ~= v.data.currentAmmo then
                            need = v.data.maxAmmo - v.data.currentAmmo
                            used = nil
                            if need >= item.count then
                                used = item.count
                            else
                                used = need
                            end
                            found = true
                            reloadMagazine(weaponHash, item.name, item.slot, item.data, used, v.slot)
                            break
                        end
                    end
                end
            end

            if not found then
                exports.notify:display({
                    type = "error",
                    title = "Chyba",
                    text = "Nemáš žádný zásobník k páskování!",
                    icon = "fas fa-times",
                    length = 5000
                })
            end
        end
    else
        exports.notify:display({
            type = "error",
            title = "Chyba",
            text = "Nemůžeš páskovat se zbraní v ruce!",
            icon = "fas fa-times",
            length = 5000
        })
    end
end

function canReload()
    return IsEntityPlayingAnim(PlayerPedId(), "mp_arresting", "a_uncuff", 2)
end

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

function getDependencies(weaponHash, playerPed)
    local maxAmmo = GetMaxAmmoInClip(playerPed, weaponHash, 1)
    local _, ammoCount = GetAmmoInClip(playerPed, weaponHash)
    local weapon = getWeaponData(weaponHash)
    return maxAmmo, ammoCount, weapon
end

function isSameAmmoType(weaponType, magazineType)
    if weaponType == magazineType then
        return true
    elseif (weaponType % 0x10000000) == (magazineType % 0x100000000) then
        return true
    elseif (weaponType % 0x10000000) == magazineType then
        return true
    elseif weaponType == (magazineType % 0x10000000) then
        return true
    end
    return false
end

function dump(node, printing)
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