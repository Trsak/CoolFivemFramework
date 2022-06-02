local items = {}

RegisterNetEvent("fishing:giveFish")
AddEventHandler(
    "fishing:giveFish",
    function()
        local _source = source
        local foundItem, count, foundItemData = nil, 1, {}
        local maxChance = 0
        for k, data in each(Config.Fishes) do
            maxChance = maxChance + data.chance
        end
        local random = math.random(1, maxChance)
        local currentChance = 0
        for i, item in each(Config.Fishes) do
            print("itemChanceMin", item.chanceMin)
            print("itemChanceMax", item.chanceMax)
            print("random", random)
            print("item", item.item)
            currentChance = currentChance + item.chance
            if random <= currentChance then
                foundItem = item.item
                print("foundItem2", foundItem)
                count = math.random(item.itemMin, item.itemMax)
                print("amount", count)
                break
            end
        end
        print("foundItem", foundItem)
        local itemData = exports.inventory:getItem(foundItem)
        if itemData.type == "weapon" then
            local weaponNumber = exports.base_shops:generateSerialNumber()
            foundItemData = {
                id = weaponNumber,
                number = weaponNumber,
                time = os.time(),
                label = "Seriové číslo: " .. weaponNumber .. "<br>Datum vydání: " .. os.date("%x", os.time())
            }
        end
        if not exports.food:getItem(foundItem) then
            addResult = exports.inventory:forceAddPlayerItem(_source, foundItem, count, foundItemData)
        elseif string.match(foundItem, "cigs") or string.match(foundItem, "cigars") then
            reason = exports.smokable:givePack(_source, foundItem, count)
        else
            addResult = exports.food:giveItem(_source, foundItem, count)
        end
    end
)

RegisterNetEvent("fishing:sell")
AddEventHandler(
    "fishing:sell",
    function(amount, fish)
        local label = exports.inventory:getItem(fish.item).label

        local sold = false
        local trueAmount = amount

        if exports.inventory:checkPlayerItem(source, fish.item, amount, {}) then
            sold = true
            trueAmount = amount
        else
            sold = false
            local count = exports.inventory:getPlayerItemCount(source, fish.item, {})
            if count > 0 then
                if exports.inventory:checkPlayerItem(source, fish.item, count, {}) then
                    trueAmount = count
                    sold = true
                end
            end
        end

        if sold then
            local removed = exports.inventory:removePlayerItem(source, fish.item, amount, {})
            if removed == "done" then
                local price = math.random(fish.minPrice, fish.maxPrice) * trueAmount
                exports.inventory:addPlayerItem(source, "cash", price, {})
                TriggerClientEvent(
                    "notify:display",
                    source,
                    {
                        type = "success",
                        title = "Úspěch",
                        text = "Prodal jsi " .. trueAmount .. "x " .. label,
                        icon = "fas fa-times",
                        length = 5000
                    }
                )
            else
                sold = false
            end
        end
        if not sold then
            TriggerClientEvent(
                "notify:display",
                source,
                {
                    type = "error",
                    title = "Neúspěch",
                    text = "Nemáš u sebe " .. label,
                    icon = "fas fa-times",
                    length = 5000
                }
            )
        end
    end
)

RegisterNetEvent("fishing:rentCheck")
AddEventHandler(
    "fishing:rentCheck",
    function()
        payRent = exports.inventory:removePlayerItem(source, "cash", 250, {})
        if payRent == "done" then
            TriggerClientEvent(
                "notify:display",
                source,
                {
                    type = "success",
                    title = "Úspěch",
                    text = "Pronajal sis loď",
                    icon = "fas fa-times",
                    length = 5000
                }
            )
            TriggerClientEvent("fishing:rentBoat", source)
        else
            TriggerClientEvent(
                "notify:display",
                source,
                {
                    type = "error",
                    title = "Neúspěch",
                    text = "Nemáš dostatek peněz",
                    icon = "fas fa-times",
                    length = 5000
                }
            )
        end
    end
)
