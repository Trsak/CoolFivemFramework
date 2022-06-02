local usingItem = {}

function giveItem(target, itemName, count, slot, amount, specialId)
    if itemName then
        if Config.Packs[itemName] then
            local itemId = itemName .. "-" .. Config.Packs[itemName].Count
            if specialId then itemId = itemId .. specialId end
            local packType = getTypeStrings("pack", Config.Packs[itemName].Type)
            local reason = exports.inventory:addPlayerItem(target, itemName,
                                                           count, {
                id = itemId,
                amount = Config.Packs[itemName].Count,
                label = "Zbývá: " .. Config.Packs[itemName].Count .. " " ..
                    packType
            }, slot and slot or nil)
            return reason
        elseif Config.Food[itemName] or Config.Drinks[itemName] then
            local ending = " ml"
            local foodData = Config.Drinks[itemName]
            if Config.Food[itemName] then
                ending = " g"
                foodData = Config.Food[itemName]
            end
            local itemAmount = amount and amount or tonumber(foodData.Capacity)
            local itemId = itemName .. "-" .. itemAmount
            if specialId then itemId = itemId .. specialId end
            local hasDescription = nil
            if foodData.Description then
                hasDescription = foodData.Description
            end

            local reason = exports.inventory:addPlayerItem(target, itemName,
                                                           count, {
                id = itemId,
                amount = itemAmount,
                label = "Zbývá: " .. itemAmount .. ending ..
                    (hasDescription and ("<br>Popis: " .. hasDescription) or "")
            }, slot and slot or nil)
            return reason
        end
    end
end

