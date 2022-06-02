local doorState = {}

Citizen.CreateThread(
    function()
        Citizen.Wait(500)
        prepareDoors()
    end
)
RegisterCommand(
    "giveKeys",
    function(source, args)
        local client = source
        if exports.data:getUserVar(source, "admin") < 2 then
            TriggerClientEvent(
                "chat:addMessage",
                client,
                {
                    templateId = "error",
                    args = {"Na toto nemáte právo"}
                }
            )
            return
        end
        if not args[1] or not args[2] then
            TriggerClientEvent(
                "chat:addMessage",
                client,
                {
                    templateId = "error",
                    args = {"Formát: /giveKeys [door_keys/door_keycard] [pd-missionrow] [počet] [ID]"}
                }
            )
            return
        end

        if not doDoorExists(args[2]) then
            TriggerClientEvent(
                "chat:addMessage",
                client,
                {
                    templateId = "error",
                    args = {"Takové dveře neexistují"}
                }
            )
            return
        end

        local count = 1
        if args[3] and tonumber(args[3]) then
            count = tonumber(args[3])
        end

        if args[4] and tonumber(args[4]) and GetPlayerName(tonumber(args[4])) then
            client = tonumber(args[4])
        end

        exports.inventory:addPlayerItem(
            client,
            args[1],
            count,
            {
                id = "door_keys-" .. args[2],
                doorid = args[2],
                label = "Prostý klíč... K čemu tak může být.. Asi se někam strká.."
            }
        )
    end
)

function doDoorExists(key_id)
    for _, v in pairs(doorState) do
        if v.key_id then
            for _, key in pairs(v.key_id) do
                if key_id == key then
                    return true
                end
            end
        end
    end

    return false
end

RegisterNetEvent("doorlock:updateState")
AddEventHandler(
    "doorlock:updateState",
    function(doorID, state)
        local door = doorState[doorID]

        if door then
            doorState[doorID].locked = state
        end

        TriggerClientEvent("doorlock:updateState", -1, doorID, state)
    end
)

RegisterNetEvent("doorlock:getDoorsState")
AddEventHandler(
    "doorlock:getDoorsState",
    function()
        local _source = source
        TriggerClientEvent("doorlock:doorsState", _source, doorState)
    end
)

function updateDoorState(doorID, state)
    local door = doorState[doorID]

    if door then
        doorState[doorID].locked = state
    end

    TriggerClientEvent("doorlock:updateState", -1, doorID, state)
end

function prepareDoors()
    MySQL.Async.fetchAll(
        "SELECT * FROM doors",
        {},
        function(result)
            for i, res in each(result) do
                if type(res.objects) == "string" then
                    res.objects = json.decode(res.objects)
                end
                if type(res.key_id) == "string" then
                    res.key_id = json.decode(res.key_id)
                end
                if type(res.objects) == "string" then
                    res.objects = json.decode(res.objects)
                end
                res.locked = (res.locked == 1)
                for x, door in each(res.objects) do
                    local coords = door.objCoords
                    door.objCoords = vector3(coords.x, coords.y, coords.z)
                end
                local coords = json.decode(res.text)
                res.text = vec3(coords.x, coords.y, coords.z)
                doorState[tostring(res.id)] = res
            end
            TriggerClientEvent("doorlock:doorsState", -1, doorState)
        end
    )
end

RegisterNetEvent("doorlock:createDoors")
AddEventHandler(
    "doorlock:createDoors",
    function(data)
        local _source = source
        if exports.data:getUserVar(_source, "admin") > 2 then
            MySQL.Async.execute(
                "INSERT INTO doors (key_id, text, objects, locked, distance, note) VALUES (@key_id, @text, @objects, @locked, @distance, @note)",
                {
                    ["@key_id"] = json.encode(data.Keys),
                    ["@text"] = json.encode(data.Text),
                    ["@objects"] = json.encode(data.Objects),
                    ["@locked"] = data.Locked and 1 or 0,
                    ["@distance"] = data.Distance,
                    ["@note"] = data.Note
                },
                function()
                    TriggerClientEvent(
                        "chat:addMessage",
                        _source,
                        {
                            templateId = "success",
                            args = {"Dveře byly úspěšně vytvořeny!"}
                        }
                    )
                    prepareDoors()
                end
            )
        else
            exports.admin:banClientForCheating(
                _source,
                "0",
                "Cheating",
                "doorlock:createDoors",
                "Hráč se pokusil vytvořit dveře!"
            )
        end
    end
)
