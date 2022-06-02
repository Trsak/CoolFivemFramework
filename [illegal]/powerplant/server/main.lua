local points = {}
local blackout = false
local pointsReady = 0
local ready = true
local alarmed = false

Citizen.CreateThread(
    function()
        for i, point in each(Config.Points) do
            table.insert(
                points,
                {
                    Coords = point.Coords,
                    Changed = false,
                    Reserved = false,
                    Made = false,
                    Actions = point.Actions
                }
            )
        end
    end
)

RegisterNetEvent("powerplant:sync")
AddEventHandler(
    "powerplant:sync",
    function()
        while #points == 0 do
            Citizen.Wait(20)
        end
        syncData(source, false)
    end
)

RegisterNetEvent("powerplant:checkItem")
AddEventHandler(
    "powerplant:checkItem",
    function(pointId, place)
        if not points[pointId].Reserved then
            local _source = source
            local policeCount = exports.data:countEmployees(nil, "police", nil, true)

            if policeCount < 0 then -- 12
                TriggerClientEvent(
                    "chat:addMessage",
                    _source,
                    {
                        templateId = "error",
                        args = {
                            "Pro elektrárnu musí být na serveru alespoň 12 policistů!"
                        }
                    }
                )
                return
            elseif not ready then
                return
            end

            local item = nil
            item = (place == "Bomb" and "c4" or checkUsb(_source))
            if item then
                local hasItem = exports.inventory:checkPlayerItem(_source, item, 1, {})
                if hasItem then
                    if item ~= "laptop" then
                        local remove = exports.inventory:removePlayerItem(_source, item, 1, {})
                    end

                    points[pointId].Reserved = true
                    TriggerClientEvent("powerplant:doAction", _source, pointId, place)
                else
                    TriggerClientEvent(
                        "notify:display",
                        _source,
                        {
                            type = "warning",
                            title = "Elektrárna",
                            text = "Chybí ti " .. exports.inventory:getItem(item).label .. "!",
                            icon = "fas fa-wrench",
                            length = 3000
                        }
                    )
                end
            else
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "warning",
                        title = "Elektrárna",
                        text = "Něco ti chybí!",
                        icon = "fas fa-wrench",
                        length = 3000
                    }
                )
            end
        end
    end
)
RegisterNetEvent("powerplant:doPoint")
AddEventHandler(
    "powerplant:doPoint",
    function(pointId)
        local _source = source
        if not points[pointId].Made and points[pointId].Reserved then
            points[pointId].Changed = true
            points[pointId].Made = true
            pointsReady = pointsReady + 1
            syncData(nil, false)
        end
    end
)

RegisterNetEvent("powerplant:blackout")
AddEventHandler(
    "powerplant:blackout",
    function()
        if ready and not blackout then
            ready, blackout = false, true
            Citizen.SetTimeout(
                10000,
                function()
                    syncData(nil, false)
                    TriggerClientEvent("powerplant:playAudio", -1)
                    TriggerEvent("powerplant:blackout", true)
                    Citizen.SetTimeout(
                        pointsReady * 60000,
                        function()
                            blackout, ready, pointsReady, alarmed = false, true, 0, false
                            syncData(nil, false)
                            TriggerEvent("powerplant:blackout", false)
                        end
                    )
                end
            )
        end
    end
)

RegisterNetEvent("powerplant:alarm")
AddEventHandler(
    "powerplant:alarm",
    function()
        if not alarmed then
            TriggerEvent(
                "sound:playYoutubeSound",
                "SVJENXqb388",
                600.0,
                vec3(2741.467529, 1527.203369, 51.699089),
                "powerplant"
            )

            TriggerEvent(
                "outlawalert:sendAlert",
                {
                    Type = "powerplant",
                    Coords = vec3(2741.467529, 1527.203369, 51.699089)
                }
            )
            alarmed = true
        end
    end
)

function getBlackoutState()
    return blackout
end

function syncData(user, reserve)
    if not user then
        user = -1
    end
    TriggerClientEvent(
        "powerplant:sync",
        user,
        {
            Points = points,
            Reserve = reserve,
            Blackout = blackout,
            Ready = ready
        }
    )
end

function checkUsb(source)
    local hasLaptop = exports.inventory:checkPlayerItem(source, "laptop", 1, {})
    if hasLaptop then
        local hasCard = exports.inventory:checkPlayerItem(source, "hack_card", 1, {})
        if hasCard then
            local hasUsb = exports.inventory:checkPlayerItem(source, "hack_usb", 1, {})
            if hasUsb then
                return "laptop"
            else
                return false
            end
        else
            return false
        end
    else
        return false
    end
end
