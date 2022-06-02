math.randomseed(os.time() .. math.random(1000, 9999))
local jewelry, ready, alarmed, inProgress = {}, false, false, false
local delay = ServerConfig.Delay

Citizen.CreateThread(function()
    Citizen.Wait(1000) -- 600000
    prepareJewelry(true)
end)

AddEventHandler("txAdmin:events:scheduledRestart", function(data)
    local actualTime = tonumber(data.secondsRemaining / 60) - 3
    if actualTime <= 10 then
        ready = false
    end
end)

function prepareJewelry(first)
    jewelry, ready, alarmed, inProgress = {}, true, false, false
    for i, jewel in each(Config.Jewelry) do
        if jewel.Type == "showcase" then
            jewelry[tostring(i)] = {
                Coords = jewel.Coords,
                Reserved = false,
                Robbed = false,
                Hacked = false,
                Changed = false
            }
        end
    end
    TriggerClientEvent("jewelry:countPolice", -1, exports.data:countEmployees(nil, "police", nil, true))
    syncData(nil, false, first)
end

RegisterNetEvent("jewelry:sync")
AddEventHandler("jewelry:sync", function()
    local client = source
    syncData(client, false, true)
end)

RegisterNetEvent("jewelry:countPolice")
AddEventHandler("jewelry:countPolice", function()
    local client = source
    TriggerClientEvent("jewelry:countPolice", client, exports.data:countEmployees(nil, "police", nil, true))
end)

RegisterNetEvent("jewelry:reserveShowcase")
AddEventHandler("jewelry:reserveShowcase", function(showcase)
    jewelry[showcase].Reserved = not jewelry[showcase].Reserved
    exports.logs:sendToDiscord({
        channel = "jewelry",
        title = "Klenoty",
        description = "Nastavil status vitríny č. " .. showcase .. " na " .. tostring(not jewelry[showcase].Reserved),
        color = "2061822"
    }, source)
    syncData(nil, true)
end)

RegisterNetEvent("jewelry:hackShowcase")
AddEventHandler("jewelry:hackShowcase", function(showcase)
    startStealingTimer()
    jewelry[showcase].Changed = true
    jewelry[showcase].Hacked = true
    Citizen.Wait(100)

    local stillClosedShowCases = {}
    for i, jewel in pairs(jewelry) do
        if not jewel.Hacked then
            table.insert(stillClosedShowCases, (i))
        end
    end

    if #stillClosedShowCases == 0 then
        for i, jewel in pairs(Config.Jewelry) do
            if jewel.Type == "wall" then
                jewelry[tostring(i)] = {
                    Coords = jewel.Coords,
                    Reserved = false,
                    Robbed = false,
                    Hacked = true
                }
            end
        end
    end

    syncData()
end)

RegisterNetEvent("jewelry:stealJewelry")
AddEventHandler("jewelry:stealJewelry", function(showcase)
    local client = source
    exports.admin:banClientForCheating(client, "0", "Cheating", "jewelry:stealJewelry", "Špatný event...")
end)

RegisterNetEvent("jewelry:stoleJewelry")
AddEventHandler("jewelry:stoleJewelry", function(showcase)
    local client = source
    if not jewelry[showcase] then
        exports.admin:banClientForCheating(client, "0", "Cheating", "jewelry:stealJewelry", "Neexistující vitrína!")
        return
    end
    if jewelry[showcase].Reserved then
        if jewelry[showcase].Robbed then
            exports.admin:banClientForCheating(client, "0", "Cheating", "jewelry:stealJewelry",
                "Již vykradená vitrína!")
            return
        end
        local playerCoords = GetEntityCoords(GetPlayerPed(client))
        if #(playerCoords - vec3(-622.058105, -230.651886, 38.057064)) >= 200.0 then
            exports.admin:banClientForCheating(client, "0", "Cheating", "jewelry:stealJewelry",
                "Moc daleko od vitríny!")
            return
        end

        startStealingTimer()
        jewelry[showcase].Changed, jewelry[showcase].Robbed = true, true
        syncData()
        local itemName, itemCount = nil, 1
        while not itemName do
            for i, item in each(ServerConfig.Items) do
                if math.random(100) <= item.Chance then
                    itemName = item.Item
                    itemCount = math.random(item.Min, item.Max)
                end
            end
            Citizen.Wait(100)
        end
        local giveItem = exports.inventory:forceAddPlayerItem(client, itemName, itemCount, {})
        exports.logs:sendToDiscord({
            channel = "jewelry",
            title = "Klenotnictví",
            description = "Získal/a " .. itemCount .. "x " .. exports.inventory:getItem(itemName).label,
            color = "2061822"
        }, client)
    end
end)

