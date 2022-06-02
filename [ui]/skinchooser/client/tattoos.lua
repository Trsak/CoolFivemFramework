local maleTattoos = {}
local femaleTattoos = {}

Citizen.CreateThread(
    function()
        while not exports.data:isUserLoaded() do
            Citizen.Wait(500)
        end

        TriggerServerEvent("skinchooser:requestReloadTattoosList")
    end
)

RegisterNetEvent("skinchooser:reloadTattoosList")
AddEventHandler(
    "skinchooser:reloadTattoosList",
    function(newMaleTattoos, newFemaleTattoos)
        maleTattoos = newMaleTattoos
        femaleTattoos = newFemaleTattoos
    end
)

RegisterNetEvent("skinchooser:getTattoosLabels")
AddEventHandler(
    "skinchooser:getTattoosLabels",
    function(newMaleTattoos, newFemaleTattoos)
        for i, tattooData in each(newMaleTattoos) do
            newMaleTattoos[i].label = fixTattooLabel(i, GetLabelText(tattooData.label))
        end

        for i, tattooData in each(newFemaleTattoos) do
            newFemaleTattoos[i].label = fixTattooLabel(i, GetLabelText(tattooData.label))
        end

        TriggerServerEvent("skinchooser:setTattoosLabels", newMaleTattoos, newFemaleTattoos)
    end
)

function fixTattooLabel(index, label)
    if label == "" or label == "NULL" or label == "???" then
        return "Tetování #" .. index
    end

    return label
end

function getTattosList(sex)
    if sex == 0 then
        return maleTattoos
    end

    return femaleTattoos
end

function getTattosListByZone(sex, zone)
    if sex == 0 then
        return maleTattoos[zone]
    end

    return femaleTattoos[zone]
end

function getCurrentTattoos()
    if playerSexPre ~= getPlayerSex() then
        return {}
    end

    return exports.data:getCharVar("tattoos")
end