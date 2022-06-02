local smoking = {}

function givePack(target, itemName, count, slot, amount)
    if itemName then
        if Config.CigPacks[itemName] or Config.Cigs[itemName] then
            local amount = amount and amount or (Config.Cigs[itemName] and 10 or 20)
            local ending = Config.Cigs[itemName] and " doutníků" or " cigaret"
            local reason = exports.inventory:addPlayerItem(
                target,
                itemName,
                count,
                {
                    id = itemName .. "-" .. amount,
                    amount = amount,
                    label = "Zbývá: " .. amount .. " " .. ending
                },
                slot and slot or nil
            )
            return reason
        end
    end
end

RegisterNetEvent("inventory:usedItem")
AddEventHandler(
    "inventory:usedItem",
    function(itemName, slot, data)
        local client = source
        if Config.CigPacks[itemName] then
            if not smoking[tostring(client)] and not exports.food:isPlayerEating(client) then
                if data.amount > 0 then
                    local hasLighter = false
                    for item, prop in pairs(Config.Lighters) do
                        local lighterChecked = exports.inventory:checkPlayerItem(client, item, 1, {})
                        if lighterChecked then
                            hasLighter = prop
                            break
                        end
                    end
                    if hasLighter then
                        smoking[tostring(client)] = itemName
                        local newAmount = data.amount - 1
                        local newData = {
                            id = itemName .. "-" .. newAmount,
                            amount = newAmount,
                            label = "Zbývá: " .. newAmount
                        }
                        exports.inventory:removePlayerItem(client, itemName, 1, data, slot)
                        exports.inventory:addPlayerItem(client, itemName, 1, newData)
                        TriggerClientEvent("smokable:startSmokeCigarette", client, hasLighter)
                    else
                        TriggerClientEvent(
                            "notify:display",
                            client,
                            {
                                type = "error",
                                title = "Cigaretky",
                                text = "Chybí ti zapalovač",
                                icon = "fas fa-smoking",
                                length = 3000
                            }
                        )
                    end
                else
                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "error",
                            title = "Cigaretky",
                            text = "Krabička je již prázdná!",
                            icon = "fas fa-smoking",
                            length = 3000
                        }
                    )
                end
            else
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "error",
                        title = "Kouření",
                        text = "Nemůžeš dělat více věcí najednou!",
                        icon = "fas fa-smoking",
                        length = 3000
                    }
                )
            end
        elseif Config.Cigs[itemName] then
            if not smoking[tostring(client)] and not exports.food:isPlayerEating(client) then
                if data.amount > 0 then
                    local hasLighter = false
                    for item, prop in pairs(Config.Lighters) do
                        local lighterChecked = exports.inventory:checkPlayerItem(client, item, 1, {})
                        if lighterChecked then
                            hasLighter = prop
                            break
                        end
                    end
                    if hasLighter then
                        smoking[tostring(client)] = itemName
                        local newAmount = data.amount - 1
                        local newData = {
                            id = itemName .. "-" .. newAmount,
                            amount = newAmount,
                            label = "Zbývá: " .. newAmount
                        }
                        exports.inventory:removePlayerItem(client, itemName, 1, data, slot)
                        exports.inventory:addPlayerItem(client, itemName, 1, newData)
                        TriggerClientEvent("smokable:startSmokeCig", client, hasLighter)
                    else
                        TriggerClientEvent(
                            "notify:display",
                            client,
                            {
                                type = "error",
                                title = "Kouření",
                                text = "Chybí ti zapalovač",
                                icon = "fas fa-smoking",
                                length = 3000
                            }
                        )
                    end
                else
                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "error",
                            title = "Kouření",
                            text = "Krabička je prázdná!",
                            icon = "fas fa-smoking",
                            length = 3000
                        }
                    )
                end
            else
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "error",
                        title = "Kouření",
                        text = "Nemůžeš dělat více věcí najednou!",
                        icon = "fas fa-smoking",
                        length = 3000
                    }
                )
            end
        elseif Config.Joints[itemName] then
            if not smoking[tostring(client)] and not exports.food:isPlayerEating(client) then
                local hasLighter = false
                for item, prop in pairs(Config.Lighters) do
                    local lighterChecked = exports.inventory:checkPlayerItem(client, item, 1, {})
                    if lighterChecked then
                        hasLighter = prop
                        break
                    end
                end
                if hasLighter then
                    smoking[tostring(client)] = itemName
                    exports.inventory:removePlayerItem(client, itemName, 1, data, slot)
                    TriggerClientEvent("smokable:startSmokeJoint", client, hasLighter)
                else
                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "error",
                            title = "Kouření",
                            text = "Chybí ti zapalovač",
                            icon = "fas fa-smoking",
                            length = 3000
                        }
                    )
                end
            else
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "error",
                        title = "Kouření",
                        text = "Nemůžeš dělat více věcí najednou!",
                        icon = "fas fa-smoking",
                        length = 3000
                    }
                )
            end
        end
    end
)

RegisterNetEvent("smokable:lighterEffect")
AddEventHandler(
    "smokable:lighterEffect",
    function(lighter)
        TriggerClientEvent("smokable:lighterEffect", -1, lighter)
    end
)

RegisterNetEvent("smokable:stopSmoke")
AddEventHandler(
    "smokable:stopSmoke",
    function()
        smoking[tostring(source)] = nil
    end
)

AddEventHandler(
    "playerDropped",
    function(reason)
        local client = source
        smoking[tostring(client)] = nil
    end
)

function isPlayerSmoking(client)
    return smoking[tostring(client)]
end
