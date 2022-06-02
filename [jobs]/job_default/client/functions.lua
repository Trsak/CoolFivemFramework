function giveLicense()
    exports.emotes:playEmoteByName("notepad")

    WarMenu.CreateMenu("licenses", "Předání licence", "Zvole typ")
    WarMenu.SetMenuY("licenses", 0.35)
    WarMenu.OpenMenu("licenses")

    while true do
        if WarMenu.IsMenuOpened("licenses") then
            for i, license in each(Config.Licenses) do
                if WarMenu.Button(license.Label, license.Name) then
                    WarMenu.CloseMenu()
                    TriggerEvent(
                        "util:closestPlayer",
                        {
                            radius = 2.0
                        },
                        function(player)
                            if player then
                                TriggerServerEvent("job_default:addLicense", player, license.Name)
                                exports.emotes:cancelEmote()
                            end
                        end
                    )
                end
            end

            WarMenu.Display()
        else
            exports.emotes:cancelEmote()
            break
        end
        Citizen.Wait(0)
    end
end

function changeOutfit()

end