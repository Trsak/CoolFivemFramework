RegisterCommand("rozsireni", function()
    openRemoveWeaponComponentMenu()
end)

RegisterCommand("doplnky", function()
    openRemoveWeaponComponentMenu()
end)

RegisterCommand("weaponcomponents", function()
    openRemoveWeaponComponentMenu()
end)

Citizen.CreateThread(function()
    Citizen.Wait(500)

    exports.chat:addSuggestion("/rozsireni", "Otevře menu pro správu rozšíření na zbrani")
    exports.chat:addSuggestion("/doplnky", "Otevře menu pro správu rozšíření na zbrani")
    exports.chat:addSuggestion("/weaponcomponents", "Otevře menu pro správu rozšíření na zbrani")
end)

function openRemoveWeaponComponentMenu(weaponHash)
    if weaponHash == nil then
        _, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true)
    end

    local foundAndHasComponents = false
    local components = {}
    local currentWeaponName

    for weaponName, weapon in pairs(Weapons) do
        local hash = GetHashKey(weaponName)
        if hash == weaponHash or hash == weaponHash % 0x100000000 and weapon.data and weapon.data.components and #weapon.data.components > 0 then
            foundAndHasComponents = true
            currentWeaponName = weaponName

            for i = 1, #weapon.data.components do
                table.insert(components, getComponentNameByHash(weaponName, weapon.data.components[i]))
            end

            break
        end
    end
    
    if not foundAndHasComponents then
        exports.notify:display({
            type = "error",
            title = "Rozšíření",
            text = "Tvoje zbraň nemá žádná rozšíření!",
            icon = "fas fa-times",
            length = 4000
        })
    else
        Citizen.CreateThread(function()
            WarMenu.CreateMenu("inventory_weapon_components", "Rozšíření na zbrani",
                "Zvolte, které rozšíření chcete odebrat")
            WarMenu.OpenMenu("inventory_weapon_components")

            while true do
                if WarMenu.IsMenuOpened("inventory_weapon_components") then
                    for _, component in each(components) do
                        if Items[component] then
                            if WarMenu.Button(Items[component].label) then
                                WarMenu.CloseMenu()

                                exports.progressbar:startProgressBar({
                                    Duration = 1000,
                                    Label = "Sundáváš rozšíření ze zbraně...",
                                    CanBeDead = false,
                                    CanCancel = true,
                                    DisableControls = {
                                        Movement = false,
                                        CarMovement = true,
                                        Mouse = false,
                                        Combat = true
                                    },
                                    Animation = {
                                        animDict = "mp_arresting",
                                        anim = "a_uncuff",
                                        flags = 51
                                    }
                                }, function(finished)
                                    if finished then
                                        TriggerServerEvent("inventory:removeComponentFromWeapon", currentWeaponName, component)
                                    end
                                end)
                            end
                        end
                    end

                    WarMenu.Display()
                else
                    break
                end

                Citizen.Wait(1)
            end
        end)
    end
end

AddEventHandler("inventory:usedItem", function(itemName, slot, data)
    local weaponAddon = Config.WeaponAddons[itemName]

    if weaponAddon then
        local weaponName = nil
        local _, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true)

        for weapon, value in pairs(weaponAddon) do
            if GetHashKey(weapon) == weaponHash or GetHashKey(weapon) == weaponHash % 0x100000000 then
                weaponName = weapon
                break
            end
        end

        if not weaponName then
            exports.notify:display({
                type = "error",
                title = "Chyba",
                text = "Rozšíření není kompatibilní s tvojí zbraní!",
                icon = "fas fa-times",
                length = 5000
            })
        else
            exports.progressbar:startProgressBar({
                Duration = 1000,
                Label = "Nasazuješ rozšíření na zbraň...",
                CanBeDead = false,
                CanCancel = true,
                DisableControls = {
                    Movement = false,
                    CarMovement = true,
                    Mouse = false,
                    Combat = true
                },
                Animation = {
                    animDict = "mp_arresting",
                    anim = "a_uncuff",
                    flags = 51
                }
            }, function(finished)
                if finished then
                    TriggerServerEvent("inventory:addComponentToWeapon", weaponName, itemName)
                end
            end)
        end
    end
end)

