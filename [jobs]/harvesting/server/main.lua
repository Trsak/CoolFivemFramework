local points = {}

Citizen.CreateThread(
    function()
        points = {}
        for type, data in pairs(Config.Jobs) do
            points[type] = {}
            for i, coords in each(data.Coords) do
                table.insert(
                    points[type],
                    {
                        Coords = coords,
                        Available = data.MaxCount,
                        Reserved = false
                    }
                )
            end
        end
        TriggerClientEvent("harvesting:sync", -1, points)
    end
)
RegisterNetEvent("harvesting:sync")
AddEventHandler(
    "harvesting:sync",
    function()
        TriggerClientEvent("harvesting:sync", source, points)
    end
)

RegisterNetEvent("harvesting:reservePoint")
AddEventHandler(
    "harvesting:reservePoint",
    function(data, status)
        points[data.Type][data.Id].Reserved = not points[data.Type][data.Id].Reserved
        TriggerClientEvent("harvesting:sync", -1, points)
    end
)
RegisterNetEvent("harvesting:madePoint")
AddEventHandler(
    "harvesting:madePoint",
    function(data)
        if points[data.Type][data.Id].Reserved then
            local _source = source
            points[data.Type][data.Id].Available = points[data.Type][data.Id].Available - 1

            local configWay = Config.Jobs[data.Type].Reward
            local itemCount = math.random(configWay.Count[1], configWay.Count[2])

            local itemAddDone = exports.inventory:forceAddPlayerItem(_source, configWay.ItemName, itemCount, {})

            local labels = Config.Jobs[data.Type].Labels
            if itemAddDone == "done" then
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "info",
                        title = labels.Title,
                        text = labels.Picked[1] .. " " .. itemCount .. " " .. labels.Picked[2],
                        icon = labels.Icon,
                        length = 3000
                    }
                )
            else
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "info",
                        title = labels.Title,
                        text = labels.NoSpace,
                        icon = labels.Icon,
                        length = 3000
                    }
                )
            end

            if points[data.Type][data.Id].Available <= 0 then
                SetTimeout(
                    Config.Jobs[type].Delay,
                    function()
                        points[data.Type][data.Id].Available = Config.Jobs[data.Type].MaxCount

                        TriggerClientEvent("harvesting:sync", -1, points)
                    end
                )
            end
            points[data.Type][data.Id].Reserved = false

            TriggerClientEvent("harvesting:sync", -1, points)
        end
    end
)

RegisterNetEvent("harvesting:printCoords")
AddEventHandler(
    "harvesting:printCoords",
    function(coords)
        print(table.concat(coords))
    end
)
