local isSelecting = false 
local selectedPlayer = nil 

Citizen.CreateThread(function()
    Citizen.Wait(500)
    local status = exports.data:getUserVar("status")
    if status == "spawned" or status == "dead" then
        isSpawned = true
        isDead = (status == "dead")
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false 
        elseif status == "spawned" or status == "dead" then 
            isSpawned = true
            isDead = (status == "dead")
        end
    end
)

RegisterNetEvent("util:closestPlayer")
AddEventHandler("util:closestPlayer", function(conf, cb)
    if not isSelecting then 
        isSelecting = true 
        local closestPlayers = exports.control:getClosestPlayersInDistance(conf.radius)

        if #closestPlayers == 0 then
            isSelecting = false
            exports.notify:display({type = "error", title = "Chyba", text = "Není u tebe nikdo, s kým bys mohl akci vykonat!", icon = "fas fa-box", length = 5000})
            cb()
        else
            Citizen.CreateThread(
                function()
                    WarMenu.CreateMenu("close_player_action", "Zvolte osobu", "Vyberte akci")
                    WarMenu.SetMenuY("close_player_action", 0.35)
                    WarMenu.OpenMenu("close_player_action")

                    local availablePlayers = {}

                    for index, player in each(closestPlayers) do
                        availablePlayers[index] = player
                    end

                    while true do
                        if WarMenu.IsMenuOpened("close_player_action") then
                            for index, player in pairs(availablePlayers) do
                                if WarMenu.Button("Hráč " .. index) then
                                    WarMenu.CloseMenu()

                                    local playerCoords = GetEntityCoords(PlayerPedId())
                                    local targetCoords = GetEntityCoords(GetPlayerPed(selectedPlayer))

                                    if #(playerCoords - targetCoords) > conf.radius then
                                        exports.notify:display({type = "error", title = "Chyba", text = "Zvolený hráč se příliš vzdálil!", icon = "fas fa-box", length = 5000})
                                    else
                                        cb(player.playerid)
                                    end
                                end
                            end

                            local currentOption = WarMenu.CurrentOption()
                            if availablePlayers[currentOption].player and selectedPlayer ~= availablePlayers[currentOption].player then
                                selectedPlayer = availablePlayers[currentOption].player
                            end

                            WarMenu.Display()
                        else
                            cb()
                            isSelecting = false
                            selectedPlayer = nil
                            break
                        end

                        local coords = GetWorldPositionOfEntityBone(GetPlayerPed(selectedPlayer), 1)
                        DrawMarker(21, coords.x, coords.y, coords.z + 1.1, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255,255,255, 100, false, false, 2, false, false, false, false)

                        Citizen.Wait(0)
                    end
                end
            )
        end
    end
end
)