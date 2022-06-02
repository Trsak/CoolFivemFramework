local isSpawned = false

Citizen.CreateThread(
    function()
        while true do
            Wait(5000)

            if isSpawned then
                setPlayerConfig()
            end
        end
    end
)

function setPlayerConfig()
    SetPoliceIgnorePlayer(PlayerId(), true)
    NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(PlayerPedId(), true, true)
    SetMaxWantedLevel(0)
    SetAutoGiveParachuteWhenEnterPlane(PlayerId(), false)
    SetPedCanLosePropsOnDamage(PlayerPedId(), false, 0)
end

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "spawned" or exports.data:getUserVar("status") == "dead" then
            setPlayerConfig()
            isSpawned = true
        else
            isSpawned = false
        end
    end
)

Citizen.CreateThread(
    function()
        while not isSpawned do
            Citizen.Wait(250)
        end

        while Config.autoCharacterSave do
            Citizen.Wait(Config.saveDuration)

            if isSpawned then
                exports.data:saveChar(-1)
            end
        end
    end
)

function getClosestPlayer()
    local players = GetActivePlayers()
    local closest = {
        player = -1,
        distance = -1,
        playerid = -1
    }
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)

    for index, value in each(players) do
        local target = GetPlayerPed(value)
        if (target ~= ply) then
            local targetCoords = GetEntityCoords(target, 0)
            local distance = #(plyCoords - targetCoords)
            if (closest.distance == -1 or closest.distance > distance) then
                closest.player = value
                closest.distance = distance
                closest.playerid = GetPlayerServerId(value)
            end
        end
    end
    return closest
end

function getClosestPlayersInDistance(maxDistance)
    local players = GetActivePlayers()
    local closest = {}
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)

    for index, value in each(players) do
        local target = GetPlayerPed(value)

        if (target ~= ply) then
            local targetCoords = GetEntityCoords(target, 0)
            local distance = #(plyCoords - targetCoords)
            if (distance <= maxDistance) then
                table.insert(
                    closest,
                    {
                        player = value,
                        distance = distance,
                        playerid = GetPlayerServerId(value)
                    }
                )
            end
        end
    end

    return closest
end

function reverseArray(arr)
    local i, j = 1, #arr

    while i < j do
        arr[i], arr[j] = arr[j], arr[i]

        i = i + 1
        j = j - 1
    end
end
