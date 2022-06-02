Citizen.CreateThread(
    function()
        local counter = 0
        while true do
            Citizen.Wait(0)

            -- Vozidla
            SetAmbientVehicleRangeMultiplierThisFrame(0.5)
            SetParkedVehicleDensityMultiplierThisFrame(0.4)
            SetRandomVehicleDensityMultiplierThisFrame(0.5)
            SetVehicleDensityMultiplierThisFrame(0.8)

            -- Peds
            SetAmbientPedRangeMultiplierThisFrame(0.80)
            SetPedDensityMultiplierThisFrame(0.80)
            SetScenarioPedDensityMultiplierThisFrame(0.8, 0.8)

            if counter > 250 then
                counter = 0
                SetGarbageTrucks(true) -- Stop garbage trucks from randomly spawning
                SetRandomBoats(true) -- Random boats
                SetRandomBoatsInMp(true) -- Random boats
                SetRandomTrains(false) -- Random trains
                SetCreateRandomCops(false) -- disable random cops walking/driving around.
                SetCreateRandomCopsNotOnScenarios(false) -- stop random cops (not in a scenario) from spawning.
                SetCreateRandomCopsOnScenarios(false) -- stop random cops (in a scenario) from spawning.
            end

            counter = counter + 1
        end
    end
)
