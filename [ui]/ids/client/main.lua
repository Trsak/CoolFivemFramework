local isSpawned, isDead, isOpened = false, false, false

local closeplayers = {}

Citizen.CreateThread(
    function()
        Citizen.Wait(500)
        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")

            if exports.data:getUserVar("admin") > 1 then
                createNewKeyMapping({command = "playerids", text = "Zobrazit / schovat ID hráčů", key = "HOME"})
            end
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned, isOpened, isDead = false, false, false
        elseif status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
            if exports.data:getUserVar("admin") > 1 then
                createNewKeyMapping({command = "playerids", text = "Zobrazit / schovat ID hráčů", key = "HOME"})
            end
            if isDead and isOpened then
                isOpened = false
                SendNUIMessage(
                    {
                        action = "hide"
                    }
                )
            end
        end
    end
)

RegisterCommand(
    "playerids",
    function()
        if exports.data:getUserVar("admin") > 1 then
            if #exports.control:getClosestPlayersInDistance(Config.maxDistance) > 0 then
                isOpened = not isOpened
                if isOpened then
                    local formattedContent = {}

                    SendNUIMessage(
                        {
                            action = "show",
                            list = "<ul><li style='font-size: 7pt; color: grey; margin-bottom: 1px;'>NAČÍTÁNÍ</li></ul>"
                        }
                    )
                    Citizen.CreateThread(
                        function()
                            while isOpened do
                                local closestPlayers = exports.control:getClosestPlayersInDistance(Config.maxDistance)
                                formattedContent = {}
                                table.insert(formattedContent, "<ul>")
                                for _, player in each(closestPlayers) do
                                    table.insert(
                                        formattedContent,
                                        ("<li><b>%s : %s : %sm</b></li>"):format(
                                            player.playerid,
                                            GetPlayerName(player.player),
                                            math.floor(player.distance) + 0.0
                                        )
                                    )
                                end
                                table.insert(formattedContent, "</ul>")

                                SendNUIMessage(
                                    {
                                        action = "refresh",
                                        list = table.concat(formattedContent)
                                    }
                                )
                                Citizen.Wait(500)
                            end
                            SendNUIMessage(
                                {
                                    action = "hide"
                                }
                            )
                        end
                    )
                    while isOpened do
                        Citizen.Wait(1)
                        local closestPlayers = exports.control:getClosestPlayersInDistance(Config.maxDistance)
                        for _, player in each(closestPlayers) do
                            if player.distance < Config.showIDdistance then
                                local pcoords = GetWorldPositionOfEntityBone(GetPlayerPed(player.player), 1)
                                exports.font:DrawText3D(
                                    pcoords.x,
                                    pcoords.y,
                                    pcoords.z + 1.0,
                                    GetPlayerName(player.player) ..
                                        "  [" .. player.playerid .. "]",
                                    false,
                                    0.4
                                )
                            end
                        end
                    end
                end
            end
        end
    end
)