RegisterNetEvent("inventory:usedItem")
AddEventHandler("inventory:usedItem", function(itemName, slot, data)
    local client = source
    if Config.Drinks[itemName] then
        if not usingItem[tostring(client)] and
            not exports.smokable:isPlayerSmoking(client) then
            if data.amount then
                if data.amount > 0 then
                    usingItem[tostring(client)] = itemName
                    exports.inventory:removePlayerItem(client, itemName, 1,
                                                       {id = data.id}, slot)
                    TriggerClientEvent("food:startDrink", client, itemName,
                                       data.amount)
                else
                    local drinkType = Config.Drinks[itemName].Type and
                                          getTypeStrings("name",
                                                         Config.Drinks[itemName]
                                                             .Type) or
                                          "Kelímek"
                    local ending = drinkType ~= "Kelímek" and "á!" or "ý!"
                    TriggerClientEvent("notify:display", client, {
                        type = "error",
                        title = "Chyba",
                        text = drinkType .. " je prázdn" .. ending,
                        icon = "fas fa-times",
                        length = 3000
                    })
                end
            else
                TriggerClientEvent("chat:addMessage", client, {
                    templateId = "error",
                    args = {"Tento předmět má chybu!"}
                })
            end
        else
            TriggerClientEvent("notify:display", client, {
                type = "error",
                title = "Chyba",
                text = "Nemůžeš dělat více věcí najednou!",
                icon = "fas fa-times",
                length = 3000
            })
        end
    elseif Config.Glass[itemName] then
        if not usingItem[tostring(client)] and
            not exports.smokable:isPlayerSmoking(client) then
            if data.amount then
                if data.amount > 0 then
                    usingItem[tostring(client)] = {
                        Item = itemName,
                        Drink = data.drink
                    }
                    exports.inventory:removePlayerItem(client, itemName, 1,
                                                       {id = data.id}, slot)
                    TriggerClientEvent("food:startDrink", client, itemName,
                                       data.amount, data.drink)
                else
                    local ending = itemName ~= "shot" and "á!" or "ý!"
                    TriggerClientEvent("notify:display", client, {
                        type = "error",
                        title = "Chyba",
                        text = exports.inventory:getItem(itemName).label ..
                            " je prázdn" .. ending,
                        icon = "fas fa-times",
                        length = 3000
                    })
                end
            else
                TriggerClientEvent("chat:addMessage", client, {
                    templateId = "error",
                    args = {"Tento předmět má chybu!"}
                })
            end
        else
            TriggerClientEvent("notify:display", client, {
                type = "error",
                title = "Chyba",
                text = "Nemůžeš dělat více věcí najednou!",
                icon = "fas fa-times",
                length = 3000
            })
        end
    elseif Config.Food[itemName] then
        if not usingItem[tostring(client)] and
            not exports.smokable:isPlayerSmoking(client) then
            if data.amount then
                if data.amount > 0 then
                    usingItem[tostring(client)] = itemName
                    exports.inventory:removePlayerItem(client, itemName, 1,
                                                       {id = data.id}, slot)
                    TriggerClientEvent("food:startEat", client, itemName,
                                       data.amount)
                else
                    local drinkType = getTypeStrings("name",
                                                     Config.Food[itemName].Type)
                    local ending = drinkType ~= "Kelímek" and "á!" or "ý!"
                    TriggerClientEvent("notify:display", client, {
                        type = "error",
                        title = "Chyba",
                        text = drinkType .. " je prázdn" .. ending,
                        icon = "fas fa-times",
                        length = 3000
                    })
                end
            else
                TriggerClientEvent("chat:addMessage", client, {
                    templateId = "error",
                    args = {"Tento předmět má chybu!"}
                })
            end
        else
            TriggerClientEvent("notify:display", client, {
                type = "error",
                title = "Chyba",
                text = "Nemůžeš dělat více věcí najednou!",
                icon = "fas fa-times",
                length = 3000
            })
        end
    elseif Config.Packs[itemName] then
        if not usingItem[tostring(client)] and
            not exports.smokable:isPlayerSmoking(client) then
            if data.amount then
                if data.amount > 0 then
                    if not string.match(data.id, "blocked") then
                        local drinkData =
                            Config.Drinks[Config.Packs[itemName].Item]
                        local packType =
                            getTypeStrings("pack", Config.Packs[itemName].Type)
                        local ending = " ml"
                        if Config.Food[itemName] then
                            ending = " g"
                        end
                        exports.inventory:removePlayerItem(source, itemName, 1,
                                                           {id = data.id}, slot)
                        exports.inventory:forceAddPlayerItem(source, itemName,
                                                             1, {
                            id = itemName .. "-" .. data.amount - 1,
                            amount = data.amount - 1,
                            label = "Zbývá: " .. data.amount - 1 .. " " ..
                                packType
                        })

                        exports.inventory:forceAddPlayerItem(source,
                                                             Config.Packs[itemName]
                                                                 .Item, 1, {
                            id = Config.Packs[itemName].Item .. "-" ..
                                tonumber(drinkData.Capacity),
                            amount = tonumber(drinkData.Capacity),
                            label = "Zbývá: " .. tonumber(drinkData.Capacity) ..
                                ending
                        })
                    else
                        TriggerClientEvent("notify:display", client, {
                            type = "error",
                            title = "Chyba",
                            text = "Tohle patří někomu jinému!",
                            icon = "fas fa-times",
                            length = 3000
                        })
                    end
                else
                    TriggerClientEvent("notify:display", client, {
                        type = "error",
                        title = "Chyba",
                        text = "Balení je již prázdné!",
                        icon = "fas fa-times",
                        length = 3000
                    })
                end
            else
                TriggerClientEvent("chat:addMessage", client, {
                    templateId = "error",
                    args = {"Tento předmět má chybu!"}
                })
            end
        else
            TriggerClientEvent("notify:display", client, {
                type = "error",
                title = "Chyba",
                text = "Momentálně děláš něco jiného!",
                icon = "fas fa-times",
                length = 3000
            })
        end
    end
end)

RegisterNetEvent("food:stopUsing")
AddEventHandler("food:stopUsing", function(amount)
    local client = source
    local item = type(usingItem[tostring(client)]) == "table" and
                     usingItem[tostring(client)].Item or
                     usingItem[tostring(client)]

    if string.match(item, "_glass") or item == "shot" then
        local glassDrink = usingItem[tostring(client)].Drink
        exports.inventory:addPlayerItem(client, item, 1, {
            id = amount > 0 and (item .. "-" .. glassDrink .. "-" .. amount) or
                nil,
            amount = amount > 0 and amount or nil,
            label = amount > 0 and ("Zbývá: " .. amount .. " ml") or nil,
            drink = amount > 0 and glassDrink or nil
        })
    elseif not Config.Food[item] or amount > 0 then
        giveItem(client, item, 1, nil, amount)
    end
    usingItem[tostring(client)] = nil
end)

function getTypeStrings(type, item)
    if type == "pack" then
        if item == "bottle" then
            return "láhví"
        elseif item == "can" then
            return "plechovek"
        elseif item == "piece" then
            return "kousků"
        elseif "pill" then
            return "pilulek"
        end
    elseif type == "name" then
        if item == "bottle" then
            return "Láhev"
        elseif item == "can" then
            return "Plechovka"
        elseif item == "cup" then
            return "Kelímek"
        elseif item == "glass" then
            return "Sklenička"
        elseif item == "plastic" then
            return "Obal"
        elseif item == "paper" then
            return "Papír"
        end
    end
end

