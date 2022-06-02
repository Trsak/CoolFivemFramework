local simcards = {}
local phones = {}

MySQL.ready(function()
    MySQL.Async.fetchAll("SELECT * FROM simcard", {}, function(sim)
        for _, v in each(sim) do
            v["blockedNumbers"] = json.decode(v["blockedNumbers"])
            v["data"] = json.decode(v["data"])
            v.charid = tostring(v.charid)
            if simcards[v.charid] == nil then
                simcards[v.charid] = {}
            end

            table.insert(simcards[v.charid], v)
        end
    end)
    for _, v in each(exports.phone:getAllPhones()) do
        v.charid = tostring(v.charid)
        if phones[v.charid] == nil then
            phones[v.charid] = {}
        end
        table.insert(phones[v.charid], v)
    end
    exports.player_near_coords:add_event(GetCurrentResourceName(),
            {
                coords = Shop_Config.Stores,
                job = false,
                distance = 2,
                event = "phone_shop:near_coords",
                handler = "table_key"
            }
    )
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == "player_near_coords" then
        Citizen.Wait(500)
        exports.player_near_coords:add_event(GetCurrentResourceName(),
                {
                    coords = Shop_Config.Stores,
                    job = false,
                    distance = 2,
                    event = "phone_shop:near_coords",
                    handler = "table_key"
                }
        )
    end
end)

RegisterNetEvent('phone_shop:server:open_shop')
AddEventHandler('phone_shop:server:open_shop', function()
    local src = source
    local Player = tostring(exports.data:getCharVar(src, 'id'))
    TriggerClientEvent('phone_shop:client:open_shop',src, { sim = simcards[Player], phone = phones[Player] })
end)

RegisterNetEvent('phone_shop:server:buy_phone')
AddEventHandler('phone_shop:server:buy_phone', function(data)
    local src = source
    local payment = "error"

    if data.payment == "byCash" then
        payment = exports.inventory:removePlayerItem(src, "cash", data.price, {})
    end

    if data.payment == "byCard" then
        local found = false
        for k, v in each(exports.bank:getPlayerAccesibleAccounts(src, "send")) do
            if k == data.account then
                found = true
                break
            end
        end

        for _, v in each(exports.data:getCharVar(src, 'jobs')) do
            for k, value in each(exports.bank:getJobAccesibleAccounts(v.job, v.job_grade, "send")) do
                if k == data.account then
                    found = true
                    break
                end
            end
        end
        payment = payFromAccount(data.account, data.price, false, string.format("Zakoupení telefonu %s", data.phoneModel))
    end

    if payment == "done" then
        for _, v in each(data.phoneModel) do
            if v then
                ee = {
                    [1] = src,
                    [2] = v
                }
                exports.phone:create(ee)
                --TriggerEvent("qb-phone:server:giveMobile", ee)
                Wait(100)
            end
        end
    end

    TriggerClientEvent("phone_shop:client:buy_phone", src, payment)
end)

RegisterNetEvent('phone_shop:server:recover')
AddEventHandler('phone_shop:server:recover', function(data)
    local src = source
    local payment = "error"
    local recover = "error"

    if data.payment == "byCash" then
        payment = exports.inventory:removePlayerItem(src, "cash", data.price, {})
    end

    if data.payment == "byCard" then
        local found = false
        for k, v in each(exports.bank:getPlayerAccesibleAccounts(src, "send")) do
            if k == data.account then
                found = true
                break
            end
        end

        for _, v in each(exports.data:getCharVar(src, 'jobs')) do
            for k, value in each(exports.bank:getJobAccesibleAccounts(v.job, v.job_grade, "send")) do
                if k == data.account then
                    found = true
                    break
                end
            end
        end
        payment = payFromAccount(data.account, data.price, false, string.format("Zakoupení telefonu %s", data.phoneModel))
    end

    if payment == "done" then
        if data.sync.model == "phone" then
            local sync = {}
            sync['settings'] = data.sync.settings
            sync["InstalledApps"] = data.sync["InstalledApps"]
            exports.inventory:updateItemData(src, data.phoneid, sync)
            SetTimeout(100, function()
                TriggerClientEvent('qb-phone:client:RefreshPhone', src)
            end)
            SetTimeout(100, function()
                TriggerServerEvent('qb-phone:server:EditContact', data.phoneid, data.sync.player_contacts)
            end)
            recover = "done"
        elseif data.sync.model == "sim" then
        end
        --give = exports.inventory:addPlayerItem(src, data.item, 1, data)
    end
    TriggerClientEvent("phone_shop:client:recover", src, payment, recover)
end)