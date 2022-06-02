RegisterNetEvent("inventory:addComponentToWeapon")
AddEventHandler(
    "inventory:addComponentToWeapon",
    function(weaponName, component, slot, reload)
        local _source = source

        local identifier = GetPlayerIdentifier(_source, 0)
        if Inventories[identifier] then
            for index, item in each(Inventories[identifier].data) do
                if item.name == weaponName and item.data and item.data.activeWeapon then
                    if item.data.components then
                        for i, comp in each(item.data.components) do
                            local componentName = getComponentNameByHash(item.name, comp)
                            if componentName == component then
                                TriggerClientEvent("inventory:error", _source, "componentAlreadyOn")
                                return
                            end
                            if
                            (string.find(component, "scope") or string.find(component, "sight")) and
                                (string.find(componentName, "scope") or string.find(componentName, "sight"))
                            then
                                TriggerClientEvent("inventory:error", _source, "scopeAlreadyOn")
                                return
                            end
                        end

                        for i, comp in each(item.data.components) do
                            local componentName = getComponentNameByHash(item.name, comp)
                            if Config.SameWeaponAddons[component] then
                                for x, sameComponent in each(Config.SameWeaponAddons[component]) do
                                    if sameComponent == componentName then
                                        if slot then
                                            addPlayerItem(_source, componentName, 1, {}, nil)
                                        end
                                        table.remove(item.data.components, i)
                                    end
                                end
                            end
                        end
                    end

                    if not item.data.components then
                        item.data.components = {}
                    end

                    if reload or removePlayerItem(_source, component, 1, {}) == "done" then
                        table.insert(item.data.components, Config.WeaponAddons[component][item.name])
                        setCharInventory(_source, Inventories[identifier])
                    end
                end
            end
        end
    end
)

RegisterNetEvent("inventory:removeComponentFromWeapon")
AddEventHandler(
    "inventory:removeComponentFromWeapon",
    function(weaponName, component, clip)
        local _source = source

        local identifier = GetPlayerIdentifier(_source, 0)
        if Inventories[identifier] then
            for index, item in each(Inventories[identifier].data) do
                if item.name == weaponName and item.data and item.data.activeWeapon then
                    if item.data.components then
                        for i, comp in each(item.data.components) do
                            if comp == Config.WeaponAddons[component][item.name] then
                                local addResult = "done"

                                if not clip then
                                    addResult = addPlayerItem(_source, component, 1, {}, nil)
                                end

                                if addResult ~= "done" then
                                    TriggerClientEvent("inventory:error", _source, addResult)
                                else
                                    table.remove(item.data.components, i)
                                    setCharInventory(_source, Inventories[identifier])
                                end

                                break
                            end
                        end
                    end
                end
            end
        end
    end
)

RegisterNetEvent("inventory:addCamoToWeapon")
AddEventHandler(
    "inventory:addCamoToWeapon",
    function(weaponName, components, slot)
        local _source = source

        local removeResult = removePlayerItem(_source, "weapontoolkit", 1, {}, slot)
        if removeResult == "done" then
            local identifier = GetPlayerIdentifier(_source, 0)
            if Inventories[identifier] then
                for index, item in each(Inventories[identifier].data) do
                    if item.name == weaponName and item.data and item.data.activeWeapon then
                        if not item.data.components then
                            Inventories[identifier].data[index].data.components = {}
                        end

                        for i = 1, #components do
                            table.insert(Inventories[identifier].data[index].data.components, GetHashKey(components[i]))
                        end

                        setCharInventory(_source, Inventories[identifier])
                        break
                    end
                end
            end
        end
    end
)
RegisterNetEvent("inventory:removeCamoFromWeapon")
AddEventHandler(
    "inventory:removeCamoFromWeapon",
    function(weapon, price, defaultCamo)
        local _source = source

        local removeResult = removePlayerItem(_source, "cash", price, {}, nil)
        if removeResult ~= "done" then
            TriggerClientEvent("inventory:error", _source, "noMoney")
            return
        end

        local identifier = GetPlayerIdentifier(_source, 0)
        if Inventories[identifier] then
            for index, item in each(Inventories[identifier].data) do
                if item.name == weapon and item.data and item.data.activeWeapon then
                    if item.data.components then
                        for i, component in each(item.data.components) do
                            local comp = getComponentNameByHash(weapon, component)
                            if not comp then
                                table.remove(item.data.components, i)
                            end
                        end
                    end
                    if not item.data.components then
                        item.data.components = {}
                    end
                    if defaultCamo then
                        table.insert(item.data.components, GetHashKey(defaultCamo))
                    end
                    setCharInventory(_source, Inventories[identifier])
                end
            end
        end
    end
)

RegisterNetEvent("inventory:setWeaponColor")
AddEventHandler(
    "inventory:setWeaponColor",
    function(weaponToSpray, itemName, slot, isSpecial)
        local _source = source
        local identifier = GetPlayerIdentifier(_source, 0)

        if Inventories[identifier] then
            local removeSpray = removePlayerItem(_source, itemName, 1, {}, slot)

            if removeSpray == "done" then
                for index, item in each(Inventories[identifier].data) do
                    if item.name == weaponToSpray and item.data and item.data.activeWeapon then
                        local colorsIndex = 1
                        if isSpecial then
                            colorsIndex = 2
                        end

                        Inventories[identifier].data[index].data.color = Config.WeaponColors[colorsIndex][itemName]
                        setCharInventory(_source, Inventories[identifier])
                        break
                    end
                end
            end
        end
    end
)

function getComponentNameByHash(weaponName, componentHash)
    for componentName, componentWeapon in each(Config.WeaponAddons) do
        if componentHash == componentWeapon[weaponName] then
            return componentName
        end
    end

    return nil
end
