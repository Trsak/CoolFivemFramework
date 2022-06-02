local weapons = nil

MySQL.ready(function()
    Wait(5)

    MySQL.Async.fetchAll("SELECT * FROM register_weapons", {}, function(result)
        if not weapons then
            weapons = {}
        end
        if #result > 0 then
            for i, weapon in each(result) do
                weapons[weapon.serialnumber] = {
                    owner = weapon.owner,
                    bought = weapon.bought,
                    type = weapon.type,
                    status = weapon.status,
                    changed = false
                }
            end
        end
        SetTimeout(120000, saveWeapons)
    end)
end)

function saveWeapons()
    for key, _ in pairs(weapons) do
        if weapons[key].changed then
            weapons[key].changed = false
            MySQL.Async.execute(
                "UPDATE register_weapons SET owner=@owner, bought=@bought, type=@type, status=@status WHERE serialnumber=@serialnumber",
                {
                    ["@serialnumber"] = key,
                    ["@owner"] = weapons[key].owner,
                    ["@bought"] = weapons[key].bought,
                    ["@type"] = weapons[key].type,
                    ["@status"] = weapons[key].status
                })
        end
    end
    SetTimeout(120000, saveWeapons)
end

RegisterNetEvent("rw:checkSerialnumber")
AddEventHandler("rw:checkSerialnumber", function(serialnumber)
    local client = source

    if not isPolice(client) then
        return
    end

    local isRegistered, weaponData = false, {}
    if weapons[serialnumber] then
        isRegistered = true

        local ownerName = weapons[serialnumber].owner
        if tonumber(ownerName) then
            weaponData.name = exports.data:getCharNameById(ownerName)
        else
            weaponData.name = ownerName
        end


        weaponData.serialnumber = serialnumber
        weaponData.bought = os.date("%x", weapons[serialnumber].bought)
        weaponData.type = weapons[serialnumber].type
        weaponData.status = weapons[serialnumber].status
    end

    TriggerClientEvent("rw:checkSerialnumber", client, isRegistered, weaponData)
end)

function registerWeapon(serialnumber, owner, type, date)
    if weapons[serialnumber] then
        return "exits"
    end

    if not date or date == 0 then
        date = os.time()
    end

    MySQL.Async.execute(
        "INSERT INTO register_weapons (serialnumber, owner, bought, type, status) VALUES (@serialnumber, @owner, @date, @type, @status)",
        {
            ["@serialnumber"] = serialnumber,
            ["@owner"] = owner,
            ["@date"] = date,
            ["@type"] = type,
            ["@status"] = "registered"
        })

    weapons[serialnumber] = {
        owner = owner,
        bought = date,
        type = type,
        status = "registered",
        changed = false
    }

    return "done"
end

RegisterNetEvent("rw:add")
AddEventHandler("rw:add", function(serialnumber, clientOwner, type)
    local client = source

    if not isPolice(client) then
        return
    end

    if GetPlayerName(clientOwner) then
        clientOwner = exports.data:getCharVar(clientOwner, "id")
    end
    local date = os.time()

    MySQL.Async.execute(
        "INSERT INTO register_weapons (serialnumber, owner, bought, type, status) VALUES (@serialnumber, @owner, @date, @type, @status)",
        {
            ["@serialnumber"] = serialnumber,
            ["@owner"] = clientOwner,
            ["@date"] = date,
            ["@type"] = type,
            ["@status"] = "registered"
        })

    weapons[serialnumber] = {
        owner = clientOwner,
        bought = date,
        type = type,
        status = "registered",
        changed = false
    }

    TriggerClientEvent("notify:display", client, {
        type = "info",
        title = "Registr zbraní",
        text = "Zbraň se seriovým číslem " .. serialnumber .. " zadána do systému!",
        icon = "fas fa-atlas",
        length = 5000
    })
end)

RegisterNetEvent("rw:edit")
AddEventHandler("rw:edit", function(serialnumber, type, status)
    local client = source

    if not weapons[serialnumber] or not isPolice(client) then
        return
    end

    weapons[serialnumber].type = type
    weapons[serialnumber].status = status
    weapons[serialnumber].changed = true

    TriggerClientEvent("notify:display", client, {
        type = "info",
        title = "Registr zbraní",
        text = "Zbraň se seriovým číslem " .. serialnumber .. " upravena v systému",
        icon = "fas fa-atlas",
        length = 3500
    })
end)

RegisterNetEvent("rw:remove")
AddEventHandler("rw:remove", function(serialnumber)
    local client = source

    if not weapons[serialnumber] or not isPolice(client) then
        return
    end

    weapons[serialnumber] = nil

    MySQL.Async.execute("DELETE FROM register_weapons WHERE serialnumber = @serialnumber", {
        ["@serialnumber"] = serialnumber
    })

    TriggerClientEvent("notify:display", client, {
        type = "success",
        title = "Úspěch",
        text = "Zbraň byla odebrána ze systému",
        icon = "fas fa-atlas",
        length = 3000
    })
end)

function isPolice(client)
    return exports.base_jobs:hasUserJobType(client, "police", true)
end
