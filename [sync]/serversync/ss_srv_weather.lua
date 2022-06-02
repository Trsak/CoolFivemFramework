local weatherForecast = {}
local currentWeather = nil
local forcedWeather

local allowedWeathers = {
    "BLIZZARD",
    "CLEAR",
    "CLEARING",
    "CLOUDS",
    "EXTRASUNNY",
    "FOGGY",
    "HALLOWEEN",
    "NEUTRAL",
    "OVERCAST",
    "RAIN",
    "SMOG",
    "SNOW",
    "SNOWLIGHT",
    "THUNDER",
    "XMAS"
}

local cloudHats = {
    "Cirrus",
    "cirrocumulus",
    "Clear 01",
    "Cloudy 01",
    "Contrails",
    "Horizon",
    "horizonband1",
    "horizonband2",
    "horizonband3",
    "horsey",
    "Nimbus",
    "Puffs",
    "stratoscumulus",
    "Stripey",
    "Wispy"
}

function loadNewWeathers()
    MySQL.Async.execute("DELETE FROM weather WHERE datetime < (NOW() - INTERVAL 1 HOUR)", {})

    local queries = {}

    PerformHttpRequest(
        "http://api.openweathermap.org/data/2.5/onecall?lat=45.523064&lon=-122.676&units=metric&lang=cz&exclude=current,minutely,daily,alerts",
        function(errorCode, resultData, resultHeaders)
            if errorCode == 200 then
                local weatherData = json.decode(resultData)

                for _, hourlyData in each(weatherData.hourly) do
                    weatherForecast[tostring(hourlyData.dt)] = {
                        temp = tonumber(hourlyData.temp),
                        weather = hourlyData.weather[1].main,
                        weatherId = hourlyData.weather[1].id,
                        description = hourlyData.weather[1].description,
                        icon = hourlyData.weather[1].icon,
                        wind = tonumber(hourlyData.wind_speed),
                        windDirection = tonumber(hourlyData.wind_deg),
                        cloudHat = cloudHats[math.random(#cloudHats)],
                        cloudHatsOpacity = math.random(2, 100) / 100
                    }

                    table.insert(queries, {
                        query = "INSERT INTO weather VALUES (FROM_UNIXTIME(:datetime), :temp, :weather, :weather_id, :description, :icon, :wind, :wind_direction) ON DUPLICATE KEY UPDATE temp = :temp, weather = :weather, weather_id = :weather_id, description = :description, icon = :icon, wind = :wind, wind_direction = :wind_direction",
                        values = {
                            ["datetime"] = hourlyData.dt,
                            ["temp"] = tonumber(hourlyData.temp),
                            ["weather"] = hourlyData.weather[1].main,
                            ["weather_id"] = hourlyData.weather[1].id,
                            ["description"] = hourlyData.weather[1].description,
                            ["icon"] = hourlyData.weather[1].icon,
                            ["wind"] = tonumber(hourlyData.wind_speed),
                            ["wind_direction"] = tonumber(hourlyData.wind_deg)
                        }
                    })
                end
            end

            exports.oxmysql:transaction(queries)

            getCurrentWeather()
            TriggerClientEvent("changeWeather", -1, currentWeather, forcedWeather)
            Wait(3600000)
            getCurrentWeather()
            TriggerClientEvent("changeWeather", -1, currentWeather, forcedWeather)
            SetTimeout(3600000, loadNewWeathers)
        end,
        "GET",
        ""
    )
end

function getCurrentWeather()
    local currentTime = os.time()

    for datetime, weatherData in pairs(weatherForecast) do
        if tonumber(datetime) - currentTime <= 0 and tonumber(datetime) - currentTime >= -3600 then
            currentWeather = weatherData
            break
        end
    end
end

MySQL.ready(
    function()
        Wait(500)

        MySQL.Async.fetchAll(
            "SELECT * FROM weather",
            {},
            function(weatherDatas)
                for _, weatherData in each(weatherDatas) do
                    weatherForecast[tostring(math.floor(weatherData.datetime / 1000))] = {
                        temp = tonumber(weatherData.temp),
                        weather = weatherData.weather,
                        weatherId = tonumber(weatherData.weather_id),
                        description = weatherData.description,
                        icon = weatherData.icon,
                        wind = tonumber(weatherData.wind),
                        windDirection = tonumber(weatherData.wind_direction),
                        cloudHat = cloudHats[math.random(#cloudHats)],
                        cloudHatsOpacity = math.random(2, 100) / 100
                    }
                end

                loadNewWeathers()
            end
        )
    end
)

RegisterNetEvent("syncWeather")
AddEventHandler(
    "syncWeather",
    function()
        local client = source

        while currentWeather == nil do
            Wait(100)
        end

        TriggerClientEvent("changeWeather", client, currentWeather, forcedWeather)
    end
)

RegisterCommand(
    "weather",
    function(client, args)
        if client == 0 or exports.data:getUserVar(client, "admin") > 1 then
            if args[1] == nil then
                TriggerClientEvent(
                    "chat:addMessage",
                    client,
                    {
                        templateId = "error",
                        args = { "Špatné použití! Použij /weather <typ>" }
                    }
                )
            else
                local weatherType = string.upper(args[1])
                local validWeatherType = false

                for _, wtype in each(allowedWeathers) do
                    if wtype == weatherType then
                        validWeatherType = true
                        break
                    end
                end

                if validWeatherType then
                    forcedWeather = weatherType

                    TriggerClientEvent(
                        "chat:addMessage",
                        client,
                        {
                            template = '<div style="float: left; padding: 10px; margin: 5px; background-color: rgba(70, 130, 180, 0.75); border-left: 10px solid rgb(70, 130, 180);">Změnil jsi počasí na {0}</div>',
                            args = { forcedWeather }
                        }
                    )

                    exports.logs:sendToDiscord(
                        {
                            channel = "admin-commands",
                            title = "Počasí",
                            description = "Nastavil počasí na " .. forcedWeather,
                            color = "34749"
                        },
                        client
                    )

                    TriggerClientEvent("changeWeather", -1, currentWeather, forcedWeather)
                else
                    TriggerClientEvent(
                        "chat:addMessage",
                        client,
                        {
                            templateId = "error",
                            args = {
                                "Špatný typ počasí! Správné: EXTRASUNNY CLEAR SMOG FOGGY OVERCAST CLOUDS CLEARING RAIN THUNDER SNOW BLIZZARD SNOWLIGHT XMAS NEUTRAL HALLOWEEN"
                            }
                        }
                    )
                end
            end
        else
            TriggerClientEvent(
                "chat:addMessage",
                client,
                {
                    templateId = "error",
                    args = { "Na toto nemáš právo!" }
                }
            )
        end
    end,
    false
)

RegisterCommand(
    "weatherrestore",
    function(client, args)
        if client == 0 or exports.data:getUserVar(client, "admin") > 1 then
            if forcedWeather ~= nil then
                forcedWeather = nil

                TriggerClientEvent(
                    "chat:addMessage",
                    client,
                    {
                        template = '<div style="float: left; padding: 10px; margin: 5px; background-color: rgba(70, 130, 180, 0.75); border-left: 10px solid rgb(70, 130, 180);"><strong>Počasí </strong>Zrušil jsi nastavené počasí</div>',
                        args = {}
                    }
                )

                exports.logs:sendToDiscord(
                    {
                        channel = "admin-commands",
                        title = "Počasí",
                        description = "Zrušil nastavené počasí",
                        color = "34749"
                    },
                    client
                )

                getCurrentWeather()
                TriggerClientEvent("changeWeather", -1, currentWeather, forcedWeather)
            else
                TriggerClientEvent(
                    "chat:addMessage",
                    client,
                    {
                        templateId = "error",
                        args = { "Není nastavené žádné fixní počasí!" }
                    }
                )
            end
        else
            TriggerClientEvent(
                "chat:addMessage",
                client,
                {
                    templateId = "error",
                    args = { "Na toto nemáš právo!" }
                }
            )
        end
    end,
    false
)
