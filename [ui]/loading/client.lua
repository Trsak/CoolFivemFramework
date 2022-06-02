function loadingDone()
    TriggerServerEvent("data:setStatusChoosing")

    ShutdownLoadingScreen()

    Citizen.Wait(0)
    DoScreenFadeOut(0)

    ShutdownLoadingScreenNui()

    exports.chars:startChoosing()
end

Citizen.CreateThread(
    function()
        Citizen.Wait(1000)

        while true do
            Citizen.Wait(10)
            local loaded = true
            for i = 1, GetNumResources() do
                local res = GetResourceByFindIndex(i)
                if res then
                    local resState = GetResourceState(res)
                    if resState == "missing" or resState == "starting" or resState == "uninitialized" or resState == "unknown" then
                        loaded = false
                        break
                    end
                end
            end

            if loaded then
                break
            end
        end

        exports.chars:preparePlayerPed()
        Citizen.Wait(500)
        loadingDone()
    end
)
