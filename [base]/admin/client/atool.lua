local currentSettings = {
    ["invisible"] = false,
    ["invincible"] = false
}

RegisterCommand("atool",
    function()
        if exports.data:getUserVar("admin") < 2 then
            return
        end

        currentPed = PlayerPedId()

        WarMenu.CreateMenu("atool", "Admin Tool", "Configure")
        WarMenu.OpenMenu("atool")
        WarMenu.SetMenuY("atool", 0.35)

        while true do
            if WarMenu.IsMenuOpened("atool") then
                if WarMenu.CheckBox("Invisibility", currentSettings["invisible"]) then
                    toggleInvisibility()
                elseif WarMenu.CheckBox("Invincibility", currentSettings["invincible"]) then
                    toggleInvincibility()
                elseif WarMenu.Button("Simulate an event", "outlawalert") then
                    exports.input:openInput(
                        "text",
                        {title = "Type", placeholder = ""},
                        function(type)
                            if type then
                                TriggerServerEvent(
                                    "outlawalert:sendAlert",
                                    {
                                        Type = type,
                                        Coords = GetEntityCoords(GetPlayerPed(-1))
                                    }
                                )
                            end
                        end
                    )
                end

                WarMenu.Display()
            else
                WarMenu.CloseMenu()
                break
            end

            Citizen.Wait(0)
        end
    end
)

RegisterCommand("simulateevent",
    function(_, args)
        if exports.data:getUserVar("admin") < 2 then
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = {"Na toto nemáš právo!"}
                }
            )
            return
        end

        local currentPed = PlayerPedId()
        local eventType = ""

        if not args[1] then
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = {"Musíš použít jeden z eventů"}
                }
            )
            return
        end

        eventType = table.concat(args)

        if eventType then
            TriggerServerEvent(
                "outlawalert:sendAlert",
                {
                    Type = eventType,
                    Coords = GetEntityCoords(currentPed)
                }
            )

            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "success",
                    args = {"Event " .. eventType .. " odeslán"}
                }
            )
        end

        TriggerServerEvent(
            "logs:sendToLog",
            {
                channel = "admin-commands",
                title = "Simulace eventu",
                description = "Simuloval event: " .. eventType,
                color = "34749"
            }
        )
    end
)

RegisterCommand("fuel",
    function(source, args)
        if exports.data:getUserVar("admin") < 2 then
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = {"Na toto nemáš právo!"}
                }
            )
            return
        end

        local currentPed = PlayerPedId()
        local currentVehicle = GetVehiclePedIsIn(currentPed, false)

        if not currentVehicle or (currentVehicle and GetPedInVehicleSeat(currentVehicle, -1) ~= currentPed) then
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = {"Musíš sedět na místě řidiče"}
                }
            )
            return
        end


        exports.gas_stations:SetFuel(currentVehicle, (args == nil and 100.0 or tonumber(args[1])))
        TriggerEvent(
            "chat:addMessage",
            {
                templateId = "success",
                args = {"Natankováno"}
            }
        )
        TriggerServerEvent(
            "logs:sendToLog",
            {
                channel = "admin-commands",
                title = "Fuel",
                description = "Natankoval vozidlo",
                color = "34749"
            }
        )
    end
)

function toggleInvisibility()
    if exports.data:getUserVar("admin") < 2 then
        return
    end
    local currentPed = PlayerPedId()
    currentSettings["invisible"] = not currentSettings["invisible"]

    if currentSettings["invisible"] then
        SetEntityAlpha(currentPed, 51, 0)
    else
        ResetEntityAlpha(currentPed)
    end

    SetEntityVisible(currentPed, not currentSettings["invisible"], 0) -- when active: FALSE
    SetEveryoneIgnorePlayer(currentPed, currentSettings["invisible"]); -- when active: TRUE
    SetPoliceIgnorePlayer(currentPed, currentSettings["invisible"]); -- when active: TRUE
end
function toggleInvincibility()
    if exports.data:getUserVar("admin") < 2 then
        return
    end
    currentSettings["invincible"] = not currentSettings["invincible"]

    SetEntityInvincible(PlayerPedId(), currentSettings["invincible"])
end