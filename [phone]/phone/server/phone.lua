local Phones, Sim = Config.Phones, Config.Sim

RegisterNetEvent('qb-phone:server:giveMobile')
AddEventHandler('qb-phone:server:giveMobile', function(args)
    local src = source
    if exports.data:getUserVar(src, "admin") >= 2 then
        args[3] = "admin"
    end
    create(args)
end)

function createData(type)
    local found = nil
    local data = {}
    if Phones[type] or Sim[type] then
        found = Phones[type] or Sim[type]
        for k, v in each(found) do
            data[k] = v
        end
        data.id = generateUid()
        return data
    end
    return nil
end

function generateUid()
    local uid
    local doBreak = false
    while true do
        Citizen.Wait(2)
        math.randomseed(GetGameTimer())
        uid = string.upper(Utils.GetRandomNumber(5) .. Utils.GetRandomNumber(5))
        if not checkUid(uid) then
            doBreak = true
        end
        if doBreak then
            break
        end
    end
    return uid
end

function generateTelephoneNumber()
    local TelNumber
    local doBreak = false
    while true do
        Citizen.Wait(2)
        math.randomseed(GetGameTimer())
        TelNumber = string.upper(Utils.GetRandomNumber(2) .. Utils.GetRandomNumber(4))
        if not checkTelNumber(TelNumber) then
            doBreak = true
        end
        if doBreak then
            break
        end
    end
    return TelNumber
end

function generateIPNumber()
    local IPNumber
    local doBreak = false
    while true do
        Citizen.Wait(2)
        math.randomseed(GetGameTimer())
        IPNumber = string.upper(Utils.GetRandomNumber(3) .. '.' ..  Utils.GetRandomNumber(3) .. '.' ..  Utils.GetRandomNumber(2) .. '.' ..  Utils.GetRandomNumber(2))
        if not checkIPNumber(IPNumber) then
            doBreak = true
        end
        if doBreak then
            break
        end
    end
    return IPNumber
end

function checkUid(uid)
    local found = false
    MySQL.Async.fetchAll("SELECT phoneid FROM phone_settings WHERE `phoneid` = @id LIMIT 1",
    {
        ["@id"] = uid,
    }, function(result)
        if result[1] then
            found = true
        end
    end)
    MySQL.Async.fetchAll("SELECT simid FROM simcard WHERE `simid` = @id LIMIT 1",
    {
        ["@id"] = uid,
    }, function(result)
        if result[1] then
            found = true
        end
    end)
    return found
end

function checkTelNumber(number)
    local found = false
    MySQL.Async.fetchAll("SELECT telephoneNumber FROM simcard WHERE `telephoneNumber` = @number LIMIT 1",
    {
        ["@number"] = number,
    }, function(result)
        if result[1] then
            found = true
        end
    end)
    return found
end

function checkIPNumber(number)
    local found = false
    MySQL.Async.fetchAll("SELECT ip FROM simcard WHERE `ip` = @number LIMIT 1",
            {
                ["@number"] = number,
            }, function(result)
                if result[1] then
                    found = true
                end
            end)
    return found
end

