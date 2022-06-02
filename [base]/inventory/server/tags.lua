RegisterNetEvent("inventory:addTagForItem")
AddEventHandler(
    "inventory:addTagForItem",
    function(targetItem, tag)
        local _source = source

        local identifier = GetPlayerIdentifier(_source, 0)
        if Inventories[identifier] then
            for index, item in each(Inventories[identifier].data) do
                if item.name == targetItem.name and item.slot == targetItem.slot and item.data then
                    local itemData = getItem(item.name)
                    if itemData.type == "weapon" or item.name == "plate" or exports.food:getItem(item.name) or string.match(item.name, "magazine_") or string.match(item.name, "cigs") or string.match(item.name, "cigars") then
                        item.data.label = item.data.label .. " <br>Poznámka: " .. tag
                    elseif item.name == "evidencebag" then
                        item.data.nametag = tag
                    else
                        item.data.label = "Poznámka: " .. tag
                    end
                    setCharInventory(_source, Inventories[identifier])
                    break
                end
            end
        end
    end
)

RegisterNetEvent("inventory:removeTagFromItem")
AddEventHandler(
    "inventory:removeTagFromItem",
    function(targetItem)
        local _source = source

        local identifier = GetPlayerIdentifier(_source, 0)
        if Inventories[identifier] then
            for index, item in each(Inventories[identifier].data) do
                if item.name == targetItem.name and item.slot == targetItem.slot and item.data then
                    local itemData = getItem(item.name)
                    if item.name == "door_keys" then
                        item.data.label = "Prostý klíč... K čemu tak může být.. Asi se někam strká.."
                    elseif item.name == "door_keycard" then
                        item.data.label = "Prostá karta... K čemu tak může být.. Asi se něčím projíždí.."
                    elseif item.name == "plate" then
                        item.data.label = "SPZ: " .. item.data.plateText
                    elseif itemData.type == "weapon" then
                        if item.data.number and item.data.time then
                            item.data.label = "Seriové číslo: " ..
                                item.data.number .. "<br>Datum vydání: " .. os.date("%x", item.data.time)
                        else
                            item.data.label = "Zbraň nemá sériové číslo"
                        end
                    elseif exports.food:getItem(item.name) then
                        local foodData = exports.food:getItem(item.name)
                        local ending = " ml"
                        if foodData.Type ~= "bottle" and foodData.Type ~= "can" then
                            ending = " g"
                        end
                        local hasDescription = nil
                        if foodData.Description then
                            hasDescription = foodData.Description
                        end
                        item.data.label = "Zbývá: " .. item.data.amount .. ending .. (hasDescription and ("<br>Popis: " .. hasDescription) or "")
                    elseif string.match(item.name, "cigs") or string.match(item.name, "cigars") then
                        item.data.label = "Zbývá: " .. item.data.amount
                    elseif string.match(item.name, "magazine_") then
                        item.data.label = "Počet nábojů: " .. item.data.amount
                    else
                        item.data.label = nil
                    end
                    setCharInventory(_source, Inventories[identifier])
                    break
                end
            end
        end
    end
)
