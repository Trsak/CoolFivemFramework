local entities = {}

RegisterNetEvent("sound:playSound")
AddEventHandler(
    "sound:playSound",
    function(sound, maxDistance, coords, id, instance, networkId)
        if instance == nil then
            instance = ""

            if source ~= nil and GetPlayerName(source) ~= nil then
                instance = exports.instance:getPlayerInstance(source)
            end
        end

        if networkId ~= nil then
            coords = GetEntityCoords(NetworkGetEntityFromNetworkId(networkId))
            entities[tostring(id)] = networkId
        end

        TriggerClientEvent("sound:playSound", -1, sound, maxDistance, coords, id, instance)
    end
)

RegisterNetEvent("sound:playYoutubeSound")
AddEventHandler(
    "sound:playYoutubeSound",
    function(video, maxDistance, coords, id, instance, networkId)
        if instance == nil then
            instance = ""

            if source and GetPlayerName(source) then
                instance = exports.instance:getPlayerInstance(source)
            end
            if istance == " " or not instance then
                instance = ""
            end
        end

        if networkId then
            coords = GetEntityCoords(NetworkGetEntityFromNetworkId(networkId))
            entities[tostring(id)] = networkId
        end

        TriggerClientEvent("sound:playYoutubeSound", -1, video, maxDistance, coords, id, instance)
    end
)

RegisterNetEvent("sound:playRadio")
AddEventHandler(
    "sound:playRadio",
    function(radio, maxDistance, coords, id, instance, networkId)
        if instance == nil then
            instance = ""

            if source ~= nil and GetPlayerName(source) ~= nil then
                instance = exports.instance:getPlayerInstance(source)
            end
            if instance == " " then
                instance = ""
            end
        end

        if networkId ~= nil then
            coords = GetEntityCoords(NetworkGetEntityFromNetworkId(networkId))
            entities[tostring(id)] = networkId
        end

        TriggerClientEvent("sound:playRadio", -1, radio, maxDistance, coords, id, instance)
    end
)

RegisterNetEvent("sound:stopSound")
AddEventHandler(
    "sound:stopSound",
    function(id)
        if entities[tostring(id)] then
            entities[tostring(id)] = nil
        end
        TriggerClientEvent("sound:stopSound", -1, id)
    end
)

Citizen.CreateThread(
    function()
        while true do
            for k, v in each(entities) do
                local coords = GetEntityCoords(NetworkGetEntityFromNetworkId(v))
                TriggerClientEvent("sound:updateAudioCoords", -1, k, coords)
            end

            Citizen.Wait(10)
        end
    end
)