function create(args)
    local player = tonumber(args[1])
    if player then
        local data = createData(args[2])
        local charid = exports.data:getCharVar(player, 'id')
        local penis = false
        if data ~= nil and charid ~= nil then
            if Phones[args[2]] then
                penis = true
                MySQL.Async.execute(
                        "INSERT INTO phone_settings (charid, phoneid, settings, recent_calls, app_alerts, InstalledApps, player_contacts) VALUES (@charid, @phoneid, @settings, @recent_calls, @app_alerts, @InstalledApps, @player_contacts)",
                        {
                            ["@charid"] = charid,
                            ["@phoneid"] = data.id,
                            ["@settings"] = json.encode(data.settings),
                            ["@InstalledApps"] = json.encode({}),
                            ["@player_contacts"] = json.encode({}),
                            ["@recent_calls"] = json.encode({}),
                            ["@app_alerts"] = json.encode({})
                        })
            elseif Sim[args[2]] then
                penis = true
                data.telNumber = generateTelephoneNumber()
                data.ip = generateIPNumber()
                data.active = true
                MySQL.Async.execute(
                        "INSERT INTO simcard (simid, phone, charid, blockedNumbers, telephoneNumber, ip, data, blocked) VALUES (@simid, @phone, @charid, @blockedNumbers, @telephoneNumber, @ip, @data, @blocked)",
                        {
                            ["@simid"] = data.id,
                            ["@phone"] = 0,
                            ["@charid"] = charid,
                            ["@blockedNumbers"] = json.encode({}),
                            ["@telephoneNumber"] = data.telNumber,
                            ["@ip"] = data.ip,
                            ["@data"] = json.encode(data),
                            ['@blocked'] = false
                        })
                insertNewSim(data.telNumber, data.id)
            end
            if penis then
                local name = data.label
                data.bCharID = charid
                data.label = string.format("%s - %s <br> type - %s", name, data.id, data.item)
                give = exports.inventory:addPlayerItem(player, data.item, 1, data)
                if args[3] ~= nil then
                    if give == "done" then
                        TriggerClientEvent('notify:display', player, {type = "success", title = "Give", text = "Podařilo se ti darovat " .. data.item .. ". 👿", icon = "fas fa-times", length = 5000})
                        return "done"
                    else
                        TriggerClientEvent('notify:display', player, {type = "error", title = "Give Chyba", text = "Nepodařilo se ti darovat " .. data.item .. ". 👿", icon = "fas fa-times", length = 5000})
                        return "error"
                    end
                else
                    if give == "done" then
                        return "done"
                    else
                        return "error"
                    end
                end

                if Config.Debug then
                    --Utils.DumpTable(data)
                end
            end
        else
            TriggerClientEvent('notify:display', player, {type = "error", title = "Chyba", text = "Špatně zadaný typ mobilu. 👿", icon = "fas fa-times", length = 5000})
            return "error"
        end
    end
end

RegisterNetEvent('qb-phone:server:UpdateSim')
AddEventHandler('qb-phone:server:UpdateSim', function(MData, simData, key, action)
    local src = source
    local phoneData = MData
    local data = {
        ["simActive"] = {}
    }
    if key ~= "switch" then
        if action == "pull" then
            exports.inventory:addPlayerItem(src, phoneData["simActive"][key].item, 1, phoneData["simActive"][key])
            TriggerEvent("qb-phone:server:updateSimPhone", 0, phoneData["simActive"][key].id)
            phoneData["simActive"][key] = {}
        elseif action == "change" then
            exports.inventory:removePlayerItem(src, simData.item, 1, simData)
            TriggerEvent("qb-phone:server:updateSimPhone", MData.id, simData.id)
            exports.inventory:addPlayerItem(src, phoneData["simActive"][key].item, 1, phoneData["simActive"][key])
            TriggerEvent("qb-phone:server:updateSimPhone", MData.id, phoneData["simActive"][key].id)
            phoneData["simActive"][key] = simData
        elseif action == "insert" then
            phoneData["simActive"][key] = simData
            exports.inventory:removePlayerItem(src, simData.item, 1, simData)
            TriggerEvent("qb-phone:server:updateSimPhone", MData.id, simData.id)
        end
        data["simActive"] = phoneData["simActive"]
    else
        primary = phoneData["simActive"]["primary"]
        secondary = phoneData["simActive"]["secondary"]
        data["simActive"]["primary"] = secondary
        data["simActive"]["secondary"] = primary
    end

    exports.inventory:updateItemData(src, MData.id, data)
    SetTimeout(100, function()
        TriggerClientEvent("qb-phone:client:RefreshPhone", src)
        if Config.Debug then
            --Utils.DumpTable(data)
        end
    end)
end)

RegisterNetEvent('qb-phone:server:updateSimPhone')
AddEventHandler('qb-phone:server:updateSimPhone', function(phone, sim)
    MySQL.Async.execute(
            "UPDATE simcard SET phone=@phone WHERE simid = @simid",
            {
                ["@phone"] = tonumber(phone),
                ["@simid"] = tonumber(sim)
            })
end)