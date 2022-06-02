local shouldStop = false

RegisterNetEvent("weed:packStop")
AddEventHandler(
    "weed:packStop",
    function()
        shouldStop = true
    end
)

RegisterNetEvent("weed:packCannabis")
AddEventHandler(
    "weed:packCannabis",
    function(maxAmount)
        exports.input:openInput(
            "number",
            { title = "Zadejte počet balíků (maximálně " .. maxAmount .. ")", placeholder = "0 - " .. maxAmount },
            function(amount)
                if amount == nil then
                    exports.notify:display(
                        {
                            type = "error",
                            title = "Chyba",
                            text = "Musíš zadat počet!",
                            icon = "fas fa-times",
                            length = 3500
                        }
                    )
                else
                    amount = tonumber(amount, 10)
                    if amount == nil or amount < 0 or amount > maxAmount then
                        exports.notify:display(
                            {
                                type = "error",
                                title = "Chyba",
                                text = "Počet musí být číslo od 0 do " .. maxAmount .. "!",
                                icon = "fas fa-times",
                                length = 3500
                            }
                        )
                    else
                        packWeed(amount)
                    end
                end
            end
        )
    end
)

function packWeed(packsToDo)
    exports.progressbar:startProgressBar({
        Duration = 650,
        Label = "Balíš trávu..",
        CanBeDead = false,
        CanCancel = true,
        DisableControls = {
            Movement = false,
            CarMovement = true,
            Mouse = false,
            Combat = true
        },
        Animation = {
            animDict = "mp_arresting",
            anim = "a_uncuff",
            flags = 51
        }
    }, function(finished)
        if finished then
            TriggerServerEvent("weed:packed")
            packsToDo = packsToDo - 1

            if shouldStop then
                shouldStop = false
            elseif packsToDo > 0 then
                packWeed(packsToDo)
            end
        end
    end)
end

RegisterNetEvent("weed:makeJoint")
AddEventHandler(
    "weed:makeJoint",
    function(slot, data)
        exports.progressbar:startProgressBar({
            Duration = 500,
            Label = "Balíš join..",
            CanBeDead = false,
            CanCancel = true,
            DisableControls = {
                Movement = false,
                CarMovement = true,
                Mouse = false,
                Combat = true
            },
            Animation = {
                animDict = "mp_arresting",
                anim = "a_uncuff",
                flags = 51
            }
        }, function(finished)
            if finished then
                TriggerServerEvent("weed:jointMade", slot, data)
            end
        end)
    end
)

RegisterNetEvent("weed:unpackWeedBag")
AddEventHandler(
    "weed:unpackWeedBag",
    function(slot, data)
        exports.progressbar:startProgressBar({
            Duration = 500,
            Label = "Rozbaluješ sáček s trávou..",
            CanBeDead = false,
            CanCancel = true,
            DisableControls = {
                Movement = false,
                CarMovement = true,
                Mouse = false,
                Combat = true
            },
            Animation = {
                animDict = "mp_arresting",
                anim = "a_uncuff",
                flags = 51
            }
        }, function(finished)
            if finished then
                TriggerServerEvent("weed:unpackWeedBag", slot, data)
            end
        end)
    end
)