function getComponentNameByHash(weaponName, componentHash)
    for componentName, componentWeapon in pairs(Config.WeaponAddons) do
        if componentHash == componentWeapon[weaponName] then
            return componentName
        end
    end

    return nil
end

AddEventHandler("inventory:usedItem", function(itemName, slot, data)
    if itemName == "weapontoolkit" then
        usedWeaponToolkit(itemName, slot)
    elseif string.find(itemName, "weaponspray_mk2") then
        usedWeaponSpray(true, itemName, slot)
    elseif string.find(itemName, "weaponspray_") then
        usedWeaponSpray(false, itemName, slot)
    end
end)

function usedWeaponToolkit(itemName, slot)
    local _, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true)

    local weaponToUpdate

    for weaponName, _ in pairs(Weapons) do
        if GetHashKey(weaponName) == weaponHash or GetHashKey(weaponName) == weaponHash % 0x100000000 then
            weaponToUpdate = weaponName

            break
        end
    end

    if weaponToUpdate then
        local weaponCamos

        for weaponCamo, weaponCamoData in pairs(Config.WeaponCamos) do
            if string.lower(weaponCamo) == string.lower(weaponToUpdate) then
                weaponCamos = weaponCamoData
                break
            end
        end

        if weaponCamos == nil then
            exports.notify:display({
                type = "error",
                title = "Sada",
                text = "Tvoje zbraň nemá žádné možné úpravy vzhledu!",
                icon = "fas fa-times",
                length = 4000
            })
            return
        end

        WarMenu.CreateMenu("weapon_tints", "Úprava zbraně", "Vyberte úpravu zbraně")
        WarMenu.OpenMenu("weapon_tints")
        while WarMenu.IsMenuOpened("weapon_tints") do
            for tint, data in pairs(weaponCamos) do
                if WarMenu.Button(tint) then
                    exports.progressbar:startProgressBar({
                        Duration = 1500,
                        Label = "Upravuješ vzhled zbraně...",
                        CanBeDead = false,
                        CanCancel = true,
                        DisableControls = {
                            Movement = false,
                            CarMovement = true,
                            Mouse = false,
                            Combat = true
                        },
                        Animation = {
                            animDict = "mp_arresting",
                            anim = "a_uncuff",
                            flags = 51
                        }
                    }, function(finished)
                        if finished then
                            TriggerServerEvent("inventory:addCamoToWeapon", string.lower(weaponToUpdate), data.Components, slot)
                        end
                    end)

                    WarMenu.CloseMenu()
                end
            end

            WarMenu.Display()

            Citizen.Wait(1)
        end
    else
        exports.notify:display({
            type = "error",
            title = "Sada",
            text = "Musíš mít v ruce vhodnout zbraň!",
            icon = "fas fa-times",
            length = 4000
        })
    end
end

function usedWeaponSpray(isSpecial, itemName, slot)
    local _, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true)

    local weaponToSpray

    for weaponName, weapon in pairs(Weapons) do
        if GetHashKey(weaponName) == weaponHash or GetHashKey(weaponName) == weaponHash % 0x100000000 then
            if not weapon.isMelee then
                weaponToSpray = weaponName
            end

            break
        end
    end

    if weaponToSpray then
        if (string.find(weaponToSpray, "mk2") and not isSpecial) or
            (not string.find(weaponToSpray, "mk2") and isSpecial) then
            exports.notify:display({
                type = "error",
                title = "Barva",
                text = "Tento sprej není vhodný na zbraň co máš v ruce!",
                icon = "fas fa-times",
                length = 4000
            })
            return
        end

        exports.progressbar:startProgressBar({
            Duration = 1500,
            Label = "Upravuješ vzhled zbraně...",
            CanBeDead = false,
            CanCancel = true,
            DisableControls = {
                Movement = false,
                CarMovement = true,
                Mouse = false,
                Combat = true
            },
            Animation = {
                emotes = "sprayweapon"
            }
        }, function(finished)
            if finished then
                TriggerServerEvent("inventory:setWeaponColor", weaponToSpray, itemName, slot, isSpecial)
            end
        end)
    else
        exports.notify:display({
            type = "error",
            title = "Barva",
            text = "Na zbraň co máš v ruce aplikovat barvu nelze!",
            icon = "fas fa-times",
            length = 4000
        })
    end
end
