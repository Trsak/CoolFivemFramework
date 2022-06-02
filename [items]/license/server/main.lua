local licenses = {}
local loaded = false

MySQL.ready(
    function()
        Wait(5)

        MySQL.Async.fetchAll(
            "SELECT * FROM licenses",
            {},
            function(result)
                if #result > 0 then
                    for i, res in each(result) do
                        licenses[tostring(res.charid)] = json.decode(res.data)
                    end
                    loaded = true
                    print("^3[LICENSE]^7 Successfully loaded with " .. tableLength(licenses) .. " licenses!")
                end
            end
        )
        while true do
            Citizen.Wait(1800000)
            local time = os.time()
            for char, lic in pairs(licenses) do
                local toUnblock = {}
                for type, curr in pairs(lic) do
                    if curr.status == "blocked" and curr.blocked < time then
                        toUnblock[type] = 0
                    end
                end
                unblockLicences(char, toUnblock, 0)
            end
        end
    end
)

RegisterNetEvent("license:sync")
AddEventHandler(
    "license:sync",
    function(db)
        while not loaded do
            Citizen.Wait(1000)
        end
        local _source = source
        local charId = exports.data:getCharVar(_source, "id")
        if not licenses[tostring(charId)] then
            licenses[tostring(charId)] = {}
            MySQL.Async.execute(
                "INSERT INTO licenses (charId, data) VALUES (@charId, '[]')",
                {
                    ["@charId"] = charId
                }
            )
        end
        local toSend = licenses[tostring(charId)]
        if db then
            toSend = getCharLicenses(charId, true)
        end

        TriggerClientEvent("license:sync", _source, toSend)
    end
)

function getCharLicenses(charId, db)
    if not licenses[tostring(charId)] then
        licenses[tostring(charId)] = {}
        MySQL.Async.execute(
            "INSERT INTO licenses (charId, data) VALUES (@charId, '[]')",
            {
                ["@charId"] = charId
            }
        )
    end
    if db then
        MySQL.Async.fetchAll(
            "SELECT * FROM licenses WHERE `charid` = @charid",
            {
                ["@charid"] = charId
            },
            function(result)
                if #result > 0 then
                    licenses[tostring(charId)] = json.decode(result[1].data)
                end
            end
        )
    end
    return licenses[tostring(charId)]
end

RegisterNetEvent("license:getLicenses")
AddEventHandler(
    "license:getLicenses",
    function(type)
        local _source = source
        local charId = exports.data:getCharVar(_source, "id")
        if not licenses[tostring(charId)] then
            licenses[tostring(charId)] = {}
            MySQL.Async.execute(
                "INSERT INTO licenses (charId, data) VALUES (@charId, '[]')",
                {
                    ["@charId"] = charId
                }
            )
        end
        TriggerClientEvent("license:getLicenses", _source, licenses[tostring(charId)], type, os.time())
    end
)

RegisterNetEvent("license:checkMoney")
AddEventHandler(
    "license:checkMoney",
    function(test)
        local _source = source
        local charId = exports.data:getCharVar(_source, "id")
        local idData = { id = charId }
        local hasId = exports.inventory:checkPlayerItem(_source, "idcard", 1, idData)

        if hasId then
            hasCash = exports.inventory:removePlayerItem(_source, "cash", Config.Licenses[test].Price, {})
        end
        TriggerClientEvent("license:checkedMoney", _source, test, hasCash, hasId)
    end
)

RegisterCommand(
    "addLicenseOffline",
    function(client, args)
        if client == 0 and args[1] ~= nil and args[2] ~= nil and args[3] ~= nil then
            addLicenseToChar(
                {
                    char = tonumber(args[1]),
                    test = args[2],
                    source = getUserByCharId(args[1]),
                    license = {
                        status = "done",
                        blocked = 0,
                        points = 10,
                        byWho = tonumber(args[3])
                    }
                }
            )
        end
    end
)

RegisterCommand(
    "blockLicenseOffline",
    function(client, args)
        if client == 0 and args[1] ~= nil and args[2] ~= nil and args[3] ~= nil and args[4] ~= nil then
            blockLicence(args[1], args[2], args[3], args[4])
        end
    end
)

RegisterCommand(
    "unblockLicenseOffline",
    function(client, args)
        if client == 0 and args[1] ~= nil and args[2] ~= nil and args[3] ~= nil then
            unblockLicence(args[1], args[2], args[3])
        end
    end
)

function getUserByCharId(charId)
    local playerList = exports.data:getUsersBaseData(
        function(userData)
            return (userData.status == "spawned" or userData.status == "dead") and (userData.character ~= nil and userData.character.id == tonumber(charId))
        end
    )

    for _, userData in each(playerList) do
        return userData.source
    end

    return nil
end

RegisterNetEvent("license:successful")
AddEventHandler(
    "license:successful",
    function(data)
        local _source = source
        data.char = tostring(exports.data:getCharVar(_source, "id"))
        if not licenses[data.char][data.test] or (licenses[data.char][data.test] and licenses[data.char][data.test].status and licenses[data.char][data.test].status == "unblocked") then
            data.license = {
                status = "done",
                blocked = 0,
                points = data.points
            }
            data.source = _source
            addLicenseToChar(data)
        end
    end
)