RegisterNetEvent("rob_jewelry:checkHackItem")
AddEventHandler("rob_jewelry:checkHackItem", function(showcase)
    local client = source
    local hasCard = exports.inventory:checkPlayerItem(source, "hack_card", 1, {})
    if hasCard then
        TriggerClientEvent("rob_jewelry:checkHackItem", client, showcase)
    else
        TriggerClientEvent("notify:display", client, {
            type = "warning",
            title = "Klenotnictví",
            text = "Něco ti chybí!",
            icon = "fas fa-wrench",
            length = 3000
        })
    end
end)

RegisterNetEvent("jewelry:breakShowcase")
AddEventHandler("jewelry:breakShowcase", function(showcase)
    TriggerClientEvent("jewelry:breakShowcase", -1, showcase)
end)

local toAlarm = 0
RegisterNetEvent("jewelry:alarm")
AddEventHandler("jewelry:alarm", function()
    local client = source
    if not alarmed then
        TriggerEvent("sound:playYoutubeSound", "SVJENXqb388", 60.0, vec3(-622.058105, -230.651886, 38.057064), "jewelry")

        TriggerEvent("outlawalert:sendAlert", {
            Type = "jewelry",
            Coords = vec3(-622.058105, -230.651886, 38.057064)
        })
        exports.logs:sendToDiscord({
            channel = "jewelry",
            title = "Klenotnictví",
            description = "Spustil alarm!",
            color = "7601682"
        }, client)
        exports.admin:takePlayerScreenshot(client, "Spustil alarm ve klenotnictví")
        alarmed = true
        syncData()
        Citizen.Wait(300000)
        TriggerEvent("sound:stopSound", "jewelry")
    else
        toAlarm = toAlarm + 1
        if toAlarm >= 3 then
            toAlarm = 0
            TriggerEvent("outlawalert:sendAlert", {
                Type = "jewelry",
                Coords = vec3(-622.058105, -230.651886, 38.057064)
            })
            exports.logs:sendToDiscord({
                channel = "jewelry",
                title = "Klenotnictví",
                description = "Spustil alarm!",
                color = "7601682"
            }, client)
            exports.admin:takePlayerScreenshot(client, "Spustil alarm ve klenotnictví")
        end
    end
end)

function syncData(user, reserve, first)
    if not user then
        user = -1
    end
    TriggerClientEvent("jewelry:sync", -1, {
        Jewelry = jewelry,
        JewelryReady = ready,
        Alarmed = alarmed,
        Reserve = reserve,
        First = first
    })
end

function startStealingTimer()
    if not inProgress then
        inProgress = true
        print("[JEWELRY] Starting steal timer!")
        Citizen.SetTimeout(ServerConfig.StealingDelay, function()
            print("[JEWELRY] Starting reset timer!")
            startResetTimer()
        end)
    end
end

function startResetTimer()
    ready = false
    syncData()
    Citizen.SetTimeout(delay, function()
        delay = ServerConfig.Delay
        print("[JEWELRY] Reseting jewelry!")
        prepareJewelry(true)
    end)
end
