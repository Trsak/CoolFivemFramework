local lastWeather

Citizen.CreateThread(
    function()
        Wait(500)
        TriggerServerEvent("syncWeather")
    end
)

RegisterNetEvent("changeWeather")
AddEventHandler(
    "changeWeather",
    function(newWeather, forcedWeather)
        local weatherType = "EXTRASUNNY"
        local cloudHat = newWeather.cloudHat

        if forcedWeather ~= nil then
            weatherType = forcedWeather
        else
            -- https://openweathermap.org/weather-conditions
            if newWeather.weatherId >= 200 and newWeather.weatherId < 300 then
                weatherType = "THUNDER"
                cloudHat = "Stormy 01"
            elseif newWeather.weatherId >= 300 and newWeather.weatherId < 400 then
                weatherType = "RAIN"
            elseif newWeather.weatherId >= 500 and newWeather.weatherId < 600 then
                weatherType = "RAIN"
                cloudHat = "RAIN"
            elseif newWeather.weatherId >= 600 and newWeather.weatherId < 700 then
                weatherType = "SNOW"
                cloudHat = "Snowy 01"
            elseif newWeather.weatherId == 711 then
                weatherType = "SMOG"
            elseif newWeather.weatherId == 781 then
                weatherType = "BLIZZARD"
                cloudHat = "Stormy 01"
            elseif newWeather.weatherId >= 700 and newWeather.weatherId < 800 then
                weatherType = "FOGGY"
            elseif newWeather.weatherId == 800 then
                weatherType = "CLEAR"
            elseif newWeather.weatherId >= 801 and newWeather.weatherId < 900 then
                weatherType = "CLOUDS"
            end
        end

        if lastWeather ~= weatherType then
            lastWeather = weatherType
            SetWeatherTypeOverTime(weatherType, 15.0)
            Citizen.Wait(15000)
        end

        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist(weatherType)
        SetWeatherTypeNow(weatherType)
        SetWeatherTypeNowPersist(weatherType)

        SetRainLevel(-1)

        LoadCloudHat(cloudHat, 5.0)
        SetCloudHatOpacity(newWeather.cloudHatsOpacity)

        SetWindDirection(math.rad(newWeather.windDirection))
        SetWindSpeed(newWeather.wind)
        SetWind(newWeather.wind)

        if weatherType == "XMAS" then
            SetForceVehicleTrails(true)
            SetForcePedFootstepsTracks(true)
        else
            SetForceVehicleTrails(false)
            SetForcePedFootstepsTracks(false)
        end
    end
)