function addLicenseToChar(data)
    data.char = tostring(data.char)

    if not licenses[data.char] then
        licenses[data.char] = {}
    end

    licenses[data.char][data.test] = data.license

    if data.source then
        if data.test ~= "TR" then
            exports.inventory:removePlayerItem(
                data.source,
                "license",
                1,
                {
                    id = data.char
                }
            )
            Citizen.Wait(500)
            exports.inventory:addPlayerItem(data.source, "license", 1, makeLicenseCard(data.char, data.source))
        else
            TriggerClientEvent(
                "notify:display",
                data.source,
                {
                    type = "success",
                    title = "Autoškola",
                    text = "Záznam o splněné teoretické zkoušce máme v databázi, papír k tomu žádný není potřeba.",
                    icon = "far fa-id-card",
                    length = 5000
                }
            )
        end

        TriggerClientEvent("license:sync", data.source, licenses[data.char])
    end

    MySQL.Async.execute(
        "UPDATE licenses SET data=@data WHERE charid = @charId",
        {
            ["@data"] = json.encode(licenses[data.char]),
            ["@charId"] = tonumber(data.char)
        }
    )
end

function makeLicenseCard(char, source)
    char = tostring(char)
    local data = {}
    local counted = 0
    if licenses[char] then
        data.id = char
        data.label = exports.data:getCharVar(source, "firstname") ..
            " " .. exports.data:getCharVar(source, "lastname") .. "<br>Skupiny: "

        for license, value in pairs(licenses[char]) do
            if licenses[char][license].blocked < os.time() then
                if license ~= "TR" and license ~= "TA" then
                    data.label = data.label .. " " .. license
                    counted = counted + 1
                end
            end
        end
    end
    if counted == 0 then
        return "noDocument"
    end
    return data
end

function blockLicences(char, blockedLicenses, bywho)
    char = tostring(char)
    for licenseType, blockInDays in pairs(blockedLicenses) do
        if not licenses[char][licenseType] then
            licenses[char][licenseType] = {}
        end
        licenses[char][licenseType].status = "blocked"
        licenses[char][licenseType].blocked = os.time() + (86400 * value)
        licenses[char][licenseType].blockedLabel = os.date("%d.%m.%Y %H:%M:%S", os.time() + (86400 * value))
        licenses[char][licenseType].bywho = bywho
        licenses[char][licenseType].date = os.time()
    end

    MySQL.Async.execute(
        "UPDATE licenses SET data=@data WHERE charid = @charId",
        {
            ["@data"] = json.encode(licenses[char]),
            ["@charId"] = char
        }
    )
end

function blockLicence(char, licenseType, byWho, length)
    char = tostring(char)

    if not licenses[char] then
        licenses[char] = {}
    end

    if not licenses[char][licenseType] then
        licenses[char][licenseType] = {}
    end

    licenses[char][licenseType].status = "blocked"
    licenses[char][licenseType].blocked = os.time() + (length)
    licenses[char][licenseType].blockedLabel = os.date("%d.%m.%Y %H:%M:%S", os.time() + (length))
    licenses[char][licenseType].bywho = byWho
    licenses[char][licenseType].date = os.time()

    MySQL.Async.execute(
        "UPDATE licenses SET data=@data WHERE charid = @charId",
        {
            ["@data"] = json.encode(licenses[char]),
            ["@charId"] = char
        }
    )

    local licenseReciever = getUserByCharId(tonumber(char))
    if licenseReciever then
        TriggerClientEvent("license:sync", licenseReciever, licenses[char])
    end
end

function unblockLicence(char, licenseType, byWho)
    char = tostring(char)

    if not licenses[char][licenseType] then
        licenses[char][licenseType] = {}
    end

    licenses[char][licenseType].status = "unblocked"
    licenses[char][licenseType].blocked = 0
    licenses[char][licenseType].bywho = byWho
    licenses[char][licenseType].date = os.time()

    MySQL.Async.execute(
        "UPDATE licenses SET data=@data WHERE charid = @charId",
        {
            ["@data"] = json.encode(licenses[char]),
            ["@charId"] = char
        }
    )

    local licenseReciever = getUserByCharId(tonumber(char))
    if licenseReciever then
        TriggerClientEvent("license:sync", licenseReciever, licenses[char])
    end
end

function unblockLicences(char, blockedLicenses, byWho)
    char = tostring(char)

    for licenseType, blockInDays in pairs(blockedLicenses) do
        if not licenses[char][licenseType] then
            licenses[char][licenseType] = {}
        end

        licenses[char][licenseType].status = "unblocked"
        licenses[char][licenseType].blocked = 0
        licenses[char][licenseType].bywho = byWho
        licenses[char][licenseType].date = os.time()
    end

    MySQL.Async.execute(
        "UPDATE licenses SET data=@data WHERE charid = @charId",
        {
            ["@data"] = json.encode(licenses[char]),
            ["@charId"] = char
        }
    )
end

function setDoneState(char, blockedLicenses, bywho)
    local char = tostring(char)
    for licenseType, blockInDays in pairs(blockedLicenses) do
        if not licenses[char][licenseType] then
            licenses[char][key] = {}
        end
        licenses[char][licenseType].status = "done"
        licenses[char][licenseType].blocked = 0
        licenses[char][licenseType].bywho = bywho
        licenses[char][licenseType].date = os.time()
    end

    MySQL.Async.execute(
        "UPDATE licenses SET data=@data WHERE charid = @charId",
        {
            ["@data"] = json.encode(licenses[char]),
            ["@charId"] = tonumber(char)
        }
    )
end

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end