function getItem(itemName)
    if Config.Drinks[itemName] then
        return (Config.Drinks[itemName])
    elseif Config.Packs[itemName] then
        return (Config.Packs[itemName])
    elseif Config.Food[itemName] then
        return (Config.Food[itemName])
    end
end

RegisterNetEvent("food:checkGlasses")
AddEventHandler("food:checkGlasses",
                function(glassItem, glassCount, targetAmount)
    local client = source
    if glassItem.data.amount > 0 then
        if glassCount and glassCount > 0 then
            local availableGlass, canSend = {}, false
            local playerInventory = exports.inventory:getPlayerInventory(client)
            if playerInventory then
                for index, item in each(playerInventory.data) do
                    if Config.Glass[item.name] then
                        if (not item.data.amount or item.data.amount <= 0) and
                            not item.data.drink then
                            local amountToSpill =
                                Config.Glass[item.name].Max > targetAmount and
                                    targetAmount or Config.Glass[item.name].Max
                            canSend = true
                            local maxFullGlasses =
                                math.floor(glassItem.data.amount / amountToSpill)
                            if maxFullGlasses > 0 then
                                availableGlass[item.name] = {
                                    Max = glassCount > maxFullGlasses and
                                        maxFullGlasses or
                                        (glassCount > item.count and item.count or
                                            glassCount),
                                    Label = Config.Glass[item.name].Label,
                                    Add = amountToSpill
                                }
                            else
                                availableGlass[item.name] = {
                                    Max = 1,
                                    Label = Config.Glass[item.name].Label,
                                    Add = glassItem.data.amount
                                }
                            end
                        end
                    end
                end
                if canSend then
                    TriggerClientEvent("food:openDrinkMenu", client,
                                       availableGlass, glassItem)
                else
                    TriggerClientEvent("notify:display", client, {
                        type = "error",
                        title = "Chyba",
                        text = "Nemáš u sebe žádnou prázdnou skleničku!",
                        icon = "fas fa-times",
                        length = 3000
                    })
                end
            end
        else
            TriggerClientEvent("notify:display", client, {
                type = "error",
                title = "Chyba",
                text = "Množství skleniček musí být větší než 0!",
                icon = "fas fa-times",
                length = 3000
            })
        end
    else
        local drinkType = getTypeStrings("name", Config.Drinks[item.name].Type)
        local ending = drinkType ~= "Kelímek" and "á!" or "ý!"
        TriggerClientEvent("notify:display", client, {
            type = "error",
            title = "Chyba",
            text = drinkType .. " je prázdn" .. ending,
            icon = "fas fa-times",
            length = 3000
        })
    end
end)

RegisterNetEvent("food:spillDrink")
AddEventHandler("food:spillDrink", function(glassData, drinkData)
    local client = source
    if drinkData.name == "cash" or glassData.item == "cash" then
        exports.admin:banClientForCheating(client, "0", "Cheating",
                                           "food:spillDrink",
                                           "Prostě do tohodle eventu peníze nepatří...")
        return
    end

    local hasEnoughtGlass = exports.inventory:checkPlayerItem(client,
                                                              glassData.item,
                                                              glassData.Max, {})
    local hasDrink = exports.inventory:checkPlayerItem(client, drinkData.name,
                                                       1,
                                                       {id = drinkData.data.id})
    if hasEnoughtGlass and hasDrink then
        local drinkRemoved = exports.inventory:removePlayerItem(client,
                                                                glassData.item,
                                                                glassData.Max,
                                                                {})
        local glassRemoved = exports.inventory:removePlayerItem(client,
                                                                drinkData.name,
                                                                1, {
            id = drinkData.data.id
        })
        if drinkRemoved == "done" and glassRemoved == "done" then
            local newAmount = drinkData.data.amount -
                                  (glassData.Add * glassData.Max)
            exports.inventory:addPlayerItem(client, drinkData.name, 1, {
                id = drinkData.name .. "-" .. newAmount,
                amount = newAmount,
                label = "Zbývá: " .. newAmount .. " ml"
            })
            exports.inventory:addPlayerItem(client, glassData.item,
                                            glassData.Max, {
                id = glassData.item .. "-" .. drinkData.name .. "-" ..
                    glassData.Add,
                amount = glassData.Add,
                label = "Zbývá: " .. glassData.Add .. " ml",
                drink = drinkData.name
            })
        end
    else
        TriggerClientEvent("notify:display", client, {
            type = "error",
            title = "Chyba",
            text = "Někde nastala chyba!",
            icon = "fas fa-times",
            length = 3000
        })
    end
end)

function isPlayerEating(client) return usingItem[tostring(client)] end
