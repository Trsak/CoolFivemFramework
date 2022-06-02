local closestChangingRoom = nil
local isShowingHint = false

Citizen.CreateThread(function()
    LoadBlips()
end)

function LoadBlips()
    for _, changingRoom in each(Config.ChangingRooms) do
        if changingRoom.show then
            createNewBlip({
                coords = changingRoom.coords,
                sprite = 366,
                display = 4,
                scale = 0.65,
                colour = 0,
                isShortRange = true,
                text = "Převlékárna"
            })
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local coords = GetEntityCoords(PlayerPedId())
        local newClosest = nil

        for _, changingRoom in each(Config.ChangingRooms) do
            local distance = #(coords - changingRoom.coords)
            if (distance < 4.0) then
                newClosest = changingRoom

                if not isShowingHint then
                    isShowingHint = true
                    exports.key_hints:displayBottomHint({
                        name = "changingroom_hint",
                        key = "~INPUT_DAF1F3B5~",
                        text = "Oblekání"
                    })
                end
            end
        end

        if isShowingHint and not newClosest then
            isShowingHint = false
            exports.key_hints:hideBottomHint({
                name = "changingroom_hint"
            })
        end

        closestChangingRoom = newClosest
    end
end)

RegisterCommand("openchangingroom", function()
    if closestChangingRoom then
        if not closestChangingRoom.type then
            exports["clothes_shop"]:openClothesMenu()
        else
            exports["clothes_shop"]:setSpecialOutfit(closestChangingRoom.type)
        end
    end
end)
createNewKeyMapping({
    command = "openchangingroom",
    text = "Otevření převlékárny",
    key = "E"
})
