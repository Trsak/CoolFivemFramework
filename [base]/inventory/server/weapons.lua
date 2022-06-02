RegisterNetEvent("inventory:setWeaponAmmo")
AddEventHandler("inventory:setWeaponAmmo", function(weapon, ammoCount)
    local client = source
    local identifier = GetPlayerIdentifier(client, 0)

    if Inventories[identifier] ~= nil then
        for index, item in each(Inventories[identifier].data) do
            if Items[item.name].type == "weapon" and item.data.activeWeapon and item.name == weapon then
                item.data.ammo = ammoCount
                if Config.Weapons[item.name].isThrowable then
                    removePlayerItem(client, item.name, 1, item.data, item.slot)
                end
                break
            end
        end
        setCharInventoryWithoutReload(client, Inventories[identifier])
    end
end)

RegisterNetEvent("inventory:setWeaponFireMode")
AddEventHandler("inventory:setWeaponFireMode", function(weaponHash, number, ammoCount)
    local client = source
    local identifier = GetPlayerIdentifier(client, 0)

    if Inventories[identifier] ~= nil then
        for index, item in each(Inventories[identifier].data) do
            if Items[item.name].type == "weapon" and item.data.activeWeapon and GetHashKey(item.name) == weaponHash then
                item.data.ammo = ammoCount
                item.data.fireMode = number
                break
            end
        end

        setCharInventoryWithoutReload(client, Inventories[identifier])
    end
end)

RegisterNetEvent("inventory:setMagazineAmmo")
AddEventHandler("inventory:setMagazineAmmo", function(ammoCount, slot)
    local client = source
    local identifier = GetPlayerIdentifier(client, 0)
    if Inventories[identifier] then
        for index, item in each(Inventories[identifier].data) do
            if item.data.isMagazine and item.slot == slot then
                item.data.currentAmmo = ammoCount
                item.data.amount = ammoCount
                item.data.label = "Počet nábojů: " .. ammoCount
                break
            end
        end

        setCharInventoryWithoutReload(client, Inventories[identifier])
    end
end)
