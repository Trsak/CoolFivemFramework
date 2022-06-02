local playerLimits = {}
local today = os.time()
local savedBeforeRestart = false

MySQL.ready(
    function()
        Wait(400)

        MySQL.Async.execute("DELETE FROM daily_limits WHERE `day` < (NOW() - INTERVAL 2 DAY)", {})

        MySQL.Async.fetchAll(
            "SELECT * FROM daily_limits WHERE `day` = DATE(FROM_UNIXTIME(@today));",
            {
                ["@today"] = today
            },
            function(todayLimits)
                for _, todayLimit in each(todayLimits) do
                    local charId = tostring(todayLimit.char)

                    if playerLimits[charId] == nil then
                        playerLimits[charId] = {}
                    end

                    playerLimits[charId][todayLimit.item] = {
                        count = todayLimit.count,
                        changed = false
                    }
                end
            end
        )
    end
)

function checkIfIsOverLimit(client, item)
    local charId = tostring(exports.data:getCharVar(client, "id"))

    if playerLimits[charId] and playerLimits[charId][item] and playerLimits[charId][item].count >= Config.ItemLimits[item] then
        return true
    end

    return false
end

function addLimitCount(client, item, count)
    local charId = tostring(exports.data:getCharVar(client, "id"))

    if playerLimits[charId] == nil then
        playerLimits[charId] = {}
    end

    if playerLimits[charId][item] == nil then
        playerLimits[charId][item] = {
            count = count,
            changed = true
        }
    else
        playerLimits[charId][item] = {
            count = playerLimits[charId][item].count + count,
            changed = true
        }
    end
end

function saveData()
    local queries = {}

    for charId, items in pairs(playerLimits) do
        for item, itemData in pairs(items) do
            if itemData.changed then
                table.insert(queries, {
                    query = "INSERT INTO daily_limits (`char`, `day`, `item`, `count`) VALUES (:char, DATE(FROM_UNIXTIME(:day)), :item, :count) ON DUPLICATE KEY UPDATE `count` = :count",
                    values = {
                        ["char"] = charId,
                        ["day"] = today,
                        ["item"] = item,
                        ["count"] = itemData.count
                    }
                })
            end
        end
    end

    exports.oxmysql:transaction(queries)
end

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(600000)
            saveData()
        end
    end
)

AddEventHandler(
    "txAdmin:events:scheduledRestart",
    function(eventData)
        if savedBeforeRestart then
            return
        end

        savedBeforeRestart = true

        if eventData.secondsRemaining <= 120 then
            saveData()
        end
    end
)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    saveData()
end)
