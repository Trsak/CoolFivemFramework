local alarmed = false

local doors = {}
local trolly = {}

local trollyChanges = {
    gold = 50,
    money = 50
}

Citizen.CreateThread(
    function()
        for i, door in each(Config.Points) do
            table.insert(
                doors,
                {
                    Coords = door.Coords,
                    Prop = door.Prop,
                    Changed = false,
                    Reserved = false,
                    Made = false,
                    Actions = door.Actions,
                    DoorLockID = door.DoorLockID
                }
            )
        end
        for i, coords in each(Config.TrollyPlaces) do
            table.insert(
                trolly,
                {
                    Coords = coords,
                    NetId = nil,
                    Reserved = false,
                    Type = nil,
                    Left = 0
                }
            )
        end
    end
)

RegisterNetEvent("rob_pacificbank:sync")
AddEventHandler(
    "rob_pacificbank:sync",
    function()
        local _source = source
        while #doors == 0 do
            Citizen.Wait(20)
        end
        syncData(_source, false)
    end
)

RegisterNetEvent("rob_pacificbank:checkItem")
AddEventHandler(
    "rob_pacificbank:checkItem",
    function(doorId, place)
        if not doors[doorId].Reserved then
            local _source = source
            local policeCount = exports.data:countEmployees(nil, "police", nil, true)
            if policeCount < 12 then
                TriggerClientEvent(
                    "chat:addMessage",
                    _source,
                    {
                        templateId = "error",
                        args = {
                            "Pro vykradení banky musí být na serveru alespoň 12 policistů!"
                        }
                    }
                )
                return
            end

            local item = nil
            item = ((place == "thermite" or place == "lockpick") and place or checkDepencencies(_source))
            if item then
                local hasItem = exports.inventory:checkPlayerItem(_source, item, 1, {})
                if hasItem then
                    if item ~= "laptop" then
                        local remove = exports.inventory:removePlayerItem(_source, item, 1, {})
                    end

                    doors[doorId].Reserved = _source
                    TriggerClientEvent("rob_pacificbank:doAction", _source, doorId, place)
                    if not alarmed and place == "thermite" then
                        TriggerEvent("rob_pacificbank:alarm")
                    end
                else
                    TriggerClientEvent(
                        "notify:display",
                        _source,
                        {
                            type = "warning",
                            title = "Velká banka",
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
                        title = "Velká banka",
                        text = "Něco ti chybí!",
                        icon = "fas fa-wrench",
                        length = 3000
                    }
                )
            end
        end
    end
)

RegisterNetEvent("rob_pacificbank:reserveDoor")
AddEventHandler(
    "rob_pacificbank:reserveDoor",
    function(doorId, reserve)
        local _source = source
        if not reserve then
            if trolly[doorId].Reserved == _source then
                doors[doorId].Reserved = not doors[doorId].Reserved
                syncData(nil, true)
            end
        else
            trolly[doorId].Reserved = _source
        end
    end
)

RegisterNetEvent("rob_pacificbank:reserveTrolly")
AddEventHandler(
    "rob_pacificbank:reserveTrolly",
    function(trollyId)
        if not trolly[trollyId].Reserved then
            trolly[trollyId].Reserved = source
            syncData(nil, true)
        end
    end
)

RegisterNetEvent("rob_pacificbank:lootTrolly")
AddEventHandler(
    "rob_pacificbank:lootTrolly",
    function(trollyId)
        local _source = source
        if trolly[trollyId].Reserved == _source then
            if trolly[trollyId].Left > 0 then
                local type = type == "gold"
                exports.logs:sendToDiscord(
                    {
                        channel = "paciffic",
                        title = "Hlavní banka",
                        description = "Sebral " .. ((type == "gold" and "zlatou cihlu" or "peníze") .. (type == "gold" and "1" or "1000") .. "x"),
                        color = "34749"
                    },
                    source
                )
                if type then
                    exports.inventory:forceAddPlayerItem(_source, "goldbar", 1, {})
                else
                    exports.inventory:forceAddPlayerItem(_source, "cash", 10000, {})
                end
                trolly[trollyId].Left = trolly[trollyId].Left - 1
                syncData(nil, false)
            end
        end
    end
)

function syncData(user, reserve)
    if not user then
        user = -1
    end
    TriggerClientEvent(
        "rob_pacificbank:sync",
        user,
        {
            Doors = doors,
            Trolly = trolly,
            Reserve = reserve,
            Started = started
        }
    )
end

RegisterNetEvent("rob_pacificbank:unlockDoors")
AddEventHandler(
    "rob_pacificbank:unlockDoors",
    function(doorId, style)
        doors[doorId].Changed = true
        doors[doorId].Made = true
        syncData(nil, false)
        exports.doorlock:updateDoorState(doors[doorId].DoorLockID, false)
        Citizen.Wait(100)
        if style == "Loud" then
            TriggerClientEvent("rob_pacificbank:swapDoors", -1, doorId, "Melt")
        end
    end
)

RegisterNetEvent("rob_pacificbank:startThermite")
AddEventHandler(
    "rob_pacificbank:startThermite",
    function(doorId)
        TriggerClientEvent("rob_pacificbank:startThermite", -1, doorId)
    end
)

RegisterNetEvent("rob_pacificbank:vaultManipulate")
AddEventHandler(
    "rob_pacificbank:vaultManipulate",
    function(type)
        TriggerClientEvent("rob_pacificbank:vaultManipulate", -1, type)
    end
)

RegisterNetEvent("rob_pacificbank:createTrollys")
AddEventHandler(
    "rob_pacificbank:createTrollys",
    function()
        local maxTrollys = math.random(2, 4)
        local trollys = {}

        for i = 1, maxTrollys do
            local finished = false
            while not finished do
                for type, typeChance in pairs(trollyChanges) do
                    if math.random(100) <= typeChance then
                        local randomPlace = math.random(#trolly)
                        if not trolly[randomPlace].NetId then
                            local createdObject =
                                CreateObject(Config.Models[type], trolly[randomPlace].Coords.xyz, true, true, false)
                            trolly[randomPlace].Type = type
                            trolly[randomPlace].Left = 44
                            Citizen.Wait(1200)
                            SetEntityHeading(tonumber(createdObject), trolly[randomPlace].Coords.w)
                            trolly[randomPlace].NetId = NetworkGetNetworkIdFromEntity((tonumber(createdObject)))
                            finished = true
                        end
                    end
                end
                Citizen.Wait(20)
            end
        end
        syncData(nil, false)
    end
)

RegisterNetEvent("rob_pacificbank:alarm")
AddEventHandler(
    "rob_pacificbank:alarm",
    function()
        if not alarmed then
            TriggerEvent("sound:playYoutubeSound", "SVJENXqb388", 60.0, Config.Sound, "pacificbank")
            TriggerEvent(
                "outlawalert:sendAlert",
                {
                    Type = "pacific",
                    Coords = Config.Sound
                }
            )
            alarmed = true

            Citizen.Wait(300000)
            TriggerEvent("sound:stopSound", "pacificbank")
        end
    end
)

function checkDepencencies(source)
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
