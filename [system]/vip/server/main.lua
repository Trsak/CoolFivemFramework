local vipData = {}

MySQL.ready(
    function()
        Wait(250)
        MySQL.Async.execute("DELETE FROM tebex_quepoints WHERE until < NOW()", {})
    end
)

function getPlayerData(identifier, fromDatabase)
    if not vipData[identifier] or fromDatabase then
        local playerVipData = {}

        local vipQueuePoints =
            MySQL.Sync.fetchScalar(
            "SELECT SUM(amount) FROM tebex_quepoints WHERE identifier = @identifier AND until > NOW()",
            {["@identifier"] = identifier}
        )

        playerVipData.QueQuePoints = 0
        if vipQueuePoints then
            playerVipData.QueQuePoints = vipQueuePoints
        end

        local activeVips =
            MySQL.Sync.fetchAll(
            "SELECT type FROM vip_until WHERE identifier = @identifier AND until > NOW()",
            {["@identifier"] = identifier}
        )
        playerVipData.activeVips = {}
        for i = 1, #activeVips do
            if activeVips[i].type == 3 then
                playerVipData.QueQuePoints = playerVipData.QueQuePoints + 100
            elseif activeVips[i].type == 2 then
                playerVipData.QueQuePoints = playerVipData.QueQuePoints + 400
            elseif activeVips[i].type == 1 then
                playerVipData.QueQuePoints = playerVipData.QueQuePoints + 1200
            end

            table.insert(playerVipData.activeVips, activeVips[i])
        end

        local vipThings =
            MySQL.Sync.fetchAll(
            "SELECT `bank_account`, `plate`  FROM `tebex_things` WHERE `identifier` = @identifier LIMIT 1",
            {
                ["@identifier"] = identifier
            }
        )
        playerVipData.plate = 0

        if vipThings and vipThings[1] then
            playerVipData.plate = vipThings[1].plate
        end

        vipData[identifier] = playerVipData
    end

    return vipData[identifier]
end

function getQueQuePoints(identifier, db)
    local playerVipData = getPlayerData(identifier, db)
    local queQuePoints = 0

    if playerVipData ~= nil and playerVipData.QueQuePoints ~= nil then
        queQuePoints = playerVipData.QueQuePoints
    end

    return playerVipData.QueQuePoints
end

function getVipLevel(identifier)
    local playerVipData = getPlayerData(identifier)

    local vipLevel = 0

    if playerVipData.activeVips then
        for _, vip in each(playerVipData.activeVips) do
            if vipLevel < vip.type then
                vipLevel = vip.type
            end
        end
    end

    return vipLevel
end

AddEventHandler(
    "playerDropped",
    function(reason)
        local _source = source
        local steamIdentifier = GetPlayerIdentifier(_source, 0)

        if vipData[steamIdentifier] then
            vipData[steamIdentifier] = nil
        end
    end
)

RegisterNetEvent("vip:getVIPLevel")
AddEventHandler(
    "vip:getVIPLevel",
    function()
        local _source = source
        local steamIdentifier = GetPlayerIdentifier(_source, 0)
        local level = getVipLevel(steamIdentifier)

        TriggerClientEvent("vip:getVIPLevel", _source, level)
    end
)

-- TEBEX SCRIPTS
RegisterCommand(
    "addQueuePoints",
    function(src, args)
        args[3], args[4] = tonumber(args[3]), tonumber(args[4])
        if args[1] and args[2] and args[3] and args[4] and args[5] and args[6] then
            local steam = "steam:" .. args[2]
            MySQL.Async.execute(
                "INSERT INTO `tebex_quepoints` (`identifier`, `amount`, `until`) VALUES (@identifier, @amount, CURDATE() + INTERVAL " ..
                    tonumber(args[4]) .. " MONTH) ON DUPLICATE KEY UPDATE amount = amount + @amount",
                {
                    ["@identifier"] = steam,
                    ["@amount"] = tonumber(args[3])
                },
                function()
                    exports.logs:sendToDiscord(
                        {
                            channel = "tebex",
                            title = "Queue Points",
                            description = args[5] ..
                                (args[6] == "purchase" and " zakoupil " or " předplatil ") ..
                                    args[3] .. " Queue bodů pro Steam ID: " .. steam,
                            color = "34749"
                        },
                        source
                    )
                end
            )
        end
    end,
    true
)

