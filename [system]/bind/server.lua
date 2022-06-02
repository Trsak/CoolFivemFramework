RegisterNetEvent("bind:loadBinds")
AddEventHandler(
    "bind:loadBinds",
    function()
        local _source = source
        local charId = exports.data:getCharVar(_source, "id")

        if charId then
            MySQL.Async.fetchAll(
                "SELECT binds FROM binds WHERE char_id = @char_id LIMIT 1",
                {
                    ["@char_id"] = charId
                },
                function(result)
                    if result ~= nil and result[1] ~= nil and json.decode(result[1].binds) ~= nil then
                        TriggerClientEvent("bind:loadBinds", _source, json.decode(result[1].binds))
                    end
                end
            )
        end
    end
)

RegisterNetEvent("bind:saveBinds")
AddEventHandler(
    "bind:saveBinds",
    function(binds)
        local _source = source
        local charId = exports.data:getCharVar(_source, "id")

        if charId then
            MySQL.Async.execute(
                "INSERT INTO binds (char_id, binds) VALUES (@char_id, @binds) ON DUPLICATE KEY UPDATE binds = @binds",
                {
                    ["@char_id"] = charId,
                    ["@binds"] = json.encode(binds)
                }
            )
        end
    end
)
