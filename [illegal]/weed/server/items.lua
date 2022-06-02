RegisterNetEvent("weed:packed")
AddEventHandler(
    "weed:packed",
    function()
        local client = source

        if checkIfCanPackCannabis(client) then
            local weedBagRemove = exports.inventory:removePlayerItem(client, "drugbag", 1, {})
            if weedBagRemove == "done" then
                local cannabisRemove = exports.inventory:removePlayerItem(client, "cannabis", 5, {})

                if cannabisRemove == "done" then
                    exports.inventory:forceAddPlayerItem(client, "weedbag", 1, {})
                else
                    TriggerClientEvent("weed:packStop", client)
                end
            else
                TriggerClientEvent("weed:packStop", client)
            end
        else
            TriggerClientEvent("weed:packStop", client)
        end
    end
)

function packCannabis(client)
    if checkIfCanPackCannabis(client) then
        local playerInventory = exports.inventory:getPlayerInventory(client)
        local weedbagCount = 0
        local cannabisCount = 0

        for _, item in each(playerInventory.data) do
            if item.name == "cannabis" then
                cannabisCount = cannabisCount + tonumber(item.count)
            elseif item.name == "drugbag" then
                weedbagCount = weedbagCount + tonumber(item.count)
            end
        end

        local maxCannabis = cannabisCount // 5
        local maxWeedbags = weedbagCount
        local maxAmount = maxCannabis

        if maxCannabis > maxWeedbags then
            maxAmount = maxWeedbags
        end

        TriggerClientEvent("weed:packCannabis", client, maxAmount)
    end
end

function checkIfCanPackCannabis(client)
    if not exports.inventory:checkPlayerItem(client, "scale", 1, {}) then
        TriggerClientEvent(
            "notify:display",
            client,
            {
                type = "error",
                title = "Chyba",
                text = "Pro zabalení konopí potřebuješ váhu!",
                icon = "fas fa-cannabis",
                length = 3000
            }
        )
        return false
    elseif not exports.inventory:checkPlayerItem(client, "drugbag", 1, {}) then
        TriggerClientEvent(
            "notify:display",
            client,
            {
                type = "error",
                title = "Chyba",
                text = "Pro zabalení konopí potřebuješ prázdný sáček!",
                icon = "fas fa-cannabis",
                length = 3000
            }
        )
        return false
    elseif not exports.inventory:checkPlayerItem(client, "cannabis", 5, {}) then
        TriggerClientEvent(
            "notify:display",
            client,
            {
                type = "error",
                title = "Chyba",
                text = "Potřebuješ alespoň 5g konopí!",
                icon = "fas fa-cannabis",
                length = 3000
            }
        )
        return false
    end

    return true
end

RegisterNetEvent("weed:jointMade")
AddEventHandler(
    "weed:jointMade",
    function(slot, data)
        local client = source
        if exports.inventory:checkPlayerItem(client, "cannabis", 1, {}) then
            local removePaper = exports.inventory:removePlayerItem(client, "joint_paper", 1, data, slot)

            if removePaper == "done" then
                local removeCannabis = exports.inventory:removePlayerItem(client, "cannabis", 1, {})
                if removeCannabis == "done" then
                    exports.inventory:forceAddPlayerItem(client, "joint", 1, {})

                    if data.amount > 0 then
                        exports.inventory:forceAddPlayerItem(client, "joint_paper", 1, {
                            id = data.id - 1,
                            amount = data.id - 1,
                            label = "Zbývá: " .. (data.id - 1),
                        })
                    end
                else
                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "error",
                            title = "Chyba",
                            text = "Nemáš u sebe žádnou trávu!",
                            icon = "fas fa-cannabis",
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
                        title = "Chyba",
                        text = "Nemáš u sebe použitý papírek!",
                        icon = "fas fa-cannabis",
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
                    title = "Chyba",
                    text = "Nemáš u sebe žádnou trávu!",
                    icon = "fas fa-cannabis",
                    length = 3000
                }
            )
        end
    end
)

function unpackWeedBag(client, slot, data)
    TriggerClientEvent("weed:unpackWeedBag", client, slot, data)
end

RegisterNetEvent("weed:unpackWeedBag")
AddEventHandler(
    "weed:unpackWeedBag",
    function(slot, data)
        local client = source
        local removeWeedBag = exports.inventory:removePlayerItem(client, "weedbag", 1, data, slot)

        if removeWeedBag == "done" then
            exports.inventory:forceAddPlayerItem(client, "cannabis", 5, {})
            exports.inventory:forceAddPlayerItem(client, "drugbag", 1, {})
        else
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "error",
                    title = "Chyba",
                    text = "Nemáš u sebe zvolený balíček s trávou!",
                    icon = "fas fa-cannabis",
                    length = 3000
                }
            )
        end
    end
)

function makeJoint(client, slot, data)
    if exports.inventory:checkPlayerItem(client, "cannabis", 1, {}) then
        if data.amount ~= nil and data.amount > 0 then
            TriggerClientEvent("weed:makeJoint", client, slot, data)
        else
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "error",
                    title = "Chyba",
                    text = "V této krabičce už nejsou žádné papírky!",
                    icon = "fas fa-cannabis",
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
                title = "Chyba",
                text = "Nemáš u sebe žádnou trávu!",
                icon = "fas fa-cannabis",
                length = 3000
            }
        )
    end
end