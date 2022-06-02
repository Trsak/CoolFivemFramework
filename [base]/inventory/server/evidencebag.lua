RegisterNetEvent("inventory:usedItem")
AddEventHandler(
    "inventory:usedItem",
    function(itemName, slot, data)
        local client = source

        if itemName == "evidencebag" then
            if exports.base_jobs:hasUserJobType(client, "police", true) then
                if data.id == nil then
                    removePlayerItem(client, itemName, 1, data, slot)

                    data.id = os.time() .. client .. math.random(1000, 9999)
                    data.items = 0
                    data.weight = 0.0
                    data.label = "Připravený sáček pro uložení důkazů"
                    forceAddPlayerItem(client, itemName, 1, data, slot, dropIfNeeded)
                else
                    openStorage(client, "evidencebag", data.id, {
                        maxWeight = 65.0,
                        maxSpace = 30,
                        label = "Sáček s důkazy #" .. data.id
                    })
                end
            else
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "error",
                        title = "Chyba",
                        text = "Tento předmět je určen pouze pro policii ve službě!",
                        icon = "fas fa-times",
                        length = 3000
                    }
                )
            end
        end
    end
)

RegisterNetEvent("inventory:openEvidenceBag")
AddEventHandler(
    "inventory:openEvidenceBag",
    function(itemData)
        local client = source
        local identifier = GetPlayerIdentifier(client, 0)

        local item = findItemBySlot(Inventories[identifier].data, itemData.slot)
        if item then
            if item.data.id == nil or item.data.items == nil or item.data.items <= 0 then
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "error",
                        title = "Chyba",
                        text = "V tomto sáčku nic není!",
                        icon = "fas fa-times",
                        length = 3000
                    }
                )
            else
                local storage = loadStorage("evidencebag", item.data.id, {})

                if storage then
                    while #storage.data > 0 do
                        for index, storageItem in each(storage.data) do
                            local count = storageItem.count
                            local removeResult = removeItemFromStorage(storage, storageItem.name, storageItem.count, storageItem.data, storageItem.slot)
                            if removeResult == "done" then
                                forceAddPlayerItem(client, storageItem.name, count, storageItem.data)
                            else

                                TriggerClientEvent(
                                    "notify:display",
                                    client,
                                    {
                                        type = "success",
                                        title = "Chyba",
                                        text = "Při rozdělávání sáčku nastala chyba!",
                                        icon = "fas fa-box",
                                        length = 3000
                                    }
                                )
                                break
                            end
                        end
                    end

                    updateItemData(client, item.data.id, {
                        items = #storage.data,
                        weight = storage.currentWeight
                    })

                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "success",
                            title = "Chyba",
                            text = "Sáček byl rozbalen!",
                            icon = "fas fa-box",
                            length = 3000
                        }
                    )
                end
            end
        end
    end
)

RegisterNetEvent("inventory:evidenceBagRequest")
AddEventHandler(
    "inventory:evidenceBagRequest",
    function(target, evidencebagId)
        local client = source
        if exports.base_jobs:hasUserJobType(client, "police", true) then
            TriggerClientEvent("inventory:evidenceBagRequest", target, client, evidencebagId)
            TriggerClientEvent(
                "chat:addMessage", client,
                {
                    templateId = "success",
                    args = { "Odeslal/a jsi hráči žádost o vložení předmětů do sáčku!" }
                }
            )
        else
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "error",
                    title = "Chyba",
                    text = "Tento předmět je určen pouze pro policii ve službě!",
                    icon = "fas fa-times",
                    length = 4500
                }
            )
        end
    end
)

