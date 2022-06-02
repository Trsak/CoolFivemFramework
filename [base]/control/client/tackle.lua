local TimerEnabled = false

Citizen.CreateThread(
    function()
        createNewKeyMapping({command = "+tryTacklePlayer", text = "Povalit hráče na zem", key = "E"})
        RegisterCommand("+tryTacklePlayer", tryTacklePlayer)
        RegisterCommand(
            "-tryTacklePlayer",
            function()
            end
        )
    end
)

function tryTacklePlayer()
    if IsUsingKeyboard(2) and not LocalPlayer.state.isCuffed then
        local playerPed = PlayerPedId()
        local isInVeh = IsPedInAnyVehicle(playerPed, false)
        if not isInVeh and (IsPedSprinting(playerPed) or IsControlPressed(0, 21)) and GetEntitySpeed(playerPed) > 2.5 then
            TryToTackle()
        end
    end
end

function TryToTackle()
    if not TimerEnabled then
        local closestPlayer = getClosestPlayer()
        local playerPed = PlayerPedId()
        if closestPlayer.distance and (closestPlayer.distance ~= -1 and closestPlayer.distance < 3.0) and HasEntityClearLosToEntityInFront(playerPed, GetPlayerPed(closestPlayer.player))
         then
            TriggerServerEvent("playerTackled", closestPlayer.playerid)
            tackleAnimation()
            TimerEnabled = true
            Citizen.Wait(3500)
            TimerEnabled = false
        else
            TimerEnabled = true
            Citizen.Wait(200)
            TimerEnabled = false
        end
    end
end

function tackleAnimation()
    if not LocalPlayer.state.isCuffed and not IsPedRagdoll(PlayerPedId()) then
        local lPed = PlayerPedId()

        RequestAnimDict("swimming@first_person@diving")
        while not HasAnimDictLoaded("swimming@first_person@diving") do
            Citizen.Wait(1)
        end

        if IsEntityPlayingAnim(lPed, "swimming@first_person@diving", "dive_run_fwd_-45_loop", 3) then
            ClearPedSecondaryTask(lPed)
        else
            TaskPlayAnim(lPed, "swimming@first_person@diving", "dive_run_fwd_-45_loop", 8.0, -8, -1, 49, 0, 0, 0, 0)
            seccount = 3
            while seccount > 0 do
                Citizen.Wait(100)
                seccount = seccount - 1
            end
            ClearPedSecondaryTask(lPed)
            SetPedToRagdoll(PlayerPedId(), 150, 150, 0, 0, 0, 0)
        end
    end
end

RegisterNetEvent("playerTackled")
AddEventHandler(
    "playerTackled",
    function()
        SetPedToRagdoll(PlayerPedId(), math.random(3500, 5000), math.random(3500, 5000), 0, 0, 0, 0)
        TimerEnabled = true
        Citizen.Wait(3500)
        TimerEnabled = false
    end
)
