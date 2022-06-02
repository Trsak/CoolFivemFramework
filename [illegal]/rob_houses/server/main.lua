local housesData = {}

Citizen.CreateThread(
    function()
        local currentTime = os.time()
        MySQL.Async.fetchAll(
            "SELECT * FROM rob_houses",
            {},
            function(houses)
                for i, house in each(houses) do
                    local lockHouse, changeHouse, resetTime, robbed = false, false, house.lastreset, house.robbed
                    local difference = (house.lastreset + 10800) - currentTime
                    if difference < 0 then
                        lockHouse, changeHouse, resetTime, robbed = true, true, currentTime, {}
                    end
                    housesData[house.house] = {
                        locked = lockHouse,
                        robbed = {},
                        players = json.decode(house.players),
                        lastreset = resetTime,
                        changed = changeHouse
                    }
                end

                syncHousesData()
            end
        )
    end
)

RegisterNetEvent("rob_houses:sync")
AddEventHandler(
    "rob_houses:sync",
    function()
        local _source = source
        TriggerClientEvent("rob_houses:sync", _source, housesData, true)
    end
)

RegisterNetEvent("rob_houses:lockpick")
AddEventHandler(
    "rob_houses:lockpick",
    function(house)
        local _source = source
        local policeCount = exports.data:countEmployees(nil, "police", nil, true)
        local neededPoliceCount = Config.RobPlaces[house].Residence.NeedPoliceCount

        if policeCount < neededPoliceCount then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = {
                        "Pro vykradení tohoto domu musí být na serveru alespoň " .. neededPoliceCount .. " policisti!"
                    }
                }
            )
            return
        end
        local removeResult = exports.inventory:removePlayerItem(_source, "lockpick", 1, {}, nil)
        if removeResult == "done" then
            TriggerClientEvent("rob_houses:lockpick", _source, house)
        else
            TriggerClientEvent("rob_houses:error", _source, "Musíš mít u sebe šperhák!")
        end
    end
)

RegisterNetEvent("rob_houses:unlockHouse")
AddEventHandler(
    "rob_houses:unlockHouse",
    function(house)
        local _source = source
        local Residence = Config.RobPlaces[house].Residence

        if math.random(100) <= Residence.ReportChance then
            TriggerEvent(
                "outlawalert:sendAlert",
                {
                    Type = "house",
                    Coords = Config.RobPlaces[house].Coords.xyz
                }
            )
            if math.random(100) > Residence.ReportChance then
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "error",
                        title = "Alarm",
                        text = "Spustil jsi alarm!",
                        icon = "fas fa-exclamation-triangle",
                        length = 5000
                    }
                )
            end
        end

        if housesData[house] then
            housesData[house].locked = false
        else
            housesData[house] = {
                locked = false,
                robbed = {},
                players = {},
                lastreset = os.time(),
                changed = true
            }
        end
        TriggerClientEvent("rob_houses:sync", -1, housesData, false)
    end
)

RegisterNetEvent("rob_houses:joinHouse")
AddEventHandler(
    "rob_houses:joinHouse",
    function(house)
        local _source = source

        local alreadyIn = false

        if housesData[house] then
            local char = exports.data:getCharVar(_source, "id")
            for i, player in each(housesData[house].players) do
                if player == char then
                    alreadyIn = true
                    break
                end
            end
        else
            housesData[house] = {
                locked = false,
                robbed = {},
                players = {},
                lastreset = os.time(),
                changed = true
            }
        end

        if not alreadyIn then
            table.insert(housesData[house].players, exports.data:getCharVar(_source, "id"))
        end
    end
)

RegisterNetEvent("rob_houses:robbedHousePlace")
AddEventHandler(
    "rob_houses:robbedHousePlace",
    function(house, place)
        local _source = source
        local Residence = Config.RobPlaces[house].Residence

        if math.random(1, 100) <= Residence.ChanceToFindNothing then
            TriggerClientEvent("rob_houses:searchResult", _source, nil, nil)
        else
            local foundItem, count, foundItemData = nil, 1, {}
            while not foundItem do
                for i, item in each(Residence.Items) do
                    if math.random(100) <= item.Chance then
                        foundItem = item.Item
                        count = math.random(item.MinCount, item.MaxCount)
                    end
                end
            end
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
            if addResult == "done" then
                TriggerClientEvent("rob_houses:searchResult", _source, foundItem, count)
            else
                TriggerClientEvent("rob_houses:error", _source, addResult)
            end
        end

        table.insert(housesData[house].robbed, place)
        housesData[house].changed = true
        TriggerClientEvent("rob_houses:sync", -1, housesData, false)
    end
)

RegisterNetEvent("rob_houses:leaveHouse")
AddEventHandler(
    "rob_houses:leaveHouse",
    function(house)
        local _source = source
        local char = exports.data:getCharVar(_source, "id")

        for i, player in each(housesData[house].players) do
            if player == char then
                table.remove(housesData[house].players, i)
                housesData[house].changed = true
                break
            end
        end
    end
)

RegisterNetEvent("inventory:usedItem")
AddEventHandler(
    "inventory:usedItem",
    function(itemName, slot, data)
        local _source = source

        if itemName == "lotteryticket" then
            local removeResult = exports.inventory:removePlayerItem(_source, itemName, 1, data, slot)
            if removeResult == "done" then
                local winnings = 0

                for i, ticket in each(Config.lotteryTicketChances) do
                    if math.random(100) <= ticket.Chance then
                        winnings = math.random(ticket.Min, ticket.Max)
                    else
                        break
                    end
                end

                if winnings ~= 0 then
                    exports.inventory:addPlayerItem(_source, "cash", winnings, {})
                end

                TriggerClientEvent("rob_houses:lotteryResult", _source, winnings)
            end
        end
    end
)

function syncHousesData()
    local currentTime = os.time()
    for house, data in pairs(housesData) do
        if data.changed then
            data.changed = false
            local lockHouse = data.locked
            local difference = currentTime - (data.lastreset + 10800)
            if difference > 0 then
                lockHouse = true
            end
            if lockHouse then
                data.locked = true
                data.robbed = {}
                data.lastreset = os.time()
            end
            MySQL.Async.execute(
                "INSERT INTO rob_houses (house, locked, robbed, players) VALUES (@house, @locked, @robbed, @players) ON DUPLICATE KEY UPDATE locked = @locked, robbed = @robbed, players = @players, lastreset = @lastreset",
                {
                    ["@house"] = house,
                    ["@robbed"] = json.encode(data.robbed),
                    ["@players"] = json.encode(data.players),
                    ["@locked"] = lockHouse,
                    ["@lastreset"] = data.lastreset
                }
            )
        end
    end
    TriggerClientEvent("rob_houses:sync", -1, housesData)
    SetTimeout(1800000, syncHousesData)
end