RegisterNetEvent("inventory:evidenceBagInsertFromPlayer")
AddEventHandler(
    "inventory:evidenceBagInsertFromPlayer",
    function(toClient, evidencebagId)
        local client = source

        local identifierTo = GetPlayerIdentifier(toClient, 0)
        local identifierFrom = GetPlayerIdentifier(client, 0)

        local item = findItemById(Inventories[identifierTo].data, evidencebagId)
        if item then
            local storage = loadStorage("evidencebag", item.data.id, {})
            if storage then
                if storage.currentWeight + Inventories[identifierFrom].currentWeight > storage.maxWeight then
                    TriggerClientEvent(
                        "notify:display",
                        toClient,
                        {
                            type = "success",
                            title = "Chyba",
                            text = "Sáček na důkazní materiál toho tolik neunese!",
                            icon = "fas fa-box",
                            length = 3000
                        }
                    )
                elseif #storage.data + #Inventories[identifierFrom].data > storage.maxSpace then
                    TriggerClientEvent(
                        "notify:display",
                        toClient,
                        {
                            type = "success",
                            title = "Chyba",
                            text = "V sáčku není dostatek místa na tolik předmětů!",
                            icon = "fas fa-box",
                            length = 3000
                        }
                    )
                else
                    while #Inventories[identifierFrom].data > 0 do
                        for index, playerItem in each(Inventories[identifierFrom].data) do
                            local count = playerItem.count
                            local removeResult = removePlayerItem(client, playerItem.name, count, playerItem.data, playerItem.slot)
                            if removeResult == "done" then
                                addItemToStorage(storage, playerItem.name, count, playerItem.data)
                            else
                                TriggerClientEvent(
                                    "notify:display",
                                    client,
                                    {
                                        type = "success",
                                        title = "Chyba",
                                        text = "Při naplňování sáčku nastala chyba!",
                                        icon = "fas fa-box",
                                        length = 3000
                                    }
                                )
                                break
                            end
                        end
                    end

                    updateItemData(toClient, item.data.id, {
                        items = #storage.data,
                        weight = storage.currentWeight
                    })

                    TriggerClientEvent(
                        "notify:display",
                        toClient,
                        {
                            type = "success",
                            title = "Chyba",
                            text = "Sáček byl naplněn!",
                            icon = "fas fa-box",
                            length = 3000
                        }
                    )

                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "success",
                            title = "Chyba",
                            text = "Vložil jsi všechny svoje předmětu do sáčku na důkazy!",
                            icon = "fas fa-box",
                            length = 3000
                        }
                    )
                end
            end
        end
    end
)

RegisterNetEvent("inventory:evidenceBagOpenRequest")
AddEventHandler(
    "inventory:evidenceBagOpenRequest",
    function(target, evidencebagId)
        local client = source
        if exports.base_jobs:hasUserJobType(client, "police", true) then
            TriggerClientEvent("inventory:evidenceBagOpenRequest", target, client, evidencebagId)
            TriggerClientEvent(
                "chat:addMessage", client,
                {
                    templateId = "success",
                    args = { "Odeslal/a jsi hráči žádost o vložení předmětů do inventáře!" }
                }
            )
        else
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "error",
                    title = "Chyba",
                    text = "Tento předmět je určen pouze pro policii ve službě!",
                    icon = "fas fa-times",
                    length = 4500
                }
            )
        end
    end
)

RegisterNetEvent("inventory:evidenceBagInsertToPlayer")
AddEventHandler(
    "inventory:evidenceBagInsertToPlayer",
    function(fromClient, evidencebagId)
        local client = source
        local identifierTo = GetPlayerIdentifier(fromClient, 0)
        local identifierFrom = GetPlayerIdentifier(client, 0)

        local item = findItemById(Inventories[identifierTo].data, evidencebagId)
        if item then
            if not item.data.id or not item.data.items or item.data.items <= 0 then
                TriggerClientEvent(
                    "notify:display",
                    fromClient,
                    {
                        type = "error",
                        title = "Chyba",
                        text = "V tomto sáčku nic není!",
                        icon = "fas fa-times",
                        length = 3000
                    }
                )
            else
                local storage = loadStorage("evidencebag", item.data.id, {})

                if storage then
                    while #storage.data > 0 do
                        for index, storageItem in each(storage.data) do
                            local count = storageItem.count
                            local removeResult = removeItemFromStorage(storage, storageItem.name, storageItem.count, storageItem.data, storageItem.slot)
                            if removeResult == "done" then
                                forceAddPlayerItem(client, storageItem.name, count, storageItem.data)
                            else

                                TriggerClientEvent(
                                    "notify:display",
                                    fromClient,
                                    {
                                        type = "success",
                                        title = "Chyba",
                                        text = "Při rozdělávání sáčku nastala chyba!",
                                        icon = "fas fa-box",
                                        length = 3000
                                    }
                                )
                                break
                            end
                        end
                    end

                    updateItemData(fromClient, item.data.id, {
                        items = #storage.data,
                        weight = storage.currentWeight
                    })

                    TriggerClientEvent(
                        "notify:display",
                        fromClient,
                        {
                            type = "success",
                            title = "Chyba",
                            text = "Sáček byl rozbalen!",
                            icon = "fas fa-box",
                            length = 3000
                        }
                    )
                end
            end
        end
    end
)