RegisterCommand(
    "addVehiclePlate",
    function(src, args)
        args[2] = tonumber(args[2])
        if args[1] and args[2] then
            local steam = "steam:" .. args[1]
            MySQL.Async.execute(
                "INSERT INTO `tebex_things` (`plate`, `identifier`) VALUES (@plate, @identifier) ON DUPLICATE KEY UPDATE `plate` = `plate` + @plate",
                {
                    ["@plate"] = args[2],
                    ["@identifier"] = steam
                },
                function()
                    exports.logs:sendToDiscord(
                        {
                            channel = "tebex",
                            title = "Bankovní účty",
                            description = "Zakoupeno " .. args[2] .. " SPZtky pro Steam ID: " .. steam,
                            color = "34749"
                        },
                        source
                    )
                end
            )
        end
    end,
    true
)

RegisterCommand(
    "addPlayerChar",
    function(src, args)
        args[2] = tonumber(args[2])
        if args[1] and args[2] then
            local steam = "steam:" .. args[1]
            local user = exports.data:getUserByIdentifier(steam)
            if user then
                print "Server user"
                exports.data:updateUserVar(user.source, "chars_left", user.chars_left + args[2])
            else
                print "Database user"
                MySQL.Async.execute(
                    "UPDATE users SET chars_left = chars_left + @chars_left WHERE identifier = @identifier",
                    {
                        ["@identifier"] = steam,
                        ["@chars_left"] = tonumber(args[2])
                    },
                    function()
                        exports.logs:sendToDiscord(
                            {
                                channel = "tebex",
                                title = "Postava",
                                description = args[3] .. "Zakoupil postavu pro Steam ID: " .. steam,
                                color = "34749"
                            },
                            source
                        )
                    end
                )
            end
        end
    end,
    true
)
-- TEBEX SCRIPTS

RegisterCommand(
    "claimVehiclePlate",
    function(source, args)
        local _source = source
        local steamIdentifier = GetPlayerIdentifier(_source, 0)
        local plateRemains = getPlayerData(steamIdentifier, true).plate
        if plateRemains <= 0 then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = {"Nemáš dostupnou žádnou SPZ k aktivaci!"}
                }
            )
        elseif not args[1] then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = {"Musíš zadat starou SPZ k aktivaci!"}
                }
            )
        elseif not args[2] then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = {"Musíš zadat novou SPZ k aktivaci!"}
                }
            )
        elseif not exports.base_vehicles:getVehicle(args[1]) then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = {"Zadané vozidlo neexistuje!"}
                }
            )
        elseif args[1] == args[2] then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = {"SPZ se nesmí shodovat!"}
                }
            )
        elseif args[2]:match("%W") or string.len(args[2]) ~= 8 then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = {"Nová SPZ musí mít 8 znaků a být bez mezer!"}
                }
            )
        elseif exports.base_vehicles:doesVehicleExist(args[2]) then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = {"Nová zadaná SPZ již existuje!"}
                }
            )
        elseif exports.base_vehicles:getVehicle(args[1]).owner ~= exports.data:getCharVar(_source, "id") then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = {"Nejsi majitelem vozidla!"}
                }
            )
        elseif exports.base_vehicles:getVehicle(args[1]).in_garage == 0 then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = {"Vozidlo musí být v garáži!"}
                }
            )
        else
            local status = exports.base_vehicles:updateVehiclePlate(args[1], args[2])
            if status == "done" then
                TriggerClientEvent(
                    "chat:addMessage",
                    source,
                    {
                        templateId = "success",
                        args = {"SPZ byla úspěšně změněná!"}
                    }
                )
                MySQL.Async.execute(
                    "UPDATE `tebex_things` SET `plate` = `plate` - 1 WHERE `identifier` = @identifier",
                    {
                        ["@identifier"] = steamIdentifier
                    }
                )
            end
        end
    end
)
